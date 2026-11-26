--[[
+--------------------------------------------------------------------------------------------------+
| ZJPopup - The popup of the modules                                                               |
+--------------------------------------------------------------------------------------------------+
|   Battle Sense has one popup, and one key that opens it, (the "Popup Key": left / right Ctrl,    |
|   Alt or Shift, in the "Battle Sense Modules" tab). While the key is held, the modules are asked |
|   in order of priority whether they have something to say about what is under the cursor, and   |
|   the first one that does fills the popup with its panel. If none does, there is no popup.       |
|                                                                                                  |
|   Modules add a panel with ZJPopup_AddPanel(): a text panel is shown in the popup's box of text  |
|   beside the cursor, (ZJPopup.menu), a panel that draws itself opens a menu of its own.          |
|                                                                                                  |
|   Toward the player these stay separate modules: each has its own on / off switch in the        |
|   "Battle Sense Modules" tab, and its own tab for its panel's settings.                          |
+--------------------------------------------------------------------------------------------------+
--]]

-- Loaded by the startup file and by every module that has a popup, only the first one does anything
if ZJPopup_Loaded then return end
ZJPopup_Loaded = true

-- The cycle widget the "Popup Key" button is built on
Infinity_DoFile("ZJBarCol")

---------
-- Key --
---------

-- [option value] = The key that has to be held
ZJPopup_OpenOnKeys = {
	{ ["name"] = "ZJBattleSense_TRANSLATION_OpenOn_LeftCtrl",   ["key"] = 0x400000E0 }, -- SDLK_LCTRL
	{ ["name"] = "ZJBattleSense_TRANSLATION_OpenOn_LeftAlt",    ["key"] = 0x400000E2 }, -- SDLK_LALT
	{ ["name"] = "ZJBattleSense_TRANSLATION_OpenOn_LeftShift",  ["key"] = 0x400000E1 }, -- SDLK_LSHIFT
	{ ["name"] = "ZJBattleSense_TRANSLATION_OpenOn_RightCtrl",  ["key"] = 0x400000E4 }, -- SDLK_RCTRL
	{ ["name"] = "ZJBattleSense_TRANSLATION_OpenOn_RightAlt",   ["key"] = 0x400000E6 }, -- SDLK_RALT
	{ ["name"] = "ZJBattleSense_TRANSLATION_OpenOn_RightShift", ["key"] = 0x400000E5 }, -- SDLK_RSHIFT
}

ZJPopup_OpenOnDefault = 1 -- Left Ctrl

ZJPopup_OpenOnSection = "Battle Sense"
ZJPopup_KeyStorageKey = "Popup Key"
ZJPopup_KeyOptionID = "ZJPopup_Key"

ZJPopup_Private_Key = nil -- The "Popup Key" option, see ZJPopup_RegisterKey()

