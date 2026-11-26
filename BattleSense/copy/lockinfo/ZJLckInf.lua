--[[
+--------------------------------------------------------------------------------------------------+
| ZJLockInfo - How hard a lock / trap is, when hovering a container, door or trap                  |
+--------------------------------------------------------------------------------------------------+
|   Hovering a locked container or door while the "Popup Key" is held opens the popup with its     |
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

-- The popup this module adds its panel to, (shared by every module with a popup)
Infinity_DoFile("ZJPopup")

-------------
-- Options --
-------------

-- The module's on / off switch, in the "Battle Sense Modules" tab
EEex_Options_Register("ZJLockInfo_Enable", ZJPopup_NewSwitch("Lock Info", {
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

-- The text of the panel for the object under the cursor, or nil if this module has nothing to say about it
function ZJLockInfo_Private_GetText()

	if not ZJLockInfo_Private_Enabled then return nil end
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

-- @bubb_doc { ZJLockInfo_SetEnabled }
-- @summary: Temporarily turns the panel on / off. To persist this, change the ``ZJLockInfo_Enable`` option instead.
function ZJLockInfo_SetEnabled(enabled)
	ZJLockInfo_Private_Enabled = enabled
end

-----------
-- Panel --
-----------

-- After Spell Info and Attack Info: a creature is never a container, door or trap, so they never compete
ZJPopup_AddPanel({
	["name"]         = "Lock Info",
	["priority"]     = 30,
	["getText"]      = ZJLockInfo_Private_GetText,
	["getFontPoint"] = function() return ZJLockInfo_Private_FontPoint:get() end,
})
