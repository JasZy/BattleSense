
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
	["ZJCmbLog"] = false,
	["ZJTimer"]  = false,
}

-- The order the modules are started in
ZJBattleSense_Private_ModuleOrder = { "ZJCmbLog", "ZJTimer" }

-- A module can be an extended version of a module that ships with EEex. Running both versions
-- at once would draw everything twice, so the EEex version is switched off:
--
--   "option" - The EEex option that enables its version. It is turned off, which EEex applies on the next launch.
--   "tick"   - The function that drives EEex's version. It is emptied, which silences it until that next launch.
--
ZJBattleSense_Private_Replaces = {
	["ZJTimer"]  = { ["option"] = "EEex_Module_Timer",      ["tick"] = "B3Timer_Private_Menu_Tick"             },
}

function ZJBattleSense_Private_ReplaceEEexModule(replaces)

	local option = EEex_Options_Get(replaces.option)
	if option == nil or option:get() ~= 1 then return end

	option:set(0)

	if type(_G[replaces.tick]) == "function" then
		_G[replaces.tick] = function() end
	end
end

------------------
-- Options tabs --
------------------

-- EEex sorts its options tabs by name, which puts "Battle Sense: ..." in front of everything. Once all tabs are in,
-- EEex makes one last change to the order, (EEex_Options_Private_SpecialSortTabs()); after it, the Battle Sense
-- tabs are moved behind Bubb's "Module: ..." tabs, (or to the end if there are none), keeping their own order.
ZJBattleSense_Private_TabLabelPrefix = "ZJBattleSense_Options_TRANSLATION_"

function ZJBattleSense_Private_SortTabs()

	local tabs = EEex_Options_Private_Tabs
	local prefix = ZJBattleSense_Private_TabLabelPrefix
	local ours = {}

	for i = #tabs, 1, -1 do
		if tabs[i].label:sub(1, #prefix) == prefix then
			table.insert(ours, 1, table.remove(tabs, i))
		end
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

Infinity_DoFile("ZJSprite")

for _, moduleFile in ipairs(ZJBattleSense_Private_ModuleOrder) do
	if ZJBattleSense_Modules[moduleFile] then

		local replaces = ZJBattleSense_Private_Replaces[moduleFile]
		if replaces ~= nil then
			EEex_Utility_TryIgnore(ZJBattleSense_Private_ReplaceEEexModule, replaces)
		end

		ZJBattleSense_Private_DoModuleFile(moduleFile)
	end
end
