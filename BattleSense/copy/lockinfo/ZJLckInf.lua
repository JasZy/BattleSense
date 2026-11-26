--[[
+--------------------------------------------------------------------------------------------------+
| ZJLockInfo - How hard a lock / trap is, when hovering a container, door or trap                  |
+--------------------------------------------------------------------------------------------------+
|   Hovering a locked container or door while the module's key is held opens a popup with its      |
|   lock difficulty, and each selected character's chance to pick and to force it. A trap that has |
|   been detected, (on a container or door, or on the floor), adds its difficulty and each         |
|   selected character's chance to disarm it. Undetected traps are never mentioned.                |
|                                                                                                  |
|     Lock difficulty 50 (pick and force)                                                          |
|     Imoen: pick 40% (45 + d10), force 0% (15 + d10)                                              |
|     Minsc: force 0% (35 + d10)                                                                   |
|                                                                                                  |
|   The engine's rules, (CGameSprite::PickLock, ::BashDoor and ::RemoveTraps), are all the same:   |
|                                                                                                  |
|     skill + clamp(d10 - 1 + luck, 0, 9) > difficulty                                             |
|                                                                                                  |
|   and a difficulty of exactly 100 always fails. The skill is:                                    |
|                                                                                                  |
|     * Pick:   Open Locks, (LOCKPICKING)                                                          |
|     * Force:  BEND_BARS_LIFT_GATES of STRMOD.2DA, (row STR), plus that of STRMODEX.2DA, (row      |
|               STREXTRA). Compared with the same lock difficulty as picking.                      |
|     * Disarm: Remove Traps, (TRAPS)                                                              |
|                                                                                                  |
|   Picking is only listed for characters with Open Locks, disarming only for characters with      |
|   Remove Traps.                                                                                  |
+--------------------------------------------------------------------------------------------------+
--]]

-- The module's switch, (Off or the key that opens the popup), (shared by every popup)
Infinity_DoFile("ZJPopup")

-------------
-- Options --
-------------

-- The module's switch, (Off or the key that opens the popup), in the "Battle Sense Modules" tab
ZJLockInfo_Private_OpenOn = EEex_Options_Register("ZJLockInfo_Enable", ZJPopup_NewSwitch("Lock Info", {
	["onChange"] = function(self, oldValue) ZJLockInfo_SetEnabled(self:get() ~= 0) end,
}))

ZJLockInfo_Private_FontPoint = EEex_Options_Register("ZJLockInfo_FontPoint", EEex_Options_Option.new({
	["default"]  = 11,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Lock Info Module: Font Point" }),
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_LockInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJLockInfo_FontPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_LockInfo_FontPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_LockInfo_FontPoint_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"]        = true,
			}),
		}),
	},
} end)

-----------
-- State --
-----------

ZJLockInfo_Private_Enabled = true
ZJLockInfo_Private_Menu_IsOpen = false
ZJLockInfo_Private_Menu_Text = ""
ZJLockInfo_Private_Menu_TextUD = nil

ZJLockInfo_Private_GrayColorStr = "^0xFFA0A0A0"

function ZJLockInfo_Private_T(key)
	return getUiString("ZJBattleSense_TRANSLATION_LockInfo_"..key)
end

-------------
-- Objects --
-------------

-- The locked flag of each object type's m_dwFlags, (the flags of the area file)
ZJLockInfo_Private_LockedFlags = {
	[CGameObjectType.CONTAINER] = 0x1, -- BIT0
	[CGameObjectType.DOOR]      = 0x2, -- BIT1
}

-- A number field of an engine object, nil if the object doesn't have it
function ZJLockInfo_Private_Field(object, name)
	local ok, value = pcall(function() return object[name] end)
	return ok and type(value) == "number" and value or nil
end

-- The lock difficulty of `object`, nil if it isn't a locked container / door
function ZJLockInfo_Private_GetLockDifficulty(object)
	local flag = ZJLockInfo_Private_LockedFlags[object.m_objectType]
	if flag == nil then return nil end
	local flags = ZJLockInfo_Private_Field(object, "m_dwFlags")
	if flags == nil or EEex_BAnd(flags, flag) == 0 then return nil end
	return ZJLockInfo_Private_Field(object, "m_lockDifficulty")
