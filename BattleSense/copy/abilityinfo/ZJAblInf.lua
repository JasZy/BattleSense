--[[
+--------------------------------------------------------------------------------------------------+
| ZJAbilityInfo - What one more point in an ability would do, on the abilities screen              |
+--------------------------------------------------------------------------------------------------+
|   Hovering an ability on the abilities screen of character creation, (or its + / - buttons),    |
|   opens a popup beside it with what raising that ability by one point would change:              |
|   `Strength 16 -> 17`, `To-hit bonus: +0 -> +1 (+1)`, `Weight allowance: 150 -> 170 (+20)`.      |
|                                                                                                  |
|   The values come from the game's own tables, (STRMOD, STRMODEX, DEXMOD, SKILLDEX, HPCONBON,     |
|   INTMOD, LOREBON, MXSPLWIS, CHRMODST), so mods that change those tables are followed. Lines     |
|   that only matter to some classes, (spells, thieving skills), are only shown to those classes.  |
|   If the next point changes nothing, the popup says at which score the next change comes.        |
|                                                                                                  |
|   Nothing in UI.menu is changed: the abilities list is found by the table it shows,              |
|   (chargen.ability), so this also works with UI mods that keep that list.                        |
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

ZJAbilityInfo_Private_FontPoint = EEex_Options_Register("ZJAbilityInfo_FontPoint", EEex_Options_Option.new({
	["default"]  = 11,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Ability Info Module: Font Point" }),
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_AbilityInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJAbilityInfo_Enable",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_Enable",
			["description"] = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_Enable_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJAbilityInfo_FontPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_FontPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_AbilityInfo_FontPoint_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"]        = true,
			}),
		}),
	},
} end)

-------------
-- Globals --
-------------

ZJAbilityInfo_Private_Enabled = false
ZJAbilityInfo_Private_ErrorReported = false

-- The engine's abilities screen, (the same name in every Enhanced Edition, and kept by UI mods)
ZJAbilityInfo_Private_MenuName = "CHARGEN_ABILITIES"

ZJAbilityInfo_Private_TitleColorStr  = "^0xFF64D7FF"
ZJAbilityInfo_Private_DimColorStr    = "^0xFFA0A0A0"
ZJAbilityInfo_Private_BetterColorStr = "^0xFF40E040"
ZJAbilityInfo_Private_WorseColorStr  = "^0xFF2B4BFF"
ZJAbilityInfo_Private_ColorEndStr    = "^-"

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

-- The highest score the tables go up to
ZJAbilityInfo_Private_MaxScore = 25

-- RACE.IDS => ABRACERQ.2DA / ABRACEAD.2DA row
ZJAbilityInfo_Private_RaceRows = {
	[1] = "HUMAN",
	[2] = "ELF",
	[3] = "HALF_ELF",
	[4] = "DWARF",
	[5] = "HALFLING",
	[6] = "GNOME",
	[7] = "HALFORC",
}

