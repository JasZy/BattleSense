--[[
+--------------------------------------------------------------------------------------------------+
| ZJProficiencyInfo - What the proficiency points give, on the proficiencies screen                |
+--------------------------------------------------------------------------------------------------+
|   Hovering a weapon proficiency or fighting style on the proficiencies screen, (character        |
|   creation and level up), opens a popup with what its points give now, (values of 0 are left    |
|   out):                                                                                          |
|                                                                                                  |
|     Large Sword: 2 points                                                                        |
|     To-hit bonus +1                                                                              |
|     Damage bonus +2                                                                              |
|                                                                                                  |
|     * A weapon: the to-hit and damage bonus and speed factor, (WSPECIAL.2DA, or the class's      |
|       penalty without points), and the extra attacks per round the points add at the character's |
|       level, (WSPATCK.2DA)                                                                       |
|     * A fighting style: the bonuses of its STYLBONU.2DA row                                      |
|                                                                                                  |
|   It follows the points as they are changed with the + / - buttons. The values come from the     |
|   game's own tables, so mods that change proficiencies or fighting styles are followed.          |
|                                                                                                  |
|   Nothing in UI.menu is changed: the screen's help text comes from proficiencyOrGeneralHelp(),   |
|   which the screen asks for every frame. It is wrapped every time the UI loads, to update the    |
|   popup.                                                                                         |
+--------------------------------------------------------------------------------------------------+
--]]

-- The popup key and the screen popup, (shared by every module with a popup)
Infinity_DoFile("ZJPopup")

-------------
-- Options --
-------------

-- The module's on / off switch, in the "Battle Sense Modules" tab
ZJProficiencyInfo_Private_OpenOn = EEex_Options_Register("ZJProficiencyInfo_Enable", ZJPopup_NewSwitch("Proficiency Info", {
	["onChange"] = function(self, oldValue) ZJProficiencyInfo_SetEnabled(self:get() ~= 0) end,
}))

ZJProficiencyInfo_Private_FontPoint = EEex_Options_Register("ZJProficiencyInfo_FontPoint", EEex_Options_Option.new({
	["default"]  = 11,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Proficiency Info Module: Font Point" }),
}))

ZJProficiencyInfo_Private_BackgroundOpacity = EEex_Options_Register("ZJProficiencyInfo_BackgroundOpacity", EEex_Options_Option.new({
	["default"]  = 92,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 100 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Proficiency Info Module: Background Opacity" }),
}))

ZJProficiencyInfo_Private_ShowNextPoint = EEex_Options_Register("ZJProficiencyInfo_ShowNextPoint", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Proficiency Info Module: Show Next Point" }),
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJProficiencyInfo_FontPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_FontPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_FontPoint_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"]        = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJProficiencyInfo_BackgroundOpacity",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_BackgroundOpacity",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_BackgroundOpacity_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 3,
				["number"]        = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJProficiencyInfo_ShowNextPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_ShowNextPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_ShowNextPoint_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
	},
} end)

-------------
-- Globals --
-------------

ZJProficiencyInfo_Private_Enabled = false
ZJProficiencyInfo_Private_ErrorReported = false

ZJProficiencyInfo_Private_MenuName   = "CHARGEN_PROFICIENCIES"
ZJProficiencyInfo_Private_PopupOwner = "ZJProficiencyInfo" -- Who is showing the screen popup, (ZJPopup.lua)

ZJProficiencyInfo_Private_TitleColorStr  = "^0xFF64D7FF"
ZJProficiencyInfo_Private_ColorEndStr    = "^-"

-- The fighting style proficiencies, (WEAPPROF.2DA ID / STATS.IDS), => their STYLBONU.2DA row prefix
ZJProficiencyInfo_Private_Styles = {
	[111] = "TWOHANDED",
	[112] = "SWORDANDSHIELD",
	[113] = "SINGLEWEAPON",
	[114] = "TWOWEAPON",
}

