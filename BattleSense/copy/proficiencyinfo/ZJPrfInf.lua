--[[
+--------------------------------------------------------------------------------------------------+
| ZJProficiencyInfo - What the proficiency points give, on the proficiencies screen                |
+--------------------------------------------------------------------------------------------------+
|   Adds two rows to the top of the help text of the proficiencies screen, (character creation and |
|   level up): the last weapon proficiency, and the last fighting style, that was clicked or       |
|   changed. A row shows what the points give now, (values of 0 are left out):                     |
|                                                                                                  |
|     Large Sword: 2 points: To-hit bonus +1, Damage bonus +2                                      |
|     Two Weapon Style: 0 points: Main hand to-hit bonus -4, Off-hand to-hit bonus -8              |
|                                                                                                  |
|     * A weapon: the to-hit and damage bonus and speed factor, (WSPECIAL.2DA, or the class's      |
|       penalty without points), and the extra attacks per round the points add at the character's |
|       level, (WSPATCK.2DA)                                                                       |
|     * A fighting style: the bonuses of its STYLBONU.2DA row                                      |
|                                                                                                  |
|   Changes are found by comparing the points in the screen's list from one frame to the next, so  |
|   nothing depends on where things are on the screen. The values come from the game's own tables, |
|   so mods that change proficiencies or fighting styles are followed.                             |
|                                                                                                  |
|   Nothing in UI.menu is changed: the screen's help text comes from proficiencyOrGeneralHelp(),   |
|   which is wrapped every time the UI loads.                                                      |
+--------------------------------------------------------------------------------------------------+
--]]

-------------
-- Options --
-------------

EEex_Options_Register("ZJProficiencyInfo_Enable", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Proficiency Info" }),
	["onChange"] = function(self, oldValue) ZJProficiencyInfo_SetEnabled(self:get() ~= 0) end,
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJProficiencyInfo_Enable",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_Enable",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_Enable_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
	},
} end)

-------------
-- Globals --
-------------

ZJProficiencyInfo_Private_Enabled = false
ZJProficiencyInfo_Private_ErrorReported = false

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

-- Temporarily changes whether the overview is shown.
-- To persist this change, instead modify the "ZJProficiencyInfo_Enable" option.
function ZJProficiencyInfo_SetEnabled(enabled)
	ZJProficiencyInfo_Private_Enabled = enabled
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
-- { label, value, format }, where format is "signed" or "attacks". Values of 0 are left out.
function ZJProficiencyInfo_Private_GetStats(id, points, class, level)

	local T = ZJProficiencyInfo_Private_T
	local stats = {}

	local add = function(key, value, format)
		if value == 0 then return end
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

---------------------
-- Change tracking --
---------------------

-- The screen gets two rows: the last weapon proficiency and the last fighting style that was clicked or changed
ZJProficiencyInfo_Private_Points    = nil -- [proficiency id] = its points the last time they were looked at
ZJProficiencyInfo_Private_Selected  = nil -- The row of the list that was selected the last time it was looked at
ZJProficiencyInfo_Private_LastShown = {}  -- ["weapon" / "style"] = the id of the proficiency shown for that kind

-- Forgets everything, (the screen was opened: for a new character, or a new level up)
function ZJProficiencyInfo_Private_ResetTracking()
	ZJProficiencyInfo_Private_Points = nil
	ZJProficiencyInfo_Private_Selected = nil
	ZJProficiencyInfo_Private_LastShown = {}
end

function ZJProficiencyInfo_Private_GetKind(id)
	return ZJProficiencyInfo_Private_Styles[tonumber(id)] ~= nil and "style" or "weapon"
end

-- Compares the points of every proficiency to the last time, and the selected row: a proficiency whose points changed,
-- or that was clicked, becomes the one shown for its kind. Only the values of the list are looked at, so this doesn't
-- care where anything is on the screen, or how the points were changed.
function ZJProficiencyInfo_Private_TrackChanges()

	local proficiencies = chargen.proficiency
	local lastShown = ZJProficiencyInfo_Private_LastShown
	local firstLook = ZJProficiencyInfo_Private_Points == nil

	if firstLook then ZJProficiencyInfo_Private_Points = {} end

	for _, rowEntry in ipairs(proficiencies) do
		local id = rowEntry.id
		local points = tonumber(rowEntry.value)
		if id ~= nil and points ~= nil then
			local old = ZJProficiencyInfo_Private_Points[id]
			if not firstLook and old ~= nil and old ~= points then
				lastShown[ZJProficiencyInfo_Private_GetKind(id)] = id
			end
			ZJProficiencyInfo_Private_Points[id] = points
		end
	end

	-- A clicked proficiency is shown, (clicking + / - also selects the row)
	local selected = currentChargenProficiency
	if selected ~= ZJProficiencyInfo_Private_Selected then
		ZJProficiencyInfo_Private_Selected = selected
		local rowEntry = proficiencies[selected]
		if type(rowEntry) == "table" and rowEntry.id ~= nil then
			lastShown[ZJProficiencyInfo_Private_GetKind(rowEntry.id)] = rowEntry.id
		end
	end
