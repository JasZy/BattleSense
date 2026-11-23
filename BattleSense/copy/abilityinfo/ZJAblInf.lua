--[[
+--------------------------------------------------------------------------------------------------+
| ZJAbilityInfo - What the ability scores give, on the abilities screen                            |
+--------------------------------------------------------------------------------------------------+
|   Adds an overview to the top of the help text of the abilities screen, (character creation),    |
|   with what each of the character's current scores gives a character of its class:              |
|                                                                                                  |
|     Strength 16                                                                                  |
|     To-hit bonus +0, Damage bonus +1, Weight allowance 150, Bend bars / lift gates 16%           |
|                                                                                                  |
|   It follows the scores as they are rerolled or changed with the + / - buttons.                  |
|                                                                                                  |
|   The values come from the game's own tables, (STRMOD, STRMODEX, DEXMOD, SKILLDEX, HPCONBON,     |
|   INTMOD, LOREBON, MXSPLWIS, CHRMODST), so mods that change those tables are followed. Values    |
|   that only matter to some classes, (spells, thieving skills), are only listed for those.        |
|                                                                                                  |
|   Nothing in UI.menu is changed: the screen's help text comes from abilityOrGeneralHelp(), which |
|   is wrapped every time the UI loads.                                                            |
+--------------------------------------------------------------------------------------------------+
--]]

-------------
-- Options --
-------------

EEex_Options_Register("ZJAbilityInfo_Enable", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Ability Info" }),
	["onChange"] = function(self, oldValue) ZJAbilityInfo_SetEnabled(self:get() ~= 0) end,
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_AbilityInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJAbilityInfo_Enable",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_Enable",
			["description"] = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_Enable_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
	},
} end)

-------------
-- Globals --
-------------

ZJAbilityInfo_Private_Enabled = false
ZJAbilityInfo_Private_ErrorReported = false

ZJAbilityInfo_Private_TitleColorStr = "^0xFF64D7FF"
ZJAbilityInfo_Private_ColorEndStr   = "^-"

-- The `name` of a chargen.ability row => the ability. UI.menu lists them in this order, which is used if a UI mod renamed them.
ZJAbilityInfo_Private_AbilityByLabel = {
	["STRENGTH_LABEL"]     = "STR",
	["DEXTERITY_LABEL"]    = "DEX",
	["CONSTITUTION_LABEL"] = "CON",
	["INTELLIGENCE_LABEL"] = "INT",
	["WISDOM_LABEL"]       = "WIS",
	["CHARISMA_LABEL"]     = "CHR",
}
ZJAbilityInfo_Private_AbilityOrder = { "STR", "DEX", "CON", "INT", "WIS", "CHR" }

-- CLASS.IDS values, by what they get from their abilities
ZJAbilityInfo_Private_WarriorClasses = { -- The WARRIOR column of HPCONBON.2DA
	[2] = true, [6] = true, [7] = true, [8] = true, [9] = true, [10] = true, [12] = true, [16] = true, [17] = true, [18] = true,
}
ZJAbilityInfo_Private_WizardClasses = { -- Learn spells from scrolls, (INTMOD.2DA)
	[1] = true, [5] = true, [7] = true, [10] = true, [13] = true, [14] = true, [17] = true,
}
ZJAbilityInfo_Private_PriestClasses = { -- Bonus priest spells, (MXSPLWIS.2DA)
	[3] = true, [6] = true, [8] = true, [11] = true, [12] = true, [14] = true, [15] = true, [16] = true, [17] = true, [18] = true, [21] = true,
}

-- CLASS.IDS => the SKILLDEX.2DA columns of the thieving skills the class has
ZJAbilityInfo_Private_AllThiefSkills = { "PICK_POCKETS", "OPEN_LOCKS", "FIND_TRAPS", "MOVE_SILENTLY", "HIDE_IN_SHADOWS", "DETECT_ILLUSION", "SET_TRAPS" }
ZJAbilityInfo_Private_ThiefSkillsByClass = {
	[4]  = ZJAbilityInfo_Private_AllThiefSkills,
	[9]  = ZJAbilityInfo_Private_AllThiefSkills,
	[10] = ZJAbilityInfo_Private_AllThiefSkills,
	[13] = ZJAbilityInfo_Private_AllThiefSkills,
	[15] = ZJAbilityInfo_Private_AllThiefSkills,
	[5]  = { "PICK_POCKETS" },
	[12] = { "MOVE_SILENTLY", "HIDE_IN_SHADOWS" },
	[18] = { "MOVE_SILENTLY", "HIDE_IN_SHADOWS" },
}

-------------
-- General --
-------------

-- Temporarily changes whether the overview is shown.
-- To persist this change, instead modify the "ZJAbilityInfo_Enable" option.
function ZJAbilityInfo_SetEnabled(enabled)
	ZJAbilityInfo_Private_Enabled = enabled
