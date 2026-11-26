
--[[
+--------------------------------------------------------------------------------------------------+
| Battle Sense - Startup                                                                           |
+--------------------------------------------------------------------------------------------------+
|   The engine runs every M_*.lua file in the override folder while it starts up. EEex is already  |
|   running by then, and the UI has not been loaded yet, so the modules started from here register  |
|   their options, menus and listeners at the same point EEex's own modules do.                    |
+--------------------------------------------------------------------------------------------------+
--]]

-- Only start once, even if the engine runs this file again
if ZJBattleSense_Private_Started then return end
ZJBattleSense_Private_Started = true

-- Battle Sense is built on EEex. EEex reports it itself if the game was started without it.
if not EEex_Active then return end

-------------
-- Modules --
-------------

-- The installer turns a module on by changing its "false" to "true". Do not edit by hand,
-- uninstalling the component restores this file.
ZJBattleSense_Modules = {
	["ZJAblInf"] = false,
	["ZJAtkInf"] = false,
	["ZJCmbLog"] = false,
	["ZJCntCol"] = false,
	["ZJItmInf"] = false,
	["ZJLckInf"] = false,
	["ZJPrfInf"] = false,
	["ZJSplInf"] = false,
	["ZJTimer"]  = false,
}

-- The order the modules are started in
ZJBattleSense_Private_ModuleOrder = { "ZJAblInf", "ZJAtkInf", "ZJCmbLog", "ZJCntCol", "ZJItmInf", "ZJLckInf", "ZJPrfInf", "ZJSplInf", "ZJTimer" }

-- Four of the modules are extended versions of a module that ships with EEex, (the Combat Log one only with the EEex
-- fork Battle Sense started in). Running both versions at once would draw / print everything twice, so the EEex
-- version is switched off when it is there:
--
--   "option" - The EEex option that enables its version. It is turned off, which EEex applies on the next launch.
--   "tick"   - The function that drives EEex's version, (or that all of its output goes through). It is emptied,
--              which silences it until that next launch. Container Colors has none: it takes over the function of
--              EEex's version itself, (see ZJCntCol.lua).
--
ZJBattleSense_Private_Replaces = {
	["ZJAtkInf"] = { ["option"] = "EEex_Module_AttackInfo",     ["tick"] = "B3AttackInfo_Private_Menu_Ticker_Tick" },
	["ZJCmbLog"] = { ["option"] = "EEex_Module_CombatLog",      ["tick"] = "B3CombatLog_Private_Say"               },
	["ZJCntCol"] = { ["option"] = "EEex_Module_EmptyContainer"                                                     },
	["ZJTimer"]  = { ["option"] = "EEex_Module_Timer",          ["tick"] = "B3Timer_Private_Menu_Tick"             },
}

function ZJBattleSense_Private_ReplaceEEexModule(replaces)

	local option = EEex_Options_Get(replaces.option)
	if option == nil or option:get() ~= 1 then return end

	option:set(0)

	if replaces.tick ~= nil and type(_G[replaces.tick]) == "function" then
		_G[replaces.tick] = function() end
	end
end

------------------
-- Options tabs --
------------------

-- EEex sorts its options tabs by name, which puts "Battle Sense: ..." in front of everything. Once all tabs are in,
-- EEex makes one last change to the order, (EEex_Options_Private_SpecialSortTabs()); after it, the Battle Sense
-- tabs are moved behind Bubb's "Module: ..." tabs, (or to the end if there are none), keeping their own order,
-- except that the "Battle Sense Modules" tab goes first, (as EEex puts its "Modules" tab before its module tabs).
ZJBattleSense_Private_TabLabelPrefix = "ZJBattleSense_Options_TRANSLATION_"
ZJBattleSense_Private_ModulesTabLabel = "ZJBattleSense_Options_TRANSLATION_Modules_TabTitle"

