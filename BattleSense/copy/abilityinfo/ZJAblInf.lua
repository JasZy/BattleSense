--[[
+--------------------------------------------------------------------------------------------------+
| ZJAbilityInfo - What the ability scores give, on the abilities screen                            |
+--------------------------------------------------------------------------------------------------+
|   Hovering an ability on the abilities screen, (character creation), opens a popup with what    |
|   the character's current score gives a character of its class:                                 |
|                                                                                                  |
|     Strength 16                                                                                  |
|     To-hit bonus +0                                                                              |
|     Damage bonus +1                                                                              |
|     Weight allowance 150                                                                         |
|     Bend bars / lift gates 16%                                                                   |
|                                                                                                  |
|   It follows the score as it is rerolled or changed with the + / - buttons.                      |
|                                                                                                  |
|   The values come from the game's own tables, (STRMOD, STRMODEX, DEXMOD, SKILLDEX, HPCONBON,     |
|   INTMOD, LOREBON, MXSPLWIS, CHRMODST), so mods that change those tables are followed. Values    |
|   that only matter to some classes, (spells, thieving skills), are only listed for those.        |
|                                                                                                  |
|   Nothing in UI.menu is changed: the screen's help text comes from abilityOrGeneralHelp(), which |
|   the screen asks for every frame. It is wrapped every time the UI loads, to update the popup.   |
+--------------------------------------------------------------------------------------------------+
--]]

-- The switch that opens the popup and the screen popup, (shared by every popup)
Infinity_DoFile("ZJPopup")

-------------
-- Options --
-------------

-- The module's switch, (Off or the key that opens the popup), in the "Battle Sense Modules" tab
ZJAbilityInfo_Private_OpenOn = EEex_Options_Register("ZJAbilityInfo_Enable", ZJPopup_NewSwitch("Ability Info", {
	["onChange"] = function(self, oldValue) ZJAbilityInfo_SetEnabled(self:get() ~= 0) end,
}))

ZJAbilityInfo_Private_FontPoint = EEex_Options_Register("ZJAbilityInfo_FontPoint", EEex_Options_Option.new({
	["default"]  = 11,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Ability Info Module: Font Point" }),
}))

ZJAbilityInfo_Private_BackgroundOpacity = EEex_Options_Register("ZJAbilityInfo_BackgroundOpacity", EEex_Options_Option.new({
	["default"]  = 92,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 100 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Ability Info Module: Background Opacity" }),
}))

ZJAbilityInfo_Private_ShowNextScore = EEex_Options_Register("ZJAbilityInfo_ShowNextScore", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Ability Info Module: Show Next Score" }),
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_AbilityInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJAbilityInfo_FontPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_FontPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_FontPoint_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"]        = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJAbilityInfo_BackgroundOpacity",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_BackgroundOpacity",
			["description"] = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_BackgroundOpacity_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 3,
				["number"]        = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJAbilityInfo_ShowNextScore",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_ShowNextScore",
			["description"] = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_ShowNextScore_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
	},
} end)

-------------
-- Globals --
-------------

ZJAbilityInfo_Private_Enabled = false
ZJAbilityInfo_Private_ErrorReported = false

ZJAbilityInfo_Private_MenuName    = "CHARGEN_ABILITIES"
ZJAbilityInfo_Private_PopupOwner  = "ZJAbilityInfo" -- Who is showing the screen popup, (ZJPopup.lua)

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

-- Temporarily changes whether the popup is shown.
-- To persist this change, instead modify the "ZJAbilityInfo_Enable" option.
function ZJAbilityInfo_SetEnabled(enabled)
	ZJAbilityInfo_Private_Enabled = enabled
	if not enabled then
		ZJPopup_HideOnScreen(ZJAbilityInfo_Private_PopupOwner)
	end
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

ZJAbilityInfo_Private_MaxScore = 25