-- Registers the "Popup Key" option. Called by the startup file once the old settings have been moved over, (see
-- ZJPopup_MigrateSwitch()), before the modules are loaded.
function ZJPopup_RegisterKey()
	if ZJPopup_Private_Key ~= nil then return end
	ZJPopup_Private_Key = EEex_Options_Register(ZJPopup_KeyOptionID, EEex_Options_Option.new({
		["default"]  = ZJPopup_OpenOnDefault,
		["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = #ZJPopup_OpenOnKeys }),
		["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = ZJPopup_OpenOnSection, ["key"] = ZJPopup_KeyStorageKey }),
	}))
end

-- Whether the "Popup Key" is held down
function ZJPopup_IsKeyDown()
	local value = ZJPopup_Private_Key ~= nil and ZJPopup_Private_Key:get() or ZJPopup_OpenOnDefault
	local entry = ZJPopup_OpenOnKeys[value] or ZJPopup_OpenOnKeys[ZJPopup_OpenOnDefault]
	return EEex_Key_IsDown(entry.key) == true
end

-- The on / off switch of a module with a popup, shown in the "Battle Sense Modules" tab, (M_ZJBSen.lua). `storageKey`
-- is its key in the options file, `fields` any more fields of the option, (onChange, requiresRestart).
function ZJPopup_NewSwitch(storageKey, fields)
	local option = {
		["default"]  = 1,
		["type"]     = EEex_Options_ToggleType.new(),
		["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
		["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = ZJPopup_OpenOnSection, ["key"] = storageKey }),
	}
	for field, value in pairs(fields or {}) do
		option[field] = value
	end
	return EEex_Options_Option.new(option)
end

-- Whether the popup of a module with the switch `option` may be open now: the module is on and the "Popup Key" is held
function ZJPopup_IsOpenAllowed(option)
	return option:get() ~= 0 and ZJPopup_IsKeyDown()
end

-- Moves the older settings of a popup module's switch, (stored under `storageKey`), over to the "Popup Key". Called for
-- every installed popup module, in the order they start, before the switches and the "Popup Key" are registered:
--
--   * Up to v0.1.0 the switch was on / off, (1 / 0), with the key in a separate "Open On" option, (stored under
--     `oldOpenOnKey`, never 0). That option is set to 0 once it has been read.
--   * After that, (commit 911ecb0), the switch was the key itself: 0 = Off, 1 - 6 = the key. A key above 1 becomes On.
--
-- The first module that is on and had a key gives the "Popup Key", if it wasn't stored yet.
function ZJPopup_MigrateSwitch(storageKey, oldOpenOnKey)

	local section = ZJPopup_OpenOnSection
	local read = function(key) return tonumber(Infinity_GetINIString(section, key, "X-DEFAULT")) end

	local switch = read(storageKey)
	local openOn = oldOpenOnKey ~= nil and read(oldOpenOnKey) or nil
	local key = nil

	if openOn ~= nil and openOn >= 1 then
		key = openOn
		Infinity_SetINIValue(section, oldOpenOnKey, 0)
	elseif switch ~= nil and switch >= 1 then
		key = switch
	end

	if switch ~= nil and switch > 1 then
		Infinity_SetINIValue(section, storageKey, 1)
	end

	if key ~= nil and switch ~= 0 and read(ZJPopup_KeyStorageKey) == nil then
		Infinity_SetINIValue(section, ZJPopup_KeyStorageKey, math.max(1, math.min(math.floor(key), #ZJPopup_OpenOnKeys)))
	end
end

-- A button that shows the name of the key, clicking it steps to the next one
ZJPopup_OpenOnWidget = {}
ZJPopup_OpenOnWidget.__index = ZJPopup_OpenOnWidget
setmetatable(ZJPopup_OpenOnWidget, ZJBarColors_CycleWidget)

ZJPopup_OpenOnWidget.new = function(o)
	if o == nil then o = {} end
	setmetatable(o, ZJPopup_OpenOnWidget)
	o:_init()
	return o
end

function ZJPopup_OpenOnWidget:_getCount()
	return #ZJPopup_OpenOnKeys
end

function ZJPopup_OpenOnWidget:_getMin()
	return 1
end

function ZJPopup_OpenOnWidget:_getText(value)
	local entry = ZJPopup_OpenOnKeys[value] or ZJPopup_OpenOnKeys[ZJPopup_OpenOnDefault]
	return getUiString(entry.name)
end

function ZJPopup_OpenOnWidget:_getColor(value)
	return EEex_Options_Private_GetFontStyleColor(styles["EEex_Options_Normal"])
end

-- The "Popup Key" entry of the "Battle Sense Modules" tab
function ZJPopup_KeyDisplayEntry()
	return EEex_Options_DisplayEntry.new({
		["optionID"]    = ZJPopup_KeyOptionID,
		["label"]       = "ZJBattleSense_Options_TRANSLATION_PopupKey",
		["description"] = "ZJBattleSense_Options_TRANSLATION_PopupKey_Description",
		["widget"]      = ZJPopup_OpenOnWidget.new(),
	})
end


-----------
-- Popup --
-----------

-- The panels of the modules, in order of priority, (see ZJPopup_AddPanel())
ZJPopup_Private_Panels = {}

-- Adds a module's panel to the popup. While the "Popup Key" is held, the panels are asked every frame in order of
-- priority, and the first one that has something to say about what is under the cursor shows; the rest aren't asked.
-- `panel` is a table:
--
--   "name"         - The module's name, (for ZJPopup_GetCursorPanel() and error messages).
--   "priority"     - Lower is asked first. Item Info = 5, (an item on the screen, on top of the game world), Spell
--                    Info = 10, (a spell waiting for a target, over a creature), Creature Info = 20, (a creature), Lock
--                    Info = 30, (a container, door or trap), Ability Info = 40 and Proficiency Info = 50, (a row of
--                    their character creation screen).
--
-- A text panel, shown in the popup's box of text:
--
--   "getText"      - function() returning the text of the panel for what is under the cursor, or nil if the module
--                    has nothing to say about it. The box goes beside the cursor, with its top at the top of the
--                    cursor. A second value can place it otherwise: a number puts its top at that height, (in menu
--                    coordinates, the hovered row of a list), { ["above"] = { x, y, w, h } } centers it above that area,
--                    (or below it if there is no room above, an action bar button).
--   "getFontPoint" - function() returning the size of the text, (optional).
--   "getOpacity"   - function() returning the background's opacity in percent, (optional).
--   "wrap"         - true to wrap the text at a width that follows the size of the text, (optional, otherwise the box
--                    is as wide as the longest line).
--
-- A panel that draws itself, in a menu of its own, (Creature Info):
--
--   "show"         - function() that lays out and opens the module's menu and returns true, or returns false if the
--                    module has nothing to say about what is under the cursor.
--   "hide"         - function() that closes the module's menu. Called every frame that the panel doesn't show, (another
--                    panel does, or the key isn't held), so it must be cheap when the menu is already closed.
--
-- The popup is updated by its ticker menu, which is open while a game is running. Screens that may close it, (the
-- character creation screens), also call ZJPopup_Tick() themselves, every frame they are drawn.
function ZJPopup_AddPanel(panel)
	table.insert(ZJPopup_Private_Panels, panel)
	table.sort(ZJPopup_Private_Panels, function(a, b) return a.priority < b.priority end)
end

ZJPopup_Private_IsOpen      = false
ZJPopup_Private_Text        = ""
ZJPopup_Private_TextUD      = nil -- uiItem
ZJPopup_Private_FontPoint   = 11  -- Used if the panel doesn't give one
ZJPopup_Private_Opacity     = 85  -- The background's opacity in percent, used if the panel doesn't give one
ZJPopup_Private_ShownOpacity = ZJPopup_Private_Opacity
ZJPopup_Private_ShownFrame  = -1  -- The frame the box was last laid out in
ZJPopup_Private_ErrorShown  = {}  -- [panel name] = true once its error was reported

ZJPopup_Private_ChoiceFrame = -1  -- The frame the choice below was made in
ZJPopup_Private_Choice      = nil -- { panel, text, y }, or nil if no panel shows

-- Reports an error of a panel, once, (this runs every frame, don't flood the log)
function ZJPopup_Private_ReportError(name, err)
	if not ZJPopup_Private_ErrorShown[name] then
		ZJPopup_Private_ErrorShown[name] = true
		print("[Battle Sense] "..tostring(name)..": "..tostring(err))
	end
end

-- Asks `panel` whether it has something to say: returns nil, or { panel, text, y }, (text and y for a text panel)
function ZJPopup_Private_Ask(panel)
	if panel.getText ~= nil then
		local ok, text, y = pcall(panel.getText)
		if not ok then
			ZJPopup_Private_ReportError(panel.name, text)
			return nil
		end
		return text ~= nil and { ["panel"] = panel, ["text"] = text, ["y"] = y } or nil
	end
	local ok, shows = pcall(panel.show)
	if not ok then
		ZJPopup_Private_ReportError(panel.name, shows)
		return nil
	end
	return shows == true and { ["panel"] = panel } or nil
end

-- The first panel, (in order of priority), with something to say, or nil. The panels that draw themselves and don't
-- show this frame are told to close.
function ZJPopup_Private_Choose()

	local choice = nil

	if ZJPopup_IsKeyDown() then
		for _, panel in ipairs(ZJPopup_Private_Panels) do
			choice = ZJPopup_Private_Ask(panel)
			if choice ~= nil then break end
		end
	end

	local chosen = choice and choice.panel
	for _, panel in ipairs(ZJPopup_Private_Panels) do
		if panel ~= chosen and panel.hide ~= nil then
			local ok, err = pcall(panel.hide)
			if not ok then ZJPopup_Private_ReportError(panel.name, err) end
		end
	end

	return choice
end

-- ZJPopup_Private_Choose(), worked out at most once per frame, so every caller gets the same answer whichever menu or
-- screen asks first
function ZJPopup_Private_GetChoice()
	local frame = Infinity_GetFrameCounter()
	if frame ~= ZJPopup_Private_ChoiceFrame then
		ZJPopup_Private_ChoiceFrame = frame
		ZJPopup_Private_Choice = ZJPopup_Private_Choose()
	end
	return ZJPopup_Private_Choice
end

-- The name of the module whose panel the popup shows this frame, or nil
function ZJPopup_GetCursorPanel()
	local choice = ZJPopup_Private_GetChoice()
	return choice and choice.panel.name
end

-- Whether the box was laid out in this frame or the one before. Whatever updates it does so every frame, so once that
-- stops, (its screen is gone), the box stops drawing, even before anything closed it.
function ZJPopup_Private_IsFresh()
	return Infinity_GetFrameCounter() - ZJPopup_Private_ShownFrame <= 1
end

function ZJPopup_Private_StripColors(text)
	return (text:gsub("%^0x%x%x%x%x%x%x%x%x", ""):gsub("%^%-", ""))
end

-- The row of the list on the menu `menuName` that shows the Lua table `listTable`, which is under the cursor. Returns
-- the row number and its area, (x, y, w, h), or nil.
function ZJPopup_FindHoveredRow(menuName, listTable)

	if type(listTable) ~= "table" or not Infinity_IsMenuOnStack(menuName) then return nil end

	local menu = EEex_Menu_Find(menuName)
	if menu == nil then return nil end

	local item = menu.items
	while item do

		if item.type == uiItemType.ITEM_LIST and item.list.table ~= 0 and item.list.rowheight > 0 then

			local ok, itemTable = pcall(EEex_GetLuaRegistryIndex(item.list.table))

			if ok and rawequal(itemTable, listTable) then

				local x, y, w, h = item:getArea()
				if not EEex_Menu_IsCursorWithinRect(x, y, w, h) then return nil end

				-- The scrollbar moves the rows up by making their top negative
				local okTop, scrollTop = pcall(function() return item.scrollbar.top end)
				if not okTop or type(scrollTop) ~= "number" then scrollTop = 0 end

				local _, mouseY = EEex_Menu_GetMousePos()
				local rowHeight = item.list.rowheight
				local row = math.floor((mouseY - y - scrollTop) / rowHeight) + 1
				if listTable[row] == nil then return nil end

				return row, x, y + scrollTop + (row - 1) * rowHeight, w, rowHeight
			end
		end

		item = item.next
	end

	return nil
end


-- The cursor's hotspot and size, (in menu coordinates), so the popup can go beside the cursor image
function ZJPopup_GetCursorRenderData()

	local vidMode = EngineGlobals.g_pBaldurChitin.cVideo.pCurrentMode
	local cursorCell = vidMode.pPointerVidCell
	if cursorCell == nil then return end

	local centerX, centerY = cursorCell:GetCurrentCenterPoint()
	local w, h = cursorCell:GetCurrentFrameSize()
	return EEex_Menu_ScaleX(centerX), EEex_Menu_ScaleY(centerY), EEex_Menu_ScaleX(w), EEex_Menu_ScaleY(h)
end

-- Lays out the box of `choice`, (a text panel): beside the cursor image, with its top at the top of the cursor, or at
-- the height the panel gave, or above the area the panel gave
function ZJPopup_Private_Layout(choice)

	local panel = choice.panel
	local fontPoint = panel.getFontPoint ~= nil and panel.getFontPoint() or ZJPopup_Private_FontPoint
	local style = styles["normal"]
	local text = choice.text
	local plainText = ZJPopup_Private_StripColors(text)

	ZJPopup_Private_Text = text
	ZJPopup_Private_ShownOpacity = panel.getOpacity ~= nil and panel.getOpacity() or ZJPopup_Private_Opacity
	if ZJPopup_Private_TextUD ~= nil then
		ZJPopup_Private_TextUD.text.point = fontPoint
	end

	local textW = 0
	for line in (plainText.."\n"):gmatch("(.-)\n") do
		textW = math.max(textW, (EEex_Menu_GetTextWidthHeight(line, style.font, fontPoint, style.useFontZoom)))
	end
	if panel.wrap then
		textW = math.min(textW, fontPoint * 32)
	end
	textW = math.ceil(textW) + 2 -- Room for rounding, so the engine doesn't wrap a line that just fits

	local _, textH = EEex_Menu_GetTextWidthHeight(plainText, style.font, fontPoint, style.useFontZoom, textW)
	textH = math.ceil(textH)

	local pad = 12
	local backgroundW = textW + pad * 2
	local backgroundH = textH + pad * 2

	local cursorX, cursorY = EEex_Menu_GetMousePos()
	local cursorCenterX, cursorCenterY, cursorW = ZJPopup_GetCursorRenderData()
	cursorCenterX, cursorCenterY, cursorW = cursorCenterX or 0, cursorCenterY or 0, cursorW or 0

	local cursorRenderX = cursorX - cursorCenterX
	local screenW, screenH = Infinity_GetScreenSize()
	local where = choice.y
	local backgroundX, backgroundY

	if type(where) == "table" and type(where.above) == "table" then

		local gap = 8
		local areaX, areaY, areaW, areaH = where.above[1], where.above[2], where.above[3], where.above[4]

		backgroundX = areaX + areaW / 2 - backgroundW / 2
		backgroundY = areaY - gap - backgroundH
		if backgroundY < 0 then
			backgroundY = areaY + areaH + gap
		end
	else
		backgroundX = cursorRenderX + cursorW + 5
		backgroundY = type(where) == "number" and where or (cursorY - cursorCenterY)

		if backgroundX + backgroundW > screenW then
			backgroundX = cursorRenderX - backgroundW - 5
		end
	end
	backgroundX = math.max(0, math.min(backgroundX, screenW - backgroundW))
	backgroundY = math.max(0, math.min(backgroundY, screenH - backgroundH))

	Infinity_SetOffset("ZJPopup_Cursor", math.floor(backgroundX), math.floor(backgroundY))
	Infinity_SetArea("ZJPopup_Cursor_Background", 0, 0, backgroundW, backgroundH)
	Infinity_SetArea("ZJPopup_Cursor_Text", pad, pad, textW, textH)

	ZJPopup_Private_ShownFrame = Infinity_GetFrameCounter()
end

function ZJPopup_Private_SetOpen(open)
	if open then
		if not ZJPopup_Private_IsOpen then
			Infinity_PushMenu("ZJPopup_Cursor")
			ZJPopup_Private_IsOpen = true
		end
	elseif ZJPopup_Private_IsOpen then
		ZJPopup_Private_IsOpen = false
		ZJPopup_Private_ShownFrame = -1
		Infinity_PopMenu("ZJPopup_Cursor")
	end
end

-- Whether the popup's box of text is showing
function ZJPopup_IsCursorPopupOpen()
	return ZJPopup_Private_IsOpen
end

-- Closes the popup's box of text, (a screen with a text panel that closes, before the next update)
function ZJPopup_Close()
	ZJPopup_Private_SetOpen(false)
end

function ZJPopup_Private_DoTick()

	local choice = ZJPopup_Private_GetChoice()

	-- The box of text is only for text panels, a panel that draws itself has opened its own menu
	if choice == nil or choice.panel.getText == nil then
		ZJPopup_Private_SetOpen(false)
		return
	end

	ZJPopup_Private_SetOpen(true)
	ZJPopup_Private_Layout(choice)
end

-- Updates the popup: asks the panels, (at most once per frame), and opens, lays out or closes the box. Called every
-- frame by the ticker menu, and by the screens that may close the ticker, (any number of times per frame).
function ZJPopup_Tick()
	local ok, err = pcall(ZJPopup_Private_DoTick)
	if not ok then
		pcall(ZJPopup_Private_SetOpen, false)
		ZJPopup_Private_ReportError("Popup", err)
	end
end

-- Opens the ticker, (if a module added a panel). It is opened when a game starts; a module whose screens may have closed
-- it, (Item Info: the inventory, stores, the quick loot bar), opens it again when those screens open.
function ZJPopup_PushTicker()
	if ZJPopup_Private_Panels[1] == nil then return end
	if not Infinity_IsMenuOnStack("ZJPopup_Cursor_Ticker") then
		Infinity_PushMenu("ZJPopup_Cursor_Ticker")
	end
end

-- UI.menu often closes its screen with Infinity_PopMenu() without a name, which closes the menu on top. While the box
-- is open over that screen, that would close the box instead and leave the screen open, so the box is closed first.
EEex_Utility_NewScope(function()
	local popMenu = Infinity_PopMenu
	if type(popMenu) ~= "function" then return end
	Infinity_PopMenu = function(...)
		if select("#", ...) == 0 and ZJPopup_Private_IsOpen then
			pcall(ZJPopup_Private_SetOpen, false)
		end
		return popMenu(...)
	end
end)

EEex_Menu_AddMainFileLoadedListener(function()
	EEex_Menu_LoadFile("ZJPopup")
	ZJPopup_Private_IsOpen = false
	ZJPopup_Private_ShownFrame = -1
	ZJPopup_Private_TextUD = EEex_Menu_GetItem("ZJPopup_Cursor_Text")
end)

EEex_GameState_AddInitializedListener(ZJPopup_PushTicker)
EEex_Menu_AddAfterMainFileReloadedListener(ZJPopup_PushTicker)

EEex.RegisterSlicedRect("ZJPopup_BackgroundRect", {
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

EEex_Menu_AddBeforeUIItemRenderListener("ZJPopup_Cursor_Background", function(item)
	EEex.DrawSlicedRect("ZJPopup_BackgroundRect", { item:getArea() }, math.floor(255 * ZJPopup_Private_ShownOpacity / 100))
end)

-- A creature's own tooltip would sit under the popup
EEex_Utility_NewScope(function()
	local old = EEex_Sprite_Hook_CheckSuppressTooltip
	EEex_Sprite_Hook_CheckSuppressTooltip = function()
		return ZJPopup_Private_IsOpen or old()
	end
end)
