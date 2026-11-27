
--[[
+--------------------------------------------------------------------------------------------------+
| ZJItemInfo - Item popup for stores, containers, the quick loot bar and the inventory             |
+--------------------------------------------------------------------------------------------------+
|   Hovering the cursor over an item in a store, a container, the quick loot bar, or the inventory |
|   screen, opens a popup with the properties of that item. If a character is selected, and the    |
|   item can be worn / wielded, the popup also lists how the character's stats would change if     |
|   they equipped it, (not for an item the character is already wearing).                          |
|                                                                                                  |
|   Hovering a quick item on the action bar that is used on its owner, (a potion), lists what     |
|   using it does to the selected character: hit points, stat changes, effects and duration.       |
|                                                                                                  |
|   Nothing in UI.menu is changed: the item under the cursor is worked out from the areas of the   |
|   game's own lists / buttons, so this also works with UI mods that keep those lists / buttons.   |
+--------------------------------------------------------------------------------------------------+
--]]

-- The popup and its key, (shared by every module with a popup)
Infinity_DoFile("ZJPopup")
-- The colors, and the button that steps through them, (shared with Timer, Creature Info and Spell Info)
Infinity_DoFile("ZJBarCol")

-------------
-- Options --
-------------

-- The module's on / off switch, in the "Battle Sense Modules" tab
EEex_Options_Register("ZJItemInfo_Enable", ZJPopup_NewSwitch("Item Info", {
	["onChange"] = function(self, oldValue) ZJItemInfo_SetEnabled(self:get() ~= 0) end,
}))

ZJItemInfo_Private_FontPoint = EEex_Options_Register("ZJItemInfo_FontPoint", EEex_Options_Option.new({
	["default"]  = 11,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Font Point" }),
}))

ZJItemInfo_Private_ShowFullDescription = EEex_Options_Register("ZJItemInfo_ShowFullDescription", EEex_Options_Option.new({
	["default"]  = 0,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Show Full Description" }),
}))

ZJItemInfo_Private_ShowComparison = EEex_Options_Register("ZJItemInfo_ShowComparison", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Show Comparison" }),
}))

ZJItemInfo_Private_ShowWeaponStats = EEex_Options_Register("ZJItemInfo_ShowWeaponStats", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Show Weapon Stats" }),
}))

ZJItemInfo_Private_ShowInStores = EEex_Options_Register("ZJItemInfo_ShowInStores", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Show In Stores" }),
}))

ZJItemInfo_Private_ShowInQuickLoot = EEex_Options_Register("ZJItemInfo_ShowInQuickLoot", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Show In Quick Loot" }),
}))

ZJItemInfo_Private_ShowInContainers = EEex_Options_Register("ZJItemInfo_ShowInContainers", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Show In Containers" }),
}))

ZJItemInfo_Private_ShowInInventory = EEex_Options_Register("ZJItemInfo_ShowInInventory", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Show In Inventory" }),
}))

ZJItemInfo_Private_ShowOnQuickItems = EEex_Options_Register("ZJItemInfo_ShowOnQuickItems", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Item Info Module: Show On Quick Items" }),
}))

-- The colors of a value that is better / worse than that of the item it replaces, (one of the bar colors, ZJBarCol.lua)
ZJItemInfo_Private_BetterColor = ZJBarColors_RegisterColorOption("ZJItemInfo_BetterColor", "Item Info Module: Better Color", 4) -- Green
ZJItemInfo_Private_WorseColor  = ZJBarColors_RegisterColorOption("ZJItemInfo_WorseColor",  "Item Info Module: Worse Color",  1) -- Red

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_ItemInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_FontPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_FontPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_FontPoint_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"]        = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_ShowFullDescription",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowFullDescription",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowFullDescription_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_ShowComparison",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowComparison",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowComparison_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
			["subOptions"]  = {
				EEex_Options_DisplayEntry.new({
					["optionID"]    = "ZJItemInfo_ShowWeaponStats",
					["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowWeaponStats",
					["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowWeaponStats_Description",
					["widget"]      = EEex_Options_ToggleWidget.new(),
				}),
			},
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_ShowInStores",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInStores",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInStores_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_ShowInQuickLoot",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInQuickLoot",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInQuickLoot_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_ShowInContainers",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInContainers",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInContainers_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_ShowInInventory",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInInventory",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInInventory_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_ShowOnQuickItems",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowOnQuickItems",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowOnQuickItems_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_BetterColor",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_BetterColor",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_BetterColor_Description",
			["widget"]      = ZJBarColors_ColorWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJItemInfo_WorseColor",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_ItemInfo_WorseColor",
			["description"] = "ZJBattleSense_Options_TRANSLATION_ItemInfo_WorseColor_Description",
			["widget"]      = ZJBarColors_ColorWidget.new(),
		}),
	},
} end)

-------------
-- Globals --
-------------

ZJItemInfo_Private_Enabled = false
ZJItemInfo_Private_QuickItemErrorReported = false -- Shown in the message log, the quick item popup is new
ZJItemInfo_Private_ContainerErrorReported = false -- Shown in the message log, the container popup is new
ZJItemInfo_Private_InventoryErrorReported = false -- Shown in the message log, the inventory popup is new
ZJItemInfo_Private_RefreshInterval = 500 -- Milliseconds, how often the popup of an item is rebuilt while the cursor stays on it

-- The menus that hide the item under the cursor while they are open
ZJItemInfo_Private_BlockingMenus = { "ITEM_DESCRIPTION", "POPUP_REQUESTER" }

ZJItemInfo_Private_TitleColorStr  = "^0xFF64D7FF"
ZJItemInfo_Private_DimColorStr    = "^0xFFA0A0A0"
ZJItemInfo_Private_ColorEndStr    = "^-"

-- The text color codes of the "Better Color" / "Worse Color" options
function ZJItemInfo_Private_BetterColorStr()
	return ZJBarColors_TextColorStr(ZJItemInfo_Private_BetterColor:get())
end

function ZJItemInfo_Private_WorseColorStr()
	return ZJBarColors_TextColorStr(ZJItemInfo_Private_WorseColor:get())
end

-------------
-- General --
-------------

-- Temporarily changes the enable state of the item popup.
-- To persist this change, instead modify the "ZJItemInfo_Enable" option.
function ZJItemInfo_SetEnabled(enabled)
	ZJItemInfo_Private_Enabled = enabled
end

function ZJItemInfo_Private_T(key)
	return uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_"..key] or key
end

function ZJItemInfo_Private_FetchString(strref)
	if type(strref) ~= "number" or strref < 0 or strref > 0x7FFFFFFF then return "" end
	local ok, str = pcall(Infinity_FetchString, strref)
	return ok and type(str) == "string" and str or ""
end

function ZJItemInfo_Private_Trim(str)
	return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

----------------
-- Item files --
----------------

-- SLOTS.IDS, where an item of a category is equipped. "weapon" is the weapon the character has in hand, "ring" is either ring slot.
ZJItemInfo_Private_Slot_Armor     = 1
ZJItemInfo_Private_Slot_RingLeft  = 7
ZJItemInfo_Private_Slot_RingRight = 8
ZJItemInfo_Private_Slot_Shield    = 9
ZJItemInfo_Private_Slot_QuickItemFirst = 15 -- SLOT_MISC0, the quick item slots follow it

ZJItemInfo_Private_CategorySlots = {
	[1]  = 0, -- Amulet
	[2]  = 1, [60] = 1, [61] = 1, [62] = 1, [63] = 1, [64] = 1, [65] = 1, [66] = 1, [67] = 1, [68] = 1, -- Armor
	[3]  = 2, -- Belt
	[4]  = 3, -- Boots
	[32] = 4, -- Cloak
	[6]  = 5, [73] = 5, -- Bracers / gauntlets
	[7]  = 6, [72] = 6, -- Helmet / hat
	[10] = "ring",
	[12] = 9, [41] = 9, [47] = 9, [49] = 9, [53] = 9, -- Shields
	[15] = "weapon", [16] = "weapon", [17] = "weapon", [18] = "weapon", [19] = "weapon", [20] = "weapon",
	[21] = "weapon", [22] = "weapon", [23] = "weapon", [24] = "weapon", [25] = "weapon", [26] = "weapon",
	[27] = "weapon", [28] = "weapon", [29] = "weapon", [30] = "weapon", [44] = "weapon", [57] = "weapon",
	[69] = "weapon",
}

ZJItemInfo_Private_LauncherCategories = { [15] = true, [18] = true, [27] = true } -- Bow, sling, crossbow
ZJItemInfo_Private_ShieldCategories = { [12] = true, [41] = true, [47] = true, [49] = true, [53] = true }

-- What is read from an .ITM file, kept for the lifetime of the Lua state: [resref] = info, (false if the file can't be read)
ZJItemInfo_Private_ItemInfoCache = {}

function ZJItemInfo_Private_ReadItemInfo(resref)

	local header = EEex_Resource_Demand(resref, "ITM")
	if header == nil then return nil end

	local info = {
		["category"]              = header.itemType,
		["twoHanded"]             = EEex_BAnd(header.itemFlags, 0x2) ~= 0,
		["lore"]                  = header.loreValue,
		["genericName"]           = header.genericName,
		["identifiedName"]        = header.identifiedName,
		["genericDescription"]    = header.genericDescription,
		["identifiedDescription"] = header.identifiedDescription,
		["proficiencyType"]       = header.proficiencyType,
		["equipped"]              = {}, -- Array of { opcode, param1, param2 }, the effects it applies while it is equipped
		["weapon"]                = nil, -- Its first melee / ranged ability
	}

	local headerAddress = EEex_UDToPtr(header)
	local effectsAddress = headerAddress + header.effectsOffset

	for i = header.equipedStartingEffect, header.equipedStartingEffect + header.equipedEffectCount - 1 do
		local effect = EEex_PtrToUD(effectsAddress + Item_effect_st.sizeof * i, "Item_effect_st")
		table.insert(info.equipped, { effect.effectID, effect.effectAmount, effect.dwFlags })
	end

	local abilitiesAddress = headerAddress + header.abilityOffset

	for i = 0, header.abilityCount - 1 do
		local ability = EEex_PtrToUD(abilitiesAddress + Item_ability_st.sizeof * i, "Item_ability_st")
		local abilityType = ability.type
		if abilityType == 1 or abilityType == 2 or abilityType == 4 then -- Melee / ranged / launcher
			-- The ability's flags, (0x26): bit 0 adds the strength bonus to a ranged attack, a melee attack always gets it
			local abilityFlags = EEex_ReadU32(EEex_UDToPtr(ability) + 0x26)
			info.weapon = {
				["diceCount"]   = ability.damageDiceCount,
				["diceSize"]    = ability.damageDice,
				["bonus"]       = ability.damageDiceBonus,
				["thac0Bonus"]  = ability.thac0Bonus,
				["speedFactor"] = ability.speedFactor,
				["ranged"]      = abilityType ~= 1,
				["launcher"]    = abilityType == 4, -- Its bonuses add to those of the ammunition it fires
				["addStrength"] = abilityType == 1 or EEex_BAnd(abilityFlags, 0x1) ~= 0,
			}
			break
		end
	end

	return info
end

function ZJItemInfo_Private_GetItemInfo(resref)

	if type(resref) ~= "string" or resref == "" then return nil end
	resref = resref:upper()

	local info = ZJItemInfo_Private_ItemInfoCache[resref]

	if info == nil then
		local ok, readInfo = pcall(ZJItemInfo_Private_ReadItemInfo, resref)
		info = ok and readInfo or false
		ZJItemInfo_Private_ItemInfoCache[resref] = info
	end

	return info or nil
end

function ZJItemInfo_Private_GetItemName(info, identified)
	local name = identified and ZJItemInfo_Private_FetchString(info.identifiedName) or ""
	if name == "" then
		name = ZJItemInfo_Private_FetchString(info.genericName)
	end
	return name
end

-- The part of an item's description that lists its properties: everything below the first line that is a heading in
-- capitals, ("STATISTICS:" in English). Returns the whole description if it has no such heading.
function ZJItemInfo_Private_GetStatistics(description)
	local _, headingEnd = ("\n"..description):find("\n[%u\128-\255][%u%s\128-\255]*:[ \t\r]*\n")
	if headingEnd == nil then return description end
	local statistics = ZJItemInfo_Private_Trim(description:sub(headingEnd)) -- The match is one further in because of the "\n" in front
	return statistics ~= "" and statistics or description
end

function ZJItemInfo_Private_GetItemDescription(info, identified)

	local description = identified and ZJItemInfo_Private_FetchString(info.identifiedDescription) or ""
	if description == "" then
		description = ZJItemInfo_Private_FetchString(info.genericDescription)
	end

	description = ZJItemInfo_Private_Trim(description)

	if ZJItemInfo_Private_ShowFullDescription:get() == 0 then
		description = ZJItemInfo_Private_GetStatistics(description)
	end

	return ZJItemInfo_Private_TrimToLength(description, ZJItemInfo_Private_MaxDescriptionLength)
end

-- The most characters of an item's description the popup shows, (a scroll has the spell's whole description), so the
-- popup stays small enough to fit above the item without covering it
ZJItemInfo_Private_MaxDescriptionLength = 700

-- Cuts `text` to at most `maxLength` characters, at the end of a word, with "..." behind it
function ZJItemInfo_Private_TrimToLength(text, maxLength)
	if #text <= maxLength then return text end
	local cut = text:sub(1, maxLength)
	local lastSpace = cut:match(".*()%s")
	if lastSpace ~= nil and lastSpace > maxLength / 2 then
		cut = cut:sub(1, lastSpace - 1)
	end
	return ZJItemInfo_Private_Trim(cut):gsub("[,;:%.]+$", "").."..."
end

----------------
-- Comparison --
----------------