-- What one more point in `ability` would change: a heading, ("At 17:"), and the values that change, ("Damage bonus +0 ->
-- +1"), or "No change". A score of 18 with exceptional strength goes to 19. Nil at the highest score.
function ZJAbilityInfo_Private_GetNextScoreLines(ability, score, extra, class)

	local T = ZJAbilityInfo_Private_T
	local format = ZJAbilityInfo_Private_FormatValue

	local nextScore = score + 1
	if nextScore > ZJAbilityInfo_Private_MaxScore then return nil end

	local currentValues = {} -- [label] = the value now, as shown
	for _, stat in ipairs(ZJAbilityInfo_Private_GetStats(ability, score, extra, class)) do
		currentValues[stat.label] = format(stat.value, stat.format)
	end

	local lines = { ZJAbilityInfo_Private_TitleColorStr..string.format(T("NextScore"), tostring(nextScore))..ZJAbilityInfo_Private_ColorEndStr }

	for _, stat in ipairs(ZJAbilityInfo_Private_GetStats(ability, nextScore, 0, class)) do
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

ZJAbilityInfo_Private_PopupKey  = nil -- What the popup text was last built for
ZJAbilityInfo_Private_PopupText = nil

-- What the current score of the ability on `row` of the screen's list gives, or nil if it isn't known
function ZJAbilityInfo_Private_GetText(row)

	local rowEntry = chargen.ability[row]
	if type(rowEntry) ~= "table" then return nil end

	local okClass, class = pcall(ZJAbilityInfo_Private_GetClass)
	if not okClass then class = nil end

	-- The popup is updated every frame, only build its text again when something changed
	local showNextScore = ZJAbilityInfo_Private_ShowNextScore:get() ~= 0
	local key = string.format("%d|%s|%s|%s", row, tostring(class), tostring(rowEntry.roll), tostring(showNextScore))
	if key == ZJAbilityInfo_Private_PopupKey then return ZJAbilityInfo_Private_PopupText end

	local text = nil

	local ability = ZJAbilityInfo_Private_AbilityByLabel[rowEntry.name] or ZJAbilityInfo_Private_AbilityOrder[row]
	local score, extra = ZJAbilityInfo_Private_ParseRoll(rowEntry.roll)

	if ability ~= nil and score ~= nil then

		local name = type(rowEntry.name) == "string" and t(rowEntry.name) or ability

		local values = {}
		for _, stat in ipairs(ZJAbilityInfo_Private_GetStats(ability, score, extra, class)) do
			table.insert(values, stat.label.." "..ZJAbilityInfo_Private_FormatValue(stat.value, stat.format))
		end

		text = ZJAbilityInfo_Private_TitleColorStr..name.." "..ZJAbilityInfo_Private_FormatScore(score, extra)
			..ZJAbilityInfo_Private_ColorEndStr.."\n"..table.concat(values, "\n")

		if showNextScore then
			local nextLines = ZJAbilityInfo_Private_GetNextScoreLines(ability, score, extra, class)
			if nextLines ~= nil then
				text = text.."\n\n"..table.concat(nextLines, "\n")
			end
		end
	end

	ZJAbilityInfo_Private_PopupKey = key
	ZJAbilityInfo_Private_PopupText = text
	return text
end

-- Shows the popup for the ability under the cursor, or closes it. Runs every frame the abilities screen is drawn.
function ZJAbilityInfo_Private_UpdatePopup()

	local owner = ZJAbilityInfo_Private_PopupOwner

	if not ZJAbilityInfo_Private_Enabled or type(chargen) ~= "table"
		or not ZJPopup_IsOpenAllowed(ZJAbilityInfo_Private_OpenOn)
	then
		ZJPopup_HideOnScreen(owner)
		return
	end

	local row, _, rowY = ZJPopup_FindHoveredRow(ZJAbilityInfo_Private_MenuName, chargen.ability)
	local text = row and ZJAbilityInfo_Private_GetText(row)

	if text == nil then
		ZJPopup_HideOnScreen(owner)
		return
	end

	ZJPopup_ShowOnScreen(owner, text, rowY, ZJAbilityInfo_Private_FontPoint:get(), ZJAbilityInfo_Private_BackgroundOpacity:get())
end

---------------
-- Listeners --
---------------

ZJAbilityInfo_Private_HelpWrapper = nil

-- The abilities screen shows abilityOrGeneralHelp() as its help text, and asks for it every frame, which is what
-- updates the popup. UI.menu defines it each time it loads, so it is wrapped again every time.
function ZJAbilityInfo_Private_WrapHelp()

	local original = abilityOrGeneralHelp
	if type(original) ~= "function" or original == ZJAbilityInfo_Private_HelpWrapper then return end

	ZJAbilityInfo_Private_HelpWrapper = function(...)

		local ok, err = pcall(ZJAbilityInfo_Private_UpdatePopup)

		if not ok then
			pcall(ZJPopup_HideOnScreen, ZJAbilityInfo_Private_PopupOwner)
			if not ZJAbilityInfo_Private_ErrorReported then
				ZJAbilityInfo_Private_ErrorReported = true
				print("[Battle Sense] Ability Info: "..tostring(err))
			end
		end

		return original(...)
	end

	abilityOrGeneralHelp = ZJAbilityInfo_Private_HelpWrapper
end

EEex_Menu_AddMainFileLoadedListener(function()

	ZJAbilityInfo_Private_PopupKey = nil
	ZJAbilityInfo_Private_WrapHelp()

	-- The popup closes with the screen, (its own onClose still runs first)
	local menu = EEex_Menu_Find(ZJAbilityInfo_Private_MenuName)
	if menu == nil then return end

	local oldOnClose = EEex_Menu_GetItemFunction(menu.reference_onClose) or function() end
	EEex_Menu_SetItemFunction(menu.reference_onClose, function()
		local toReturn = oldOnClose()
		ZJPopup_HideOnScreen(ZJAbilityInfo_Private_PopupOwner)
		return toReturn
	end)
end)