end

----------
-- Text --
----------

-- The row for the proficiency `shownID`, or nil if it isn't in the list, with what its points give now:
--
--   Large Sword: 2 points: To-hit bonus +1, Damage bonus +2
function ZJProficiencyInfo_Private_GetRow(shownID, class, level)

	local rowEntry = nil
	for _, entry in ipairs(chargen.proficiency) do
		if entry.id == shownID then
			rowEntry = entry
			break
		end
	end
	if rowEntry == nil then return nil end

	local id = tonumber(rowEntry.id)
	local points = tonumber(rowEntry.value)
	if id == nil or points == nil then return nil end

	local T = ZJProficiencyInfo_Private_T

	local name = ""
	if type(rowEntry.name) == "number" then
		local okName, str = pcall(Infinity_FetchString, rowEntry.name)
		if okName and type(str) == "string" then name = str end
	end

	local title = string.format(T("Title"), name, points)

	local values = {}
	for _, stat in ipairs(ZJProficiencyInfo_Private_GetStats(id, points, class, level)) do
		table.insert(values, stat.label.." "..ZJProficiencyInfo_Private_FormatValue(stat.value, stat.format))
	end

	local text = #values > 0 and table.concat(values, ", ") or T("NoBonus")
	return ZJProficiencyInfo_Private_TitleColorStr..title..ZJProficiencyInfo_Private_ColorEndStr..": "..text
end

-- The rows for the last weapon proficiency and the last fighting style that was clicked or changed, or nil
function ZJProficiencyInfo_Private_GetText()

	if type(chargen) ~= "table" or type(chargen.proficiency) ~= "table" then return nil end

	ZJProficiencyInfo_Private_TrackChanges()

	local okClass, class, level = pcall(ZJProficiencyInfo_Private_GetClassAndLevel)
	if not okClass then class, level = nil, nil end

	local rows = {}
	for _, kind in ipairs({ "weapon", "style" }) do
		local shown = ZJProficiencyInfo_Private_LastShown[kind]
		if shown ~= nil then
			local row = ZJProficiencyInfo_Private_GetRow(shown, class, level)
			if row ~= nil then table.insert(rows, row) end
		end
	end

	if #rows == 0 then return nil end
	return table.concat(rows, "\n")
end

---------------
-- Listeners --
---------------

ZJProficiencyInfo_Private_HelpWrapper = nil

-- The proficiencies screen shows proficiencyOrGeneralHelp() as its help text, (the description of the selected
-- proficiency). UI.menu defines it each time it loads, so it is wrapped again every time.
function ZJProficiencyInfo_Private_WrapHelp()

	local original = proficiencyOrGeneralHelp
	if type(original) ~= "function" or original == ZJProficiencyInfo_Private_HelpWrapper then return end

	ZJProficiencyInfo_Private_HelpWrapper = function(...)

		local help = original(...)
		if not ZJProficiencyInfo_Private_Enabled then return help end

		local ok, text = pcall(ZJProficiencyInfo_Private_GetText)

		if not ok then
			if not ZJProficiencyInfo_Private_ErrorReported then
				ZJProficiencyInfo_Private_ErrorReported = true
				print("[Battle Sense] Proficiency Info: "..tostring(text))
			end
			return help
		end

		if text == nil then return help end
		if help == nil or help == "" then return text end
		return text.."\n\n"..tostring(help)
	end

	proficiencyOrGeneralHelp = ZJProficiencyInfo_Private_HelpWrapper
end

EEex_Menu_AddMainFileLoadedListener(function()

	ZJProficiencyInfo_Private_WrapHelp()
	ZJProficiencyInfo_Private_ResetTracking()

	-- Start over every time the screen opens, (its own onOpen still runs first)
	local menu = EEex_Menu_Find("CHARGEN_PROFICIENCIES")
	if menu == nil then return end

	local oldOnOpen = EEex_Menu_GetItemFunction(menu.reference_onOpen) or function() end
	EEex_Menu_SetItemFunction(menu.reference_onOpen, function()
		local toReturn = oldOnOpen()
		ZJProficiencyInfo_Private_ResetTracking()
		return toReturn
	end)
end)
