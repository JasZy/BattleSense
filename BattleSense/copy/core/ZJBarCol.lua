--[[
+--------------------------------------------------------------------------------------------------+
| ZJBarCol - The colors of the timer bars, shared by the Timer and Attack Info modules             |
+--------------------------------------------------------------------------------------------------+
|   Every bar type, (cast, contingency, modal, attack), has one option: Off, or one of the colors  |
|   below. It applies to the bars beside the portraits and to the ones in the attack info popup.   |
|   The options menu shows it as a button with the color's name, clicking it steps to the next.    |
+--------------------------------------------------------------------------------------------------+
--]]

-- Loaded by every module that has bars, only the first one does anything
if ZJBarColors_Loaded then return end
ZJBarColors_Loaded = true

------------
-- Colors --
------------

-- [option value] = The color, option value 0 is Off.
-- The Timer module's ZJTBAR.BAM has one sequence per color, (sequence = option value - 1), in the same colors.
-- tools/make-bar-bam.ps1 builds it: change a color there too, and run it.
ZJBarColors_Colors = {
	{ ["name"] = "ZJBattleSense_TRANSLATION_BarColor_Red",    ["r"] = 230, ["g"] = 0,   ["b"] = 0   },
	{ ["name"] = "ZJBattleSense_TRANSLATION_BarColor_Orange", ["r"] = 255, ["g"] = 145, ["b"] = 0   },
	{ ["name"] = "ZJBattleSense_TRANSLATION_BarColor_Yellow", ["r"] = 255, ["g"] = 225, ["b"] = 0   },
	{ ["name"] = "ZJBattleSense_TRANSLATION_BarColor_Green",  ["r"] = 0,   ["g"] = 210, ["b"] = 0   },
	{ ["name"] = "ZJBattleSense_TRANSLATION_BarColor_Cyan",   ["r"] = 0,   ["g"] = 225, ["b"] = 225 },
	{ ["name"] = "ZJBattleSense_TRANSLATION_BarColor_Blue",   ["r"] = 40,  ["g"] = 110, ["b"] = 255 },
	{ ["name"] = "ZJBattleSense_TRANSLATION_BarColor_Purple", ["r"] = 175, ["g"] = 80,  ["b"] = 255 },
	{ ["name"] = "ZJBattleSense_TRANSLATION_BarColor_Pink",   ["r"] = 255, ["g"] = 100, ["b"] = 200 },
}

ZJBarColors_OffName = "ZJBattleSense_TRANSLATION_BarColor_Off"

