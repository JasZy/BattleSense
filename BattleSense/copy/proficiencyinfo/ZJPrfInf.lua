--[[
+--------------------------------------------------------------------------------------------------+
| ZJProficiencyInfo - What one more proficiency point would do, on the proficiencies screen        |
+--------------------------------------------------------------------------------------------------+
|   Hovering a proficiency on the proficiencies screen, (character creation and level up), or its  |
|   + / - buttons, opens a popup beside it with what one more point in it would change:            |
|                                                                                                  |
|     * A weapon: to-hit and damage bonus and speed factor, (WSPECIAL.2DA, or the class's penalty  |
|       for having no points), and extra attacks per round, (WSPATCK.2DA, at the character's       |
|       level)                                                                                     |
|     * A fighting style: the bonuses of its STYLBONU.2DA row, (damage, to-hit, armor class,       |
|       speed factor, critical hit range)                                                          |
|                                                                                                  |
|   The values come from the game's own tables, so mods that change them are followed.            |
|                                                                                                  |
|   Nothing in UI.menu is changed: the list is found by the table it shows, (chargen.proficiency), |
|   and the popup is injected into the screen as templates, (see ZJPrfInf.menu).                   |
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

ZJProficiencyInfo_Private_FontPoint = EEex_Options_Register("ZJProficiencyInfo_FontPoint", EEex_Options_Option.new({
	["default"]  = 11,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Proficiency Info Module: Font Point" }),
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJProficiencyInfo_Enable",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_Enable",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_Enable_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJProficiencyInfo_FontPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_FontPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_FontPoint_Description",
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

ZJProficiencyInfo_Private_Enabled = false
ZJProficiencyInfo_Private_ErrorReported = false

-- The engine's proficiencies screen, used by both character creation and level up
ZJProficiencyInfo_Private_MenuName = "CHARGEN_PROFICIENCIES"

-- The most points a proficiency can hold, (the five pips on the screen)
ZJProficiencyInfo_Private_MaxPoints = 5

ZJProficiencyInfo_Private_TitleColorStr  = "^0xFF64D7FF"
ZJProficiencyInfo_Private_DimColorStr    = "^0xFFA0A0A0"
ZJProficiencyInfo_Private_BetterColorStr = "^0xFF40E040"
ZJProficiencyInfo_Private_WorseColorStr  = "^0xFF2B4BFF"
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

-- Temporarily changes the enable state of the proficiency popup.
-- To persist this change, instead modify the "ZJProficiencyInfo_Enable" option.
function ZJProficiencyInfo_SetEnabled(enabled)
	ZJProficiencyInfo_Private_Enabled = enabled
	if not enabled then
		ZJProficiencyInfo_Private_Menu_SetOpen(false)
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

	local class = sprite.m_typeAI.m_Class
	local levelIndex = ZJProficiencyInfo_Private_WarriorLevelIndex[class] or 1
	local stats = sprite.m_derivedStats

	local level = stats.m_nLevel1
	if levelIndex == 2 then level = stats.m_nLevel2 end

	return class, level
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
-- { key, label, value, format, lowerIsBetter }, where format is "signed" or "attacks"
function ZJProficiencyInfo_Private_GetStats(id, points, class, level)

	local T = ZJProficiencyInfo_Private_T
	local stats = {}

	local add = function(key, value, format, lowerIsBetter)
		table.insert(stats, { ["key"] = key, ["label"] = T("Stat_"..key), ["value"] = value, ["format"] = format, ["lowerIsBetter"] = lowerIsBetter })
	end

	local style = ZJProficiencyInfo_Private_Styles[id]

	if style ~= nil then

		local row = style.."-"..points
		local get = function(column) return ZJProficiencyInfo_Private_Get("STYLBONU", column, row) end

		-- The THAC0 columns lower THAC0, (a positive number is a penalty), shown here as a to-hit bonus
		add("MainHandToHit",   -get("THAC0_RIGHT"),  "signed")
		add("OffHandToHit",    -get("THAC0_LEFT"),   "signed")
		add("MainHandDamage",  get("DAMAGE_RIGHT"),  "signed")
		add("OffHandDamage",   get("DAMAGE_LEFT"),   "signed")
		add("ArmorClass",      get("AC_BASE"),       "signed", true)
		add("ArmorClassMissile", get("AC_MISSILE"),  "signed", true)
		add("SpeedFactor",     get("SPEED"),         "signed", true)
		add("CriticalRange",   get("CRITICALROLL"),  "signed")

	else

		local hit, damage, speed = 0, 0, 0
		if points == 0 then
			hit = ZJProficiencyInfo_Private_NonProficiencyPenalties[class] or 0
		else
			local row = ZJProficiencyInfo_Private_GetSpecializationRow(points)
			hit, damage, speed = row[1], row[2], row[3]
		end

		add("ToHit",       hit,    "signed")
		add("Damage",      damage, "signed")
		add("SpeedFactor", speed,  "signed", true)

		-- WSPATCK.2DA goes by level, (and holds the extra attacks warriors get from their level), only the difference shows
		local attacks = ZJProficiencyInfo_Private_GetExtraAttacks(points, level)
		if attacks ~= nil then
			add("ExtraAttacks", attacks, "attacks")
			stats[#stats].label = string.format(stats[#stats].label, level)
		end
	end

	return stats
end

function ZJProficiencyInfo_Private_FormatValue(value, format)
	if format == "attacks" then return ZJProficiencyInfo_Private_FormatHalfAttacks(value) end
	return string.format("%+d", value)
end

function ZJProficiencyInfo_Private_ColorChange(text, better)
	return (better and ZJProficiencyInfo_Private_BetterColorStr or ZJProficiencyInfo_Private_WorseColorStr)..text..ZJProficiencyInfo_Private_ColorEndStr
end

-- The lines for the stats that differ between `oldStats` and `newStats`, (both from ZJProficiencyInfo_Private_GetStats())
function ZJProficiencyInfo_Private_GetChangeLines(oldStats, newStats)

	local lines = {}

	for i, old in ipairs(oldStats) do

		local new = newStats[i]

		if new ~= nil and old.value ~= new.value then

			local change = new.value - old.value
			local better = (change < 0) == (old.lowerIsBetter == true)

			local newText = string.format("%s (%s)", ZJProficiencyInfo_Private_FormatValue(new.value, old.format),
				ZJProficiencyInfo_Private_FormatValue(change, old.format))

			table.insert(lines, string.format("%s: %s -> %s", old.label, ZJProficiencyInfo_Private_FormatValue(old.value, old.format),
				ZJProficiencyInfo_Private_ColorChange(newText, better)))
		end
	end

	return lines
end

-- Whether the screen's own + button of `row` would add a point, (the engine provides plusButtonClickable()), or nil if
-- that can't be told
function ZJProficiencyInfo_Private_CanAddPoint(row)
	if type(plusButtonClickable) ~= "function" then return nil end
	local ok, clickable = pcall(plusButtonClickable, row)
	if not ok then return nil end
	return clickable == true
end

-- The popup's text for the proficiency in row `row` of chargen.proficiency
function ZJProficiencyInfo_Private_BuildText(row, rowEntry)

	local T = ZJProficiencyInfo_Private_T

	local id = tonumber(rowEntry.id)
	local points = tonumber(rowEntry.value)
	if id == nil or points == nil then return nil end

	local name = ""
	if type(rowEntry.name) == "number" then
		local ok, str = pcall(Infinity_FetchString, rowEntry.name)
		if ok and type(str) == "string" then name = str end
	end

	local okClass, class, level = pcall(ZJProficiencyInfo_Private_GetClassAndLevel)
	if not okClass then class, level = nil, nil end

	local parts = {}
	local title = function(text)
		table.insert(parts, ZJProficiencyInfo_Private_TitleColorStr..text..ZJProficiencyInfo_Private_ColorEndStr)
	end
	local dim = function(text)
		table.insert(parts, ZJProficiencyInfo_Private_DimColorStr..text..ZJProficiencyInfo_Private_ColorEndStr)
	end

	if points >= ZJProficiencyInfo_Private_MaxPoints then
		title(string.format(T("Title"), name, points))
		dim(T("AtMaximum"))
		return table.concat(parts, "\n")
	end

	title(string.format(T("TitleChange"), name, points, points + 1))

	local lines = ZJProficiencyInfo_Private_GetChangeLines(
		ZJProficiencyInfo_Private_GetStats(id, points, class, level),
		ZJProficiencyInfo_Private_GetStats(id, points + 1, class, level))

	if #lines == 0 then
		dim(T("NoChange"))
	else
		table.insert(parts, table.concat(lines, "\n"))
	end

	-- The screen greys out the + button when no point can go here, say why if it is the points
	if ZJProficiencyInfo_Private_CanAddPoint(row) == false then
		local slots = type(chargen) == "table" and tonumber(chargen.extraProficiencySlots) or nil
		dim(slots == 0 and T("NoPointsLeft") or T("NotAllowed"))
	end

	return table.concat(parts, "\n")
end

-----------
-- Popup --
-----------

ZJProficiencyInfo_Private_List = nil -- uiItem, the proficiencies list, found the first time it is needed after the UI loads

-- The list of the proficiencies screen that shows chargen.proficiency
function ZJProficiencyInfo_Private_GetList()

	if ZJProficiencyInfo_Private_List ~= nil then return ZJProficiencyInfo_Private_List end
	if type(chargen) ~= "table" or type(chargen.proficiency) ~= "table" then return nil end

	local menu = EEex_Menu_Find(ZJProficiencyInfo_Private_MenuName)
	if menu == nil then return nil end

	local item = menu.items
	while item do
		if item.type == uiItemType.ITEM_LIST and item.list.table ~= 0 then
			local tableFunc = EEex_GetLuaRegistryIndex(item.list.table)
			local ok, listTable = pcall(tableFunc)
			if ok and rawequal(listTable, chargen.proficiency) then
				ZJProficiencyInfo_Private_List = item
				return item
			end
		end
		item = item.next
	end

	return nil
end

-- Returns { row, entry, area } for the row of the proficiencies list under the cursor, or nil
function ZJProficiencyInfo_Private_FindHoveredProficiency()

	local listItem = ZJProficiencyInfo_Private_GetList()
	if listItem == nil then return nil end

	-- The engine replaces chargen.proficiency when the screen opens, the list keeps showing the new table
	local tableFunc = EEex_GetLuaRegistryIndex(listItem.list.table)
	local ok, listTable = pcall(tableFunc)
	if not ok or type(listTable) ~= "table" then return nil end

	local rowHeight = listItem.list.rowheight
	if rowHeight <= 0 then return nil end

	local x, y, w, h = listItem:getArea()
	if not EEex_Menu_IsCursorWithinRect(x, y, w, h) then return nil end

	-- The scrollbar moves the rows up by making their top negative
	local _, mouseY = EEex_Menu_GetMousePos()
	local row = math.floor((mouseY - y - listItem.scrollbar.top) / rowHeight) + 1

	local rowEntry = listTable[row]
	if type(rowEntry) ~= "table" or rowEntry.id == nil then return nil end

	return {
		["row"]   = row,
		["entry"] = rowEntry,
		["area"]  = { x, y + listItem.scrollbar.top + (row - 1) * rowHeight, w, rowHeight },
	}
end

ZJProficiencyInfo_Private_Menu_IsOpen   = false
ZJProficiencyInfo_Private_Menu_Text     = ""
ZJProficiencyInfo_Private_Menu_Key      = nil -- What the popup was last built for
ZJProficiencyInfo_Private_Menu_TextItem = nil -- uiItem, the injected text label
ZJProficiencyInfo_Private_Menu_Area     = nil -- { x, y, w, h } of the popup, in screen coordinates

-- The popup is drawn by the templates injected into the proficiencies screen, so opening / closing it is only a flag
function ZJProficiencyInfo_Private_Menu_SetOpen(open)
	ZJProficiencyInfo_Private_Menu_IsOpen = open
	if not open then
		ZJProficiencyInfo_Private_Menu_Key = nil
	end
end

function ZJProficiencyInfo_Private_StripColors(text)
	return (text:gsub("%^0x%x%x%x%x%x%x%x%x", ""):gsub("%^%-", ""))
end

-- Places the popup beside the hovered row, inside the proficiencies screen
function ZJProficiencyInfo_Private_Layout(hovered)

	local fontPoint = ZJProficiencyInfo_Private_FontPoint:get()
	local style = styles["normal"]

	local pad = 10
	local gap = 8 -- Between the popup and the list
	local wrapWidth = fontPoint * 32

	local text = ZJProficiencyInfo_Private_Menu_Text
	local textW, textH = EEex_Menu_GetTextWidthHeight(ZJProficiencyInfo_Private_StripColors(text), style.font, fontPoint, style.useFontZoom, wrapWidth)
	textW = math.min(math.ceil(textW), wrapWidth)
	textH = math.ceil(textH)

	local width = textW + pad * 2
	local height = textH + pad * 2

	local textItem = ZJProficiencyInfo_Private_Menu_TextItem
	if textItem ~= nil then
		textItem.text.point = fontPoint
	end

	local menuX, menuY, menuW, menuH = EEex_Menu_GetArea(ZJProficiencyInfo_Private_MenuName)
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

	ZJProficiencyInfo_Private_Menu_Area = { x, y, width, height }
	Infinity_SetArea("ZJProficiencyInfo_Menu_Text", x - menuX + pad, y - menuY + pad, wrapWidth, textH)
end

function ZJProficiencyInfo_Private_DoTick()

	if not ZJProficiencyInfo_Private_Enabled then
		ZJProficiencyInfo_Private_Menu_SetOpen(false)
		return
	end

	local hovered = ZJProficiencyInfo_Private_FindHoveredProficiency()

	if hovered == nil then
		ZJProficiencyInfo_Private_Menu_SetOpen(false)
		return
	end

	-- Points spent elsewhere can grey out this row's + button, so the points left are part of what the text is built for
	local slots = type(chargen) == "table" and tostring(chargen.extraProficiencySlots) or ""
	local key = string.format("%d|%s|%s|%s", hovered.row, tostring(hovered.entry.id), tostring(hovered.entry.value), slots)

	if key ~= ZJProficiencyInfo_Private_Menu_Key then
		local text = ZJProficiencyInfo_Private_BuildText(hovered.row, hovered.entry)
		if text == nil then
			ZJProficiencyInfo_Private_Menu_SetOpen(false)
			return
		end
		ZJProficiencyInfo_Private_Menu_Text = text
		ZJProficiencyInfo_Private_Menu_Key = key
	end

	ZJProficiencyInfo_Private_Layout(hovered)
	ZJProficiencyInfo_Private_Menu_IsOpen = true

	EEex.DrawSlicedRect("ZJProficiencyInfo_BackgroundRect", ZJProficiencyInfo_Private_Menu_Area, 255 * 0.92)
end

-- The ticker template's "enabled". The engine asks it right before it would draw the template, which is in front of the
-- rest of the proficiencies screen, so the popup's background is drawn from here, right before the text template.
function ZJProficiencyInfo_Private_Tick()

	local ok, err = pcall(ZJProficiencyInfo_Private_DoTick)

	if not ok then
		pcall(ZJProficiencyInfo_Private_Menu_SetOpen, false)
		-- This runs every frame, don't flood the log
		if not ZJProficiencyInfo_Private_ErrorReported then
			ZJProficiencyInfo_Private_ErrorReported = true
			print("[Battle Sense] Proficiency Info: "..tostring(err))
		end
	end

	return false
end

---------------
-- Listeners --
---------------

-- Adds the popup's templates to the end of the proficiencies screen, so they are drawn in front of it. A menu pushed on
-- top of the screen would be closed by its Done / Back buttons, (a bare Infinity_PopMenu()), in place of the screen.
function ZJProficiencyInfo_Private_Inject()

	local menuName = ZJProficiencyInfo_Private_MenuName
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
	inject("ZJProficiencyInfo_Menu_TEMPLATE_Ticker", 0, 0, math.max(menuW, 1), math.max(menuH, 1))
	inject("ZJProficiencyInfo_Menu_TEMPLATE_Text", 0, 0, 1, 1)

	-- Gives the text template a name, so Infinity_SetArea() can move it
	EEex_Menu_StoreTemplateInstance(menuName, "ZJProficiencyInfo_Menu_TEMPLATE_Text", 1, "ZJProficiencyInfo_Menu_Text")
	ZJProficiencyInfo_Private_Menu_TextItem = EEex_Menu_GetItem("ZJProficiencyInfo_Menu_Text")
end

EEex_Menu_AddMainFileLoadedListener(function()

	EEex_Menu_LoadFile("ZJPrfInf")

	ZJProficiencyInfo_Private_List = nil
	ZJProficiencyInfo_Private_Menu_TextItem = nil
	ZJProficiencyInfo_Private_Menu_SetOpen(false)

	ZJProficiencyInfo_Private_Inject()
end)

EEex.RegisterSlicedRect("ZJProficiencyInfo_BackgroundRect", {
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
