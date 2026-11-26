--[[
+--------------------------------------------------------------------------------------------------+
| ZJContainerColors - Colors the outline of locked and empty containers                            |
+--------------------------------------------------------------------------------------------------+
|   The game outlines a container cyan when it is hovered, (or always, while the highlight key is  |
|   held). This module changes that color:                                                         |
|                                                                                                  |
|     * Locked containers, (red by default)                                                        |
|     * Empty containers, (gray by default, as EEex's "Empty Container" module does)               |
|                                                                                                  |
|   Each has a color option, "None" leaves those containers the game's own cyan. A container that  |
|   is both gets the locked color: it still has to be opened before it can be looted, (and the    |
|   game doesn't say a locked container is empty either), unless the locked color is "None".       |
|                                                                                                  |
|   The game outlines a container green instead, when the cursor is a thieving, spell or item     |
|   cursor that can target it. That green is left alone.                                           |
|                                                                                                  |
|   This replaces EEex's "Empty Container" module, and uses the same hook in                       |
|   CGameContainer::Render(): it calls the Lua function named                                      |
|   B3EmptyContainer_Hook_OnBeforeContainerOutlineRender() with the container and the outline      |
|   color, which the function can change. If EEex's module is on, its hook is already installed    |
|   and that function is simply replaced. If it is off, EEex's own file is run to install the hook, |
|   after which the function is replaced. EEex's module is switched off, (see M_ZJBSen.lua), so    |
|   from the next launch on the hook is always installed from here.                                |
|                                                                                                  |
|   The outline colors are 0x00BBGGRR.                                                             |
+--------------------------------------------------------------------------------------------------+
--]]

-- The color button of the options menu, (ZJBarColors_CycleWidget), and the colors it cycles through
Infinity_DoFile("ZJBarCol")

------------
-- Colors --
------------

-- [option value] = The color, option value 0 is None: the game's own color. The bar colors, (ZJBarCol.lua), and gray.
ZJContainerColors_Colors = {}

for _, color in ipairs(ZJBarColors_Colors) do
	table.insert(ZJContainerColors_Colors, color)
end

table.insert(ZJContainerColors_Colors, {
	["name"]   = "ZJBattleSense_TRANSLATION_ContainerColors_Gray",
	["r"]      = 128, ["g"] = 128, ["b"] = 128,
	["packed"] = 0x808080,
})

ZJContainerColors_Private_GrayValue = #ZJContainerColors_Colors

ZJContainerColors_NoneName = "ZJBattleSense_TRANSLATION_ContainerColors_None"

-- The color the game uses when the cursor can target the container, (thieving, spell or item cursor)
ZJContainerColors_Private_TargetColor = 0x00FF00

-------------
-- Options --
-------------

EEex_Options_Register("ZJContainerColors_Enable", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Container Colors" }),
	["onChange"] = function(self, oldValue) ZJContainerColors_Private_Enabled = self:get() ~= 0 end,
}))

local registerColorOption = function(name, default)
	return EEex_Options_Register("ZJContainerColors_"..name.."Color", EEex_Options_Option.new({
		["default"]  = default,
		["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = #ZJContainerColors_Colors }),
		["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Container Colors Module: "..name.." Color" }),
	}))
end

ZJContainerColors_Private_LockedColor = registerColorOption("Locked", 1)                                   -- Red
ZJContainerColors_Private_EmptyColor  = registerColorOption("Empty",  ZJContainerColors_Private_GrayValue) -- Gray
-- A button showing the color's name in that color, or "None". Clicking it steps to the next color, and from the last
-- one back to None.
ZJContainerColors_ColorWidget = {}
ZJContainerColors_ColorWidget.__index = ZJContainerColors_ColorWidget
setmetatable(ZJContainerColors_ColorWidget, ZJBarColors_CycleWidget)

ZJContainerColors_ColorWidget.new = function(o)
	if o == nil then o = {} end
	setmetatable(o, ZJContainerColors_ColorWidget)
	o:_init()
	return o
end

function ZJContainerColors_ColorWidget:_getCount()
	return #ZJContainerColors_Colors
end

function ZJContainerColors_ColorWidget:_getText(value)
	local color = ZJContainerColors_Colors[value]
	return getUiString(color and color.name or ZJContainerColors_NoneName)
end

function ZJContainerColors_ColorWidget:_getColor(value)
	local color = ZJContainerColors_Colors[value]
	return color and color.packed or EEex_Options_Private_GetFontStyleColor(styles["EEex_Options_Normal"])
end

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_ContainerColors_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJContainerColors_LockedColor",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ContainerColors_LockedColor",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ContainerColors_LockedColor_Description",
			["widget"]      = ZJContainerColors_ColorWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJContainerColors_EmptyColor",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ContainerColors_EmptyColor",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ContainerColors_EmptyColor_Description",
			["widget"]      = ZJContainerColors_ColorWidget.new(),
		}),
	},
} end)

-------------
-- Outline --
-------------

ZJContainerColors_Private_Enabled = true

-- CGameContainer.m_dwFlags, (the container flags of the area file)
ZJContainerColors_Private_FlagLocked = 0x1

function ZJContainerColors_Private_IsLocked(container)
	local flags = container.m_dwFlags
	return type(flags) == "number" and EEex_BAnd(flags, ZJContainerColors_Private_FlagLocked) ~= 0
end

-- The outline color of a color option, nil if it is None
function ZJContainerColors_Private_OutlineColor(option)
	local color = ZJContainerColors_Colors[option:get()]
	return color and color.packed
end
function ZJContainerColors_Private_OnBeforeOutlineRender(container, color)

	if not ZJContainerColors_Private_Enabled or color.value == ZJContainerColors_Private_TargetColor then return end

	local lockedColor = ZJContainerColors_Private_OutlineColor(ZJContainerColors_Private_LockedColor)
	if lockedColor ~= nil and ZJContainerColors_Private_IsLocked(container) then
		color.value = lockedColor
		return
	end

	local emptyColor = ZJContainerColors_Private_OutlineColor(ZJContainerColors_Private_EmptyColor)
	if emptyColor ~= nil and container.m_lstItems.m_nCount == 0 then
		color.value = emptyColor
	end
end

----------
-- Hook --
----------

-- EEex's module wasn't loaded, so its hook isn't installed: run its file to install it
if type(B3EmptyContainer_Hook_OnBeforeContainerOutlineRender) ~= "function" then
	EEex_DoFile("B3EmptyContainer")
end

B3EmptyContainer_Hook_OnBeforeContainerOutlineRender = ZJContainerColors_Private_OnBeforeOutlineRender