end

function ZJAbilityInfo_Private_T(key)
	return uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_"..key] or key
end

------------
-- Tables --
------------

ZJAbilityInfo_Private_Tables = {} -- [resref] = C2DArray, loaded the first time it is needed

-- The number at `column`, `row` of the 2DA `resref`, (0 if it isn't a number)
function ZJAbilityInfo_Private_Get(resref, column, row)
	local array = ZJAbilityInfo_Private_Tables[resref]
	if array == nil then
		array = EEex_Resource_Load2DA(resref)
		ZJAbilityInfo_Private_Tables[resref] = array
	end
	return tonumber(array:getAtLabels(column, tostring(row))) or 0
end

-------------------
-- The character --
-------------------

-- The class, (CLASS.IDS), of the character being created, or nil
function ZJAbilityInfo_Private_GetClass()
	local createChar = EngineGlobals.g_pBaldurChitin.m_pEngineCreateChar
	if createChar == nil then return nil end
	local sprite = EEex_GameObject_Get(createChar.m_nGameSprite)
	if sprite == nil then return nil end
	-- The engine keeps three copies of a creature's type, a character being created may only have its class in some of them
	for _, typeAI in ipairs({ sprite.m_typeAI, sprite.m_liveTypeAI, sprite.m_startTypeAI }) do
		if typeAI.m_Class ~= 0 then return typeAI.m_Class end
	end
	return nil
end

-- The score shown in an ability row, "16" or "18/76", => 16, 0 or 18, 76, (18/00 is 100)
function ZJAbilityInfo_Private_ParseRoll(roll)
	local score, extra = tostring(roll or ""):match("^%s*(%d+)%s*/%s*(%d+)")
	if score ~= nil then
		extra = tonumber(extra)
		if extra == 0 then extra = 100 end
		return tonumber(score), extra
	end
	return tonumber(roll), 0
end

-----------
-- Stats --
-----------

-- Returns what `ability` at `score`, (`extra` = exceptional strength), gives a character of `class`, as a list of
-- { label, value, format }, where format is "signed", "plain", "percent", "signedPercent" or "spells". Every value is the
-- modifier the score adds, (what it adds to depends on weapons, armor and level).
function ZJAbilityInfo_Private_GetStats(ability, score, extra, class)

	local T = ZJAbilityInfo_Private_T
	local get = ZJAbilityInfo_Private_Get
	local stats = {}

	local add = function(key, value, format)
		table.insert(stats, { ["label"] = T("Stat_"..key), ["value"] = value, ["format"] = format })
	end

	if ability == "STR" then

		local strengthMod = function(column)
			return get("STRMOD", column, score) + get("STRMODEX", column, extra)
		end

		add("ToHit",           strengthMod("TO_HIT"),               "signed")
		add("Damage",          strengthMod("DAMAGE"),               "signed")
		add("WeightAllowance", strengthMod("WEIGHT_ALLOWANCE"),     "plain")
		add("BendBars",        strengthMod("BEND_BARS_LIFT_GATES"), "percent")

	elseif ability == "DEX" then

		add("ArmorClass", get("DEXMOD", "AC", score),      "signed")
		add("Missile",    get("DEXMOD", "MISSILE", score), "signed")

		for _, skill in ipairs(ZJAbilityInfo_Private_ThiefSkillsByClass[class] or {}) do
			add(skill, get("SKILLDEX", skill, score), "signedPercent")
		end

	elseif ability == "CON" then

		local hitPointsColumn = ZJAbilityInfo_Private_WarriorClasses[class] and "WARRIOR" or "OTHER"
		add("HitPointsPerLevel", get("HPCONBON", hitPointsColumn, score), "signed")
		add("FatigueBonus",      get("HPCONBON", "FATIGUE_BONUS", score), "signed")

		-- Only differs from 1 at very high scores
		local minimumRoll = get("HPCONBON", "MIN_ROLL", score)
		if minimumRoll > 1 then
			add("MinimumRoll", minimumRoll, "plain")
		end

	elseif ability == "INT" then

		if ZJAbilityInfo_Private_WizardClasses[class] then
			add("LearnSpell",        get("INTMOD", "LEARN_SPELL", score),          "percent")
			add("MaxSpellsPerLevel", get("INTMOD", "MAX_SPELLS_PER_LEVEL", score), "plain")
		end
		add("Lore", get("LOREBON", "VALUE", score), "signed")

	elseif ability == "WIS" then

		if ZJAbilityInfo_Private_PriestClasses[class] then
			local counts = {}
			for level = 1, 7 do
				counts[level] = get("MXSPLWIS", tostring(level), score)
			end
			add("BonusPriestSpells", counts, "spells")
		end
		add("Lore", get("LOREBON", "VALUE", score), "signed")

	elseif ability == "CHR" then

		-- CHRMODST.2DA has a single row, "1", with a column for every score
		add("StorePrices", get("CHRMODST", tostring(score), 1), "signedPercent")
	end

	return stats
end

-- Bonus priest spells per level, { 2, 1, 0, ... } => "2/1", (up to the highest level with any), or "none"
function ZJAbilityInfo_Private_FormatSpellCounts(counts)
	local upToLevel = 0
	for level = 7, 1, -1 do
		if counts[level] ~= 0 then
			upToLevel = level
			break
		end
	end
	if upToLevel == 0 then return ZJAbilityInfo_Private_T("None") end
	local parts = {}
	for level = 1, upToLevel do
		table.insert(parts, tostring(counts[level]))
	end
	return table.concat(parts, "/")
end

function ZJAbilityInfo_Private_FormatValue(value, format)
	if format == "spells"        then return ZJAbilityInfo_Private_FormatSpellCounts(value) end
	if format == "signed"        then return string.format("%+d", value) end
	if format == "percent"       then return string.format("%d%%", value) end
	if format == "signedPercent" then return string.format("%+d%%", value) end
	return tostring(value)
end

function ZJAbilityInfo_Private_FormatScore(score, extra)
	if extra > 0 then
		return string.format("%d/%02d", score, extra % 100)
	end
	return tostring(score)
end

--------------
-- Overview --
--------------

ZJAbilityInfo_Private_OverviewKey  = nil -- What the overview was last built for
ZJAbilityInfo_Private_OverviewText = nil

-- The overview of what every current score gives, or nil if the scores aren't known
function ZJAbilityInfo_Private_GetOverview()

	if type(chargen) ~= "table" or type(chargen.ability) ~= "table" then return nil end

	local okClass, class = pcall(ZJAbilityInfo_Private_GetClass)
	if not okClass then class = nil end

	-- The help text is asked for every frame, only build the overview again when a score changed
	local keyParts = { tostring(class) }
	for _, rowEntry in ipairs(chargen.ability) do
		table.insert(keyParts, tostring(rowEntry.roll))
	end
	local key = table.concat(keyParts, "|")
	if key == ZJAbilityInfo_Private_OverviewKey then return ZJAbilityInfo_Private_OverviewText end

	local parts = {}

	for row, rowEntry in ipairs(chargen.ability) do

		local ability = ZJAbilityInfo_Private_AbilityByLabel[rowEntry.name] or ZJAbilityInfo_Private_AbilityOrder[row]
		local score, extra = ZJAbilityInfo_Private_ParseRoll(rowEntry.roll)

		if ability ~= nil and score ~= nil then

			local name = type(rowEntry.name) == "string" and t(rowEntry.name) or ability

			local values = {}
			for _, stat in ipairs(ZJAbilityInfo_Private_GetStats(ability, score, extra, class)) do
				table.insert(values, stat.label.." "..ZJAbilityInfo_Private_FormatValue(stat.value, stat.format))
			end

			table.insert(parts, ZJAbilityInfo_Private_TitleColorStr..name.." "..ZJAbilityInfo_Private_FormatScore(score, extra)
				..ZJAbilityInfo_Private_ColorEndStr.."\n"..table.concat(values, ", "))
		end
	end

	ZJAbilityInfo_Private_OverviewKey = key
	ZJAbilityInfo_Private_OverviewText = #parts > 0 and table.concat(parts, "\n") or nil
	return ZJAbilityInfo_Private_OverviewText
end

---------------
-- Listeners --
---------------

ZJAbilityInfo_Private_HelpWrapper = nil

-- The abilities screen shows abilityOrGeneralHelp() as its help text. UI.menu defines it each time it loads, so it is
-- wrapped again every time.
function ZJAbilityInfo_Private_WrapHelp()

	local original = abilityOrGeneralHelp
	if type(original) ~= "function" or original == ZJAbilityInfo_Private_HelpWrapper then return end

	ZJAbilityInfo_Private_HelpWrapper = function(...)

		local help = original(...)
		if not ZJAbilityInfo_Private_Enabled then return help end

		local ok, overview = pcall(ZJAbilityInfo_Private_GetOverview)

		if not ok then
			if not ZJAbilityInfo_Private_ErrorReported then
				ZJAbilityInfo_Private_ErrorReported = true
				print("[Battle Sense] Ability Info: "..tostring(overview))
			end
			return help
		end

		if overview == nil then return help end
		if help == nil or help == "" then return overview end
		return overview.."\n\n"..tostring(help)
	end

	abilityOrGeneralHelp = ZJAbilityInfo_Private_HelpWrapper
end

EEex_Menu_AddMainFileLoadedListener(function()
	ZJAbilityInfo_Private_OverviewKey = nil
	ZJAbilityInfo_Private_WrapHelp()
end)
