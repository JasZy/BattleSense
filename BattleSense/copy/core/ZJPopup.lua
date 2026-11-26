--[[
+--------------------------------------------------------------------------------------------------+
| ZJPopup - What the popups of the modules share                                                   |
+--------------------------------------------------------------------------------------------------+
|   * The switch: a popup only opens while its key is held, (left / right Ctrl, Alt or Shift),     |
|     with the cursor over what it describes. The key is also the module's on / off switch, the    |
|     "Battle Sense Modules" tab shows it as a button with "Off" or the key's name.                |
|                                                                                                  |
|   * The screen popup, (ZJPopup.menu): a box of text beside the cursor, for the modules that      |
|     describe a row of a list on a full screen menu, (the abilities and proficiencies screens).   |
+--------------------------------------------------------------------------------------------------+
--]]

-- Loaded by every module that has a popup, only the first one does anything
if ZJPopup_Loaded then return end
ZJPopup_Loaded = true

-- The cycle widget the "Open On" button is built on
Infinity_DoFile("ZJBarCol")

-------------
-- Open On --
-------------

-- [option value] = The key that has to be held, (0 = Off, see ZJPopup_NewSwitch())
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

-- A popup module's switch is also its "Open On" key: 0 = Off, (the module is switched off), otherwise the key that has
-- to be held, ([option value] of ZJPopup_OpenOnKeys). It is shown in the "Battle Sense Modules" tab, (M_ZJBSen.lua).
-- `storageKey` is its key in the options file, `fields` any more fields of the option, (onChange, requiresRestart).
function ZJPopup_NewSwitch(storageKey, fields)
	local option = {
		["default"]  = ZJPopup_OpenOnDefault,
		["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = #ZJPopup_OpenOnKeys }),
		["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = ZJPopup_OpenOnSection, ["key"] = storageKey }),
	}
	for field, value in pairs(fields or {}) do
		option[field] = value
	end
	return EEex_Options_Option.new(option)
end

-- The switch used to be an on / off toggle, (1 = on), with the key in a separate "Open On" option stored under
-- `oldOpenOnKey`. A switch that is on takes over that key once, after which the old option is set to 0, (it was never
-- 0 otherwise: that was "Automatically", which was removed). Called before the switch is registered or read.
function ZJPopup_MoveOldOpenOn(storageKey, oldOpenOnKey)

	local section = ZJPopup_OpenOnSection
	local openOn = tonumber(Infinity_GetINIString(section, oldOpenOnKey, "X-DEFAULT"))
	if openOn == nil or openOn < 1 then return end

	local switch = tonumber(Infinity_GetINIString(section, storageKey, "X-DEFAULT"))
	if switch == nil or switch == 1 then
		Infinity_SetINIValue(section, storageKey, math.min(math.floor(openOn), #ZJPopup_OpenOnKeys))
	end

	Infinity_SetINIValue(section, oldOpenOnKey, 0)
end

-- Whether a popup with the switch `option` may be open now: only while its key is held, (never while it is Off)
function ZJPopup_IsOpenAllowed(option)
	local entry = ZJPopup_OpenOnKeys[option:get()]
	return entry ~= nil and EEex_Key_IsDown(entry.key) == true
end

-- A button that shows "Off" or the name of the key, clicking it steps to the next one
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
	return 0
end

function ZJPopup_OpenOnWidget:_getText(value)
	local entry = ZJPopup_OpenOnKeys[value]
	return getUiString(entry and entry.name or "ZJBattleSense_TRANSLATION_OpenOn_Off")
end

function ZJPopup_OpenOnWidget:_getColor(value)
	return EEex_Options_Private_GetFontStyleColor(styles["EEex_Options_Normal"])
end

------------------
-- Screen popup --
------------------

ZJPopup_Private_Screen_IsOpen     = false
ZJPopup_Private_Screen_Owner      = nil -- The module showing it
ZJPopup_Private_Screen_Text       = ""
ZJPopup_Private_Screen_TextUD     = nil -- uiItem
ZJPopup_Private_Screen_ShownFrame = -1  -- The frame it was last shown in

ZJPopup_Private_Screen_FontPoint = 11 -- Used if the module doesn't give one
ZJPopup_Private_Screen_DefaultOpacity = 92 -- The background's opacity in percent, used if the module doesn't give one
ZJPopup_Private_Screen_Opacity = ZJPopup_Private_Screen_DefaultOpacity

-- Whether the screen popup was shown in this frame or the one before. A module shows it every frame from something its
-- screen draws, so once that screen is gone the popup stops drawing, even before anything closed it.
function ZJPopup_Private_Screen_IsFresh()
	return Infinity_GetFrameCounter() - ZJPopup_Private_Screen_ShownFrame <= 1
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

-- Shows `text` in the screen popup, beside the cursor, at the height of `rowY`. `owner` is the module showing it,
-- `fontPoint` the size of the text and `opacity` the background's opacity in percent, (both optional). Called every
-- frame while it should be showing.
function ZJPopup_ShowOnScreen(owner, text, rowY, fontPoint, opacity)

	local style = styles["normal"]
	fontPoint = fontPoint or ZJPopup_Private_Screen_FontPoint
	ZJPopup_Private_Screen_Opacity = opacity or ZJPopup_Private_Screen_DefaultOpacity

	local pad = 10
	local gap = 8 -- Between the popup and the cursor
	local cursorRoom = 32
	local wrapWidth = fontPoint * 32

	local textW, textH = EEex_Menu_GetTextWidthHeight(ZJPopup_Private_StripColors(text), style.font, fontPoint, style.useFontZoom, wrapWidth)
	textW = math.min(math.ceil(textW), wrapWidth)
	textH = math.ceil(textH)

	local width = textW + pad * 2
	local height = textH + pad * 2

	ZJPopup_Private_Screen_Text = text
	if ZJPopup_Private_Screen_TextUD ~= nil then
		ZJPopup_Private_Screen_TextUD.text.point = fontPoint
	end

	Infinity_SetArea("ZJPopup_Screen_Background", 0, 0, width, height)
	Infinity_SetArea("ZJPopup_Screen_Text", pad, pad, wrapWidth, textH)

	local screenW, screenH = Infinity_GetScreenSize()
	local mouseX = EEex_Menu_GetMousePos()

	local x = mouseX + cursorRoom
	if x + width > screenW then
		x = mouseX - gap - width
	end

	x = math.max(0, math.min(x, screenW - width))
	local y = math.max(0, math.min(rowY, screenH - height))

	Infinity_SetOffset("ZJPopup_Screen", math.floor(x), math.floor(y))

	ZJPopup_Private_Screen_Owner = owner
	ZJPopup_Private_Screen_ShownFrame = Infinity_GetFrameCounter()

	if not ZJPopup_Private_Screen_IsOpen then
		Infinity_PushMenu("ZJPopup_Screen")
		ZJPopup_Private_Screen_IsOpen = true
	end
end

-- Closes the screen popup if `owner` is showing it, (any module if nil)
function ZJPopup_HideOnScreen(owner)
	if not ZJPopup_Private_Screen_IsOpen then return end
	if owner ~= nil and owner ~= ZJPopup_Private_Screen_Owner then return end
	Infinity_PopMenu("ZJPopup_Screen")
	ZJPopup_Private_Screen_IsOpen = false
	ZJPopup_Private_Screen_Owner = nil
	ZJPopup_Private_Screen_ShownFrame = -1
end

-- UI.menu often closes its screen with Infinity_PopMenu() without a name, which closes the menu on top. While the
-- screen popup is open over that screen, that would close the popup instead and leave the screen open, so the popup is
-- closed first.
EEex_Utility_NewScope(function()
	local popMenu = Infinity_PopMenu
	if type(popMenu) ~= "function" then return end
	Infinity_PopMenu = function(...)
		if select("#", ...) == 0 and ZJPopup_Private_Screen_IsOpen then
			pcall(ZJPopup_HideOnScreen, nil)
		end
		return popMenu(...)
	end
end)

EEex_Menu_AddMainFileLoadedListener(function()
	EEex_Menu_LoadFile("ZJPopup")
	ZJPopup_Private_Screen_IsOpen = false
	ZJPopup_Private_Screen_Owner = nil
	ZJPopup_Private_Screen_TextUD = EEex_Menu_GetItem("ZJPopup_Screen_Text")
end)

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

EEex_Menu_AddBeforeUIItemRenderListener("ZJPopup_Screen_Background", function(item)
	EEex.DrawSlicedRect("ZJPopup_BackgroundRect", { item:getArea() }, math.floor(255 * ZJPopup_Private_Screen_Opacity / 100))
end)