end

-- The removal difficulty of the trap on / of `object`, nil if it has no armed trap that has been detected
function ZJLockInfo_Private_GetTrapDifficulty(object)
	local type = object.m_objectType
	if type ~= CGameObjectType.CONTAINER and type ~= CGameObjectType.DOOR and type ~= CGameObjectType.TRIGGER then
		return nil
	end
	if (ZJLockInfo_Private_Field(object, "m_trapActivated") or 0) == 0 then return nil end
	if (ZJLockInfo_Private_Field(object, "m_trapDetected") or 0) == 0 then return nil end
	return ZJLockInfo_Private_Field(object, "m_trapRemovalDifficulty")
end

-------------
-- Chances --
-------------

ZJLockInfo_Private_Tables = {} -- [resref] = C2DArray, loaded the first time it is needed

-- The number at `column`, `row` of the 2DA `resref`, (0 if it isn't a number)
function ZJLockInfo_Private_Get2DA(resref, column, row)
	local array = ZJLockInfo_Private_Tables[resref]
	if array == nil then
		array = EEex_Resource_Load2DA(resref)
		ZJLockInfo_Private_Tables[resref] = array
	end
	return tonumber(array:getAtLabels(column, tostring(row))) or 0
end

-- The chance in percent that `skill` + clamp(d10 - 1 + `luck`, 0, 9) is above `difficulty`, (100 always fails)
function ZJLockInfo_Private_Chance(skill, luck, difficulty)
	if difficulty == 100 then return 0 end
	local successes = 0
	for roll = 0, 9 do
		if skill + math.max(0, math.min(9, roll + luck)) > difficulty then
			successes = successes + 1
		end
	end
	return successes * 10
end

function ZJLockInfo_Private_ForceSkill(stats)
	return ZJLockInfo_Private_Get2DA("STRMOD", "BEND_BARS_LIFT_GATES", stats.m_nSTR)
		+ ZJLockInfo_Private_Get2DA("STRMODEX", "BEND_BARS_LIFT_GATES", stats.m_nSTRExtra)
end

-- "pick 60% (45 + d10)", the chance of `skill` against `difficulty`, with the roll it makes, (gray if it is 0%)
function ZJLockInfo_Private_FormatChance(key, skill, luck, difficulty)
	local chance = ZJLockInfo_Private_Chance(skill, luck, difficulty)
	local roll = luck ~= 0 and string.format(ZJLockInfo_Private_T("RollLuck"), skill, luck)
		or string.format(ZJLockInfo_Private_T("Roll"), skill)
	local text = string.format(ZJLockInfo_Private_T(key), chance).." "..roll
	if chance == 0 then return ZJLockInfo_Private_GrayColorStr..text.."^-" end
	return text
end

-- The selected characters, (in selection order)
function ZJLockInfo_Private_GetCharacters()
	local characters = {}
	EEex_Sprite_IterateSelected(function(sprite)
		table.insert(characters, sprite)
	end)
	return characters
end

----------
-- Text --
----------

function ZJLockInfo_Private_DescribeLock(lines, difficulty, characters)

	if difficulty == 100 then
		table.insert(lines, ZJLockInfo_Private_T("LockImpossible"))
		return
	end

	table.insert(lines, string.format(ZJLockInfo_Private_T("Lock"), difficulty))

	for _, sprite in ipairs(characters) do
		local stats = sprite:getActiveStats()
		local luck = stats.m_nLuck
		local parts = {}
		if stats.m_nLockPicking > 0 then
			table.insert(parts, ZJLockInfo_Private_FormatChance("Pick", stats.m_nLockPicking, luck, difficulty))
		end
		table.insert(parts, ZJLockInfo_Private_FormatChance("Force", ZJLockInfo_Private_ForceSkill(stats), luck, difficulty))
		table.insert(lines, string.format("%s: %s", sprite:getName(), table.concat(parts, ", ")))
	end
end

function ZJLockInfo_Private_DescribeTrap(lines, difficulty, characters)

	if difficulty == 100 then
		table.insert(lines, ZJLockInfo_Private_T("TrapImpossible"))
		return
	end

	table.insert(lines, string.format(ZJLockInfo_Private_T("Trap"), difficulty))

	for _, sprite in ipairs(characters) do
		local stats = sprite:getActiveStats()
		if stats.m_nTraps > 0 then
			table.insert(lines, string.format("%s: %s", sprite:getName(),
				ZJLockInfo_Private_FormatChance("Disarm", stats.m_nTraps, stats.m_nLuck, difficulty)))
		end
	end
end

-- The text of the popup for the object under the cursor, or nil if it shouldn't be showing
function ZJLockInfo_Private_GetText()

	if not ZJLockInfo_Private_Enabled then return nil end
	if not ZJPopup_IsOpenAllowed(ZJLockInfo_Private_OpenOn) then return nil end
	if e:GetActiveEngine() ~= worldScreen then return nil end

	local object = EEex_GameObject_GetUnderCursor()
	if object == nil then return nil end

	local lockDifficulty = ZJLockInfo_Private_GetLockDifficulty(object)
	local trapDifficulty = ZJLockInfo_Private_GetTrapDifficulty(object)
	if lockDifficulty == nil and trapDifficulty == nil then return nil end

	local characters = ZJLockInfo_Private_GetCharacters()
	local lines = {}

	if lockDifficulty ~= nil then
		ZJLockInfo_Private_DescribeLock(lines, lockDifficulty, characters)
	end
	if trapDifficulty ~= nil then
		ZJLockInfo_Private_DescribeTrap(lines, trapDifficulty, characters)
	end

	return table.concat(lines, "\n")
end

----------
-- Menu --
----------

-- The cursor's hotspot and size, (in menu coordinates), so the popup can go beside the cursor image
function ZJLockInfo_Private_GetCursorRenderData()

	local vidMode = EngineGlobals.g_pBaldurChitin.cVideo.pCurrentMode
	local cursorCell = vidMode.pPointerVidCell
	if cursorCell == nil then return end

	local centerX, centerY = cursorCell:GetCurrentCenterPoint()
	local w, h = cursorCell:GetCurrentFrameSize()
	return EEex_Menu_ScaleX(centerX), EEex_Menu_ScaleY(centerY), EEex_Menu_ScaleX(w), EEex_Menu_ScaleY(h)
end

function ZJLockInfo_Private_Layout()

	local fontPoint = ZJLockInfo_Private_FontPoint:get()
	local style = styles["normal"]
	local text = ZJLockInfo_Private_Menu_Text

	ZJLockInfo_Private_Menu_TextUD.text.point = fontPoint

	local textW = 0
	for line in (text.."\n"):gmatch("(.-)\n") do
		textW = math.max(textW, (EEex_Menu_GetTextWidthHeight(line, style.font, fontPoint, style.useFontZoom)))
	end
	textW = textW + 2 -- Room for rounding, so the engine doesn't wrap a line that just fits

	local _, textH = EEex_Menu_GetTextWidthHeight(text, style.font, fontPoint, style.useFontZoom, textW)

	local pad = 12
	local backgroundW = textW + pad * 2
	local backgroundH = textH + pad * 2

	-- Beside the cursor, like the other popups
	local cursorX, cursorY = EEex_Menu_GetMousePos()
	local cursorCenterX, cursorCenterY, cursorW = ZJLockInfo_Private_GetCursorRenderData()
	cursorCenterX, cursorCenterY, cursorW = cursorCenterX or 0, cursorCenterY or 0, cursorW or 0

	local cursorRenderX = cursorX - cursorCenterX
	local backgroundX = cursorRenderX + cursorW + 5
	local backgroundY = cursorY - cursorCenterY

	local screenW, screenH = Infinity_GetScreenSize()
	if backgroundX + backgroundW > screenW then
		backgroundX = math.max(0, cursorRenderX - backgroundW - 5)
	end
	if backgroundY + backgroundH > screenH then
		backgroundY = math.max(0, screenH - backgroundH)
	end

	Infinity_SetOffset("ZJLockInfo_Menu", backgroundX, backgroundY)
	Infinity_SetArea("ZJLockInfo_Menu_BackgroundRect", 0, 0, backgroundW, backgroundH)
	Infinity_SetArea("ZJLockInfo_Menu_Text", pad, pad, textW, textH)
end

-- @bubb_doc { ZJLockInfo_SetOpen }
-- @summary: Opens / closes the lock info popup.
function ZJLockInfo_SetOpen(open)
	if open then
		if not ZJLockInfo_Private_Menu_IsOpen then
			Infinity_PushMenu("ZJLockInfo_Menu")
			ZJLockInfo_Private_Menu_IsOpen = true
		end
	elseif ZJLockInfo_Private_Menu_IsOpen then
		Infinity_PopMenu("ZJLockInfo_Menu")
		ZJLockInfo_Private_Menu_IsOpen = false
	end
end

-- @bubb_doc { ZJLockInfo_SetEnabled }
-- @summary: Temporarily turns the popup on / off. To persist this, change the ``ZJLockInfo_Enable`` option instead.
function ZJLockInfo_SetEnabled(enabled)
	ZJLockInfo_Private_Enabled = enabled
	if not enabled then ZJLockInfo_SetOpen(false) end
end

function ZJLockInfo_Private_DoTick()

	local text = ZJLockInfo_Private_GetText()

	if text == nil then
		ZJLockInfo_SetOpen(false)
		return
	end

	ZJLockInfo_Private_Menu_Text = text
	ZJLockInfo_SetOpen(true)
	ZJLockInfo_Private_Layout()
end

-- Called every frame by the ticker menu
function ZJLockInfo_Private_Tick()
	local ok, err = pcall(ZJLockInfo_Private_DoTick)
	if not ok then
		pcall(ZJLockInfo_SetOpen, false)
		-- This runs every frame, don't flood the log
		if not ZJLockInfo_Private_ErrorReported then
			ZJLockInfo_Private_ErrorReported = true
			print("[Battle Sense] Lock Info: "..tostring(err))
		end
	end
end

---------------
-- Listeners --
---------------

function ZJLockInfo_Private_PushTicker()
	if not Infinity_IsMenuOnStack("ZJLockInfo_Menu_Ticker") then
		Infinity_PushMenu("ZJLockInfo_Menu_Ticker")
	end
end

EEex_Menu_AddMainFileLoadedListener(function()
	EEex_Menu_LoadFile("ZJLckInf")
	ZJLockInfo_Private_Menu_IsOpen = false
	ZJLockInfo_Private_Menu_TextUD = EEex_Menu_GetItem("ZJLockInfo_Menu_Text")
end)

-- The ticker is always open while a game is running
EEex_GameState_AddInitializedListener(ZJLockInfo_Private_PushTicker)
EEex_Menu_AddAfterMainFileReloadedListener(ZJLockInfo_Private_PushTicker)

EEex.RegisterSlicedRect("ZJLockInfo_BackgroundRect", {
	["topLeft"]     = {  0,  0, 32, 32 },
	["top"]         = { 16,  0, 32, 32 },
	["topRight"]    = { 32,  0, 32, 32 },
	["right"]       = { 32, 16, 32, 32 },
	["bottomRight"] = { 32, 32, 32, 32 },
	["bottom"]      = { 16, 32, 32, 32 },
	["bottomLeft"]  = {  0, 32, 32, 32 },
	["left"]        = {  0, 16, 32, 32 },
	["center"]      = { 16, 16, 32, 32 },
	["dimensions"]  = { 64, 64 },
	["resref"]      = "X-OPTBOX",
	["flags"]       = 0,
})

function ZJLockInfo_Private_Background_Render(item)
	EEex.DrawSlicedRect("ZJLockInfo_BackgroundRect", { item:getArea() }, 255 * 0.85)
end

EEex_Menu_AddBeforeUIItemRenderListener("ZJLockInfo_Menu_BackgroundRect", ZJLockInfo_Private_Background_Render)