-- The stats a comparison lists, in this order:
--
--   key           => Its name is the string "Stat_<key>"
--   field         => The field of the character's stats that holds it
--   lowerIsBetter => true if a lower value is the better one
--   suffix        => What goes behind its value
--   always        => true if it is listed even when it doesn't change, (in white)
--
ZJItemInfo_Private_Stats = {
	{ ["key"] = "ArmorClass",       ["field"] = "m_nArmorClass",            ["lowerIsBetter"] = true, ["always"] = true },
	{ ["key"] = "MaxHitPoints",     ["field"] = "m_nMaxHitPoints",          ["always"] = true },
	{ ["key"] = "THAC0",            ["field"] = "m_nTHAC0",                 ["lowerIsBetter"] = true, ["always"] = true },
	{ ["key"] = "SaveDeath",        ["field"] = "m_nSaveVSDeath",           ["lowerIsBetter"] = true },
	{ ["key"] = "SaveWands",        ["field"] = "m_nSaveVSWands",           ["lowerIsBetter"] = true },
	{ ["key"] = "SavePoly",         ["field"] = "m_nSaveVSPoly",            ["lowerIsBetter"] = true },
	{ ["key"] = "SaveBreath",       ["field"] = "m_nSaveVSBreath",          ["lowerIsBetter"] = true },
	{ ["key"] = "SaveSpell",        ["field"] = "m_nSaveVSSpell",           ["lowerIsBetter"] = true },
	{ ["key"] = "DamageBonus",      ["field"] = "m_nDamageBonus"            },
	{ ["key"] = "STR",              ["field"] = "m_nSTR",                   ["baseField"] = "m_STRBase" },
	{ ["key"] = "DEX",              ["field"] = "m_nDEX",                   ["baseField"] = "m_DEXBase" },
	{ ["key"] = "CON",              ["field"] = "m_nCON",                   ["baseField"] = "m_CONBase" },
	{ ["key"] = "INT",              ["field"] = "m_nINT",                   ["baseField"] = "m_INTBase" },
	{ ["key"] = "WIS",              ["field"] = "m_nWIS",                   ["baseField"] = "m_WISBase" },
	{ ["key"] = "CHR",              ["field"] = "m_nCHR",                   ["baseField"] = "m_CHRBase" },
	{ ["key"] = "ResistMagic",      ["field"] = "m_nResistMagic",           ["suffix"] = "%" },
	{ ["key"] = "ResistFire",       ["field"] = "m_nResistFire",            ["suffix"] = "%" },
	{ ["key"] = "ResistCold",       ["field"] = "m_nResistCold",            ["suffix"] = "%" },
	{ ["key"] = "ResistElectricity",["field"] = "m_nResistElectricity",     ["suffix"] = "%" },
	{ ["key"] = "ResistAcid",       ["field"] = "m_nResistAcid",            ["suffix"] = "%" },
	{ ["key"] = "ResistPoison",     ["field"] = "m_nResistPoison",          ["suffix"] = "%" },
	{ ["key"] = "ResistMagicDamage",["field"] = "m_nMagicDamageResistance", ["suffix"] = "%" },
	{ ["key"] = "ResistMagicFire",  ["field"] = "m_nResistMagicFire",       ["suffix"] = "%" },
	{ ["key"] = "ResistMagicCold",  ["field"] = "m_nResistMagicCold",       ["suffix"] = "%" },
	{ ["key"] = "ResistSlashing",   ["field"] = "m_nResistSlashing",        ["suffix"] = "%" },
	{ ["key"] = "ResistCrushing",   ["field"] = "m_nResistCrushing",        ["suffix"] = "%" },
	{ ["key"] = "ResistPiercing",   ["field"] = "m_nResistPiercing",        ["suffix"] = "%" },
	{ ["key"] = "ResistMissile",    ["field"] = "m_nResistMissile",         ["suffix"] = "%" },
	{ ["key"] = "Luck",             ["field"] = "m_nLuck"                   },
	{ ["key"] = "OpenLocks",        ["field"] = "m_nLockPicking",           ["suffix"] = "%" },
	{ ["key"] = "FindTraps",        ["field"] = "m_nTraps",                 ["suffix"] = "%" },
	{ ["key"] = "PickPockets",      ["field"] = "m_nPickPocket",            ["suffix"] = "%" },
	{ ["key"] = "MoveSilently",     ["field"] = "m_nMoveSilently",          ["suffix"] = "%" },
	{ ["key"] = "HideInShadows",    ["field"] = "m_nHideInShadows",         ["suffix"] = "%" },
}

-- The opcodes of equipped effects that change one of the stats above:
--
--   stats  => The key(s) of the stat(s) it changes
--   sign   => -1 if a positive amount lowers the stat, (a bonus to a stat where lower is better)
--   canSet => true if its second parameter can also ask for the stat to be set to the amount, (1), instead of
--             the amount being added to it, (0). Any other mode, (e.g. a percentage), is not looked at.
--
ZJItemInfo_Private_OpcodeStats = {
	[6]   = { ["stats"] = { "CHR" }, ["canSet"] = true },
	[10]  = { ["stats"] = { "CON" }, ["canSet"] = true },
	[15]  = { ["stats"] = { "DEX" }, ["canSet"] = true },
	[19]  = { ["stats"] = { "INT" }, ["canSet"] = true },
	[44]  = { ["stats"] = { "STR" }, ["canSet"] = true },
	[49]  = { ["stats"] = { "WIS" }, ["canSet"] = true },
	[18]  = { ["stats"] = { "MaxHitPoints" } },
	[22]  = { ["stats"] = { "Luck" } },
	[27]  = { ["stats"] = { "ResistAcid" },        ["canSet"] = true },
	[28]  = { ["stats"] = { "ResistCold" },        ["canSet"] = true },
	[29]  = { ["stats"] = { "ResistElectricity" }, ["canSet"] = true },
	[30]  = { ["stats"] = { "ResistFire" },        ["canSet"] = true },
	[31]  = { ["stats"] = { "ResistMagicDamage" }, ["canSet"] = true },
	[84]  = { ["stats"] = { "ResistMagicFire" },   ["canSet"] = true },
	[85]  = { ["stats"] = { "ResistMagicCold" },   ["canSet"] = true },
	[86]  = { ["stats"] = { "ResistSlashing" },    ["canSet"] = true },
	[87]  = { ["stats"] = { "ResistCrushing" },    ["canSet"] = true },
	[88]  = { ["stats"] = { "ResistPiercing" },    ["canSet"] = true },
	[89]  = { ["stats"] = { "ResistMissile" },     ["canSet"] = true },
	[166] = { ["stats"] = { "ResistMagic" },       ["canSet"] = true },
	[173] = { ["stats"] = { "ResistPoison" },      ["canSet"] = true },
	[33]  = { ["stats"] = { "SaveDeath" },  ["sign"] = -1 },
	[34]  = { ["stats"] = { "SaveWands" },  ["sign"] = -1 },
	[35]  = { ["stats"] = { "SavePoly" },   ["sign"] = -1 },
	[36]  = { ["stats"] = { "SaveBreath" }, ["sign"] = -1 },
	[37]  = { ["stats"] = { "SaveSpell" },  ["sign"] = -1 },
	[325] = { ["stats"] = { "SaveDeath", "SaveWands", "SavePoly", "SaveBreath", "SaveSpell" }, ["sign"] = -1 },
	[54]  = { ["stats"] = { "THAC0" }, ["sign"] = -1 },
	[278] = { ["stats"] = { "THAC0" }, ["sign"] = -1 },
	[73]  = { ["stats"] = { "DamageBonus" } },
	-- Bonuses for one kind of attack, (not listed, they go into the THAC0 and damage of the weapon in hand)
	[167] = { ["stats"] = { "MissileTHAC0" } },
	[284] = { ["stats"] = { "MeleeTHAC0" } },
	[288] = { ["stats"] = { "FistTHAC0" } },
	[285] = { ["stats"] = { "MeleeDamage" } },
	[286] = { ["stats"] = { "MissileDamage" } },
	[289] = { ["stats"] = { "FistDamage" } },
	[90]  = { ["stats"] = { "OpenLocks" },     ["canSet"] = true },
	[91]  = { ["stats"] = { "FindTraps" },     ["canSet"] = true },
	[92]  = { ["stats"] = { "PickPockets" },   ["canSet"] = true },
	[59]  = { ["stats"] = { "MoveSilently" },  ["canSet"] = true },
	[275] = { ["stats"] = { "HideInShadows" }, ["canSet"] = true },
}

-- op0's second parameter => the kind of attack that armor class bonus is against
-- field => the stat with the character's modifier against it, (it is added to the armor class, so +2 is worse)
ZJItemInfo_Private_ArmorClassTypes = {
	{ ["flag"] = 1, ["key"] = "ArmorClassCrushing", ["field"] = "m_nACCrushingMod" },
	{ ["flag"] = 2, ["key"] = "ArmorClassMissile",  ["field"] = "m_nACMissileMod"  },
	{ ["flag"] = 4, ["key"] = "ArmorClassPiercing", ["field"] = "m_nACPiercingMod" },
	{ ["flag"] = 8, ["key"] = "ArmorClassSlashing", ["field"] = "m_nACSlashingMod" },
}

-- Adds what the equipped effects of an item do to `totals`, `direction` is 1 for the item that is put on and -1 for one that is taken off:
--
--   totals.add[stat key]             => What is added to the stat
--   totals.set[stat key]             => What the item that is put on sets the stat to
--   totals.unset[stat key]           => true if an item that is taken off set the stat
--   totals.armorClassBonus           => The armor class bonus against everything
--   totals.armorClassTypes[flag]     => The armor class bonus against a kind of attack
--   totals.armorClassBase            => The lowest base armor class the item that is put on sets, (nil if it sets none)
--   totals.armorClassBaseChanges     => true if the base armor class has to be worked out again
--
function ZJItemInfo_Private_AddEquippedEffects(totals, info, direction)

	for _, effect in ipairs(info.equipped) do

		local opcode, amount, mode = effect[1], effect[2], effect[3]

		if opcode == 1 then

			-- Attacks per round, in the creature file's encoding, (0 - 5 whole attacks, 6 - 10 one half up to 9 halves)
			if mode == 0 then
				totals.attackHalves = totals.attackHalves + direction * ZJItemInfo_Private_DecodeAttacks(amount)
			elseif mode == 1 then
				if direction > 0 then
					totals.attacksSet = ZJItemInfo_Private_DecodeAttacks(amount)
				else
					totals.attacksUnset = true
				end
			end

		elseif opcode == 0 then

			if mode == 0 then
				totals.armorClassBonus = totals.armorClassBonus + direction * amount
			elseif mode == 16 then
				totals.armorClassBaseChanges = true
				if direction > 0 and (totals.armorClassBase == nil or amount < totals.armorClassBase) then
					totals.armorClassBase = amount
				end
			else
				for _, armorClassType in ipairs(ZJItemInfo_Private_ArmorClassTypes) do
					if EEex_BAnd(mode, armorClassType.flag) ~= 0 then
						totals.armorClassTypes[armorClassType.flag] = (totals.armorClassTypes[armorClassType.flag] or 0) + direction * amount
					end
				end
			end
		else
			local opcodeStats = ZJItemInfo_Private_OpcodeStats[opcode]
			if opcodeStats ~= nil then
				for _, statKey in ipairs(opcodeStats.stats) do
					if mode == 0 then
						totals.add[statKey] = (totals.add[statKey] or 0) + direction * amount * (opcodeStats.sign or 1)
					elseif mode == 1 and opcodeStats.canSet then
						if direction > 0 then
							totals.set[statKey] = amount
						else
							totals.unset[statKey] = true
						end
					end
				end
			end
		end
	end
end

-- The number of half attacks of an attacks per round value, (stat / op1 encoding: 0 - 5 whole attacks, 6 - 10 are 1/2, 3/2, ... 9/2)
function ZJItemInfo_Private_DecodeAttacks(value)
	if value > 5 then return (value - 5) * 2 - 1 end
	return value * 2
end

-- Half attacks => "2", "3/2"
function ZJItemInfo_Private_FormatAttacks(halves)
	if halves % 2 == 0 then return tostring(halves / 2) end
	return string.format("%d/2", halves)
end

-- CLASS.IDS of the classes whose level gives extra attacks per round, (WSPATCK.2DA), => which of the character's
-- levels, (1 - 3), is its warrior level. Any other class gets what the table gives at level 1.
ZJItemInfo_Private_WarriorLevelIndex = {
	[2] = 1, [6] = 1, [7] = 1, [8] = 1, [9] = 1, [10] = 1, [12] = 1, [16] = 1, [17] = 1,
	[18] = 2, -- Cleric / ranger
}

ZJItemInfo_Private_WeaponAttacks = nil -- WSPATCK.2DA, loaded the first time it is needed

-- The extra half attacks per round `sprite` gets from `points` proficiency points in a melee weapon, (WSPATCK.2DA:
-- 0 to 5 are whole attacks, -1 is a half, -2 one and a half, ...). The table also holds the warrior level progression.
function ZJItemInfo_Private_GetProficiencyAttacks(sprite, points)

	if ZJItemInfo_Private_WeaponAttacks == nil then
		ZJItemInfo_Private_WeaponAttacks = EEex_Resource_Load2DA("WSPATCK")
	end

	local level = 1
	local okClass, class = pcall(function() return sprite.m_typeAI.m_Class end)
	local levelIndex = okClass and ZJItemInfo_Private_WarriorLevelIndex[class] or nil
	if levelIndex ~= nil then
		local stats = sprite:getActiveStats()
		level = levelIndex == 2 and stats.m_nLevel2 or stats.m_nLevel1
	end

	local array = ZJItemInfo_Private_WeaponAttacks
	local columns = array:getDimensions() - 1 -- The last column counts for every higher level
	local value = tonumber(array:getAtPoint(math.max(1, math.min(level, columns)) - 1, math.min(points, 5)))
	if value == nil then return 0 end
	if value < 0 then return -value * 2 - 1 end
	return value * 2
end