function ZJBattleSense_Private_SortTabs()

	local tabs = EEex_Options_Private_Tabs
	local prefix = ZJBattleSense_Private_TabLabelPrefix
	local ours = {}
	local modulesTab

	for i = #tabs, 1, -1 do
		local label = tabs[i].label
		if label == ZJBattleSense_Private_ModulesTabLabel then
			modulesTab = table.remove(tabs, i)
		elseif label:sub(1, #prefix) == prefix then
			table.insert(ours, 1, table.remove(tabs, i))
		end
	end

	if modulesTab ~= nil then
		table.insert(ours, 1, modulesTab)
	end

	local insertAt = #tabs + 1
	for i, tab in ipairs(tabs) do
		local name = getUiString(tab.label)
		if name:sub(1, 8) == "Module: " then
			insertAt = i + 1
		end
	end

	for offset, tab in ipairs(ours) do
		table.insert(tabs, insertAt + offset - 1, tab)
	end
end

if type(EEex_Options_Private_SpecialSortTabs) == "function" and type(EEex_Options_Private_Tabs) == "table" then
	local specialSortTabs = EEex_Options_Private_SpecialSortTabs
	EEex_Options_Private_SpecialSortTabs = function(...)
		specialSortTabs(...)
		EEex_Utility_TryIgnore(ZJBattleSense_Private_SortTabs)
	end
end

------------------------------
-- Saves from the EEex fork --
------------------------------

-- Battle Sense started as modules inside a fork of EEex. That fork's Combat Log added an op403 effect to every creature
-- that calls B3CLSCRN(), and saves made with it still carry that effect. Without the fork the function doesn't exist,
-- so a do-nothing version stands in for it. The Combat Log component also removes the effect, (see ZJCmbLog.lua).
function ZJBattleSense_Private_LegacyCombatLogScreen(op403, effect, sprite)
	return false
end

if B3CLSCRN == nil then
	B3CLSCRN = ZJBattleSense_Private_LegacyCombatLogScreen
end

-------------
-- Strings --
-------------

function ZJBattleSense_Private_LoadStrings()
	Infinity_DoFile("ZJ-en_US")
	local lang = Infinity_GetINIString("Language", "Text", "")
	if lang:lower() == "en_us" then return end
	Infinity_DoFile("ZJ-"..lang)
end

-- The engine throws its strings away when the language is changed, load them again when it does
EEex_Menu_AddTranslationLoadedListener(ZJBattleSense_Private_LoadStrings)

if uiStrings ~= nil then
	ZJBattleSense_Private_LoadStrings()
end

-----------
-- Start --
-----------

-- EEex has already read the options file by now, so an option registered from here gets its value, and fires its
-- "onChange", the moment it is registered. That is too early for a module: it registers its options at the top of
-- its file, before the functions its "onChange" calls exist. Hold every "onChange" back until the file is done.
function ZJBattleSense_Private_DoModuleFile(moduleFile)

	local held = {}
	local register = EEex_Options_Register

	EEex_Options_Register = function(id, option)
		local onChange = option.onChange
		if onChange == nil then return register(id, option) end
		option.onChange = nil
		local toReturn = register(id, option)
		option.onChange = onChange
		table.insert(held, option)
		return toReturn
	end

	Infinity_DoFile(moduleFile)

	EEex_Options_Register = register

	for _, option in ipairs(held) do
		EEex_Utility_TryIgnore(option.onChange, option, nil)
	end
end

-- Every module's on / off switch. A module registers its own switch, and is only loaded if the switch was on when the
-- game started: a module that is switched off adds nothing to the game, (no listeners, no menus). Switching a loaded
-- module off or on again applies at once. Switching on a module that wasn't loaded applies on the next launch, as with
-- EEex's modules, (see ZJBattleSense_Private_RegisterUnloadedToggle()).
--
--   "optionID" - The option the module registers for its switch.
--   "key"      - Where that option is stored, (the "Battle Sense" section of Baldur.lua).
--   "name"     - The module's part of the strings' names, (ZJBattleSense_Options_TRANSLATION_<name>_Enable).
--   "openOn"   - Only for the modules with a popup: where the module's own "Open On" key used to be stored. Battle Sense
--                now has a single "Popup Key", the old settings are moved over to it, (see ZJPopup_MigrateSwitch()).
--
ZJBattleSense_Private_ToggleSection = "Battle Sense"

ZJBattleSense_Private_ModuleToggles = {
	["ZJAblInf"] = { ["optionID"] = "ZJAbilityInfo_Enable",     ["key"] = "Ability Info",     ["name"] = "AbilityInfo",     ["openOn"] = "Ability Info Module: Open On"     },
	["ZJAtkInf"] = { ["optionID"] = "ZJAttackInfo_Enable",      ["key"] = "Attack Info",      ["name"] = "AttackInfo",      ["openOn"] = "Attack Info Module: Open On"      },
	["ZJCmbLog"] = { ["optionID"] = "ZJCombatLog_Enable",       ["key"] = "Combat Log",       ["name"] = "CombatLog"                                                        },
	["ZJCntCol"] = { ["optionID"] = "ZJContainerColors_Enable", ["key"] = "Container Colors", ["name"] = "ContainerColors"                                                  },
	["ZJItmInf"] = { ["optionID"] = "ZJItemInfo_Enable",        ["key"] = "Item Info",        ["name"] = "ItemInfo",        ["openOn"] = "Item Info Module: Open On"        },
	["ZJLckInf"] = { ["optionID"] = "ZJLockInfo_Enable",        ["key"] = "Lock Info",        ["name"] = "LockInfo",        ["openOn"] = "Lock Info Module: Open On"        },
	["ZJPrfInf"] = { ["optionID"] = "ZJProficiencyInfo_Enable", ["key"] = "Proficiency Info", ["name"] = "ProficiencyInfo", ["openOn"] = "Proficiency Info Module: Open On" },
	["ZJSplInf"] = { ["optionID"] = "ZJSpellInfo_Enable",       ["key"] = "Spell Info",       ["name"] = "SpellInfo",       ["openOn"] = "Spell Info Module: Open On"       },
	["ZJTimer"]  = { ["optionID"] = "ZJTimer_Enable",           ["key"] = "Timer",            ["name"] = "Timer"                                                            },
}

-- Whether the module's switch is on, read from where its option stores it, (the module isn't loaded yet, so its option
-- doesn't exist). The switches are on by default.
function ZJBattleSense_Private_IsModuleSwitchedOn(toggle)
	local value = tonumber(Infinity_GetINIString(ZJBattleSense_Private_ToggleSection, toggle.key, "X-DEFAULT"))
	return value == nil or value ~= 0
end

-- Stands in for the switch of a module that wasn't loaded, so that it can still be switched on. It is stored in the
-- same place as the module's own switch, and applies on the next launch, (EEex shows that next to it).
function ZJBattleSense_Private_RegisterUnloadedToggle(toggle)
	EEex_Options_Register(toggle.optionID, EEex_Options_Option.new({
		["default"]         = 1,
		["type"]            = EEex_Options_ToggleType.new(),
		["accessor"]        = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
		["storage"]         = EEex_Options_NumberLuaStorage.new({ ["section"] = ZJBattleSense_Private_ToggleSection, ["key"] = toggle.key }),
		["requiresRestart"] = true,
	}))
end

Infinity_DoFile("ZJSprite")
Infinity_DoFile("ZJPopup") -- The popup and its key, shared by the modules with a popup

-- Whether a module with a popup is installed
function ZJBattleSense_Private_HasPopupModule()
	for _, moduleFile in ipairs(ZJBattleSense_Private_ModuleOrder) do
		local toggle = ZJBattleSense_Private_ModuleToggles[moduleFile]
		if ZJBattleSense_Modules[moduleFile] and toggle ~= nil and toggle.openOn ~= nil then return true end
	end
	return false
end

-- The modules with a popup used to have a key each: move those settings over to the one "Popup Key" before any switch
-- or the key itself is read
for _, moduleFile in ipairs(ZJBattleSense_Private_ModuleOrder) do
	local toggle = ZJBattleSense_Private_ModuleToggles[moduleFile]
	if ZJBattleSense_Modules[moduleFile] and toggle.openOn ~= nil then
		EEex_Utility_TryIgnore(ZJPopup_MigrateSwitch, toggle.key, toggle.openOn)
	end
end

if ZJBattleSense_Private_HasPopupModule() then
	ZJPopup_RegisterKey()
end

for _, moduleFile in ipairs(ZJBattleSense_Private_ModuleOrder) do
	if ZJBattleSense_Modules[moduleFile] then

		local toggle = ZJBattleSense_Private_ModuleToggles[moduleFile]

		if ZJBattleSense_Private_IsModuleSwitchedOn(toggle) then

			local replaces = ZJBattleSense_Private_Replaces[moduleFile]
			if replaces ~= nil then
				EEex_Utility_TryIgnore(ZJBattleSense_Private_ReplaceEEexModule, replaces)
			end

			ZJBattleSense_Private_DoModuleFile(moduleFile)
		else
			ZJBattleSense_Private_RegisterUnloadedToggle(toggle)
		end
	end
end

--------------------------
-- Battle Sense Modules --
--------------------------

-- Every module's on / off switch is in one "Battle Sense Modules" tab, like EEex's "Modules" tab, instead of in the
-- module's own tab. Only the modules that are installed are listed. If a module with a popup is installed, the
-- "Popup Key" that opens the popup of all of them comes first.
function ZJBattleSense_Private_InstalledModuleToggles()
	local toggles = {}
	for _, moduleFile in ipairs(ZJBattleSense_Private_ModuleOrder) do
		local toggle = ZJBattleSense_Private_ModuleToggles[moduleFile]
		if ZJBattleSense_Modules[moduleFile] and toggle ~= nil and EEex_Options_Get(toggle.optionID) ~= nil then
			table.insert(toggles, toggle)
		end
	end
	return toggles
end

if #ZJBattleSense_Private_InstalledModuleToggles() > 0 then
	EEex_Options_AddTab(ZJBattleSense_Private_ModulesTabLabel, function()
		local entries = {}
		if EEex_Options_Get(ZJPopup_KeyOptionID) ~= nil then
			table.insert(entries, ZJPopup_KeyDisplayEntry())
		end
		for _, toggle in ipairs(ZJBattleSense_Private_InstalledModuleToggles()) do
			table.insert(entries, EEex_Options_DisplayEntry.new({
				["optionID"]    = toggle.optionID,
				["label"]       = "ZJBattleSense_Options_TRANSLATION_"..toggle.name.."_Enable",
				["description"] = "ZJBattleSense_Options_TRANSLATION_"..toggle.name.."_Enable_Description",
				["widget"]      = EEex_Options_ToggleWidget.new(),
			}))
		end
		return { entries }
	end)
end