-- The THAC0 penalty of a class, (CLASS.IDS), for using a weapon it has no proficiency points in. The engine has these
-- built in, (warriors -2, priests and rogues -3, wizards -5), a multi-class character gets the smallest one.
ZJProficiencyInfo_Private_NonProficiencyPenalties = {
	[1]  = -5, -- Mage
	[2]  = -2, -- Fighter
	[3]  = -3, -- Cleric
	[4]  = -3, -- Thief
	[5]  = -3, -- Bard
	[6]  = -2, -- Paladin
	[7]  = -2, -- Fighter / mage
	[8]  = -2, -- Fighter / cleric
	[9]  = -2, -- Fighter / thief
	[10] = -2, -- Fighter / mage / thief
	[11] = -3, -- Druid
	[12] = -2, -- Ranger
	[13] = -3, -- Mage / thief
	[14] = -3, -- Cleric / mage
	[15] = -3, -- Cleric / thief
	[16] = -2, -- Fighter / druid
	[17] = -2, -- Fighter / mage / cleric
	[18] = -2, -- Cleric / ranger
	[19] = -5, -- Sorcerer
	[20] = -3, -- Monk
	[21] = -3, -- Shaman
}

-- CLASS.IDS => which of the character's levels, (1 - 3), is its warrior level, (the one attacks per round go by).
-- Every class not listed uses its first level.
ZJProficiencyInfo_Private_WarriorLevelIndex = {
	[18] = 2, -- Cleric / ranger
}

-------------
-- General --
-------------

-- Temporarily changes whether the popup is shown.
-- To persist this change, instead modify the "ZJProficiencyInfo_Enable" option.
function ZJProficiencyInfo_SetEnabled(enabled)
	ZJProficiencyInfo_Private_Enabled = enabled
	if not enabled then
		ZJPopup_HideOnScreen(ZJProficiencyInfo_Private_PopupOwner)
	end
end

function ZJProficiencyInfo_Private_T(key)
	return uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_"..key] or key
end

------------
-- Tables --
------------

ZJProficiencyInfo_Private_Tables = {} -- [resref] = C2DArray, loaded the first time it is needed

function ZJProficiencyInfo_Private_GetTable(resref)
	local array = ZJProficiencyInfo_Private_Tables[resref]
	if array == nil then
		array = EEex_Resource_Load2DA(resref)
		ZJProficiencyInfo_Private_Tables[resref] = array
	end
	return array
end