-- CLASS.IDS values, by what they get from their abilities
ZJAbilityInfo_Private_WarriorClasses = { -- Exceptional strength, and the WARRIOR column of HPCONBON.2DA
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

-- Temporarily changes the enable state of the ability popup.
-- To persist this change, instead modify the "ZJAbilityInfo_Enable" option.
function ZJAbilityInfo_SetEnabled(enabled)
	ZJAbilityInfo_Private_Enabled = enabled
	if not enabled then
		ZJAbilityInfo_Private_Menu_SetOpen(false)
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

-- Returns the class and race, (CLASS.IDS / RACE.IDS), of the character being created, or nil
function ZJAbilityInfo_Private_GetClassAndRace()
	local createChar = EngineGlobals.g_pBaldurChitin.m_pEngineCreateChar
	if createChar == nil then return nil end
	local sprite = EEex_GameObject_Get(createChar.m_nGameSprite)
	if sprite == nil then return nil end
	local typeAI = sprite.m_typeAI
	return typeAI.m_Class, typeAI.m_Race
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

-- The highest score the race can have in `ability` at character creation, (the engine checks the score before the
-- race's adjustment against ABRACERQ.2DA, so e.g. an elf can reach 19 dexterity)
function ZJAbilityInfo_Private_GetRaceMaximum(race, ability)
	local row = ZJAbilityInfo_Private_RaceRows[race]
	if row == nil then return ZJAbilityInfo_Private_MaxScore end
	local maximum = ZJAbilityInfo_Private_Get("ABRACERQ", "MAX_"..ability, row)
	if maximum <= 0 then return ZJAbilityInfo_Private_MaxScore end
	return maximum + ZJAbilityInfo_Private_Get("ABRACEAD", "MOD_"..ability, row)
end

-----------
-- Stats --
-----------

-- Returns what `ability` at `score`, (`extra` = exceptional strength), gives a character of `class`, as a list of
-- { key, label, value, format, lowerIsBetter }, where format is "signed", "plain", "percent", "signedPercent" or "text"
function ZJAbilityInfo_Private_GetStats(ability, score, extra, class)

	local T = ZJAbilityInfo_Private_T
	local get = ZJAbilityInfo_Private_Get
	local stats = {}

	local add = function(key, value, format, lowerIsBetter)
		table.insert(stats, { ["key"] = key, ["label"] = T("Stat_"..key), ["value"] = value, ["format"] = format, ["lowerIsBetter"] = lowerIsBetter })
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

		add("ArmorClass", get("DEXMOD", "AC", score),      "signed", true)
		add("Missile",    get("DEXMOD", "MISSILE", score), "signed")

		for _, skill in ipairs(ZJAbilityInfo_Private_ThiefSkillsByClass[class] or {}) do
			add(skill, get("SKILLDEX", skill, score), "signedPercent")
		end

	elseif ability == "CON" then

		local hitPointsColumn = ZJAbilityInfo_Private_WarriorClasses[class] and "WARRIOR" or "OTHER"
		add("HitPointsPerLevel", get("HPCONBON", hitPointsColumn, score), "signed")
		add("MinimumRoll",       get("HPCONBON", "MIN_ROLL", score),      "plain")
		add("FatigueBonus",      get("HPCONBON", "FATIGUE_BONUS", score), "signed")

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
			add("BonusPriestSpells", counts, "text")
		end
		add("Lore", get("LOREBON", "VALUE", score), "signed")

	elseif ability == "CHR" then

		-- CHRMODST.2DA has a single row, "1", with a column for every score
		add("StorePrices", get("CHRMODST", tostring(score), 1), "signedPercent", true)
	end

	return stats
end

-- Bonus priest spells per level, { 2, 1, 0, ... } => "2/1", (up to the highest level either list has spells at)
function ZJAbilityInfo_Private_FormatSpellCounts(counts, upToLevel)
	local parts = {}
	for level = 1, upToLevel do
		table.insert(parts, tostring(counts[level]))
	end
	return table.concat(parts, "/")
end

function ZJAbilityInfo_Private_HighestSpellLevel(counts)
	for level = 7, 1, -1 do
		if counts[level] ~= 0 then return level end
	end
	return 0
end

function ZJAbilityInfo_Private_FormatValue(value, format)
	if format == "signed"        then return string.format("%+d", value) end
	if format == "percent"       then return string.format("%d%%", value) end
	if format == "signedPercent" then return string.format("%+d%%", value) end
	return tostring(value)
end

function ZJAbilityInfo_Private_ColorChange(text, better)
	return (better and ZJAbilityInfo_Private_BetterColorStr or ZJAbilityInfo_Private_WorseColorStr)..text..ZJAbilityInfo_Private_ColorEndStr
end

-- The lines for the stats that differ between `oldStats` and `newStats`, (both from ZJAbilityInfo_Private_GetStats())
function ZJAbilityInfo_Private_GetChangeLines(oldStats, newStats)

	local lines = {}

	for i, old in ipairs(oldStats) do

		local new = newStats[i]

		if old.format == "text" then

			-- Bonus priest spells
			local upToLevel = math.max(ZJAbilityInfo_Private_HighestSpellLevel(old.value), ZJAbilityInfo_Private_HighestSpellLevel(new.value))
			if upToLevel > 0 then
				local oldText = ZJAbilityInfo_Private_FormatSpellCounts(old.value, upToLevel)
				local newText = ZJAbilityInfo_Private_FormatSpellCounts(new.value, upToLevel)
				if oldText ~= newText then
					table.insert(lines, string.format("%s: %s -> %s", old.label, oldText, ZJAbilityInfo_Private_ColorChange(newText, true)))
				end
			end

		elseif old.value ~= new.value then

			local change = new.value - old.value
			local better = (change < 0) == (old.lowerIsBetter == true)
			local changeFormat = (old.format == "percent" or old.format == "signedPercent") and "signedPercent" or "signed"

			local newText = string.format("%s (%s)", ZJAbilityInfo_Private_FormatValue(new.value, old.format), ZJAbilityInfo_Private_FormatValue(change, changeFormat))

			table.insert(lines, string.format("%s: %s -> %s", old.label, ZJAbilityInfo_Private_FormatValue(old.value, old.format),
				ZJAbilityInfo_Private_ColorChange(newText, better)))
		end
	end

	return lines
end

function ZJAbilityInfo_Private_FormatScore(score, extra)
	if extra > 0 then
		return string.format("%d/%02d", score, extra % 100)
	end
	return tostring(score)
end

-- The popup's text for `ability`, (a key of ZJAbilityInfo_Private_AbilityByLabel's values), shown as `roll`
function ZJAbilityInfo_Private_BuildText(ability, roll, abilityName)

	local T = ZJAbilityInfo_Private_T

	local score, extra = ZJAbilityInfo_Private_ParseRoll(roll)
	if score == nil then return nil end

	local okClass, class, race = pcall(ZJAbilityInfo_Private_GetClassAndRace)
	if not okClass then class, race = nil, nil end

	local maximum = math.min(ZJAbilityInfo_Private_GetRaceMaximum(race, ability), ZJAbilityInfo_Private_MaxScore)

	local parts = {}
	local title = function(text)
		table.insert(parts, ZJAbilityInfo_Private_TitleColorStr..text..ZJAbilityInfo_Private_ColorEndStr)
	end
	local dim = function(text)
		table.insert(parts, ZJAbilityInfo_Private_DimColorStr..text..ZJAbilityInfo_Private_ColorEndStr)
	end

	if score >= maximum then
		title(string.format("%s %s", abilityName, ZJAbilityInfo_Private_FormatScore(score, extra)))
		dim(T("AtMaximum"))
		return table.concat(parts, "\n")
	end

	title(string.format("%s %s -> %d", abilityName, ZJAbilityInfo_Private_FormatScore(score, extra), score + 1))

	-- Most tables only change every few points. If the next point changes nothing, show the first score that does.
	local oldStats = ZJAbilityInfo_Private_GetStats(ability, score, extra, class)
	local changeScore, lines = nil, nil

	for nextScore = score + 1, maximum do
		lines = ZJAbilityInfo_Private_GetChangeLines(oldStats, ZJAbilityInfo_Private_GetStats(ability, nextScore, 0, class))
		if #lines > 0 then
			changeScore = nextScore
			break
		end
	end

	if changeScore == nil then
		dim(T("NoChange"))
		return table.concat(parts, "\n")
	end

	if changeScore > score + 1 then
		dim(string.format(T("NoChangeUntil"), score + 1, changeScore))
	end

	table.insert(parts, table.concat(lines, "\n"))

	-- The tables above don't know the exceptional strength a warrior gets at 18
	if ability == "STR" and ZJAbilityInfo_Private_WarriorClasses[class] and changeScore >= 18 and score < 18 then
		dim(T("ExceptionalStrength"))
	end

	return table.concat(parts, "\n")
end

-----------
-- Popup --
-----------

ZJAbilityInfo_Private_List = nil -- uiItem, the abilities list, found the first time it is needed after the UI loads

-- The list of the abilities screen that shows chargen.ability
function ZJAbilityInfo_Private_GetList()

	if ZJAbilityInfo_Private_List ~= nil then return ZJAbilityInfo_Private_List end
	if type(chargen) ~= "table" or type(chargen.ability) ~= "table" then return nil end

	local menu = EEex_Menu_Find(ZJAbilityInfo_Private_MenuName)
	if menu == nil then return nil end

	local item = menu.items
	while item do
		if item.type == uiItemType.ITEM_LIST and item.list.table ~= 0 then
			local tableFunc = EEex_GetLuaRegistryIndex(item.list.table)
			local ok, listTable = pcall(tableFunc)
			if ok and rawequal(listTable, chargen.ability) then
				ZJAbilityInfo_Private_List = item
				return item
			end
		end
		item = item.next
	end

	return nil
end

-- Returns { ability, roll, name, area } for the row of the abilities list under the cursor, or nil
function ZJAbilityInfo_Private_FindHoveredAbility()

	local listItem = ZJAbilityInfo_Private_GetList()
	if listItem == nil then return nil end

	local rowHeight = listItem.list.rowheight
	if rowHeight <= 0 then return nil end

	local x, y, w, h = listItem:getArea()
	if not EEex_Menu_IsCursorWithinRect(x, y, w, h) then return nil end

	-- The scrollbar moves the rows up by making their top negative
	local _, mouseY = EEex_Menu_GetMousePos()
	local row = math.floor((mouseY - y - listItem.scrollbar.top) / rowHeight) + 1

	local rowEntry = chargen.ability[row]
	if type(rowEntry) ~= "table" then return nil end

	local ability = ZJAbilityInfo_Private_AbilityByLabel[rowEntry.name] or ZJAbilityInfo_Private_AbilityOrder[row]
	if ability == nil then return nil end

	local name = type(rowEntry.name) == "string" and t(rowEntry.name) or ability

	return {
		["ability"] = ability,
		["roll"]    = rowEntry.roll,
		["name"]    = name,
		["area"]    = { x, y + listItem.scrollbar.top + (row - 1) * rowHeight, w, rowHeight },
	}
end

ZJAbilityInfo_Private_Menu_IsOpen   = false
ZJAbilityInfo_Private_Menu_Text     = ""
ZJAbilityInfo_Private_Menu_Key      = nil -- What the popup was last built for
ZJAbilityInfo_Private_Menu_TextItem = nil -- uiItem, the injected text label
ZJAbilityInfo_Private_Menu_Area     = nil -- { x, y, w, h } of the popup, in screen coordinates

-- The popup is drawn by the templates injected into the abilities screen, so opening / closing it is only a flag
function ZJAbilityInfo_Private_Menu_SetOpen(open)
	ZJAbilityInfo_Private_Menu_IsOpen = open
	if not open then
		ZJAbilityInfo_Private_Menu_Key = nil
	end
end

function ZJAbilityInfo_Private_StripColors(text)
	return (text:gsub("%^0x%x%x%x%x%x%x%x%x", ""):gsub("%^%-", ""))
end

-- Places the popup beside the hovered row, inside the abilities screen
function ZJAbilityInfo_Private_Layout(hovered)

	local fontPoint = ZJAbilityInfo_Private_FontPoint:get()
	local style = styles["normal"]

	local pad = 10
	local gap = 8 -- Between the popup and the list
	local wrapWidth = fontPoint * 32

	local text = ZJAbilityInfo_Private_Menu_Text
	local textW, textH = EEex_Menu_GetTextWidthHeight(ZJAbilityInfo_Private_StripColors(text), style.font, fontPoint, style.useFontZoom, wrapWidth)
	textW = math.min(math.ceil(textW), wrapWidth)
	textH = math.ceil(textH)

	local width = textW + pad * 2
	local height = textH + pad * 2

	local textItem = ZJAbilityInfo_Private_Menu_TextItem
	if textItem ~= nil then
		textItem.text.point = fontPoint
	end

	local menuX, menuY, menuW, menuH = EEex_Menu_GetArea(ZJAbilityInfo_Private_MenuName)
	local area = hovered.area

	-- To the right of the list, level with the row. Kept inside the screen, (the menu's items are placed relative to it).
	local x = area[1] + area[3] + gap
	local y = area[2]

	if menuW > 0 and x + width > menuX + menuW then
		x = area[1] - gap - width
	end
	if menuH > 0 then
		y = math.max(menuY, math.min(y, menuY + menuH - height))
	end

	x, y = math.floor(x), math.floor(y)

	ZJAbilityInfo_Private_Menu_Area = { x, y, width, height }
	Infinity_SetArea("ZJAbilityInfo_Menu_Text", x - menuX + pad, y - menuY + pad, wrapWidth, textH)
end

function ZJAbilityInfo_Private_DoTick()

	if not ZJAbilityInfo_Private_Enabled then
		ZJAbilityInfo_Private_Menu_SetOpen(false)
		return
	end

	local hovered = ZJAbilityInfo_Private_FindHoveredAbility()

	if hovered == nil then
		ZJAbilityInfo_Private_Menu_SetOpen(false)
		return
	end

	-- The class can't change on this screen, the score is what changes
	local key = hovered.ability.."|"..tostring(hovered.roll)

	if key ~= ZJAbilityInfo_Private_Menu_Key then
		local text = ZJAbilityInfo_Private_BuildText(hovered.ability, hovered.roll, hovered.name)
		if text == nil then
			ZJAbilityInfo_Private_Menu_SetOpen(false)
			return
		end
		ZJAbilityInfo_Private_Menu_Text = text
		ZJAbilityInfo_Private_Menu_Key = key
	end

	ZJAbilityInfo_Private_Layout(hovered)
	ZJAbilityInfo_Private_Menu_IsOpen = true

	EEex.DrawSlicedRect("ZJAbilityInfo_BackgroundRect", ZJAbilityInfo_Private_Menu_Area, 255 * 0.92)
end

-- The ticker template's "enabled". The engine asks it right before it would draw the template, which is in front of the
-- rest of the abilities screen, so the popup's background is drawn from here, right before the text template.
function ZJAbilityInfo_Private_Tick()

	local ok, err = pcall(ZJAbilityInfo_Private_DoTick)

	if not ok then
		pcall(ZJAbilityInfo_Private_Menu_SetOpen, false)
		-- This runs every frame, don't flood the log
		if not ZJAbilityInfo_Private_ErrorReported then
			ZJAbilityInfo_Private_ErrorReported = true
			print("[Battle Sense] Ability Info: "..tostring(err))
		end
	end

	return false
end

---------------
-- Listeners --
---------------

-- Adds the popup's templates to the end of the abilities screen, so they are drawn in front of it
function ZJAbilityInfo_Private_Inject()

	local menuName = ZJAbilityInfo_Private_MenuName
	local menu = EEex_Menu_Find(menuName)
	if menu == nil then return end

	local inject = function(templateName, x, y, w, h)
		local oldAnimationID = currentAnimationID
		currentAnimationID = 1
		EEex_Menu_InjectTemplate(menuName, templateName, x, y, w, h)
		currentAnimationID = oldAnimationID
	end

	-- The ticker covers the screen, (the engine might skip an item without an area), its "enabled" is always false
	local _, _, menuW, menuH = EEex_Menu_GetUIMenuArea(menu)
	inject("ZJAbilityInfo_Menu_TEMPLATE_Ticker", 0, 0, math.max(menuW, 1), math.max(menuH, 1))
	inject("ZJAbilityInfo_Menu_TEMPLATE_Text", 0, 0, 1, 1)

	-- Gives the text template a name, so Infinity_SetArea() can move it
	EEex_Menu_StoreTemplateInstance(menuName, "ZJAbilityInfo_Menu_TEMPLATE_Text", 1, "ZJAbilityInfo_Menu_Text")
	ZJAbilityInfo_Private_Menu_TextItem = EEex_Menu_GetItem("ZJAbilityInfo_Menu_Text")
end

EEex_Menu_AddMainFileLoadedListener(function()

	EEex_Menu_LoadFile("ZJAblInf")

	ZJAbilityInfo_Private_List = nil
	ZJAbilityInfo_Private_Menu_TextItem = nil
	ZJAbilityInfo_Private_Menu_SetOpen(false)

	ZJAbilityInfo_Private_Inject()
end)

EEex.RegisterSlicedRect("ZJAbilityInfo_BackgroundRect", {
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