-- Whether the weapon of `info` attacks from range, (a launcher's ability isn't a ranged attack, its ammunition's is)
function ZJItemInfo_Private_IsRangedWeapon(info)
	return ZJItemInfo_Private_LauncherCategories[info.category] == true or (info.weapon ~= nil and info.weapon.ranged)
end

-- Returns `value` in the color that says whether it is better or worse than `oldValue`
function ZJItemInfo_Private_ColorChange(text, change, lowerIsBetter)
	if change == 0 then return text end
	local better = (change < 0) == (lowerIsBetter == true)
	return (better and ZJItemInfo_Private_BetterColorStr() or ZJItemInfo_Private_WorseColorStr())..text..ZJItemInfo_Private_ColorEndStr
end

function ZJItemInfo_Private_FormatChangeLine(label, oldValue, newValue, lowerIsBetter, suffix)
	suffix = suffix or ""
	local change = newValue - oldValue
	local newText = string.format("%d%s (%+d)", newValue, suffix, change)
	return string.format("%s: %d%s -> %s", label, oldValue, suffix, ZJItemInfo_Private_ColorChange(newText, change, lowerIsBetter))
end

-- A stat that stays the same, (in the default color)
function ZJItemInfo_Private_FormatSameLine(label, valueText)
	return string.format("%s: %s", label, valueText)
end

function ZJItemInfo_Private_FormatWeaponDamage(weapon)
	local hasDice = weapon.diceCount > 0 and weapon.diceSize > 0
	if not hasDice then return tostring(weapon.bonus) end
	local text = string.format("%dD%d", weapon.diceCount, weapon.diceSize)
	if weapon.bonus ~= 0 then
		text = text..string.format("%+d", weapon.bonus)
	end
	return text
end

function ZJItemInfo_Private_GetWeaponAverageDamage(weapon)
	local average = weapon.bonus
	if weapon.diceCount > 0 and weapon.diceSize > 0 then
		average = average + weapon.diceCount * (weapon.diceSize + 1) / 2
	end
	return average
end

-- The number of proficiency points the character has in a weapon proficiency, (a stat, 0 if the weapon has none)
function ZJItemInfo_Private_GetProficiency(sprite, proficiencyType)
	if proficiencyType == nil or proficiencyType <= 0 then return 0 end
	local ok, value = pcall(function() return sprite:getStat(proficiencyType) end)
	if not ok or type(value) ~= "number" then return 0 end
	return EEex_BAnd(value, 0x7) -- The points of the active class, (a dual-classed character's original class is in the bits above)
end

-- The THAC0 penalty of a class, (CLASS.IDS), for using a weapon it has no proficiency points in. The engine has these
-- built in, (warriors -2, priests and rogues -3, wizards -5), a multi-class character gets the smallest one.
ZJItemInfo_Private_NonProficiencyPenalties = {
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

ZJItemInfo_Private_WeaponSpecialization = nil -- WSPECIAL.2DA, loaded the first time it is needed
ZJItemInfo_Private_WeaponSpecializationCache = {} -- [points] = { hit, damage, speed }

-- The THAC0 bonus, damage bonus and speed factor change of `points` proficiency points, (WSPECIAL.2DA)
function ZJItemInfo_Private_GetSpecializationRow(points)

	local cached = ZJItemInfo_Private_WeaponSpecializationCache[points]
	if cached ~= nil then return cached end

	if ZJItemInfo_Private_WeaponSpecialization == nil then
		ZJItemInfo_Private_WeaponSpecialization = EEex_Resource_Load2DA("WSPECIAL")
	end

	local array = ZJItemInfo_Private_WeaponSpecialization
	local row = { 0, 0, 0 }

	-- More points than the table has rows count as its last row
	for tryPoints = points, 0, -1 do
		local hit = tonumber(array:getAtPoint(0, tryPoints))
		if hit ~= nil then
			row = { hit, tonumber(array:getAtPoint(1, tryPoints)) or 0, tonumber(array:getAtPoint(2, tryPoints)) or 0 }
			break
		end
	end

	ZJItemInfo_Private_WeaponSpecializationCache[points] = row
	return row
end

-- Returns `weapon` with what `sprite`'s proficiency in `proficiencyType` does to it added to its THAC0 bonus, damage
-- bonus and speed factor. A creature without a class, (most monsters), gets no penalty for having no points.
-- The speed factor may go below 0 here: the engine adds the proficiency and the style first, and stops the total at 0,
-- (ZJItemInfo_Private_ApplyStyle()).
function ZJItemInfo_Private_ApplyProficiency(sprite, weapon, proficiencyType)

	local hit, damage, speed = 0, 0, 0

	if proficiencyType ~= nil and proficiencyType > 0 then
		local points = ZJItemInfo_Private_GetProficiency(sprite, proficiencyType)
		if points == 0 then
			local okClass, class = pcall(function() return sprite.m_typeAI.m_Class end)
			hit = okClass and ZJItemInfo_Private_NonProficiencyPenalties[class] or 0
		else
			local okRow, row = pcall(ZJItemInfo_Private_GetSpecializationRow, points)
			if okRow then hit, damage, speed = row[1], row[2], row[3] end
		end
	end

	return {
		["diceCount"]   = weapon.diceCount,
		["diceSize"]    = weapon.diceSize,
		["bonus"]       = weapon.bonus + damage,
		["thac0Bonus"]  = weapon.thac0Bonus + hit,
		["speedFactor"] = weapon.speedFactor + speed,
	}
end

-- The weapon styles, (STYLBONU.2DA row labels), => the stat that holds the character's points in it, (STATS.IDS)
ZJItemInfo_Private_StyleStats = {
	["TWOHANDED"]      = 111,
	["SWORDANDSHIELD"] = 112,
	["SINGLEWEAPON"]   = 113,
	["TWOWEAPON"]      = 114,
}

ZJItemInfo_Private_StyleBonuses = nil -- STYLBONU.2DA, loaded the first time it is needed

-- The weapon style of a character with `mainInfo` in its weapon hand and `offInfo` in its shield hand, (either may be
-- nil), or nil if it fights in no style: without a weapon, or with a ranged one.
function ZJItemInfo_Private_GetWeaponStyle(mainInfo, offInfo)
	if mainInfo == nil or mainInfo.weapon == nil then return nil end
	if ZJItemInfo_Private_LauncherCategories[mainInfo.category] or mainInfo.weapon.ranged then return nil end
	if mainInfo.twoHanded then return "TWOHANDED" end
	if offInfo == nil then return "SINGLEWEAPON" end
	if ZJItemInfo_Private_ShieldCategories[offInfo.category] then return "SWORDANDSHIELD" end
	if offInfo.weapon ~= nil then return "TWOWEAPON" end
	return "SINGLEWEAPON"
end

-- What `sprite` gets from fighting in `style`, (STYLBONU.2DA row of its points in it):
--   damage, thac0Bonus (higher is better), speed (lower is better), armorClass (lower is better), points
function ZJItemInfo_Private_GetStyleBonus(sprite, style)

	local bonus = { ["damage"] = 0, ["thac0Bonus"] = 0, ["speed"] = 0, ["armorClass"] = 0, ["points"] = 0 }
	if style == nil then return bonus end

	local okPoints, points = pcall(function() return sprite:getStat(ZJItemInfo_Private_StyleStats[style]) end)
	points = okPoints and type(points) == "number" and math.max(points, 0) or 0
	bonus.points = points

	if ZJItemInfo_Private_StyleBonuses == nil then
		ZJItemInfo_Private_StyleBonuses = EEex_Resource_Load2DA("STYLBONU")
	end

	local array = ZJItemInfo_Private_StyleBonuses
	local row = style.."-"..points
	local get = function(column) return tonumber(array:getAtLabels(column, row)) or 0 end

	bonus.damage     = get("DAMAGE_RIGHT")
	bonus.thac0Bonus = -get("THAC0_RIGHT") -- The table lowers THAC0, (a positive number is a penalty)
	bonus.speed      = get("SPEED")
	bonus.armorClass = get("AC_BASE")
	return bonus
end

-- The item info in `sprite`'s weapon hand, (nil while ammunition is selected, its launcher is ranged anyway), and in its shield hand
function ZJItemInfo_Private_GetHandInfos(sprite)

	local equipment = sprite.m_equipment
	local items = equipment.m_items

	local getInfo = function(slotNum)
		local item = items:get(slotNum)
		if item == nil then return nil end
		return ZJItemInfo_Private_GetItemInfo(item.cResRef:get())
	end

	local mainInfo = nil
	local selectedWeapon = equipment.m_selectedWeapon
	if selectedWeapon >= 35 and selectedWeapon <= 38 then
		mainInfo = getInfo(selectedWeapon)
	end

	return mainInfo, getInfo(ZJItemInfo_Private_Slot_Shield)
end

-- The item info of the weapon `sprite` attacks with, (the launcher while its ammunition is selected), nil for its fists
function ZJItemInfo_Private_GetWeaponInHand(sprite)

	local equipment = sprite.m_equipment
	local items = equipment.m_items

	local getInfo = function(slotNum)
		local item = items:get(slotNum)
		if item == nil then return nil end
		return ZJItemInfo_Private_GetItemInfo(item.cResRef:get())
	end

	local selectedWeapon = equipment.m_selectedWeapon

	if selectedWeapon >= 35 and selectedWeapon <= 38 then
		return getInfo(selectedWeapon)
	elseif selectedWeapon >= 11 and selectedWeapon <= 14 then
		for weaponSlot = 35, 38 do
			local slotInfo = getInfo(weaponSlot)
			if slotInfo ~= nil and ZJItemInfo_Private_LauncherCategories[slotInfo.category] then
				return slotInfo
			end
		end
	end

	return nil
end

-- What a character without a weapon attacks with, (FIST.ITM)
ZJItemInfo_Private_FistWeapon = {
	["diceCount"]   = 1,
	["diceSize"]    = 2,
	["bonus"]       = 0,
	["thac0Bonus"]  = 0,
	["speedFactor"] = 1,
	["ranged"]      = false,
	["addStrength"] = true,
}

-- The launcher categories => the category of the ammunition they fire, (arrows, bullets, bolts)
ZJItemInfo_Private_LauncherAmmoCategories = { [15] = 5, [18] = 14, [27] = 31 }

-- The item info of the ammunition `sprite` would fire from the launcher of `launcherInfo`: the selected quiver slot if
-- it holds the right kind, else the first quiver slot that does. nil if it has none.
function ZJItemInfo_Private_GetAmmoInfo(sprite, launcherInfo)

	local ammoCategory = ZJItemInfo_Private_LauncherAmmoCategories[launcherInfo.category]
	if ammoCategory == nil then return nil end

	local equipment = sprite.m_equipment
	local items = equipment.m_items

	local getAmmo = function(slotNum)
		local item = items:get(slotNum)
		if item == nil then return nil end
		local ammoInfo = ZJItemInfo_Private_GetItemInfo(item.cResRef:get())
		if ammoInfo == nil or ammoInfo.category ~= ammoCategory or ammoInfo.weapon == nil then return nil end
		return ammoInfo
	end

	local selectedWeapon = equipment.m_selectedWeapon
	if selectedWeapon >= 11 and selectedWeapon <= 14 then
		local ammoInfo = getAmmo(selectedWeapon)
		if ammoInfo ~= nil then return ammoInfo end
	end

	for quiverSlot = 11, 14 do
		local ammoInfo = getAmmo(quiverSlot)
		if ammoInfo ~= nil then return ammoInfo end
	end

	return nil
end

-- Returns the attack of the launcher `launcher` firing `ammo`, (the weapon of an item info, nil for none): the
-- ammunition's damage dice, the bonuses of both, and the launcher's speed factor
function ZJItemInfo_Private_ApplyAmmo(launcher, ammo)

	if ammo == nil then return launcher end

	local diceCount, diceSize = ammo.diceCount, ammo.diceSize
	if not (diceCount > 0 and diceSize > 0) then
		diceCount, diceSize = launcher.diceCount, launcher.diceSize
	elseif launcher.diceCount > 0 and launcher.diceSize == diceSize then
		diceCount = diceCount + launcher.diceCount
	end

	return {
		["diceCount"]   = diceCount,
		["diceSize"]    = diceSize,
		["bonus"]       = launcher.bonus + ammo.bonus,
		["thac0Bonus"]  = launcher.thac0Bonus + ammo.thac0Bonus,
		["speedFactor"] = launcher.speedFactor,
		["ranged"]      = true,
		["addStrength"] = launcher.addStrength or ammo.addStrength,
	}
end

-- Returns the weapon style `sprite` fights in now, and the one it would fight in after equipping the item of `info`
function ZJItemInfo_Private_GetStyleChange(sprite, info)

	local mainInfo, offInfo = ZJItemInfo_Private_GetHandInfos(sprite)
	local oldStyle = ZJItemInfo_Private_GetWeaponStyle(mainInfo, offInfo)

	local slot = ZJItemInfo_Private_CategorySlots[info.category]
	local newMain, newOff = mainInfo, offInfo

	if slot == "weapon" then
		newMain = info
		if info.twoHanded then newOff = nil end
	elseif slot == ZJItemInfo_Private_Slot_Shield then
		newOff = info
	end

	return oldStyle, ZJItemInfo_Private_GetWeaponStyle(newMain, newOff)
end

ZJItemInfo_Private_StrengthMod   = nil -- STRMOD.2DA, loaded the first time it is needed
ZJItemInfo_Private_StrengthModEx = nil -- STRMODEX.2DA, the exceptional strength of 18/01 - 18/00, on top of the row of 18

-- The THAC0 bonus and damage bonus of a strength of `strength`, (and `extra` for exceptional strength)
function ZJItemInfo_Private_GetStrengthBonus(strength, extra)

	if ZJItemInfo_Private_StrengthMod == nil then
		ZJItemInfo_Private_StrengthMod = EEex_Resource_Load2DA("STRMOD")
		ZJItemInfo_Private_StrengthModEx = EEex_Resource_Load2DA("STRMODEX")
	end

	local get = function(array, column, row) return tonumber(array:getAtLabels(column, tostring(row))) or 0 end

	local hit = get(ZJItemInfo_Private_StrengthMod, "TO_HIT", strength)
	local damage = get(ZJItemInfo_Private_StrengthMod, "DAMAGE", strength)

	if strength == 18 and extra > 0 then
		hit = hit + get(ZJItemInfo_Private_StrengthModEx, "TO_HIT", extra)
		damage = damage + get(ZJItemInfo_Private_StrengthModEx, "DAMAGE", extra)
	end

	return hit, damage
end

-- Returns `weapon` with the bonus of `strength` / `extra` added to its THAC0 bonus and damage bonus, if its attack gets it
function ZJItemInfo_Private_ApplyStrength(weapon, addStrength, strength, extra)

	local hit, damage = 0, 0
	if addStrength then
		local ok, okHit, okDamage = pcall(ZJItemInfo_Private_GetStrengthBonus, strength, extra)
		if ok then hit, damage = okHit, okDamage end
	end

	return {
		["diceCount"]   = weapon.diceCount,
		["diceSize"]    = weapon.diceSize,
		["bonus"]       = weapon.bonus + damage,
		["thac0Bonus"]  = weapon.thac0Bonus + hit,
		["speedFactor"] = weapon.speedFactor,
	}
end

ZJItemInfo_Private_DexterityMod = nil -- DEXMOD.2DA, loaded the first time it is needed

-- The THAC0 bonus of a dexterity of `dexterity` with a ranged weapon, (DEXMOD.2DA)
function ZJItemInfo_Private_GetDexterityMissileBonus(dexterity)
	if ZJItemInfo_Private_DexterityMod == nil then
		ZJItemInfo_Private_DexterityMod = EEex_Resource_Load2DA("DEXMOD")
	end
	return tonumber(ZJItemInfo_Private_DexterityMod:getAtLabels("MISSILE", tostring(dexterity))) or 0
end

-- Returns `weapon` with the bonuses of `side` for its kind of attack added to its THAC0 bonus and damage bonus:
-- a ranged attack gets the dexterity missile bonus and the missile bonuses, (op167, op286), a melee one the melee
-- bonuses, (op284, op285), and fists the fist bonuses too, (op288, op289).
--
--   side => dexterity, missileTHAC0, meleeTHAC0, fistTHAC0, missileDamage, meleeDamage, fistDamage
--
function ZJItemInfo_Private_ApplyAttackKind(weapon, kind, side)

	local hit, damage = 0, 0
	if kind == "ranged" then
		local ok, dexHit = pcall(ZJItemInfo_Private_GetDexterityMissileBonus, side.dexterity)
		hit = (ok and dexHit or 0) + side.missileTHAC0
		damage = side.missileDamage
	else
		hit, damage = side.meleeTHAC0, side.meleeDamage
		if kind == "fist" then
			hit, damage = hit + side.fistTHAC0, damage + side.fistDamage
		end
	end

	return {
		["diceCount"]   = weapon.diceCount,
		["diceSize"]    = weapon.diceSize,
		["bonus"]       = weapon.bonus + damage,
		["thac0Bonus"]  = weapon.thac0Bonus + hit,
		["speedFactor"] = weapon.speedFactor,
	}
end

-- Returns `weapon` with `styleBonus` added to its THAC0 bonus, damage bonus and speed factor. This is the last step
-- of an attack, so the speed factor stops at 0 here: a bonus larger than the weapon's own speed does nothing.
function ZJItemInfo_Private_ApplyStyle(weapon, styleBonus)
	return {
		["diceCount"]   = weapon.diceCount,
		["diceSize"]    = weapon.diceSize,
		["bonus"]       = weapon.bonus + styleBonus.damage,
		["thac0Bonus"]  = weapon.thac0Bonus + styleBonus.thac0Bonus,
		["speedFactor"] = math.max(0, weapon.speedFactor + styleBonus.speed),
	}
end

-- Returns the items the character takes off to equip an item of `info`, as an array of { resref, info }
function ZJItemInfo_Private_GetReplacedItems(sprite, info)

	local replaced = {}
	local slot = ZJItemInfo_Private_CategorySlots[info.category]
	if slot == nil then return nil end

	local equipment = sprite.m_equipment
	local items = equipment.m_items

	local getSlotInfo = function(slotNum)
		local item = items:get(slotNum)
		if item == nil then return nil, nil end
		local resref = item.cResRef:get()
		return resref, ZJItemInfo_Private_GetItemInfo(resref)
	end

	local addSlot = function(slotNum)
		local resref, slotInfo = getSlotInfo(slotNum)
		if slotInfo ~= nil then
			table.insert(replaced, { ["resref"] = resref:upper(), ["info"] = slotInfo })
		end
	end

	if slot == "ring" then

		-- A ring goes on the free hand if there is one
		if items:get(ZJItemInfo_Private_Slot_RingLeft) ~= nil and items:get(ZJItemInfo_Private_Slot_RingRight) ~= nil then
			addSlot(ZJItemInfo_Private_Slot_RingLeft)
		end

	elseif slot == "weapon" then

		local selectedWeapon = equipment.m_selectedWeapon

		if selectedWeapon >= 35 and selectedWeapon <= 38 then
			addSlot(selectedWeapon)
		elseif selectedWeapon >= 11 and selectedWeapon <= 14 then
			-- Ammunition is selected, the weapon in hand is its launcher
			for weaponSlot = 35, 38 do
				local _, slotInfo = getSlotInfo(weaponSlot)
				if slotInfo ~= nil and ZJItemInfo_Private_LauncherCategories[slotInfo.category] then
					addSlot(weaponSlot)
					break
				end
			end
		end

		-- A two-handed weapon leaves no hand for a shield / an off-hand weapon
		if info.twoHanded then
			addSlot(ZJItemInfo_Private_Slot_Shield)
		end
	else
		addSlot(slot)
	end

	return replaced
end

-- Returns the lines that tell how the stats of `sprite` change if it equips the item of `info`, in place of the
-- item(s) in `replaced`. The first line is the heading. Returns nil if the item isn't something that is equipped.
--
-- This adds up what the equipped effects of the items say they do, it doesn't equip anything. Not looked at:
-- effects that only apply under a condition, bonuses that don't stack, and
-- what a changed ability score does to other stats, (e.g. dexterity to armor class).
function ZJItemInfo_Private_GetComparisonLines(sprite, info)

	local replaced = ZJItemInfo_Private_GetReplacedItems(sprite, info)
	if replaced == nil then return nil end

	local lines = {}

	------------
	-- Header --
	------------

	local replacedNames = {}
	for _, replacedItem in ipairs(replaced) do
		local name = ZJItemInfo_Private_GetItemName(replacedItem.info, true)
		if name ~= "" then
			table.insert(replacedNames, name)
		end
	end

	local spriteName = sprite:getName()

	if #replacedNames > 0 then
		table.insert(lines, string.format(ZJItemInfo_Private_T("IfEquippedReplacing"), spriteName, table.concat(replacedNames, ", ")))
	else
		table.insert(lines, string.format(ZJItemInfo_Private_T("IfEquipped"), spriteName))
	end

	lines[1] = ZJItemInfo_Private_DimColorStr..lines[1]..ZJItemInfo_Private_ColorEndStr

	------------
	-- Totals --
	------------

	local totals = {
		["add"]             = {},
		["set"]             = {},
		["unset"]           = {},
		["armorClassBonus"] = 0,
		["armorClassTypes"] = {},
		["attackHalves"]    = 0,
	}

	local replacedResrefs = {}

	for _, replacedItem in ipairs(replaced) do
		replacedResrefs[replacedItem.resref] = true
		ZJItemInfo_Private_AddEquippedEffects(totals, replacedItem.info, -1)
	end

	ZJItemInfo_Private_AddEquippedEffects(totals, info, 1)

	-----------------
	-- Armor class --
	-----------------

	-- The base armor class is the lowest one that anything on the character sets, a bonus is taken off it
	local armorClassChange = -totals.armorClassBonus

	if totals.armorClassBaseChanges then

		local oldBase = sprite.m_baseStats.m_armorClass
		local newBase = oldBase

		local scanEffects = function(effectList)
			EEex_Utility_IterateCPtrList(effectList, function(effect)
				if effect.m_effectId == 0 and effect.m_dWFlags == 16 then
					local base = effect.m_effectAmount
					if base < oldBase then oldBase = base end
					if base < newBase and not replacedResrefs[effect.m_sourceRes:get():upper()] then newBase = base end
				end
			end)
		end

		scanEffects(sprite.m_equipedEffectList)
		scanEffects(sprite.m_timedEffectList)

		if totals.armorClassBase ~= nil and totals.armorClassBase < newBase then
			newBase = totals.armorClassBase
		end

		armorClassChange = armorClassChange + (newBase - oldBase)
	end

	-- The weapon style changes with what is in the character's hands, (a two-handed weapon in place of a sword and shield)
	local okStyle, oldStyle, newStyle = pcall(ZJItemInfo_Private_GetStyleChange, sprite, info)
	if not okStyle then oldStyle, newStyle = nil, nil end

	local oldStyleBonus = ZJItemInfo_Private_GetStyleBonus(sprite, nil)
	local newStyleBonus = oldStyleBonus

	if oldStyle ~= newStyle then
		local okOld, oldBonus = pcall(ZJItemInfo_Private_GetStyleBonus, sprite, oldStyle)
		local okNew, newBonus = pcall(ZJItemInfo_Private_GetStyleBonus, sprite, newStyle)
		if okOld and okNew then
			oldStyleBonus, newStyleBonus = oldBonus, newBonus
			armorClassChange = armorClassChange + (newBonus.armorClass - oldBonus.armorClass)
		else
			oldStyle, newStyle = nil, nil
		end
	else
		-- Same style, its bonus is the same on both sides of the comparison
		local okBonus, bonus = pcall(ZJItemInfo_Private_GetStyleBonus, sprite, oldStyle)
		if okBonus then oldStyleBonus, newStyleBonus = bonus, bonus end
	end

	totals.add["ArmorClass"] = armorClassChange

	-----------
	-- Stats --
	-----------

	local stats = sprite:getActiveStats()
	local baseStats = sprite.m_baseStats
	local newValues = {} -- [stat key] = its value after the change, for the stats that change

	-- The THAC0 line is added once the weapon in hand is worked out, (the stat leaves out its bonuses), at this index,
	-- with the attacks per round line below it
	local thac0LineIndex = nil
	local damageLineIndex = nil -- Where the damage of the weapon in hand goes, for an item that isn't a weapon

	-- On a weapon the armor class and maximum hit points are only listed when they change, on anything else, (armor,
	-- bracers, rings, ...), the THAC0 and attacks per round
	local isWeaponItem = ZJItemInfo_Private_CategorySlots[info.category] == "weapon"
	local isArmor = not isWeaponItem

	-- The armor class against each kind of attack, (the armor class plus the modifier against it), is compared as a
	-- whole: a worse modifier on a better armor can still leave the character better off. A kind with no modifier on
	-- either side would only repeat the armor class line. They go below the armor class line.
	local addArmorClassTypeLines = function()

		local oldArmorClass = stats.m_nArmorClass
		local newArmorClass = newValues["ArmorClass"] or oldArmorClass

		for _, armorClassType in ipairs(ZJItemInfo_Private_ArmorClassTypes) do
			local oldMod = stats[armorClassType.field]
			-- An op0 bonus lowers the modifier
			local newMod = oldMod - (totals.armorClassTypes[armorClassType.flag] or 0)
			if oldMod ~= 0 or newMod ~= 0 then
				local label = ZJItemInfo_Private_T("Stat_"..armorClassType.key)
				local oldValue, newValue = oldArmorClass + oldMod, newArmorClass + newMod
				if oldValue == newValue then
					if isArmor then
						table.insert(lines, ZJItemInfo_Private_FormatSameLine(label, tostring(newValue)))
					end
				else
					table.insert(lines, ZJItemInfo_Private_FormatChangeLine(label, oldValue, newValue, true))
				end
			end
		end
	end

	for _, stat in ipairs(ZJItemInfo_Private_Stats) do

		local key = stat.key
		local oldValue = stats[stat.field]
		local newValue = nil

		if totals.set[key] ~= nil then
			newValue = totals.set[key]
		elseif totals.unset[key] then
			-- What the stat falls back to is only known for the ability scores
			if stat.baseField ~= nil then
				newValue = baseStats[stat.baseField] + (totals.add[key] or 0)
			end
		elseif (totals.add[key] or 0) ~= 0 then
			newValue = oldValue + totals.add[key]
		end

		if newValue ~= nil and newValue ~= oldValue then
			newValues[key] = newValue
		end

		if key == "THAC0" then
			thac0LineIndex = #lines + 1
		elseif key == "DamageBonus" and info.weapon ~= nil and ZJItemInfo_Private_ShowWeaponStats:get() ~= 0 then
			-- It is part of the weapon damage below
		elseif key == "DamageBonus" and ZJItemInfo_Private_ShowWeaponStats:get() ~= 0 then
			-- It is shown as the damage of the weapon in hand below, (where it would have been)
			damageLineIndex = #lines + 1
		elseif newValue ~= nil and newValue ~= oldValue then
			table.insert(lines, ZJItemInfo_Private_FormatChangeLine(ZJItemInfo_Private_T("Stat_"..key), oldValue, newValue, stat.lowerIsBetter, stat.suffix))
		elseif stat.always and (key == "ArmorClass") == isArmor and not (key == "MaxHitPoints" and isWeaponItem) then
			table.insert(lines, ZJItemInfo_Private_FormatSameLine(ZJItemInfo_Private_T("Stat_"..key), string.format("%d%s", oldValue, stat.suffix or "")))
		end

		if key == "ArmorClass" then addArmorClassTypeLines() end
	end

	-----------------------
	-- Attacks per round --
	-----------------------

	-- The current number, (which the engine worked out), plus what changes: the items' op1 effects, the proficiency
	-- points in the weapon in hand, (melee only), and the extra attack of a weapon in the off hand. An item that sets
	-- the number, (a bow sets 2), replaces all of that; once it is taken off, the number is worked out again from 1.
	local okAttacks, attackLine = pcall(function()

		local oldHalves = ZJItemInfo_Private_DecodeAttacks(stats.m_nNumberOfAttacks)
		local isWeapon = ZJItemInfo_Private_CategorySlots[info.category] == "weapon"

		local oldInfo = nil
		if isWeapon then
			local oldItem = replaced[1]
			oldInfo = oldItem and ZJItemInfo_Private_CategorySlots[oldItem.info.category] == "weapon" and oldItem.info or nil
		end

		local weaponAttacks = function(weaponInfo)
			if weaponInfo ~= nil and ZJItemInfo_Private_IsRangedWeapon(weaponInfo) then return 0 end
			local points = weaponInfo and ZJItemInfo_Private_GetProficiency(sprite, weaponInfo.proficiencyType) or 0
			return ZJItemInfo_Private_GetProficiencyAttacks(sprite, points)
		end

		local offHandAttacks = function(style) return style == "TWOWEAPON" and 2 or 0 end

		local newHalves

		if totals.attacksSet ~= nil then
			newHalves = totals.attacksSet
		elseif totals.attacksUnset then
			-- Only for a weapon that is put in hand is it known what the number is without the item
			if not isWeapon then return nil end
			newHalves = 2 + totals.attackHalves + weaponAttacks(info) + offHandAttacks(newStyle)
		else
			newHalves = oldHalves + totals.attackHalves
			if isWeapon then
				newHalves = newHalves + weaponAttacks(info) - weaponAttacks(oldInfo)
			end
			newHalves = newHalves + offHandAttacks(newStyle) - offHandAttacks(oldStyle)
		end

		newHalves = math.max(newHalves, 0)
		if newHalves == oldHalves then
			if isArmor then return nil end
			return ZJItemInfo_Private_FormatSameLine(ZJItemInfo_Private_T("Stat_AttacksPerRound"), ZJItemInfo_Private_FormatAttacks(oldHalves))
		end

		local change = newHalves - oldHalves
		local changeText = change % 2 == 0 and string.format("%+d", change / 2) or string.format("%s%d/2", change < 0 and "-" or "+", math.abs(change))

		return string.format("%s: %s -> %s", ZJItemInfo_Private_T("Stat_AttacksPerRound"), ZJItemInfo_Private_FormatAttacks(oldHalves),
			ZJItemInfo_Private_ColorChange(string.format("%s (%s)", ZJItemInfo_Private_FormatAttacks(newHalves), changeText), change, false))
	end)

	-- It goes below the THAC0 line
	if not okAttacks then attackLine = nil end

	------------
	-- Weapon --
	------------

	-- The weapon in hand before and after, (the item itself if it is a weapon, else the weapon it doesn't touch). The
	-- one it replaces is the first item that is taken off, (the second one is the shield, for a two-handed weapon).
	local isWeapon = ZJItemInfo_Private_CategorySlots[info.category] == "weapon"
	local oldInfo, newInfo

	if isWeapon then
		local oldItem = replaced[1]
		oldInfo = oldItem and ZJItemInfo_Private_CategorySlots[oldItem.info.category] == "weapon" and oldItem.info or nil
		newInfo = info
	else
		local okHand, handInfo = pcall(ZJItemInfo_Private_GetWeaponInHand, sprite)
		oldInfo = okHand and handInfo or nil
		newInfo = oldInfo
	end

	-- The character's strength, now and with the item equipped, (exceptional strength only counts while it stays 18)
	local oldStrength, oldExtra = stats.m_nSTR, stats.m_nSTRExtra
	local newStrength = newValues["STR"] or oldStrength
	local newExtra = newStrength == oldStrength and oldExtra or 0

	-- The weapon as the character would use it, with its strength bonus, its proficiency in it, and the weapon style it
	-- fights in with it. No weapon is a fist, a launcher fires the ammunition the character has for it.
	local applyAll = function(weaponInfo, strength, extra, styleBonus, side)
		local weapon = weaponInfo and weaponInfo.weapon or ZJItemInfo_Private_FistWeapon
		local kind = "fist"
		if weaponInfo ~= nil and weaponInfo.weapon ~= nil then
			kind = ZJItemInfo_Private_IsRangedWeapon(weaponInfo) and "ranged" or "melee"
		end
		if weapon.launcher then
			local ammoInfo = ZJItemInfo_Private_GetAmmoInfo(sprite, weaponInfo)
			weapon = ZJItemInfo_Private_ApplyAmmo(weapon, ammoInfo and ammoInfo.weapon or nil)
		end
		weapon = ZJItemInfo_Private_ApplyStrength(weapon, weapon.addStrength, strength, extra)
		weapon = ZJItemInfo_Private_ApplyProficiency(sprite, weapon, weaponInfo and weaponInfo.weapon and weaponInfo.proficiencyType or nil)
		weapon = ZJItemInfo_Private_ApplyAttackKind(weapon, kind, side)
		return ZJItemInfo_Private_ApplyStyle(weapon, styleBonus)
	end

	-- The character's bonuses for each kind of attack, now and with the item equipped
	local oldSide = {
		["dexterity"]     = stats.m_nDEX,
		["missileTHAC0"]  = stats.m_nMissileTHAC0Bonus,
		["meleeTHAC0"]    = stats.m_nMeleeTHAC0Bonus,
		["fistTHAC0"]     = stats.m_nFistTHAC0Bonus,
		["missileDamage"] = stats.m_nMissileDamageBonus,
		["meleeDamage"]   = stats.m_nMeleeDamageBonus,
		["fistDamage"]    = stats.m_nFistDamageBonus,
	}
	local newSide = {
		["dexterity"]     = newValues["DEX"] or oldSide.dexterity,
		["missileTHAC0"]  = oldSide.missileTHAC0 + (totals.add["MissileTHAC0"] or 0),
		["meleeTHAC0"]    = oldSide.meleeTHAC0 + (totals.add["MeleeTHAC0"] or 0),
		["fistTHAC0"]     = oldSide.fistTHAC0 + (totals.add["FistTHAC0"] or 0),
		["missileDamage"] = oldSide.missileDamage + (totals.add["MissileDamage"] or 0),
		["meleeDamage"]   = oldSide.meleeDamage + (totals.add["MeleeDamage"] or 0),
		["fistDamage"]    = oldSide.fistDamage + (totals.add["FistDamage"] or 0),
	}

	local okOld, oldWeapon = pcall(applyAll, oldInfo, oldStrength, oldExtra, oldStyleBonus, oldSide)
	local okNew, newWeapon = pcall(applyAll, newInfo, newStrength, newExtra, newStyleBonus, newSide)

	-- An item that isn't a weapon: the damage of the weapon in hand, (its damage bonus and strength change it), in
	-- place of the damage bonus line. It goes in before the THAC0 lines, which come before it.
	if damageLineIndex ~= nil then
		local oldDamageBonus = stats.m_nDamageBonus
		local newDamageBonus = newValues["DamageBonus"] or oldDamageBonus
		if okOld and okNew then
			local oldShown = { diceCount = oldWeapon.diceCount, diceSize = oldWeapon.diceSize, bonus = oldWeapon.bonus + oldDamageBonus }
			local newShown = { diceCount = newWeapon.diceCount, diceSize = newWeapon.diceSize, bonus = newWeapon.bonus + newDamageBonus }
			local oldDamage = ZJItemInfo_Private_FormatWeaponDamage(oldShown)
			local newDamage = ZJItemInfo_Private_FormatWeaponDamage(newShown)
			if oldDamage ~= newDamage then
				local change = ZJItemInfo_Private_GetWeaponAverageDamage(newShown) - ZJItemInfo_Private_GetWeaponAverageDamage(oldShown)
				table.insert(lines, damageLineIndex, string.format("%s: %s -> %s", ZJItemInfo_Private_T("Weapon_Damage"), oldDamage,
					ZJItemInfo_Private_ColorChange(string.format("%s (%+d)", newDamage, newShown.bonus - oldShown.bonus), change, false)))
			end
		elseif newDamageBonus ~= oldDamageBonus then
			table.insert(lines, damageLineIndex, ZJItemInfo_Private_FormatChangeLine(ZJItemInfo_Private_T("Stat_DamageBonus"), oldDamageBonus, newDamageBonus))
		end
	end

	-- THAC0, (the stat leaves out what the weapon in hand adds to it, as does the inventory screen's)
	if thac0LineIndex ~= nil then
		local oldTHAC0 = stats.m_nTHAC0
		local newTHAC0 = newValues["THAC0"] or oldTHAC0
		if okOld and okNew then
			oldTHAC0 = oldTHAC0 - oldWeapon.thac0Bonus
			newTHAC0 = newTHAC0 - newWeapon.thac0Bonus
		end
		local label = ZJItemInfo_Private_T("Stat_THAC0")
		local attackIndex = thac0LineIndex
		if oldTHAC0 ~= newTHAC0 then
			table.insert(lines, thac0LineIndex, ZJItemInfo_Private_FormatChangeLine(label, oldTHAC0, newTHAC0, true))
			attackIndex = attackIndex + 1
		elseif not isArmor then
			table.insert(lines, thac0LineIndex, ZJItemInfo_Private_FormatSameLine(label, tostring(newTHAC0)))
			attackIndex = attackIndex + 1
		end
		if attackLine ~= nil then table.insert(lines, attackIndex, attackLine); attackLine = nil end
	end

	if isWeapon and info.weapon ~= nil and okOld and okNew and ZJItemInfo_Private_ShowWeaponStats:get() ~= 0 then

		-- The character's damage bonus, (op73 etc.), adds to the damage of every weapon
		local oldDamageBonus = stats.m_nDamageBonus
		local newDamageBonus = newValues["DamageBonus"] or oldDamageBonus
		newWeapon.bonus = newWeapon.bonus + newDamageBonus

		local newDamage = ZJItemInfo_Private_FormatWeaponDamage(newWeapon)

		if oldInfo == nil or oldInfo.weapon == nil then
			-- A weapon where there was none
			table.insert(lines, string.format("%s: %s", ZJItemInfo_Private_T("Weapon_Damage"), newDamage))
			table.insert(lines, string.format("%s: %d", ZJItemInfo_Private_T("Weapon_SpeedFactor"), newWeapon.speedFactor))
		else
			oldWeapon.bonus = oldWeapon.bonus + oldDamageBonus

			local oldDamage = ZJItemInfo_Private_FormatWeaponDamage(oldWeapon)
			if oldDamage == newDamage then
				table.insert(lines, ZJItemInfo_Private_FormatSameLine(ZJItemInfo_Private_T("Weapon_Damage"), newDamage))
			else
				local change = ZJItemInfo_Private_GetWeaponAverageDamage(newWeapon) - ZJItemInfo_Private_GetWeaponAverageDamage(oldWeapon)
				table.insert(lines, string.format("%s: %s -> %s", ZJItemInfo_Private_T("Weapon_Damage"), oldDamage,
					ZJItemInfo_Private_ColorChange(newDamage, change, false)))
			end

			if oldWeapon.speedFactor == newWeapon.speedFactor then
				table.insert(lines, ZJItemInfo_Private_FormatSameLine(ZJItemInfo_Private_T("Weapon_SpeedFactor"), tostring(newWeapon.speedFactor)))
			else
				local change = newWeapon.speedFactor - oldWeapon.speedFactor
				table.insert(lines, string.format("%s: %d -> %s", ZJItemInfo_Private_T("Weapon_SpeedFactor"), oldWeapon.speedFactor,
					ZJItemInfo_Private_ColorChange(tostring(newWeapon.speedFactor), change, true)))
			end
		end
	end

	if attackLine ~= nil then
		table.insert(lines, attackLine)
	end

	return lines
end

-------------------
-- Using an item --
-------------------

-- ITM ability targets that use the item on its user, (a potion is drunk, not aimed). An ability aimed at a creature or
-- a point, (a wand, a thrown potion), is described by the Spell Info module once a target is under the cursor.
ZJItemInfo_Private_SelfUseTargets = { [5] = true, [7] = true }

-- Effect targets that land on the user of a self-used item: self, preset, party, everyone, original caster
ZJItemInfo_Private_UserEffectTargets = { [1] = true, [2] = true, [3] = true, [4] = true, [9] = true }

-- Opcodes that cast another spell. The spell's effects are read too, (one level deep).
ZJItemInfo_Private_CastSpellOpcodes = { [146] = true, [326] = true }

-- Effects that are listed by name:
--
--   [1]     => Its name is the string "Use_<key>"
--   good    => true if it helps the user, false if it harms it, nil if it is neither
--   instant => true if it happens once, (it never has a duration)
--
ZJItemInfo_Private_UseStatusOpcodes = {
	[11]  = { "CurePoison",   ["good"] = true,  ["instant"] = true },
	[13]  = { "Death",        ["good"] = false, ["instant"] = true },
	[16]  = { "Haste",        ["good"] = true  },
	[20]  = { "Invisibility", ["good"] = true  },
	[25]  = { "Poison",       ["good"] = false },
	[40]  = { "Slow",         ["good"] = false },
	[46]  = { "CureStun",     ["good"] = true,  ["instant"] = true },
	[58]  = { "DispelMagic",  ["good"] = false, ["instant"] = true },
	[63]  = { "Infravision",  ["good"] = true  },
	[74]  = { "Blindness",    ["good"] = false },
	[76]  = { "Feeblemind",   ["good"] = false },
	[79]  = { "CureDisease",  ["good"] = true,  ["instant"] = true },
	[94]  = { "Intoxication" },
	[98]  = { "Regeneration", ["good"] = true  },
	[162] = { "CureHold",     ["good"] = true,  ["instant"] = true },
	[163] = { "FreeAction",   ["good"] = true  },
}

-- op101, (immunity to an effect): the opcodes worth naming
ZJItemInfo_Private_ImmunityNames = {
	[  3] = "berserk",        [  5] = "charm",          [ 13] = "death",          [ 24] = "fear",
	[ 25] = "poison",         [ 38] = "silence",        [ 39] = "sleep",          [ 40] = "slow",
	[ 45] = "stun",           [ 55] = "death",          [ 74] = "blindness",      [ 76] = "feeblemind",
	[ 78] = "disease",        [ 80] = "deafness",       [109] = "hold",           [126] = "movement penalties",
	[128] = "confusion",      [134] = "petrification",  [135] = "polymorph",      [154] = "entangle",
	[157] = "web",            [158] = "grease",         [175] = "hold",           [185] = "hold",
	[209] = "death",          [216] = "level drain",
}

function ZJItemInfo_Private_ReadResref(address)
	local chars = {}
	for i = 0, 7 do
		local byte = EEex_ReadU8(address + i)
		if byte == 0 then break end
		chars[#chars + 1] = string.char(byte)
	end
	return table.concat(chars):upper()
end

-- Appends the effects of the SPL / ITM ability at `abilityAddress` that land on its user to `effects`, (both keep their
-- effect count at 0x1E and their first effect index at 0x20, and the offset of their effects at 0x6A of the header)
function ZJItemInfo_Private_ReadUseEffects(headerAddress, abilityAddress, effects, depth)

	local effectsAddress = headerAddress + EEex_ReadU32(headerAddress + 0x6A)
	local count = EEex_ReadU16(abilityAddress + 0x1E)
	local first = EEex_ReadU16(abilityAddress + 0x20)

	for i = first, first + count - 1 do

		local address = effectsAddress + 0x30 * i

		local effect = {
			["opcode"]   = EEex_ReadU16(address),
			["target"]   = EEex_ReadU8(address + 0x2),
			["param1"]   = EEex_Read32(address + 0x4),
			["param2"]   = EEex_ReadU32(address + 0x8),
			["timing"]   = EEex_ReadU8(address + 0xC),
			["duration"] = EEex_ReadU32(address + 0xE),
			["res"]      = ZJItemInfo_Private_ReadResref(address + 0x14),
			["numDice"]  = EEex_ReadU32(address + 0x1C),
			["diceSize"] = EEex_ReadU32(address + 0x20),
		}

		if ZJItemInfo_Private_UserEffectTargets[effect.target] then

			table.insert(effects, effect)

			if ZJItemInfo_Private_CastSpellOpcodes[effect.opcode] and depth < 1 and effect.res ~= "" then
				local spellHeader = EEex_Resource_Demand(effect.res, "SPL")
				local spellAbility = spellHeader and spellHeader:getAbility(0)
				if spellAbility ~= nil then
					ZJItemInfo_Private_ReadUseEffects(EEex_UDToPtr(spellHeader), EEex_UDToPtr(spellAbility), effects, depth + 1)
				end
			end
		end
	end
end

-- "10 turns", "3 rounds", "8 seconds", (a round is 6 seconds, a turn 10 rounds)
function ZJItemInfo_Private_FormatDuration(seconds)
	if seconds >= 60 and seconds % 60 == 0 then
		return string.format(ZJItemInfo_Private_T(seconds == 60 and "Turn" or "Turns"), seconds / 60)
	elseif seconds >= 6 and seconds % 6 == 0 then
		return string.format(ZJItemInfo_Private_T(seconds == 6 and "Round" or "Rounds"), seconds / 6)
	end
	return string.format(ZJItemInfo_Private_T("Seconds"), seconds)
end

-- How long an effect lasts: a number of seconds, "permanent", or nil if it happens once / isn't known
function ZJItemInfo_Private_GetEffectDuration(effect)
	if effect.timing == 0 and effect.duration > 0 then return effect.duration end
	if effect.timing == 1 or effect.timing == 9 then return "permanent" end
	return nil
end

function ZJItemInfo_Private_FormatEffectDuration(duration)
	if duration == "permanent" then return ZJItemInfo_Private_T("Permanent") end
	return ZJItemInfo_Private_FormatDuration(duration)
end

-- "1-5" for consecutive numbers, "1, 3" otherwise
function ZJItemInfo_Private_FormatLevels(levels)
	table.sort(levels)
	local consecutive = true
	for i = 2, #levels do
		if levels[i] ~= levels[i - 1] + 1 then consecutive = false end
	end
	if consecutive and #levels > 2 then
		return string.format("%d-%d", levels[1], levels[#levels])
	end
	local strs = {}
	for _, level in ipairs(levels) do table.insert(strs, tostring(level)) end
	return table.concat(strs, ", ")
end

-- Returns the lines that tell what happens to `sprite` if it uses the ability `use` describes, (see
-- ZJItemInfo_Private_FindHoveredQuickItem()). The first line is the heading.
--
-- This reads the effects the ability says it applies and works them out against the character's current stats, it
-- doesn't use anything. Not looked at: effects that don't stack with what the character already has, and what a
-- changed ability score does to other stats.
function ZJItemInfo_Private_GetUseLines(sprite, use)

	local effects = {}
	ZJItemInfo_Private_ReadUseEffects(use.headerAddress, use.abilityAddress, effects, 0)

	local spriteName = sprite:getName()
	local lines = { ZJItemInfo_Private_DimColorStr..string.format(ZJItemInfo_Private_T("IfUsed"), spriteName)..ZJItemInfo_Private_ColorEndStr }
	local good, bad = ZJItemInfo_Private_BetterColorStr(), ZJItemInfo_Private_WorseColorStr()
	local colorEnd = ZJItemInfo_Private_ColorEndStr

	-- How often each duration comes up, the most common one is said once at the end instead of on every line
	local durationCounts = {}
	local countDuration = function(duration)
		if duration ~= nil then durationCounts[duration] = (durationCounts[duration] or 0) + 1 end
	end

	------------------------------
	-- The item's own exclusion --
	------------------------------

	-- op324: the item does nothing to a creature that matches a SPLPROT.2DA row, (worked out by the Spell Info module)
	if type(ZJSpellInfo_Private_CheckSplprot) == "function" then
		for _, effect in ipairs(effects) do
			if effect.opcode == 324 then
				local ok, matches, label = pcall(ZJSpellInfo_Private_CheckSplprot, sprite, effect.param2, effect.param1)
				if ok and matches then
					table.insert(lines, bad..string.format(ZJItemInfo_Private_T("Use_Excluded"), label or "")..colorEnd)
					return lines
				end
			end
		end
	end

	-----------
	-- Stats --
	-----------

	local stats = sprite:getActiveStats()
	local values, durations, statByKey = {}, {}, {}
	for _, stat in ipairs(ZJItemInfo_Private_Stats) do
		statByKey[stat.key] = stat
		values[stat.key] = stats[stat.field]
	end

	local applyStat = function(key, mode, amount, sign, canSet, duration)
		local value = values[key]
		if value == nil then return end
		if mode == 0 then
			value = value + amount * (sign or 1)
		elseif mode == 1 and canSet then
			value = amount
		elseif mode == 2 then
			value = math.floor(value * amount / 100)
		else
			return
		end
		values[key] = value
		if duration ~= nil then durations[key] = duration end
	end

	-- Armor class: a bonus lowers it, a base armor class only counts if it is better than the one the character has
	local armorClassTypes = {}
	local oldArmorClassBase = nil

	for _, effect in ipairs(effects) do

		local opcode, amount, mode = effect.opcode, effect.param1, effect.param2
		local duration = ZJItemInfo_Private_GetEffectDuration(effect)

		if opcode == 0 then
			if mode == 0 then
				applyStat("ArmorClass", 0, -amount, 1, false, duration)
			elseif mode == 16 then
				if oldArmorClassBase == nil then
					oldArmorClassBase = sprite.m_baseStats.m_armorClass
					local scanEffects = function(effectList)
						EEex_Utility_IterateCPtrList(effectList, function(active)
							if active.m_effectId == 0 and active.m_dWFlags == 16 and active.m_effectAmount < oldArmorClassBase then
								oldArmorClassBase = active.m_effectAmount
							end
						end)
					end
					scanEffects(sprite.m_equipedEffectList)
					scanEffects(sprite.m_timedEffectList)
				end
				if amount < oldArmorClassBase then
					applyStat("ArmorClass", 0, amount - oldArmorClassBase, 1, false, duration)
					oldArmorClassBase = amount
				end
			else
				for _, armorClassType in ipairs(ZJItemInfo_Private_ArmorClassTypes) do
					if EEex_BAnd(mode, armorClassType.flag) ~= 0 then
						armorClassTypes[armorClassType.flag] = (armorClassTypes[armorClassType.flag] or 0) + amount
					end
				end
			end
			countDuration(duration)
		else
			local opcodeStats = ZJItemInfo_Private_OpcodeStats[opcode]
			if opcodeStats ~= nil then
				for _, key in ipairs(opcodeStats.stats) do
					applyStat(key, mode, amount, opcodeStats.sign, opcodeStats.canSet, duration)
				end
				countDuration(duration)
			end
		end
	end

	-- Durations are filled in at the end, once the most common one is known
	local pending = {} -- Array of { text, duration }

	for _, stat in ipairs(ZJItemInfo_Private_Stats) do
		local key = stat.key
		local oldValue, newValue = stats[stat.field], values[key]
		if newValue ~= oldValue then
			table.insert(pending, { ZJItemInfo_Private_FormatChangeLine(ZJItemInfo_Private_T("Stat_"..key), oldValue, newValue,
				stat.lowerIsBetter, stat.suffix), durations[key] })
		end
	end

	for _, armorClassType in ipairs(ZJItemInfo_Private_ArmorClassTypes) do
		-- The armor class against that kind of attack, (the armor class plus the modifier against it), an op0 bonus lowers the modifier
		local bonus = armorClassTypes[armorClassType.flag] or 0
		if bonus ~= 0 then
			local mod = stats[armorClassType.field]
			table.insert(pending, { ZJItemInfo_Private_FormatChangeLine(ZJItemInfo_Private_T("Stat_"..armorClassType.key),
				stats.m_nArmorClass + mod, values["ArmorClass"] + mod - bonus, true), nil })
		end
	end

	-----------------
	-- Hit points --
	-----------------

	local maxHitPoints = values["MaxHitPoints"]
	local oldHitPoints = sprite.m_baseStats.m_hitPoints
	local hitPoints = oldHitPoints
	local heals, damage = false, {}

	for _, effect in ipairs(effects) do
		if effect.opcode == 17 then
			heals = true
			local mode = EEex_BAnd(effect.param2, 0xFFFF)
			if mode == 0 then
				hitPoints = hitPoints + effect.param1
			elseif mode == 1 then
				hitPoints = effect.param1
			elseif mode == 2 then
				hitPoints = hitPoints + math.floor(maxHitPoints * effect.param1 / 100)
			end
		elseif effect.opcode == 12 then
			local amountStr = tostring(effect.param1)
			if effect.numDice > 0 and effect.diceSize > 0 then
				amountStr = string.format("%dD%d", effect.numDice, effect.diceSize)
				if effect.param1 ~= 0 then amountStr = amountStr..string.format("%+d", effect.param1) end
			end
			table.insert(damage, amountStr)
		end
	end

	if heals then
		hitPoints = math.max(0, math.min(hitPoints, maxHitPoints))
		local label = ZJItemInfo_Private_T("Stat_HitPoints")
		if hitPoints == oldHitPoints then
			table.insert(lines, string.format("%s: %d/%d %s(%s)%s", label, oldHitPoints, maxHitPoints,
				ZJItemInfo_Private_DimColorStr, ZJItemInfo_Private_T("Use_AlreadyFull"), colorEnd))
		else
			local change = hitPoints - oldHitPoints
			local newText = string.format("%d/%d (%+d)", hitPoints, maxHitPoints, change)
			table.insert(lines, string.format("%s: %d/%d -> %s", label, oldHitPoints, maxHitPoints,
				ZJItemInfo_Private_ColorChange(newText, change, false)))
		end
	end

	if #damage > 0 then
		table.insert(lines, bad..string.format(ZJItemInfo_Private_T("Use_Damage"), table.concat(damage, " + "))..colorEnd)
	end

	--------------
	-- Statuses --
	--------------

	local seenStatuses = {}
	local immunities, seenImmunities, immunityDuration = {}, {}, nil
	local spellLevels, seenSpellLevels, spellLevelDuration = {}, {}, nil

	for _, effect in ipairs(effects) do

		local opcode = effect.opcode
		local duration = ZJItemInfo_Private_GetEffectDuration(effect)
		local status = ZJItemInfo_Private_UseStatusOpcodes[opcode]

		if status ~= nil and not seenStatuses[opcode] then
			seenStatuses[opcode] = true
			local text = ZJItemInfo_Private_T("Use_"..status[1])
			if status.good == true then
				text = good..text..colorEnd
			elseif status.good == false then
				text = bad..text..colorEnd
			end
			if status.instant then duration = nil end
			table.insert(pending, { text, duration })
			countDuration(duration)

		elseif opcode == 101 then
			local name = ZJItemInfo_Private_ImmunityNames[effect.param2]
			if name ~= nil and not seenImmunities[name] then
				seenImmunities[name] = true
				table.insert(immunities, name)
				immunityDuration = duration
				countDuration(duration)
			end

		elseif opcode == 102 and effect.param1 > 0 and not seenSpellLevels[effect.param1] then
			seenSpellLevels[effect.param1] = true
			table.insert(spellLevels, effect.param1)
			spellLevelDuration = duration
			countDuration(duration)
		end
	end

	if #immunities > 0 then
		table.insert(pending, { good..string.format(ZJItemInfo_Private_T("Use_ImmuneTo"), table.concat(immunities, ", "))..colorEnd, immunityDuration })
	end

	if #spellLevels > 0 then
		table.insert(pending, { good..string.format(ZJItemInfo_Private_T("Use_ImmuneToLevels"), ZJItemInfo_Private_FormatLevels(spellLevels))..colorEnd, spellLevelDuration })
	end

	---------------
	-- Durations --
	---------------

	local commonDuration, commonCount = nil, 0
	for duration, count in pairs(durationCounts) do
		if count > commonCount or (count == commonCount and duration ~= "permanent") then
			commonDuration, commonCount = duration, count
		end
	end

	for _, entry in ipairs(pending) do
		local text, duration = entry[1], entry[2]
		if duration ~= nil and duration ~= commonDuration then
			text = string.format("%s %s(%s)%s", text, ZJItemInfo_Private_DimColorStr, ZJItemInfo_Private_FormatEffectDuration(duration), colorEnd)
		end
		table.insert(lines, text)
	end

	if #lines == 1 then
		return lines
	end

	if commonDuration ~= nil and #pending > 0 then
		local durationStr = commonDuration == "permanent" and ZJItemInfo_Private_T("Permanent")
			or string.format(ZJItemInfo_Private_T("Lasts"), ZJItemInfo_Private_FormatDuration(commonDuration))
		table.insert(lines, ZJItemInfo_Private_DimColorStr..durationStr..colorEnd)
	end

	return lines
end

-----------
-- Hover --
-----------

ZJItemInfo_Private_QuickLootMenuName = "WORLD_QUICKLOOT"
ZJItemInfo_Private_QuickLootSlots = nil -- Array of uiItem, the slot buttons of the quick loot bar from left to right
ZJItemInfo_Private_Lists = nil          -- Array of { menuName, item }, every list in the UI

function ZJItemInfo_Private_ResetUICaches()
	ZJItemInfo_Private_QuickLootSlots = nil
	ZJItemInfo_Private_Lists = nil
	ZJItemInfo_Private_ActionbarButtons = nil
	ZJItemInfo_Private_ContainerSlots = nil
	ZJItemInfo_Private_InventorySlots = nil
end

function ZJItemInfo_Private_GetQuickLootSlots()

	local slots = ZJItemInfo_Private_QuickLootSlots
	if slots ~= nil then return slots end

	slots = {}

	local menu = EEex_Menu_Find(ZJItemInfo_Private_QuickLootMenuName)
	if menu ~= nil then
		-- The slots are the buttons that open the item's description on a right click, (the scroll arrows don't)
		local item = menu.items
		while item do
			if item.actionAlt ~= 0 then
				table.insert(slots, item)
			end
			item = item.next
		end
	end

	table.sort(slots, function(a, b)
		local areaA, areaB = a.area, b.area
		if areaA.y ~= areaB.y then return areaA.y < areaB.y end
		return areaA.x < areaB.x
	end)

	ZJItemInfo_Private_QuickLootSlots = slots
	return slots
end

function ZJItemInfo_Private_GetLists()

	local lists = ZJItemInfo_Private_Lists
	if lists ~= nil then return lists end

	lists = {}

	local numMenus = EngineGlobals.numMenus
	local menus = EngineGlobals.menus

	for i = 0, numMenus - 1 do
		local menu = menus:getReference(i)
		local menuName = menu.name:get()
		local item = menu.items
		while item do
			if item.type == uiItemType.ITEM_LIST and item.list.table ~= 0 then
				table.insert(lists, { ["menuName"] = menuName, ["item"] = item })
			end
			item = item.next
		end
	end

	ZJItemInfo_Private_Lists = lists
	return lists
end

-- Whether an item on the ground is identified. The quick loot bar's entry only says so once its description has been opened,
-- so this looks the item up in the pile it is in.
function ZJItemInfo_Private_IsGroundItemIdentified(slot, resref, info)

	local identified = slot.item.identified
	if identified ~= nil then return identified ~= 0 end

	local ok, flags = pcall(function()

		local container = EEex_GameObject_Get(slot.containerId)
		if container == nil then return nil end

		local index = 0
		local found = nil

		EEex_Utility_IterateCPtrList(container.m_lstItems, function(item)
			if index == slot.slotId then
				found = item
				return true
			end
			index = index + 1
		end)

		if found == nil or found.cResRef:get():upper() ~= resref:upper() then return nil end
		return found.m_flags
	end)

	if ok and type(flags) == "number" then
		return EEex_BAnd(flags, 0x1) ~= 0
	end

	-- The item couldn't be found: one that needs no lore to identify can't be unidentified
	return info.lore == 0
end

-- Returns the item of the quick loot bar that is under the cursor: its resref, whether it is identified, its name, and its area
function ZJItemInfo_Private_FindHoveredQuickLootItem()

	if type(loot) ~= "table" or type(loot.groundItems) ~= "table" then return nil end
	if not Infinity_IsMenuOnStack(ZJItemInfo_Private_QuickLootMenuName) then return nil end

	local menu = EEex_Menu_Find(ZJItemInfo_Private_QuickLootMenuName)
	if menu == nil then return nil end

	local menuX, menuY = menu:getArea()

	for index, slotItem in ipairs(ZJItemInfo_Private_GetQuickLootSlots()) do

		local area = slotItem.area
		local x, y, w, h = menuX + area.x, menuY + area.y, area.w, area.h

		if EEex_Menu_IsCursorWithinRect(x, y, w, h) then

			local slot = loot.groundItems[index - 1 + worldScreen:GetTopGroundItem()]
			local slotEntry = slot and slot.item
			if type(slotEntry) ~= "table" or type(slotEntry.res) ~= "string" then return nil end

			local info = ZJItemInfo_Private_GetItemInfo(slotEntry.res)
			if info == nil then return nil end

			return {
				["resref"]     = slotEntry.res,
				["info"]       = info,
				["identified"] = ZJItemInfo_Private_IsGroundItemIdentified(slot, slotEntry.res, info),
				["name"]       = slotEntry.name,
				["tint"]       = slotEntry.tint,
				["area"]       = { x, y, w, h },
				["placement"]  = "above",
			}
		end
	end

	return nil
end

ZJItemInfo_Private_ContainerMenuName = "WORLD_CONTAINER"
ZJItemInfo_Private_ContainerSlots = nil -- { container = array of uiItem, group = array of uiItem }, in the order of their index

-- The slot buttons of the container panel, (the ones that open the item's description on a right click). The panel
-- has two grids: the container's items on the left, the character's inventory on the right. The grids are told apart
-- by the widest gap between the columns of buttons, so a UI mod that moves them still works.
function ZJItemInfo_Private_GetContainerSlots()

	local slots = ZJItemInfo_Private_ContainerSlots
	if slots ~= nil then return slots end

	slots = { ["container"] = {}, ["group"] = {} }

	local buttons = {}
	local menu = EEex_Menu_Find(ZJItemInfo_Private_ContainerMenuName)
	if menu ~= nil then
		local item = menu.items
		while item do
			if item.actionAlt ~= 0 then
				table.insert(buttons, item)
			end
			item = item.next
		end
	end

	-- The x of every column of buttons, from left to right
	local columns = {}
	local seen = {}
	for _, button in ipairs(buttons) do
		local x = button.area.x
		if not seen[x] then
			seen[x] = true
			table.insert(columns, x)
		end
	end
	table.sort(columns)

	local splitX = nil
	local widestGap = -1
	for i = 2, #columns do
		local gap = columns[i] - columns[i - 1]
		if gap > widestGap then
			widestGap = gap
			splitX = columns[i]
		end
	end

	for _, button in ipairs(buttons) do
		if splitX ~= nil and button.area.x >= splitX then
			table.insert(slots.group, button)
		else
			table.insert(slots.container, button)
		end
	end

	local byRowThenColumn = function(a, b)
		local areaA, areaB = a.area, b.area
		if areaA.y ~= areaB.y then return areaA.y < areaB.y end
		return areaA.x < areaB.x
	end
	table.sort(slots.container, byRowThenColumn)
	table.sort(slots.group, byRowThenColumn)

	ZJItemInfo_Private_ContainerSlots = slots
	return slots
end

-- The flags of the item `resref` in `items`, (a CPtrList of CItem), preferring the one at `position`, nil if it isn't there
function ZJItemInfo_Private_FindItemFlags(items, position, resref)

	resref = resref:upper()
	local index = 0
	local atPosition, firstMatch = nil, nil

	EEex_Utility_IterateCPtrList(items, function(item)
		if item.cResRef:get():upper() == resref then
			if index == position then
				atPosition = item.m_flags
				return true
			end
			if firstMatch == nil then firstMatch = item.m_flags end
		end
		index = index + 1
	end)

	return atPosition or firstMatch
end

-- Whether an item of the container panel is identified. Like the quick loot bar, the panel's entry only says so once
-- its description has been opened, so the item is looked up in the container, or in the character's inventory.
function ZJItemInfo_Private_IsContainerItemIdentified(entry, key, isGroup, info)

	local identified = entry.identified
	if identified ~= nil then return identified ~= 0 end

	local ok, flags = pcall(function()

		local game = EngineGlobals.g_pBaldurChitin.m_pObjectGame

		if not isGroup then
			local container = EEex_GameObject_Get(game.m_iContainer)
			if container == nil then return nil end
			-- The panel's table may count from 0 or from 1
			return ZJItemInfo_Private_FindItemFlags(container.m_lstItems, key, entry.res)
				or ZJItemInfo_Private_FindItemFlags(container.m_lstItems, key - 1, entry.res)
		end

		local sprite = EEex_GameObject_Get(game.m_iContainerSprite)
		if not EEex_GameObject_IsSprite(sprite) then sprite = EEex_Sprite_GetSelected() end
		if not EEex_GameObject_IsSprite(sprite) then return nil end

		local resref = entry.res:upper()
		local items = sprite.m_equipment.m_items
		for slot = 0, 38 do
			local item = items:get(slot)
			if item ~= nil and item.cResRef:get():upper() == resref then
				return item.m_flags
			end
		end
		return nil
	end)

	if ok and type(flags) == "number" then
		return EEex_BAnd(flags, 0x1) ~= 0
	end

	return info.lore == 0
end

-- Returns the item of the container panel that is under the cursor, see ZJItemInfo_Private_FindHoveredQuickLootItem()
function ZJItemInfo_Private_FindHoveredContainerItem()

	if type(loot) ~= "table" then return nil end
	if not Infinity_IsMenuOnStack(ZJItemInfo_Private_ContainerMenuName) then return nil end

	local menu = EEex_Menu_Find(ZJItemInfo_Private_ContainerMenuName)
	if menu == nil then return nil end

	local menuX, menuY = menu:getArea()
	local slots = ZJItemInfo_Private_GetContainerSlots()

	local grids = {
		{ ["buttons"] = slots.container, ["items"] = loot.containerItems, ["top"] = worldScreen:GetTopContainerItem(), ["isGroup"] = false },
		{ ["buttons"] = slots.group,     ["items"] = loot.groupItems,     ["top"] = worldScreen:GetTopGroupItem(),     ["isGroup"] = true  },
	}

	for _, grid in ipairs(grids) do
		for index, button in ipairs(grid.buttons) do

			local area = button.area
			local x, y, w, h = menuX + area.x, menuY + area.y, area.w, area.h

			if EEex_Menu_IsCursorWithinRect(x, y, w, h) then

				if type(grid.items) ~= "table" then return nil end

				-- The same lookup as UI.menu's getContainerItemProperty() / getGroupItemProperty()
				local key = index - 1 + grid.top
				local slot = grid.items[key]
				local entry = slot and slot.item
				if type(entry) ~= "table" or type(entry.res) ~= "string" then return nil end

				local info = ZJItemInfo_Private_GetItemInfo(entry.res)
				if info == nil then return nil end

				return {
					["resref"]     = entry.res,
					["info"]       = info,
					["identified"] = ZJItemInfo_Private_IsContainerItemIdentified(entry, key, grid.isGroup, info),
					["name"]       = entry.name,
					["tint"]       = entry.tint,
					["area"]       = { x, y, w, h },
					["placement"]  = "above",
				}
			end
		end
	end

	return nil
end

ZJItemInfo_Private_InventoryMenuName = "INVENTORY"
ZJItemInfo_Private_InventorySlots = nil -- Array of { item = uiItem, id = number }, the slot items of the inventory screen

-- The equipment keys of UI.menu's inventory whose item is worn: it is shown without a comparison, (it would be
-- compared with itself). The weapon slots are looked at one by one, only the one in hand is worn.
ZJItemInfo_Private_InventoryWornKeys = {
	["armor"] = true, ["gauntlets"] = true, ["helmet"] = true, ["amulet"] = true, ["belt"] = true, ["ringleft"] = true,
	["ringright"] = true, ["cloak"] = true, ["boots"] = true, ["shield"] = true,
}

-- The slot items of the inventory screen. Each one is named "slot_inv_<id>", where <id> is the id of its entry in
-- characters[id].equipment, (UI.menu's inventorySplitStack() builds the name the same way).
function ZJItemInfo_Private_GetInventorySlots()

	local slots = ZJItemInfo_Private_InventorySlots
	if slots ~= nil then return slots end

	slots = {}

	local menu = EEex_Menu_Find(ZJItemInfo_Private_InventoryMenuName)
	if menu ~= nil then
		local item = menu.items
		while item do
			if item.type == uiItemType.ITEM_SLOT then
				local slotId = tonumber((item.name:get() or ""):match("^slot_inv_(%d+)$"))
				if slotId ~= nil then
					table.insert(slots, { ["item"] = item, ["id"] = slotId })
				end
			end
			item = item.next
		end
	end

	ZJItemInfo_Private_InventorySlots = slots
	return slots
end

-- Whether the item in the equipment entry `key` of the inventory screen is worn by `sprite`
function ZJItemInfo_Private_IsInventoryItemWorn(sprite, key, info)

	if ZJItemInfo_Private_InventoryWornKeys[key] then return true end

	local weaponIndex = tonumber(key:match("^weapon(%d)$"))
	if weaponIndex == nil or sprite == nil then return false end

	local selectedWeapon = sprite.m_equipment.m_selectedWeapon
	if selectedWeapon == 35 + weaponIndex then return true end

	-- Ammunition is selected, the weapon in hand is its launcher
	return selectedWeapon >= 11 and selectedWeapon <= 14 and ZJItemInfo_Private_LauncherCategories[info.category] == true
end

-- Returns the item of the inventory screen that is under the cursor, see ZJItemInfo_Private_FindHoveredQuickLootItem().
-- It also has `worn`, true if the character is wearing it / holding it.
function ZJItemInfo_Private_FindHoveredInventoryItem()

	if type(characters) ~= "table" then return nil end
	if not Infinity_IsMenuOnStack(ZJItemInfo_Private_InventoryMenuName) then return nil end

	for _, slot in ipairs(ZJItemInfo_Private_GetInventorySlots()) do

		local x, y, w, h = slot.item:getArea()

		if EEex_Menu_IsCursorWithinRect(x, y, w, h) then

			local character = characters[id]
			local equipment = type(character) == "table" and character.equipment or nil
			if type(equipment) ~= "table" then return nil end

			local key, entry = nil, nil
			for equipmentKey, equipmentEntry in pairs(equipment) do
				if type(equipmentEntry) == "table" and equipmentEntry.id == slot.id then
					key, entry = equipmentKey, equipmentEntry
					break
				end
			end

			if entry == nil or entry.empty ~= 0 then return nil end
			local itemEntry = entry.item
			if type(itemEntry) ~= "table" or type(itemEntry.res) ~= "string" then return nil end

			local info = ZJItemInfo_Private_GetItemInfo(itemEntry.res)
			if info == nil then return nil end

			local identified = itemEntry.identified
			if identified == nil then
				identified = info.lore == 0
			else
				identified = identified ~= 0
			end

			local sprite = ZJItemInfo_Private_GetSelectedSprite()

			return {
				["resref"]     = itemEntry.res,
				["info"]       = info,
				["identified"] = identified,
				["name"]       = itemEntry.name,
				["tint"]       = itemEntry.tint,
				["area"]       = { x, y, w, h },
				["placement"]  = "above",
				["worn"]       = type(key) == "string" and ZJItemInfo_Private_IsInventoryItemWorn(sprite, key, info),
			}
		end
	end

	return nil
end

function ZJItemInfo_Private_IsStoreOpen()
	if type(store) ~= "table" then return false end
	local chitin = EngineGlobals.g_pBaldurChitin
	local activeEngine = chitin.pActiveEngine
	local storeEngine = chitin.m_pEngineStore
	return activeEngine ~= nil and storeEngine ~= nil and EEex_UDToPtr(activeEngine) == EEex_UDToPtr(storeEngine)
end

-- Returns the item of a store's list that is under the cursor, see ZJItemInfo_Private_FindHoveredQuickLootItem().
-- A store's lists are the ones that show a table of the engine's "store" table, whose rows have an item.
function ZJItemInfo_Private_FindHoveredStoreItem()

	if not ZJItemInfo_Private_IsStoreOpen() then return nil end

	local mouseX, mouseY = EEex_Menu_GetMousePos()

	for _, listEntry in ipairs(ZJItemInfo_Private_GetLists()) do

		local listItem = listEntry.item
		local rowHeight = listItem.list.rowheight

		if rowHeight > 0 and Infinity_IsMenuOnStack(listEntry.menuName) then

			local x, y, w, h = listItem:getArea()

			if EEex_Menu_IsCursorWithinRect(x, y, w, h) then

				local tableFunc = EEex_GetLuaRegistryIndex(listItem.list.table)
				local ok, listTable = pcall(tableFunc)

				local isStoreTable = false
				if ok and type(listTable) == "table" then
					for _, storeTable in pairs(store) do
						if rawequal(storeTable, listTable) then
							isStoreTable = true
							break
						end
					end
				end

				if isStoreTable then

					-- The scrollbar moves the rows up by making their top negative
					local row = math.floor((mouseY - y - listItem.scrollbar.top) / rowHeight) + 1
					local rowEntry = listTable[row]
					local itemEntry = type(rowEntry) == "table" and rowEntry.item or nil
					if type(itemEntry) ~= "table" or type(itemEntry.res) ~= "string" then return nil end

					local info = ZJItemInfo_Private_GetItemInfo(itemEntry.res)
					if info == nil then return nil end

					local identified = itemEntry.identified
					if identified == nil then
						identified = info.lore == 0
					else
						identified = identified ~= 0
					end

					local rowY = y + listItem.scrollbar.top + (row - 1) * rowHeight

					return {
						["resref"]     = itemEntry.res,
						["info"]       = info,
						["identified"] = identified,
						["name"]       = itemEntry.name,
						["tint"]       = itemEntry.tint,
						["area"]       = { x, rowY, w, rowHeight },
						["placement"]  = "side",
					}
				end
			end
		end
	end

	return nil
end

ZJItemInfo_Private_ActionbarMenuName = "WORLD_ACTIONBAR"
ZJItemInfo_Private_ActionbarButtons = nil      -- Array of { item, index }, the buttons of the action bar
ZJItemInfo_Private_HoveredActionbarIndex = nil -- The action bar button the popup is showing for, its tooltip is hidden

-- The action bar's buttons type, (EEex_Actionbar_ButtonType), => the quick item slot it uses
ZJItemInfo_Private_QuickItemButtonTypes = { [21] = 0, [22] = 1, [23] = 2 }

function ZJItemInfo_Private_GetActionbarButtons()

	local buttons = ZJItemInfo_Private_ActionbarButtons
	if buttons ~= nil then return buttons end

	buttons = {}

	local menu = EEex_Menu_Find(ZJItemInfo_Private_ActionbarMenuName)
	if menu ~= nil then
		-- The buttons are the ones with an "actionBar <index>"
		local item = menu.items
		while item do
			local actionBar = item.button.actionBar
			if actionBar then
				local ok, index = pcall(EEex_Menu_GetItemVariant, actionBar)
				if ok and type(index) == "number" then
					table.insert(buttons, { ["item"] = item, ["index"] = index })
				end
			end
			item = item.next
		end
	end

	ZJItemInfo_Private_ActionbarButtons = buttons
	return buttons
end

-- Returns the item in a quick item slot of the action bar that is under the cursor, if using it means using it on the
-- character itself, (a potion), see ZJItemInfo_Private_FindHoveredQuickLootItem(). It also has:
--
--   use.sprite         => The character whose action bar it is
--   use.headerAddress  => The address of the item's header
--   use.abilityAddress => The address of the ability the button uses
--
function ZJItemInfo_Private_FindHoveredQuickItem()

	if e:GetActiveEngine() ~= worldScreen then return nil end
	if not Infinity_IsMenuOnStack(ZJItemInfo_Private_ActionbarMenuName) then return nil end

	for _, button in ipairs(ZJItemInfo_Private_GetActionbarButtons()) do

		local x, y, w, h = button.item:getArea()

		if EEex_Menu_IsCursorWithinRect(x, y, w, h) then

			local buttonType = EEex_Actionbar_GetArray().m_buttonTypes:get(button.index)
			local quickItemIndex = ZJItemInfo_Private_QuickItemButtonTypes[buttonType]
			if quickItemIndex == nil then return nil end

			local sprite = EEex_Sprite_GetSelected()
			if not EEex_GameObject_IsSprite(sprite) then return nil end

			-- The quick item buttons use the quick item slots of the inventory, in order. Which of the item's abilities a
			-- button uses isn't readable here, (the engine's quick item data isn't in EEex's bindings), the first one that
			-- is used on the character itself is taken, which is the only one for a potion.
			local slot = ZJItemInfo_Private_Slot_QuickItemFirst + quickItemIndex

			local item = sprite.m_equipment.m_items:get(slot)
			if item == nil then return nil end

			local resref = item.cResRef:get():upper()
			local header = EEex_Resource_Demand(resref, "ITM")
			if header == nil then return nil end

			local headerAddress = EEex_UDToPtr(header)
			local abilityNum, abilityAddress = nil, nil

			for i = 0, header.abilityCount - 1 do
				local address = headerAddress + header.abilityOffset + 0x38 * i
				if ZJItemInfo_Private_SelfUseTargets[EEex_ReadU8(address + 0xC)] then
					abilityNum, abilityAddress = i, address
					break
				end
			end

			if abilityNum == nil then return nil end

			local info = ZJItemInfo_Private_GetItemInfo(resref)
			if info == nil then return nil end

			return {
				["resref"]      = resref,
				["info"]        = info,
				["identified"]  = EEex_BAnd(item.m_flags, 0x1) ~= 0 or info.lore == 0,
				["area"]        = { x, y, w, h },
				["placement"]   = "above",
				["buttonIndex"] = button.index,
				["use"]         = {
					["sprite"]         = sprite,
					["headerAddress"]  = headerAddress,
					["abilityAddress"] = abilityAddress,
					["abilityNum"]     = abilityNum,
				},
			}
		end
	end

	return nil
end

function ZJItemInfo_Private_FindHoveredItem()

	for _, menuName in ipairs(ZJItemInfo_Private_BlockingMenus) do
		if Infinity_IsMenuOnStack(menuName) then return nil end
	end

	local hovered = nil

	if ZJItemInfo_Private_ShowInStores:get() ~= 0 then
		hovered = ZJItemInfo_Private_FindHoveredStoreItem()
	end

	if hovered == nil and ZJItemInfo_Private_ShowInQuickLoot:get() ~= 0 then
		hovered = ZJItemInfo_Private_FindHoveredQuickLootItem()
	end

	if hovered == nil and ZJItemInfo_Private_ShowInContainers:get() ~= 0 then
		-- Kept apart, so a problem with the container panel never stops the other popups
		local ok, containerItem = pcall(ZJItemInfo_Private_FindHoveredContainerItem)
		if ok then
			hovered = containerItem
		elseif not ZJItemInfo_Private_ContainerErrorReported then
			ZJItemInfo_Private_ContainerErrorReported = true
			Infinity_DisplayString("[Battle Sense] Item Info, containers: "..tostring(containerItem))
		end
	end

	if hovered == nil and ZJItemInfo_Private_ShowInInventory:get() ~= 0 then
		-- Kept apart, so a problem with the inventory screen never stops the other popups
		local ok, inventoryItem = pcall(ZJItemInfo_Private_FindHoveredInventoryItem)
		if ok then
			hovered = inventoryItem
		elseif not ZJItemInfo_Private_InventoryErrorReported then
			ZJItemInfo_Private_InventoryErrorReported = true
			Infinity_DisplayString("[Battle Sense] Item Info, inventory: "..tostring(inventoryItem))
		end
	end

	if hovered == nil and ZJItemInfo_Private_ShowOnQuickItems:get() ~= 0 then
		-- Kept apart, so a problem with the action bar never stops the popups of stores and the quick loot bar
		local ok, quickItem = pcall(ZJItemInfo_Private_FindHoveredQuickItem)
		if ok then
			hovered = quickItem
		elseif not ZJItemInfo_Private_QuickItemErrorReported then
			ZJItemInfo_Private_QuickItemErrorReported = true
			Infinity_DisplayString("[Battle Sense] Item Info, quick items: "..tostring(quickItem))
		end
	end

	return hovered
end

-- The character a comparison is for: the one the inventory screen shows, (UI.menu's global `id`, which can be another
-- one than the leader of the selected creatures), the one whose portrait is selected in a store, otherwise the leader
-- of the selected creatures
function ZJItemInfo_Private_GetSelectedSprite()

	local sprite = nil

	if type(id) == "number" and Infinity_IsMenuOnStack(ZJItemInfo_Private_InventoryMenuName) then
		local ok, inventorySprite = pcall(EEex_GameObject_Get, id)
		if ok then sprite = inventorySprite end
	end

	if not EEex_GameObject_IsSprite(sprite) and ZJItemInfo_Private_IsStoreOpen() then
		local ok, portraitIndex = pcall(function()
			return EngineGlobals.g_pBaldurChitin.m_pEngineStore.m_nSelectedCharacter
		end)
		if ok and type(portraitIndex) == "number" and portraitIndex >= 0 and portraitIndex <= 5 then
			sprite = EEex_Sprite_GetInPortrait(portraitIndex)
		end
	end

	if not EEex_GameObject_IsSprite(sprite) then
		sprite = EEex_Sprite_GetSelected()
	end

	return EEex_GameObject_IsSprite(sprite) and sprite or nil
end

-----------
-- Panel --
-----------

ZJItemInfo_Private_PanelText    = nil -- The panel's text, built again when what it is for changes, (and every so often)
ZJItemInfo_Private_PanelKey     = nil -- What the text was last built for
ZJItemInfo_Private_PanelBuiltAt = 0

-- Whether the popup shows this module's panel
function ZJItemInfo_Private_IsShowing()
	return ZJPopup_GetCursorPanel() == "Item Info"
end

-- The action bar button's own tooltip, (the item's name), would sit under the popup. UI.menu defines
-- getActionBarTooltip() each time it loads, so it is wrapped again every time.
function ZJItemInfo_Private_WrapActionBarTooltip()

	local original = getActionBarTooltip
	if type(original) ~= "function" or original == ZJItemInfo_Private_ActionBarTooltipWrapper then return end

	ZJItemInfo_Private_ActionBarTooltipWrapper = function(index, ...)
		if ZJItemInfo_Private_HoveredActionbarIndex == index and ZJItemInfo_Private_IsShowing() then
			return ""
		end
		return original(index, ...)
	end

	getActionBarTooltip = ZJItemInfo_Private_ActionBarTooltipWrapper
end

-- Whether the selected character can use the item under the cursor. The engine works this out itself, (class, kit, race,
-- alignment, ability scores, ...), and shows it by tinting the item's icon. Its other tint is for an item that isn't
-- identified, so on an identified item a tint means that it can't be used.
function ZJItemInfo_Private_IsUsable(hovered)
	local tint = hovered.tint
	return not (hovered.identified and type(tint) == "number" and tint ~= 0)
end

-- What using the item does to `sprite`, for an item hovered somewhere other than the action bar, (a store or the
-- quick loot bar). Only its first ability is looked at, and only when it is used on its user, (a potion), else nil.
function ZJItemInfo_Private_GetSelfUse(resref, sprite)

	local header = EEex_Resource_Demand(resref, "ITM")
	if header == nil or header.abilityCount < 1 then return nil end

	local headerAddress = EEex_UDToPtr(header)
	local abilityAddress = headerAddress + header.abilityOffset
	if not ZJItemInfo_Private_SelfUseTargets[EEex_ReadU8(abilityAddress + 0xC)] then return nil end

	return {
		["sprite"]         = sprite,
		["headerAddress"]  = headerAddress,
		["abilityAddress"] = abilityAddress,
		["abilityNum"]     = 0,
	}
end

-- The popup of a quick item that is used on the character itself, (a potion)
function ZJItemInfo_Private_BuildUseText(hovered)

	local info = hovered.info
	local identified = hovered.identified

	local parts = { ZJItemInfo_Private_TitleColorStr..ZJItemInfo_Private_GetItemName(info, identified)..ZJItemInfo_Private_ColorEndStr }

	-- What an unidentified item does isn't known to the party yet
	if not identified then
		table.insert(parts, ZJItemInfo_Private_DimColorStr..ZJItemInfo_Private_T("Unidentified")..ZJItemInfo_Private_ColorEndStr)
		return table.concat(parts, "\n\n")
	end

	local ok, lines = pcall(ZJItemInfo_Private_GetUseLines, hovered.use.sprite, hovered.use)

	if not ok and not ZJItemInfo_Private_QuickItemErrorReported then
		ZJItemInfo_Private_QuickItemErrorReported = true
		Infinity_DisplayString("[Battle Sense] Item Info, quick items: "..tostring(lines))
	end

	if ok and #lines > 1 then
		table.insert(parts, table.concat(lines, "\n"))
	else
		-- Nothing it does could be worked out, its description says it instead
		local okDescription, description = pcall(ZJItemInfo_Private_GetItemDescription, info, identified)
		if okDescription and description ~= "" then
			table.insert(parts, description)
		end
	end

	return table.concat(parts, "\n\n")
end

function ZJItemInfo_Private_BuildText(hovered, sprite)

	if hovered.use ~= nil then
		return ZJItemInfo_Private_BuildUseText(hovered)
	end

	local info = hovered.info
	local identified = hovered.identified

	local name = type(hovered.name) == "string" and hovered.name or ""
	if name == "" then
		name = ZJItemInfo_Private_GetItemName(info, identified)
	end

	local parts = { ZJItemInfo_Private_TitleColorStr..name..ZJItemInfo_Private_ColorEndStr }

	if not identified then
		table.insert(parts, ZJItemInfo_Private_DimColorStr..ZJItemInfo_Private_T("Unidentified")..ZJItemInfo_Private_ColorEndStr)
	end

	local okDescription, description = pcall(ZJItemInfo_Private_GetItemDescription, info, identified)
	if okDescription and description ~= "" then
		table.insert(parts, description)
	end

	-- What an unidentified item does isn't known to the party yet
	if identified and sprite ~= nil and ZJItemInfo_Private_ShowComparison:get() ~= 0 then
		if ZJItemInfo_Private_CategorySlots[info.category] == nil then
			-- Not something that is equipped, but it may be something that is used, (a potion)
			local okUse, use = pcall(ZJItemInfo_Private_GetSelfUse, hovered.resref, sprite)
			if okUse and use ~= nil and ZJItemInfo_Private_IsUsable(hovered) then
				local okLines, lines = pcall(ZJItemInfo_Private_GetUseLines, sprite, use)
				if okLines and #lines > 1 then
					table.insert(parts, table.concat(lines, "\n"))
				end
			end
		elseif hovered.worn then
			-- Already worn, there is nothing to compare it with
		elseif not ZJItemInfo_Private_IsUsable(hovered) then
			local okName, spriteName = pcall(function() return sprite:getName() end)
			table.insert(parts, ZJItemInfo_Private_WorseColorStr()
				..string.format(ZJItemInfo_Private_T("NotUsable"), okName and spriteName or "")
				..ZJItemInfo_Private_ColorEndStr)
		else
			local okComparison, lines = pcall(ZJItemInfo_Private_GetComparisonLines, sprite, info)
			if okComparison and lines ~= nil then
				table.insert(parts, table.concat(lines, "\n"))
			end
		end
	end

	return table.concat(parts, "\n\n")
end

-- The panel's text, (see ZJPopup_AddPanel()): the item under the cursor, and where to put the popup, (above an action
-- bar button, or beside the cursor at the height of a list's row), or nil
function ZJItemInfo_Private_GetPanelText()

	ZJItemInfo_Private_HoveredActionbarIndex = nil

	if not ZJItemInfo_Private_Enabled then return nil end

	local hovered = ZJItemInfo_Private_FindHoveredItem()
	if hovered == nil then return nil end

	local sprite = ZJItemInfo_Private_GetSelectedSprite()

	if hovered.use ~= nil then sprite = hovered.use.sprite end
	ZJItemInfo_Private_HoveredActionbarIndex = hovered.buttonIndex

	local key = string.format("%s|%s|%s|%s|%s", hovered.resref, tostring(hovered.identified), tostring(hovered.tint),
		sprite and sprite.m_id or -1, hovered.use and hovered.use.abilityNum or "")
	local curTick = Infinity_GetClockTicks()

	if key ~= ZJItemInfo_Private_PanelKey or curTick - ZJItemInfo_Private_PanelBuiltAt >= ZJItemInfo_Private_RefreshInterval then
		ZJItemInfo_Private_PanelText = ZJItemInfo_Private_BuildText(hovered, sprite)
		ZJItemInfo_Private_PanelKey = key
		ZJItemInfo_Private_PanelBuiltAt = curTick
	end

	local area = hovered.area
	if hovered.placement == "above" then
		return ZJItemInfo_Private_PanelText, { ["above"] = area }
	end
	return ZJItemInfo_Private_PanelText, area[2]
end

---------------
-- Listeners --
---------------

EEex_Menu_AddMainFileLoadedListener(function()

	ZJItemInfo_Private_ResetUICaches()
	ZJItemInfo_Private_PanelKey = nil
	ZJItemInfo_Private_HoveredActionbarIndex = nil
	ZJItemInfo_Private_WrapActionBarTooltip()

	-- The popup's ticker is opened when a game starts. Opening it again with the quick loot bar, the inventory and a
	-- store's lists makes sure it runs where it is needed, should something have closed it.
	local seenMenus = {}

	local pushTickerOnOpen = function(menuName)

		if seenMenus[menuName] then return end
		seenMenus[menuName] = true

		local menu = EEex_Menu_Find(menuName)
		if menu == nil then return end

		local oldOnOpen = EEex_Menu_GetItemFunction(menu.reference_onOpen) or function() end
		EEex_Menu_SetItemFunction(menu.reference_onOpen, function()
			local toReturn = oldOnOpen()
			ZJPopup_PushTicker()
			return toReturn
		end)
	end

	pushTickerOnOpen(ZJItemInfo_Private_QuickLootMenuName)
	pushTickerOnOpen(ZJItemInfo_Private_InventoryMenuName)

	for _, listEntry in ipairs(ZJItemInfo_Private_GetLists()) do
		if listEntry.menuName:sub(1, 6) == "STORE_" then
			pushTickerOnOpen(listEntry.menuName)
		end
	end
end)

-- First: an item is on the screen, on top of whatever in the game world is below the cursor
ZJPopup_AddPanel({
	["name"]         = "Item Info",
	["priority"]     = 5,
	["getText"]      = ZJItemInfo_Private_GetPanelText,
	["getFontPoint"] = function() return ZJItemInfo_Private_FontPoint:get() end,
	["getOpacity"]   = function() return 92 end,
	["wrap"]         = true,
})