-- The number at `column`, `row` of the 2DA `resref`, (0 if it isn't a number)
function ZJProficiencyInfo_Private_Get(resref, column, row)
	return tonumber(ZJProficiencyInfo_Private_GetTable(resref):getAtLabels(column, tostring(row))) or 0
end

-------------------
-- The character --
-------------------

-- Returns the class, (CLASS.IDS), and the warrior level of the character on the screen, or nil
function ZJProficiencyInfo_Private_GetClassAndLevel()

	local createChar = EngineGlobals.g_pBaldurChitin.m_pEngineCreateChar
	if createChar == nil then return nil end

	local sprite = EEex_GameObject_Get(createChar.m_nGameSprite)
	if sprite == nil then return nil end

	-- The engine keeps three copies of a creature's type, a character being created may only have its class in some of them
	local class = nil
	for _, typeAI in ipairs({ sprite.m_typeAI, sprite.m_liveTypeAI, sprite.m_startTypeAI }) do
		if typeAI.m_Class ~= 0 then
			class = typeAI.m_Class
			break
		end
	end

	-- A character being created may not have its level in its derived stats yet
	local levelIndex = ZJProficiencyInfo_Private_WarriorLevelIndex[class] or 1
	local derived, base = sprite.m_derivedStats, sprite.m_baseStats
	local level
	if levelIndex == 2 then
		level = math.max(derived.m_nLevel2, base.m_level2)
	else
		level = math.max(derived.m_nLevel1, base.m_level1)
	end

	return class, math.max(level, 1)
end

-----------
-- Stats --
-----------

-- WSPATCK.2DA holds the extra attacks per round as the creature file does: 0 to 5 are whole attacks, -1 is a half,
-- -2 one and a half, ... Returns the number of extra half attacks.
function ZJProficiencyInfo_Private_DecodeAttacks(value)
	if value < 0 then return -value * 2 - 1 end
	return value * 2
end

-- Half attacks => "+1/2", "+1", "+1 1/2"
function ZJProficiencyInfo_Private_FormatHalfAttacks(halves)
	local sign = halves < 0 and "-" or "+"
	halves = math.abs(halves)
	local whole, half = math.floor(halves / 2), halves % 2
	if half == 0 then return sign..whole end
	if whole == 0 then return sign.."1/2" end
	return string.format("%s%d 1/2", sign, whole)
end

-- The extra attacks per round, (in halves), of `points` in a weapon at `level`, (WSPATCK.2DA, columns "LEVEL1", "2", ...)
function ZJProficiencyInfo_Private_GetExtraAttacks(points, level)
	if level == nil or level < 1 then return nil end
	local array = ZJProficiencyInfo_Private_GetTable("WSPATCK")
	-- The table's last column counts for every higher level
	local columns = array:getDimensions() - 1
	local column = math.min(level, columns)
	local value = tonumber(array:getAtPoint(column - 1, points))
	if value == nil then return nil end
	return ZJProficiencyInfo_Private_DecodeAttacks(value)
end

-- The WSPECIAL.2DA row of `points`, { hit, damage, speed }. More points than the table has rows count as its last row.
function ZJProficiencyInfo_Private_GetSpecializationRow(points)
	local array = ZJProficiencyInfo_Private_GetTable("WSPECIAL")
	for tryPoints = points, 0, -1 do
		local hit = tonumber(array:getAtPoint(0, tryPoints))
		if hit ~= nil then
			return { hit, tonumber(array:getAtPoint(1, tryPoints)) or 0, tonumber(array:getAtPoint(2, tryPoints)) or 0 }
		end
	end
	return { 0, 0, 0 }
end

-- Returns what `points` in the proficiency `id` give a character of `class` at `level`, as a list of
-- { label, value, format }, where format is "signed" or "attacks". Values of 0 are left out, unless `keepZeros`.
function ZJProficiencyInfo_Private_GetStats(id, points, class, level, keepZeros)

	local T = ZJProficiencyInfo_Private_T
	local stats = {}

	local add = function(key, value, format)
		if value == 0 and not keepZeros then return end
		table.insert(stats, { ["label"] = T("Stat_"..key), ["value"] = value, ["format"] = format or "signed" })
	end

	local style = ZJProficiencyInfo_Private_Styles[id]

	if style ~= nil then

		local row = style.."-"..points
		local get = function(column) return ZJProficiencyInfo_Private_Get("STYLBONU", column, row) end

		-- The THAC0 columns lower THAC0, (a positive number is a penalty), shown here as a to-hit bonus
		add("MainHandToHit",     -get("THAC0_RIGHT"))
		add("OffHandToHit",      -get("THAC0_LEFT"))
		add("MainHandDamage",    get("DAMAGE_RIGHT"))
		add("OffHandDamage",     get("DAMAGE_LEFT"))

		-- AC_MISSILE comes on top of AC_BASE against missiles, (e.g. -2 and +2: -2 in melee, nothing against missiles)
		local armorClass = get("AC_BASE")
		local armorClassMissile = armorClass + get("AC_MISSILE")
		if armorClassMissile == armorClass then
			add("ArmorClass", armorClass)
		else
			table.insert(stats, {
				["label"]  = T("Stat_ArmorClass"),
				["value"]  = string.format("%+d, "..T("AgainstMissiles"), armorClass, armorClassMissile),
				["format"] = "text",
			})
		end

		add("SpeedFactor",       get("SPEED"))
		add("CriticalRange",     get("CRITICALROLL"))

	else

		local hit, damage, speed = 0, 0, 0
		if points == 0 then
			hit = ZJProficiencyInfo_Private_NonProficiencyPenalties[class] or 0
		else
			local row = ZJProficiencyInfo_Private_GetSpecializationRow(points)
			hit, damage, speed = row[1], row[2], row[3]
		end

		add("ToHit",       hit)
		add("Damage",      damage)
		add("SpeedFactor", speed)

		-- WSPATCK.2DA also holds the extra attacks warriors get from their level, only what the points add is listed
		local attacks = ZJProficiencyInfo_Private_GetExtraAttacks(points, level)
		local baseAttacks = ZJProficiencyInfo_Private_GetExtraAttacks(0, level)
		if attacks ~= nil and baseAttacks ~= nil then
			add("ExtraAttacks", attacks - baseAttacks, "attacks")
		end
	end

	return stats
end

function ZJProficiencyInfo_Private_FormatValue(value, format)
	if format == "attacks" then return ZJProficiencyInfo_Private_FormatHalfAttacks(value) end
	if format == "text" then return tostring(value) end
	return string.format("%+d", value)
end

-- The most points the game's tables go up to, (a class may allow fewer)
ZJProficiencyInfo_Private_MaxWeaponPoints = 5
ZJProficiencyInfo_Private_MaxStylePoints  = 3

-- What one more point in the proficiency `id` would change: a heading, ("Next point:"), and the values that change,
-- ("Damage bonus +2 -> +3"), or "No change". Nil at the most points the tables go up to.
function ZJProficiencyInfo_Private_GetNextPointLines(id, points, class, level)

	local T = ZJProficiencyInfo_Private_T
	local format = ZJProficiencyInfo_Private_FormatValue

	local maxPoints = ZJProficiencyInfo_Private_Styles[id] and ZJProficiencyInfo_Private_MaxStylePoints
		or ZJProficiencyInfo_Private_MaxWeaponPoints
	if points >= maxPoints then return nil end

	local currentValues = {} -- [label] = the value now, as shown
	for _, stat in ipairs(ZJProficiencyInfo_Private_GetStats(id, points, class, level, true)) do
		currentValues[stat.label] = format(stat.value, stat.format)
	end

	local lines = { ZJProficiencyInfo_Private_TitleColorStr..T("NextPoint")..ZJProficiencyInfo_Private_ColorEndStr }

	for _, stat in ipairs(ZJProficiencyInfo_Private_GetStats(id, points + 1, class, level, true)) do
		local nextValue = format(stat.value, stat.format)
		local currentValue = currentValues[stat.label]
		if currentValue == nil then
			table.insert(lines, stat.label.." "..nextValue)
		elseif currentValue ~= nextValue then
			table.insert(lines, stat.label.." "..currentValue.." -> "..nextValue)
		end
	end

	if #lines == 1 then
		table.insert(lines, T("NoChange"))
	end

	return lines
end

-----------
-- Popup --
-----------

ZJProficiencyInfo_Private_PopupKey  = nil -- What the popup text was last built for
ZJProficiencyInfo_Private_PopupText = nil

-- What the points of the proficiency on `row` of the screen's list give now, or nil if it isn't known:
--
--   Large Sword: 2 points
--   To-hit bonus +1
--   Damage bonus +2
function ZJProficiencyInfo_Private_GetText(row)

	local rowEntry = chargen.proficiency[row]
	if type(rowEntry) ~= "table" then return nil end

	local id = tonumber(rowEntry.id)
	local points = tonumber(rowEntry.value)
	if id == nil or points == nil then return nil end

	local okClass, class, level = pcall(ZJProficiencyInfo_Private_GetClassAndLevel)
	if not okClass then class, level = nil, nil end

	-- The popup is updated every frame, only build its text again when something changed
	local showNextPoint = ZJProficiencyInfo_Private_ShowNextPoint:get() ~= 0
	local key = string.format("%d|%d|%s|%s|%s", id, points, tostring(class), tostring(level), tostring(showNextPoint))
	if key == ZJProficiencyInfo_Private_PopupKey then return ZJProficiencyInfo_Private_PopupText end

	local T = ZJProficiencyInfo_Private_T

	local name = ""
	if type(rowEntry.name) == "number" then
		local okName, str = pcall(Infinity_FetchString, rowEntry.name)
		if okName and type(str) == "string" then name = str end
	end

	local lines = { ZJProficiencyInfo_Private_TitleColorStr..string.format(T("Title"), name, points)..ZJProficiencyInfo_Private_ColorEndStr }

	local stats = ZJProficiencyInfo_Private_GetStats(id, points, class, level)
	for _, stat in ipairs(stats) do
		table.insert(lines, stat.label.." "..ZJProficiencyInfo_Private_FormatValue(stat.value, stat.format))
	end
	if #stats == 0 then
		table.insert(lines, T("NoBonus"))
	end

	if showNextPoint then
		local nextLines = ZJProficiencyInfo_Private_GetNextPointLines(id, points, class, level)
		if nextLines ~= nil then
			table.insert(lines, "")
			for _, line in ipairs(nextLines) do
				table.insert(lines, line)
			end
		end
	end

	ZJProficiencyInfo_Private_PopupKey = key
	ZJProficiencyInfo_Private_PopupText = table.concat(lines, "\n")
	return ZJProficiencyInfo_Private_PopupText
end

-- Shows the popup for the proficiency under the cursor, or closes it. Runs every frame the proficiencies screen is drawn.
function ZJProficiencyInfo_Private_UpdatePopup()

	local owner = ZJProficiencyInfo_Private_PopupOwner

	if not ZJProficiencyInfo_Private_Enabled or type(chargen) ~= "table"
		or not ZJPopup_IsOpenAllowed(ZJProficiencyInfo_Private_OpenOn)
	then
		ZJPopup_HideOnScreen(owner)
		return
	end

	local row, _, rowY = ZJPopup_FindHoveredRow(ZJProficiencyInfo_Private_MenuName, chargen.proficiency)
	local text = row and ZJProficiencyInfo_Private_GetText(row)

	if text == nil then
		ZJPopup_HideOnScreen(owner)
		return
	end

	ZJPopup_ShowOnScreen(owner, text, rowY, ZJProficiencyInfo_Private_FontPoint:get(), ZJProficiencyInfo_Private_BackgroundOpacity:get())
end

---------------
-- Listeners --
---------------

ZJProficiencyInfo_Private_HelpWrapper = nil

-- The proficiencies screen shows proficiencyOrGeneralHelp() as its help text, (the description of the selected
-- proficiency), and asks for it every frame, which is what updates the popup. UI.menu defines it each time it loads, so
-- it is wrapped again every time.
function ZJProficiencyInfo_Private_WrapHelp()

	local original = proficiencyOrGeneralHelp
	if type(original) ~= "function" or original == ZJProficiencyInfo_Private_HelpWrapper then return end

	ZJProficiencyInfo_Private_HelpWrapper = function(...)

		local ok, err = pcall(ZJProficiencyInfo_Private_UpdatePopup)

		if not ok then
			pcall(ZJPopup_HideOnScreen, ZJProficiencyInfo_Private_PopupOwner)
			if not ZJProficiencyInfo_Private_ErrorReported then
				ZJProficiencyInfo_Private_ErrorReported = true
				print("[Battle Sense] Proficiency Info: "..tostring(err))
			end
		end

		return original(...)
	end

	proficiencyOrGeneralHelp = ZJProficiencyInfo_Private_HelpWrapper
end

EEex_Menu_AddMainFileLoadedListener(function()

	ZJProficiencyInfo_Private_PopupKey = nil
	ZJProficiencyInfo_Private_WrapHelp()

	-- The popup closes with the screen, (its own onClose still runs first)
	local menu = EEex_Menu_Find(ZJProficiencyInfo_Private_MenuName)
	if menu == nil then return end

	local oldOnClose = EEex_Menu_GetItemFunction(menu.reference_onClose) or function() end
	EEex_Menu_SetItemFunction(menu.reference_onClose, function()
		local toReturn = oldOnClose()
		ZJPopup_HideOnScreen(ZJProficiencyInfo_Private_PopupOwner)
		return toReturn
	end)
end)