-- The engine's packed colors: 0xAABBGGRR. An opaque color, (alpha 0xFF), is above 2^31, which the engine doesn't read
-- correctly from a Lua number, (EEex's own fills only use alpha 0x40). It is given as the signed 32-bit number with the
-- same bits instead.
local packColor = function(alpha, color)
	local packed = alpha * 0x1000000 + color.b * 0x10000 + color.g * 0x100 + color.r
	if packed >= 0x80000000 then packed = packed - 0x100000000 end
	return packed
end

for _, color in ipairs(ZJBarColors_Colors) do
	color.packed = packColor(0, color)
	color.fill = packColor(255, color)
end

-------------
-- Options --
-------------

-- [bar name] = The bar's option, and the color it starts with
ZJBarColors_Private_Options = {}

local registerBarOption = function(barName, default)
	ZJBarColors_Private_Options[barName] = EEex_Options_Register("ZJBarColors_"..barName, EEex_Options_Option.new({
		["default"]  = default,
		["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = #ZJBarColors_Colors }),
		["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Bar Color: "..barName }),
	}))
end

registerBarOption("Cast",        5) -- Cyan
registerBarOption("Contingency", 4) -- Green
registerBarOption("Modal",       1) -- Red
registerBarOption("Attack",      2) -- Orange

-- The option value of a bar, 0 = Off
function ZJBarColors_Get(barName)
	return ZJBarColors_Private_Options[barName]:get()
end

function ZJBarColors_IsShown(barName)
	return ZJBarColors_Get(barName) ~= 0
end

-- For a menu item's `fill lua`
function ZJBarColors_Fill(barName)
	local color = ZJBarColors_Colors[ZJBarColors_Get(barName)]
	return color and color.fill or 0
end

-- For a ZJTBAR.BAM `sequence lua`
function ZJBarColors_Sequence(barName)
	return math.max(ZJBarColors_Get(barName) - 1, 0)
end

------------
-- Widget --
------------

-- A button that shows the name of the option's color, in that color. Clicking it steps to the next color, and from
-- the last one back to Off.
--
-- Other modules subclass it for other values that step on click, by overriding _getCount, _getText and _getColor.
ZJBarColors_CycleWidget = {}
ZJBarColors_CycleWidget.__index = ZJBarColors_CycleWidget
setmetatable(ZJBarColors_CycleWidget, EEex_Options_Widget)

ZJBarColors_CycleWidget.new = function(o)
	if o == nil then o = {} end
	setmetatable(o, ZJBarColors_CycleWidget)
	o:_init()
	return o
end

function ZJBarColors_CycleWidget:_init()
	EEex_Utility_CallSuper(ZJBarColors_CycleWidget, "_init", self)
	-- Derived
	--   self._instanceData => The button in the options menu, (EEex_Options_TEMPLATE_TextButton instance)
end

-- The values are 0, (Off), up to and including this
function ZJBarColors_CycleWidget:_getCount()
	return #ZJBarColors_Colors
end

function ZJBarColors_CycleWidget:_getText(value)
	local color = ZJBarColors_Colors[value]
	return getUiString(color and color.name or ZJBarColors_OffName)
end

function ZJBarColors_CycleWidget:_getColor(value)
	local color = ZJBarColors_Colors[value]
	return color and color.packed or EEex_Options_Private_GetFontStyleColor(styles["EEex_Options_Normal"])
end

function ZJBarColors_CycleWidget:_update(value)
	local instanceData = self._instanceData
	if instanceData == nil then return end
	instanceData.text = self:_getText(value)
	instanceData.color = self:_getColor(value)
end

function ZJBarColors_CycleWidget:_buildLayout(displayEntry, menuName)

	local widget = self
	local style = styles["EEex_Options_Normal"]

	-- Wide enough for the longest text, so the options don't move around while clicking through the values
	local count = self:_getCount()
	local maxW = 0
	for value = 0, count do
		local w = EEex_Options_Private_GetTextWidthHeight(style.font, style.point, self:_getText(value))
		maxW = math.max(maxW, w)
	end

	local layout = EEex_Options_Private_LayoutText.new({
		["menuName"]      = menuName,
		["font"]          = style.font,
		["point"]         = style.point,
		["color"]         = self:_getColor(0),
		["text"]          = self:_getText(0),
		["width"]         = maxW,
		["verticalAlign"] = EEex_Options_Private_LayoutText_VerticalAlign.CENTER,
		["action"]        = function(instanceData)
			local value = displayEntry:_getWorkingValue()
			displayEntry:_setWorkingValue(value >= count and 0 or value + 1)
		end,
	})

	-- EEex_Options_Private_LayoutText:doLayout() doesn't keep the button it makes, which this needs to change its text
	layout.doLayout = function(self)
		widget._instanceData = EEex_Options_Private_CreateText(self.menuName, "", self._layoutLeft, self._layoutTop, self._layoutWidth, self._layoutHeight, {
			["action"]        = self.action,
			["font"]          = self.font,
			["point"]         = self.point,
			["verticalAlign"] = self.verticalAlign,
		})
		widget:_update(displayEntry:_getWorkingValue())
	end

	return layout
end

function ZJBarColors_CycleWidget:_onShowBeforeLayout(displayEntry)
	self:_update(displayEntry:_getWorkingValue())
end

function ZJBarColors_CycleWidget:_onWorkingValueChanged(newValue)
	self:_update(newValue)
end

-- An options menu entry for the color of `barName`. The same option can be in more than one tab, each with its own
-- label and description.
function ZJBarColors_DisplayEntry(barName, label, description)
	return EEex_Options_DisplayEntry.new({
		["optionID"]    = "ZJBarColors_"..barName,
		["label"]       = label,
		["description"] = description,
		["widget"]      = ZJBarColors_CycleWidget.new(),
	})
end
