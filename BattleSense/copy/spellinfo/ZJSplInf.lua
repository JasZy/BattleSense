--[[
+--------------------------------------------------------------------------------------------------------------+
| ZJSpellInfo - What a spell will do to the creature under the cursor, while the spell waits for a target      |
+--------------------------------------------------------------------------------------------------------------+
|   When a spell, or an item ability such as a wand or a scroll, is picked from the action bar, the game      |
|   waits for a target, (CInfGame.m_nState 1 / 2), and the selected caster's m_currentUseButton names it.     |
|   This popup reads the spell's effects for the caster's level, (following "cast spell" effects into the     |
|   spells they cast), and compares them with the creature under the cursor:                                 |
|                                                                                                              |
|     * Its magic resistance, and whether the spell can be resisted at all                                      |
|     * The saving throws it gets, and the roll it needs                                                        |
|     * The damage the spell does, with the creature's resistance to each element                              |
|     * Why it would be unaffected: immunities to the effect / spell / level / school, the spell's own          |
|       exclusions, (SPLPROT.2DA checks, e.g. Sleep doesn't affect elves), and level limits                     |
|                                                                                                              |
|   This is read-only: it never changes what the spell does.                                                   |
+--------------------------------------------------------------------------------------------------------------+
--]]

-- The "Open On" option, (shared by every popup)
Infinity_DoFile("ZJPopup")
-- The areas of spells / items, (shared with Attack Info)
Infinity_DoFile("ZJArea")

-------------
-- Options --
-------------

EEex_Options_Register("ZJSpellInfo_Enable", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info" }),
	["onChange"] = function(self, oldValue) ZJSpellInfo_SetEnabled(self:get() ~= 0) end,
}))

ZJSpellInfo_Private_OpenOn = ZJPopup_RegisterOpenOn("ZJSpellInfo_OpenOn", "Spell Info Module: Open On")

ZJSpellInfo_Private_FontPoint = EEex_Options_Register("ZJSpellInfo_FontPoint", EEex_Options_Option.new({
	["default"]  = 11,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Font Point" }),
}))

-- 0 = Minimum d20 roll needed to save, 1 = Chance to save, 2 = Both
ZJSpellInfo_Private_SaveDisplayType = EEex_Options_Register("ZJSpellInfo_SaveDisplayType", EEex_Options_Option.new({
	["default"]  = 2,
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 2 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Save Display Type" }),
}))

ZJSpellInfo_Private_ShowMagicResistance = EEex_Options_Register("ZJSpellInfo_ShowMagicResistance", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Show Magic Resistance" }),
}))

ZJSpellInfo_Private_ShowSavingThrows = EEex_Options_Register("ZJSpellInfo_ShowSavingThrows", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Show Saving Throws" }),
}))

ZJSpellInfo_Private_ShowDamage = EEex_Options_Register("ZJSpellInfo_ShowDamage", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Show Damage" }),
}))

ZJSpellInfo_Private_ShowImmunities = EEex_Options_Register("ZJSpellInfo_ShowImmunities", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Show Immunities" }),
}))

ZJSpellInfo_Private_ShowDistance = EEex_Options_Register("ZJSpellInfo_ShowDistance", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Show Distance" }),
}))

ZJSpellInfo_Private_ShowOnParty = EEex_Options_Register("ZJSpellInfo_ShowOnParty", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Show On Party" }),
}))

ZJSpellInfo_Private_ShowAreas = EEex_Options_Register("ZJSpellInfo_ShowAreas", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Spell Info Module: Show Areas" }),
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_SpellInfo_TabTitle", function() return {
	{
		ZJPopup_OpenOnDisplayEntry("ZJSpellInfo_OpenOn"),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_FontPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_FontPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_FontPoint_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"]        = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_SaveDisplayType",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType_Description",
			["widget"]      = EEex_Options_HorizontalMultiToggleWidget.new({
				["toggles"] = {
					{
						["label"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType_Roll",
						["data"] = { ["toggleValue"] = 0 },
					},
					{
						["label"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType_Percentage",
						["data"] = { ["toggleValue"] = 1 },
					},
					{
						["label"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType_Both",
						["data"] = { ["toggleValue"] = 2 },
					},
				},
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_ShowMagicResistance",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowMagicResistance",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowMagicResistance_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_ShowSavingThrows",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowSavingThrows",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowSavingThrows_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_ShowDamage",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowDamage",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowDamage_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_ShowImmunities",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowImmunities",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowImmunities_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_ShowDistance",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowDistance",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowDistance_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_ShowOnParty",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowOnParty",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowOnParty_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJSpellInfo_ShowAreas",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowAreas",
			["description"] = "ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowAreas_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
	},
} end)

---------------
-- Constants --
---------------

ZJSpellInfo_Private_RedColorStr   = "^0xFF2B4BFF"
ZJSpellInfo_Private_GreenColorStr = "^0xFF40E040"
ZJSpellInfo_Private_GreyColorStr  = "^0xFFA0A0A0"

-- Effect target types that land on the creature that was clicked, (not on the caster or the caster's party)
ZJSpellInfo_Private_TargetsCreature = {
	[2] = true, -- Preset target
	[4] = true, -- Everyone
	[5] = true, -- Everyone except party
	[7] = true, -- Target group
	[8] = true, -- Everyone except self
}

-- Opcodes that cast another spell on the target. Their resource is followed, so a wand that casts a spell, or a spell
-- that casts its effects through a sub-spell, (like Chant), is read the same way as the spell itself.
ZJSpellInfo_Private_CastSpellOpcodes = {
	[146] = true, -- Cast spell
	[148] = true, -- Cast spell at point
	[326] = true, -- Apply effects list
}

-- Opcodes that make the target immune to a spell when it matches a SPLPROT.2DA row
ZJSpellInfo_Private_SplprotOpcodes = {
	[318] = true, -- Protection from resource
	[324] = true, -- Immunity to resource and message
}

-- The opcodes worth naming in an immunity, and that can be limited to a level range by their dice fields
ZJSpellInfo_Private_OpcodeNames = {
	[  3] = "berserk",        [  5] = "charm",          [ 13] = "instant death",  [ 24] = "fear",
	[ 25] = "poison",         [ 38] = "silence",        [ 39] = "sleep",          [ 40] = "slow",
	[ 45] = "stun",           [ 55] = "instant death",  [ 74] = "blindness",      [ 76] = "feeblemind",
	[ 78] = "disease",        [ 80] = "deafness",       [109] = "hold",           [128] = "confusion",
	[134] = "petrification",  [135] = "polymorph",      [154] = "entangle",       [157] = "web",
	[158] = "grease",         [175] = "hold",           [185] = "hold",           [209] = "instant death",
	[211] = "imprisonment",   [213] = "maze",           [216] = "level drain",    [238] = "disintegration",
}

ZJSpellInfo_Private_SchoolNames = {
	[1] = "Abjuration", [2] = "Conjuration", [3] = "Divination", [4] = "Enchantment",
	[5] = "Illusion",   [6] = "Evocation",   [7] = "Necromancy", [8] = "Alteration",
}

-- { saving throw bit, translation key, stat field }
ZJSpellInfo_Private_SaveTypes = {
	{ 0x01, "Spell",     "m_nSaveVSSpell"  },
	{ 0x02, "Breath",    "m_nSaveVSBreath" },
	{ 0x04, "Death",     "m_nSaveVSDeath"  },
	{ 0x08, "Wand",      "m_nSaveVSWands"  },
	{ 0x10, "Polymorph", "m_nSaveVSPoly"   },
}

-- op12 damage type, (the high word of the second parameter) => { name, resistance stat field }
ZJSpellInfo_Private_DamageTypes = {
	[0x0]   = { "crushing",     "m_nResistCrushing"    },
	[0x1]   = { "acid",         "m_nResistAcid"        },
	[0x2]   = { "cold",         "m_nResistCold"        },
	[0x4]   = { "electricity",  "m_nResistElectricity" },
	[0x8]   = { "fire",         "m_nResistFire"        },
	[0x10]  = { "piercing",     "m_nResistPiercing"    },
	[0x20]  = { "poison",       nil                    },
	[0x40]  = { "magic",        nil                    },
	[0x80]  = { "missile",      "m_nResistMissile"     },
	[0x100] = { "slashing",     "m_nResistSlashing"    },
	[0x200] = { "magic fire",   "m_nResistMagicFire"   },
	[0x400] = { "magic cold",   "m_nResistMagicCold"   },
	[0x800] = { "stunning",     nil                    },
}

-- SPLPROT.2DA stats above 0x100 that aren't plain creature stats => a function returning the creature's value
ZJSpellInfo_Private_SplprotSpecialStats = {
	[0x10a] = function(sprite) return sprite.m_typeAI.m_EnemyAlly end,
	[0x10b] = function(sprite) return sprite.m_typeAI.m_General   end,
	[0x10c] = function(sprite) return sprite.m_typeAI.m_Race      end,
	[0x10d] = function(sprite) return sprite.m_typeAI.m_Class     end,
}

-- SPLPROT.2DA relations that are simple comparisons, (the bitwise ones are left out, they decide nothing here)
ZJSpellInfo_Private_SplprotRelations = {
	[0] = function(a, b) return a <= b end,
	[1] = function(a, b) return a == b end,
	[2] = function(a, b) return a <  b end,
	[3] = function(a, b) return a >  b end,
	[4] = function(a, b) return a >= b end,
	[5] = function(a, b) return a ~= b end,
}

-------------
-- Globals --
-------------

ZJSpellInfo_Private_Enabled       = false -- Set by the "ZJSpellInfo_Enable" option, (the "Battle Sense Modules" tab), once the file has loaded
ZJSpellInfo_Private_ErrorReported = false
ZJSpellInfo_Private_Menu_IsOpen = false
ZJSpellInfo_Private_Menu_Text   = ""
ZJSpellInfo_Private_Menu_TextUD = nil -- uiItem
ZJSpellInfo_Private_Splprot     = nil -- C2DArray, loaded the first time it is needed
ZJSpellInfo_Private_NameCache   = {}  -- [resref] = display name ("" if none)

-------------
-- Reading --
-------------

function ZJSpellInfo_Private_T(key)
	return uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_"..key] or key
end

function ZJSpellInfo_Private_FetchString(strref)
	if strref == nil or strref == -1 or strref == 0xFFFFFFFF then return "" end
	return Infinity_FetchString(strref) or ""
end

function ZJSpellInfo_Private_ReadResref(address)
	local chars = {}
	for i = 0, 7 do
		local byte = EEex_ReadU8(address + i)
		if byte == 0 then break end
		chars[#chars + 1] = string.char(byte)
	end
	return table.concat(chars):upper()
end

-- Returns the display name of the spell / item `resref`, or "" if it has none. A sub-spell without a name of its own
-- borrows its parent's, (the same resref without the letters at the end, SPPR203D -> SPPR203).
function ZJSpellInfo_Private_GetSourceName(resref)

	local cached = ZJSpellInfo_Private_NameCache[resref]
	if cached ~= nil then return cached end

	local lookup = function(toLookup)
		local spellHeader = EEex_Resource_Demand(toLookup, "SPL")
		if spellHeader ~= nil then
			local name = ZJSpellInfo_Private_FetchString(spellHeader.genericName)
			if name ~= "" then return name end
		end
		local itemHeader = EEex_Resource_Demand(toLookup, "ITM")
		if itemHeader ~= nil then
			local name = ZJSpellInfo_Private_FetchString(itemHeader.identifiedName)
			if name == "" then name = ZJSpellInfo_Private_FetchString(itemHeader.genericName) end
			return name
		end
		return ""
	end

	local name = lookup(resref)
	if name == "" then
		local parentResref = resref:match("^(.-%d)%a+$")
		if parentResref ~= nil then name = lookup(parentResref) end
	end

	ZJSpellInfo_Private_NameCache[resref] = name
	return name
end

-- Returns the name of the spell / item `resref` that a protection comes from, or "" if it isn't worth naming.
-- A creature's built-in immunities come from hidden items it can't drop, (a skeleton's "Ring"); naming those
-- would suggest it wears something that protects it.
function ZJSpellInfo_Private_GetProtectionSourceName(resref)
	if EEex_Resource_Demand(resref, "SPL") == nil then
		local itemHeader = EEex_Resource_Demand(resref, "ITM")
		if itemHeader ~= nil and (EEex_BAnd(itemHeader.itemFlags, 0x4) == 0 -- BIT2 = droppable
			or ZJSpellInfo_Private_FetchString(itemHeader.identifiedName) == "")
		then
			return ""
		end
	end
	return ZJSpellInfo_Private_GetSourceName(resref)
end

-- Appends the effects of the ability at `abilityAddress`, (an SPL or ITM ability, both keep their effect count at
-- 0x1E and their first effect index at 0x20), to `effects`. `origin` is what the effects are blocked by: the spell's
-- resref, level, school and secondary type.
function ZJSpellInfo_Private_ReadAbilityEffects(headerAddress, abilityAddress, origin, effects, depth, caster)

	local effectsAddress = headerAddress + EEex_ReadU32(headerAddress + 0x6A)
	local count = EEex_ReadU16(abilityAddress + 0x1E)
	local first = EEex_ReadU16(abilityAddress + 0x20)

	for i = first, first + count - 1 do

		local address = effectsAddress + 0x30 * i

		local effect = {
			["opcode"]     = EEex_ReadU16(address),
			["target"]     = EEex_ReadU8(address + 0x2),
			["param1"]     = EEex_Read32(address + 0x4),
			["param2"]     = EEex_ReadU32(address + 0x8),
			["resist"]     = EEex_ReadU8(address + 0xD),
			["res"]        = ZJSpellInfo_Private_ReadResref(address + 0x14),
			["numDice"]    = EEex_ReadU32(address + 0x1C),
			["diceSize"]   = EEex_ReadU32(address + 0x20),
			["saveType"]   = EEex_ReadU32(address + 0x24),
			["saveMod"]    = EEex_Read32(address + 0x28),
			["origin"]     = origin,
		}

		if ZJSpellInfo_Private_TargetsCreature[effect.target] then

			table.insert(effects, effect)

			-- Follow a spell cast on the target into its own effects, one level deep is enough for wands and sub-spells
			if ZJSpellInfo_Private_CastSpellOpcodes[effect.opcode] and depth < 2 and effect.res ~= "" then
				ZJSpellInfo_Private_ReadSpell(effect.res, caster, effects, depth + 1)
			end
		end
	end
end

-- Appends the effects that the spell `resref` has for `caster`'s level to `effects`. Returns the spell's header and the
-- address of the ability used, or nil.
function ZJSpellInfo_Private_ReadSpell(resref, caster, effects, depth)

	local spellHeader = EEex_Resource_Demand(resref, "SPL")
	if spellHeader == nil then return nil end

	local casterLevel = math.max(caster:getCasterLevelForSpell(resref, true), 1)
	local ability = spellHeader:getAbilityForLevel(casterLevel) or spellHeader:getAbility(0)
	if ability == nil then return nil end

	local headerAddress = EEex_UDToPtr(spellHeader)

	local origin = {
		["resref"]        = resref,
		["level"]         = EEex_ReadU32(headerAddress + 0x34),
		["school"]        = EEex_ReadU8(headerAddress + 0x25),
		["secondaryType"] = EEex_ReadU8(headerAddress + 0x27),
	}

	local abilityAddress = EEex_UDToPtr(ability)
	ZJSpellInfo_Private_ReadAbilityEffects(headerAddress, abilityAddress, origin, effects, depth, caster)
	return spellHeader, abilityAddress
end

-- Returns the name of what `caster` is about to use, its effects on a target and its range, (the ability's range field,
-- 0x0E in both SPL and ITM abilities), or nil if it isn't a spell / item ability
function ZJSpellInfo_Private_ReadUsed(caster)

	local abilityId = caster.m_currentUseButton.m_abilityId
	local effects = {}
	local resref = abilityId.m_res:get():upper()

	-- The item in the slot the button names, (a quick item button names the item's own resref, which is never a spell)
	local item, itemResref = nil, ""
	local itemNum = abilityId.m_itemNum
	if itemNum >= 0 then
		local ok, slotItem = pcall(function() return caster.m_equipment.m_items:get(itemNum) end)
		if ok and slotItem ~= nil then
			item = slotItem
			itemResref = slotItem.cResRef:get():upper()
		end
	end

	-- A spell, (from the spellbook, a special ability, an innate)
	if resref ~= "" and resref ~= itemResref then
		local spellHeader, spellAbilityAddress = ZJSpellInfo_Private_ReadSpell(resref, caster, effects, 0)
		if spellHeader ~= nil then
			local name = ZJSpellInfo_Private_GetSourceName(resref)
			return name ~= "" and name or resref, effects, EEex_ReadU16(spellAbilityAddress + 0x0E)
		end
	end

	-- An item ability, (a wand, a scroll, a potion thrown at someone)
	if item == nil or itemResref == "" then return nil end
	local itemHeader = EEex_Resource_Demand(itemResref, "ITM")
	if itemHeader == nil then return nil end

	local abilityNum = abilityId.m_abilityNum
	if abilityNum < 0 or abilityNum >= itemHeader.abilityCount then return nil end

	local headerAddress = EEex_UDToPtr(itemHeader)
	local abilityAddress = headerAddress + itemHeader.abilityOffset + 0x38 * abilityNum

	local origin = { ["resref"] = itemResref, ["level"] = 0, ["school"] = 0, ["secondaryType"] = 0 }
	ZJSpellInfo_Private_ReadAbilityEffects(headerAddress, abilityAddress, origin, effects, 0, caster)

	local name = ZJSpellInfo_Private_FetchString(itemHeader.identifiedName)
	if name == "" then name = ZJSpellInfo_Private_FetchString(itemHeader.genericName) end
	return name, effects, EEex_ReadU16(abilityAddress + 0x0E)
end

------------
-- Checks --
------------

-- Returns whether `sprite` matches row `row` of SPLPROT.2DA, (`value` is used where the row's VALUE is -1),
-- the row's label, e.g. "race=elf", and false if the check can't be worked out here
function ZJSpellInfo_Private_CheckSplprot(sprite, row, value)

	if ZJSpellInfo_Private_Splprot == nil then
		ZJSpellInfo_Private_Splprot = EEex_Resource_Load2DA("SPLPROT")
	end

	local array = ZJSpellInfo_Private_Splprot
	local stat = tonumber(array:getAtPoint(0, row))
	local tableValue = tonumber(array:getAtPoint(1, row))
	local relation = tonumber(array:getAtPoint(2, row))
	if stat == nil or tableValue == nil or relation == nil then return nil end

	-- 0x103 / 0x104 combine two other rows, (VALUE and RELATION are row numbers): the sprite matches either of them,
	-- or neither of them. Larloch's Minor Drain excludes "ENTRIES=(1||27)", undead or golems.
	if stat == 0x103 or stat == 0x104 then
		if tableValue == row or relation == row then return nil end
		local matchesA, labelA = ZJSpellInfo_Private_CheckSplprot(sprite, tableValue, value)
		local matchesB, labelB = ZJSpellInfo_Private_CheckSplprot(sprite, relation, value)
		if stat == 0x103 then
			if matchesA then return true, labelA end
			if matchesB then return true, labelB end
			if matchesA == nil or matchesB == nil then return nil end
			return false, labelA
		end
		if matchesA == nil or matchesB == nil then return nil end
		return not matchesA and not matchesB, string.format("not %s or %s", labelA, labelB)
	end

	if tableValue ~= -1 then value = tableValue end

	local compare = ZJSpellInfo_Private_SplprotRelations[relation]
	if compare == nil then return nil end

	local spriteValue
	if stat < 0x100 then
		spriteValue = sprite:getStat(stat)
	else
		local getter = ZJSpellInfo_Private_SplprotSpecialStats[stat]
		if getter == nil then return nil end
		spriteValue = getter(sprite)
	end

	local label = EEex_Resource_Get2DARowLabel(array, row) or ""
	label = label:gsub("^%d+_", ""):gsub("_", " "):lower()

	return compare(spriteValue, value), label
end

-- Returns why a creature of `level` is outside `effect`'s level range, or nil if the effect lands on it.
-- The named opcodes, and op318 / op324, use their dice fields as a level range, (Sleep only affects creatures up to level 4).
function ZJSpellInfo_Private_LevelExcludes(effect, level)

	local opcodeName = ZJSpellInfo_Private_OpcodeNames[effect.opcode]
	if opcodeName == nil and not ZJSpellInfo_Private_SplprotOpcodes[effect.opcode] then return nil end

	local maxLevel = effect.numDice
	local minLevel = effect.diceSize
	if maxLevel > 0 and level > maxLevel then
		return string.format(ZJSpellInfo_Private_T("AboveLevel"), opcodeName or "", level, maxLevel)
	end
	if minLevel > 0 and level < minLevel then
		return string.format(ZJSpellInfo_Private_T("BelowLevel"), opcodeName or "", level, minLevel)
	end
	return nil
end

-- Returns why `target` ignores `effect`, or nil, (level ranges are handled by ZJSpellInfo_Private_LevelExcludes)
function ZJSpellInfo_Private_FindBlocker(target, effect)

	local opcode = effect.opcode
	local origin = effect.origin
	local opcodeName = ZJSpellInfo_Private_OpcodeNames[opcode]

	local reason

	local scan = function(list)
		EEex_Utility_IterateCPtrList(list, function(protection)

			local protectionOpcode = protection.m_effectId

			if protectionOpcode == 101 then -- Immunity to effect
				if opcodeName ~= nil and protection.m_dWFlags == opcode then
					reason = string.format(ZJSpellInfo_Private_T("ImmuneTo"), opcodeName)
				end
			elseif protectionOpcode == 102 then -- Immunity to spell level
				if origin.level > 0 and protection.m_effectAmount == origin.level then
					reason = string.format(ZJSpellInfo_Private_T("ImmuneToLevel"), origin.level)
				end
			elseif protectionOpcode == 204 then -- Protection from spell school
				if origin.school > 0 and protection.m_dWFlags == origin.school then
					local schoolName = ZJSpellInfo_Private_SchoolNames[origin.school] or "?"
					reason = string.format(ZJSpellInfo_Private_T("ImmuneToSchool"), schoolName)
				end
			elseif protectionOpcode == 205 then -- Protection from spell type
				if origin.secondaryType > 0 and protection.m_dWFlags == origin.secondaryType then
					reason = ZJSpellInfo_Private_T("ImmuneToType")
				end
			elseif protectionOpcode == 206 then -- Protection from spell
				if protection.m_res:get():upper() == origin.resref then
					reason = ZJSpellInfo_Private_T("ProtectedFromSpell")
				end
			end

			if reason ~= nil then
				local sourceResref = protection.m_sourceRes:get()
				if sourceResref ~= "" then
					local sourceName = ZJSpellInfo_Private_GetProtectionSourceName(sourceResref:upper())
					if sourceName ~= "" then reason = string.format("%s (%s)", reason, sourceName) end
				end
				return true -- Break EEex_Utility_IterateCPtrList
			end
		end)
	end

	scan(target.m_equipedEffectList)
	if reason == nil then scan(target.m_timedEffectList) end

	return reason
end

-- Returns the lines that describe `effects` against `target`
function ZJSpellInfo_Private_Describe(target, effects)

	local lines = {}
	local red, green, grey = ZJSpellInfo_Private_RedColorStr, ZJSpellInfo_Private_GreenColorStr, ZJSpellInfo_Private_GreyColorStr
	local stats = target:getActiveStats()

	-- Keep only the effects that land on a creature of the target's level. Some spells have one version of an effect
	-- for low levels and another for high levels, (Command: no save up to level 5, a save from level 6), so an effect
	-- outside its range only makes the target unaffected when no other version of it applies.
	local level = stats.m_nLevel1
	local applying, levelReasons = {}, {}
	for _, effect in ipairs(effects) do
		local levelReason = ZJSpellInfo_Private_LevelExcludes(effect, level)
		if levelReason == nil then
			table.insert(applying, effect)
		elseif ZJSpellInfo_Private_OpcodeNames[effect.opcode] ~= nil then
			table.insert(levelReasons, { ["effect"] = effect, ["reason"] = levelReason })
		end
	end
	effects = applying

	-- The spell's own exclusions, (op318 / op324: "the target is immune to this spell if it matches SPLPROT row X")
	local excluded = {} -- [spell resref] = reason
	for _, effect in ipairs(effects) do
		if ZJSpellInfo_Private_SplprotOpcodes[effect.opcode] and excluded[effect.origin.resref] == nil then
			local ok, matches, label = pcall(ZJSpellInfo_Private_CheckSplprot, target, effect.param2, effect.param1)
			if ok and matches then
				local protectedResref = effect.res ~= "" and effect.res or effect.origin.resref
				excluded[protectedResref] = string.format(ZJSpellInfo_Private_T("Excludes"), label)
			end
		end
	end

	-- Magic resistance only stops the effects that can be resisted, (resistance field 1 / 2)
	local resistible, anyEffect = false, false
	for _, effect in ipairs(effects) do
		if not ZJSpellInfo_Private_SplprotOpcodes[effect.opcode] then
			anyEffect = true
			if effect.resist == 1 or effect.resist == 2 then resistible = true end
		end
	end

	local magicResistance = stats.m_nResistMagic
	if not anyEffect or ZJSpellInfo_Private_ShowMagicResistance:get() == 0 then
		-- Nothing lands on the target, (a spell aimed at a point / the caster)
	elseif not resistible then
		table.insert(lines, string.format("%s: %d%% %s(%s)^-", ZJSpellInfo_Private_T("MagicResistance"),
			magicResistance, grey, ZJSpellInfo_Private_T("Bypassed")))
	else
		table.insert(lines, string.format("%s: %s%d%%^-", ZJSpellInfo_Private_T("MagicResistance"),
			magicResistance > 0 and red or "", magicResistance))
	end

	-- Saving throws: the target saves when its d20 roll plus the save bonus reaches its save
	local seenSaves = {}
	local saveDisplayType = ZJSpellInfo_Private_SaveDisplayType:get()
	for _, effect in ipairs(ZJSpellInfo_Private_ShowSavingThrows:get() ~= 0 and effects or {}) do
		for _, saveType in ipairs(ZJSpellInfo_Private_SaveTypes) do
			local bit = saveType[1]
			if EEex_BAnd(effect.saveType, bit) ~= 0 and not seenSaves[bit] then
				seenSaves[bit] = true

				local need = stats[saveType[3]] - effect.saveMod
				local saveStr
				if need <= 1 then
					saveStr = red..ZJSpellInfo_Private_T("AlwaysSaves").."^-"
				elseif need > 20 then
					saveStr = green..ZJSpellInfo_Private_T("CannotSave").."^-"
				elseif saveDisplayType == 0 then
					saveStr = string.format(ZJSpellInfo_Private_T("SavesOnRoll"), need)
				elseif saveDisplayType == 1 then
					saveStr = string.format(ZJSpellInfo_Private_T("SavesChance"), (21 - need) * 5)
				else
					saveStr = string.format(ZJSpellInfo_Private_T("SavesOn"), need, (21 - need) * 5)
				end

				local modStr = effect.saveMod ~= 0 and string.format(" %s(%+d)^-", grey, effect.saveMod) or ""
				table.insert(lines, string.format("%s %s%s: %s", ZJSpellInfo_Private_T("SaveVs"),
					ZJSpellInfo_Private_T("Save"..saveType[2]), modStr, saveStr))
			end
		end
	end

	-- Damage, per element, with the target's resistance to it
	local damageOrder, damageByType = {}, {}
	for _, effect in ipairs(ZJSpellInfo_Private_ShowDamage:get() ~= 0 and effects or {}) do
		if effect.opcode == 12 then
			local damageType = EEex_RShift(effect.param2, 16)
			local amountStr = ""
			if effect.numDice > 0 and effect.diceSize > 0 then
				amountStr = string.format("%dD%d", effect.numDice, effect.diceSize)
				if effect.param1 ~= 0 then amountStr = amountStr..string.format("%+d", effect.param1) end
			elseif effect.param1 ~= 0 then
				amountStr = tostring(effect.param1)
			end

			local entry = damageByType[damageType]
			if entry == nil then
				entry = { ["amounts"] = {}, ["seen"] = {}, ["count"] = 0 }
				damageByType[damageType] = entry
				table.insert(damageOrder, damageType)
			end
			entry.count = entry.count + 1
			if amountStr ~= "" and not entry.seen[amountStr] then
				entry.seen[amountStr] = true
				table.insert(entry.amounts, amountStr)
			end
		end
	end

	for _, damageType in ipairs(damageOrder) do
		local entry = damageByType[damageType]
		local typeInfo = ZJSpellInfo_Private_DamageTypes[damageType] or { "damage", nil }
		local amountStr = table.concat(entry.amounts, "/")
		if entry.count > #entry.amounts and entry.count > 1 then
			amountStr = string.format("%s x%d", amountStr, entry.count)
		end

		local resistStr = ""
		if typeInfo[2] ~= nil then
			local resistance = math.min(stats[typeInfo[2]], 100)
			if resistance >= 100 then
				resistStr = string.format(" %s%s^-", red, ZJSpellInfo_Private_T("Immune"))
			elseif resistance > 0 then
				resistStr = string.format(" %s-%d%%^-", red, resistance)
			elseif resistance < 0 then
				resistStr = string.format(" %s+%d%%^-", green, -resistance)
			end
		end

		table.insert(lines, string.format("%s: %s%s", string.format(ZJSpellInfo_Private_T("Damage"), typeInfo[1]),
			amountStr, resistStr))
	end

	-- Why the target would be unaffected, one line per reason
	if ZJSpellInfo_Private_ShowImmunities:get() == 0 then return lines end

	local reasons, seenReasons = {}, {}
	local addReason = function(reason)
		if reason ~= nil and not seenReasons[reason] then
			seenReasons[reason] = true
			table.insert(reasons, reason)
		end
	end

	for _, reason in pairs(excluded) do
		addReason(reason)
	end

	for _, entry in ipairs(levelReasons) do
		local skipped = entry.effect
		local otherVersionApplies = false
		for _, effect in ipairs(effects) do
			if effect.opcode == skipped.opcode and effect.origin.resref == skipped.origin.resref then
				otherVersionApplies = true
				break
			end
		end
		if not otherVersionApplies and excluded[skipped.origin.resref] == nil then
			addReason(entry.reason)
		end
	end

	for _, effect in ipairs(effects) do
		if excluded[effect.origin.resref] == nil and (ZJSpellInfo_Private_OpcodeNames[effect.opcode] or effect.opcode == 12) then
			local ok, reason = pcall(ZJSpellInfo_Private_FindBlocker, target, effect)
			if ok then addReason(reason) end
		end
	end

	-- The spell / sub-spell itself can be blocked by level, school, type or name
	local seenOrigins = {}
	for _, effect in ipairs(effects) do
		local origin = effect.origin
		if not seenOrigins[origin.resref] and excluded[origin.resref] == nil then
			seenOrigins[origin.resref] = true
			local ok, reason = pcall(ZJSpellInfo_Private_FindBlocker, target,
				{ ["opcode"] = -1, ["origin"] = origin, ["numDice"] = 0, ["diceSize"] = 0 })
			if ok then addReason(reason) end
		end
	end

	for _, reason in ipairs(reasons) do
		table.insert(lines, red..reason.."^-")
	end

	return lines
end

-- Returns the popup's text for `caster` using what it is about to use on `target`, or nil if there is nothing to show
function ZJSpellInfo_Private_BuildText(caster, target)

	local name, effects, range = ZJSpellInfo_Private_ReadUsed(caster)
	if name == nil then return nil end

	local title = string.format(ZJSpellInfo_Private_T("Title"), name, target:getName())
	local lines = ZJSpellInfo_Private_Describe(target, effects)
	if ZJSpellInfo_Private_ShowDistance:get() ~= 0 then
		table.insert(lines, 1, ZJSpellInfo_Private_DescribeDistance(caster, target, range))
	end
	table.insert(lines, 1, title)
	return table.concat(lines, "\n")
end

-- Returns the line with how far `target` is from `caster`, and how far it is out of reach, in the units of an ability's
-- range field, (search map squares of 16 pixels). The engine measures distances in pixels, with the vertical axis
-- stretched by 4/3, (see Attack Info's ZJAttackInfo_Private_IsInArea).
--
-- A caster also has to see the target: its visual range, (14 by default, in units of 32 pixels), caps the range.
-- Tested in game: Command, (range 35), and Magic Missile, (range 60), both walk until about 416 pixels away, straight
-- up as well as sideways, (inside the 448 pixels of the default visual range, the caster stops on the walking grid).
function ZJSpellInfo_Private_DescribeDistance(caster, target, range)

	local casterPos, targetPos = caster.m_pos, target.m_pos
	local offsetX = targetPos.x - casterPos.x
	local offsetY = (targetPos.y - casterPos.y) * 4 / 3
	local distance = math.floor(math.sqrt(offsetX * offsetX + offsetY * offsetY) / 16 + 0.5)

	local ok, visualRange = pcall(function() return caster:getActiveStats().m_nVisualRange end)
	if not ok or visualRange == nil or visualRange <= 0 then visualRange = 14 end
	local sight = visualRange * 2

	local reach = range
	local distanceStr
	if sight < range then
		reach = sight
		distanceStr = string.format(ZJSpellInfo_Private_T("DistanceSight"), distance, range, sight)
	else
		distanceStr = string.format(ZJSpellInfo_Private_T("Distance"), distance, range)
	end

	if distance <= reach then return distanceStr end
	return string.format("%s %s%s^-", distanceStr, ZJSpellInfo_Private_RedColorStr,
		string.format(ZJSpellInfo_Private_T("OutOfRange"), distance - reach))
end

----------
-- Menu --
----------

-- The cursor's hotspot and size, (in menu coordinates), so the popup can go beside the cursor image
function ZJSpellInfo_Private_GetCursorRenderData()

	local vidMode = EngineGlobals.g_pBaldurChitin.cVideo.pCurrentMode
	local cursorCell = vidMode.pPointerVidCell
	if cursorCell == nil then return end

	local centerX, centerY = cursorCell:GetCurrentCenterPoint()
	local w, h = cursorCell:GetCurrentFrameSize()
	return EEex_Menu_ScaleX(centerX), EEex_Menu_ScaleY(centerY), EEex_Menu_ScaleX(w), EEex_Menu_ScaleY(h)
end

function ZJSpellInfo_Private_Layout()

	local fontPoint = ZJSpellInfo_Private_FontPoint:get()
	local style = styles["normal"]
	local text = ZJSpellInfo_Private_Menu_Text

	ZJSpellInfo_Private_Menu_TextUD.text.point = fontPoint

	local textW = 0
	for line in (text.."\n"):gmatch("(.-)\n") do
		textW = math.max(textW, (EEex_Menu_GetTextWidthHeight(line, style.font, fontPoint, style.useFontZoom)))
	end
	textW = textW + 2 -- Room for rounding, so the engine doesn't wrap a line that just fits

	local _, textH = EEex_Menu_GetTextWidthHeight(text, style.font, fontPoint, style.useFontZoom, textW)

	local pad = 12
	local backgroundW = textW + pad * 2
	local backgroundH = textH + pad * 2

	-- Beside the cursor, like the attack popup
	local cursorX, cursorY = EEex_Menu_GetMousePos()
	local cursorCenterX, cursorCenterY, cursorW = ZJSpellInfo_Private_GetCursorRenderData()
	cursorCenterX, cursorCenterY, cursorW = cursorCenterX or 0, cursorCenterY or 0, cursorW or 0

	local cursorRenderX = cursorX - cursorCenterX
	local backgroundX = cursorRenderX + cursorW + 5
	local backgroundY = cursorY - cursorCenterY

	local screenW, screenH = Infinity_GetScreenSize()
	if backgroundX + backgroundW > screenW then
		backgroundX = math.max(0, cursorRenderX - backgroundW - 5)
	end
	if backgroundY + backgroundH > screenH then
		backgroundY = math.max(0, screenH - backgroundH)
	end

	Infinity_SetOffset("ZJSpellInfo_Menu", backgroundX, backgroundY)
	Infinity_SetArea("ZJSpellInfo_Menu_BackgroundRect", 0, 0, backgroundW, backgroundH)
	Infinity_SetArea("ZJSpellInfo_Menu_Text", pad, pad, textW, textH)
end

-- @bubb_doc { ZJSpellInfo_SetOpen }
-- @summary: Opens / closes the spell info popup.
function ZJSpellInfo_SetOpen(open)
	if open then
		if not ZJSpellInfo_Private_Menu_IsOpen then
			Infinity_PushMenu("ZJSpellInfo_Menu")
			ZJSpellInfo_Private_Menu_IsOpen = true
		end
	elseif ZJSpellInfo_Private_Menu_IsOpen then
		Infinity_PopMenu("ZJSpellInfo_Menu")
		ZJSpellInfo_Private_Menu_IsOpen = false
	end
end

-- @bubb_doc { ZJSpellInfo_SetEnabled }
-- @summary: Temporarily turns the popup on / off. To persist this, change the ``ZJSpellInfo_Enable`` option instead.
function ZJSpellInfo_SetEnabled(enabled)
	ZJSpellInfo_Private_Enabled = enabled
	if not enabled then ZJSpellInfo_SetOpen(false) end
end

-- @bubb_doc { ZJSpellInfo_IsOpen }
-- @summary: Whether the popup is showing.
function ZJSpellInfo_IsOpen()
	return ZJSpellInfo_Private_Menu_IsOpen
end

-- The text of the popup for the creature under the cursor, or nil if it shouldn't be showing
function ZJSpellInfo_Private_GetText()

	if not ZJSpellInfo_Private_Enabled then return nil end
	if not ZJPopup_IsOpenAllowed(ZJSpellInfo_Private_OpenOn) then return nil end

	-- Only on the world screen, while a spell / item is waiting for a target,
	-- (m_nState is 1 when it is aimed at a point, like Sleep, and 2 when it is aimed at a creature, like Command)
	if e:GetActiveEngine() ~= worldScreen then return nil end
	local state = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nState
	if state ~= 1 and state ~= 2 then return nil end

	local target = EEex_GameObject_GetUnderCursor()
	if not EEex_GameObject_IsSprite(target) then return nil end

	-- PC, FAMILIAR, ALLY, CONTROLLED, CHARMED, ... up to GOODCUTOFF, (EA.IDS)
	if ZJSpellInfo_Private_ShowOnParty:get() == 0 then
		local ea = target.m_typeAI.m_EnemyAlly
		if ea >= 2 and ea <= 30 then return nil end
	end

	-- The selected creature that is about to use something
	local caster = nil
	EEex_Sprite_IterateSelected(function(sprite)
		if caster == nil then caster = sprite end
	end)
	if caster == nil then return nil end

	return ZJSpellInfo_Private_BuildText(caster, target)
end

ZJSpellInfo_Private_FrameTextFrame = -1  -- The frame ZJSpellInfo_Private_FrameText was worked out in
ZJSpellInfo_Private_FrameText      = nil

-- ZJSpellInfo_Private_GetText(), worked out at most once per frame. Both this module's ticker and Attack Info's ask for
-- it, in whichever order their menus run, and get the same answer.
function ZJSpellInfo_Private_GetFrameText()
	local frame = Infinity_GetFrameCounter()
	if frame ~= ZJSpellInfo_Private_FrameTextFrame then
		ZJSpellInfo_Private_FrameText = ZJSpellInfo_Private_GetText()
		ZJSpellInfo_Private_FrameTextFrame = frame
	end
	return ZJSpellInfo_Private_FrameText
end

-- @bubb_doc { ZJSpellInfo_WillOpen }
-- @summary: Whether the popup shows this frame, (even if its ticker hasn't run yet). The Attack Info module stays
--           out of its way while it does.
function ZJSpellInfo_WillOpen()
	local ok, text = pcall(ZJSpellInfo_Private_GetFrameText)
	return ok and text ~= nil
end

-----------
-- Areas --
-----------

-- The ground a spell / item ability will affect, drawn by ZJSpellInfo_Menu_Area:
--
--   * While a spell / item waits for a target: around the creature under the cursor, (or the cursor itself), or around
--     the caster if it casts its area on itself, (Chant)
--   * Over an action bar button: a spell cast on the caster, (Chant), around the character, and turn undead / find
--     traps around the character
--
-- Both only while the "Open On" key is held. A cone, (from the caster, while it is aimed), is drawn by its own label.

ZJSpellInfo_Private_AreaSequences = { ["spell"] = 0, ["modal"] = 1 } -- In ZJSPLARE.BAM
ZJSpellInfo_Private_Menu_Area = { ["enabled"] = false, ["sequence"] = 0 }

-- ZJSPLCON.BAM has one sequence per cone width, (the widths of the game's cone projectiles, a cone of any other width
-- uses the closest), with a frame per direction, (see tools/make-cone-bam.ps1)
ZJSpellInfo_Private_ConeWidths = { 45, 90, 120, 140 }
ZJSpellInfo_Private_ConeDirections = 64
ZJSpellInfo_Private_Menu_Cone = { ["enabled"] = false, ["sequence"] = 0, ["frame"] = 0 }
ZJSpellInfo_Private_Menu_AreaDrawing = false -- True while ZJSpellInfo_Menu_Area is being drawn
ZJSpellInfo_Private_Menu_AreaOpacity = 170 -- Of 255, on top of the see-through fill of ZJSPLARE.BAM

-- The action bar's button types, (EEex_Actionbar_ButtonType), whose modal action covers ZJArea_GetModalRange()
ZJSpellInfo_Private_ModalButtonTypes = {
	[4]  = true, -- FIND_TRAPS
	[13] = true, -- TURN_UNDEAD
}

-- An ability's target, (0x0C), that is the caster itself
ZJSpellInfo_Private_SelfTargets = {
	[5] = true, -- Caster
	[7] = true, -- Caster, (instant)
}

ZJSpellInfo_Private_ActionbarMenuName = "WORLD_ACTIONBAR"
ZJSpellInfo_Private_ActionbarButtons = nil -- Array of { item, index }, the buttons of the action bar
ZJSpellInfo_Private_HoverSpellCache = { ["key"] = nil, ["resref"] = nil }

-- Returns the address of the header and of the ability of what `caster` is about to use, and the ability's missile
-- type, (see ZJSpellInfo_Private_ReadUsed()), or nil
function ZJSpellInfo_Private_GetUsedAbility(caster)

	local abilityId = caster.m_currentUseButton.m_abilityId
	local resref = abilityId.m_res:get():upper()

	local itemResref = ""
	local itemNum = abilityId.m_itemNum
	if itemNum >= 0 then
		local ok, slotItem = pcall(function() return caster.m_equipment.m_items:get(itemNum) end)
		if ok and slotItem ~= nil then
			itemResref = slotItem.cResRef:get():upper()
		end
	end

	if resref ~= "" and resref ~= itemResref then
		local spellHeader = EEex_Resource_Demand(resref, "SPL")
		if spellHeader ~= nil then
			local casterLevel = math.max(caster:getCasterLevelForSpell(resref, true), 1)
			local ability = spellHeader:getAbilityForLevel(casterLevel) or spellHeader:getAbility(0)
			if ability == nil then return nil end
			local abilityAddress = EEex_UDToPtr(ability)
			return EEex_UDToPtr(spellHeader), abilityAddress, EEex_ReadU16(abilityAddress + 0x26)
		end
	end

	if itemResref == "" then return nil end
	local itemHeader = EEex_Resource_Demand(itemResref, "ITM")
	if itemHeader == nil then return nil end

	local abilityNum = abilityId.m_abilityNum
	if abilityNum < 0 or abilityNum >= itemHeader.abilityCount then return nil end

	local headerAddress = EEex_UDToPtr(itemHeader)
	local abilityAddress = headerAddress + itemHeader.abilityOffset + 0x38 * abilityNum
	return headerAddress, abilityAddress, EEex_ReadU16(abilityAddress + 0x2A)
end

-- Whether `area` can be drawn as a circle
function ZJSpellInfo_Private_IsDrawableArea(area)
	return area and area.range > 0 and not ZJArea_IsCone(area)
end

-- The area of the spell / item waiting for a target: { gameX, gameY } or { uiX, uiY }, range, sequence; or nil.
-- A cone also has coneSize and aimUIX, aimUIY, (the point it is aimed at), and gameX, gameY is the caster.
function ZJSpellInfo_Private_GetAimArea()

	-- 1 = aimed at a point, 2 = aimed at a creature
	local state = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nState
	if state ~= 1 and state ~= 2 then return nil end

	local caster = nil
	EEex_Sprite_IterateSelected(function(sprite)
		if caster == nil then caster = sprite end
	end)
	if caster == nil then return nil end

	local headerAddress, abilityAddress, missileType = ZJSpellInfo_Private_GetUsedAbility(caster)
	if headerAddress == nil then return nil end

	local area = ZJArea_ReadAbilityArea(headerAddress, abilityAddress, missileType)
	if not area or area.range <= 0 then return nil end

	local result = { ["range"] = area.range, ["sequence"] = ZJSpellInfo_Private_AreaSequences.spell }

	local target = EEex_GameObject_GetUnderCursor()
	if ZJArea_IsCone(area) then
		-- A cone starts at the caster and points at the creature / point it is aimed at
		result.coneSize = area.coneSize
		result.gameX, result.gameY = caster.m_pos.x, caster.m_pos.y
		if state == 2 and EEex_GameObject_IsSprite(target) then
			result.aimUIX, result.aimUIY = EEex_Menu_TranslateXYFromGame(target.m_pos.x, target.m_pos.y)
		else
			result.aimUIX, result.aimUIY = EEex_Menu_GetMousePos()
		end
	elseif area.onCaster then
		result.gameX, result.gameY = caster.m_pos.x, caster.m_pos.y
	elseif state == 2 and EEex_GameObject_IsSprite(target) then
		-- The projectile explodes where the creature stands
		result.gameX, result.gameY = target.m_pos.x, target.m_pos.y
	else
		result.uiX, result.uiY = EEex_Menu_GetMousePos()
	end

	return result
end

-- The buttons of the action bar, (the ones with an "actionBar <index>"), see Item Info's version
function ZJSpellInfo_Private_GetActionbarButtons()

	local buttons = ZJSpellInfo_Private_ActionbarButtons
	if buttons ~= nil then return buttons end

	buttons = {}
	local menu = EEex_Menu_Find(ZJSpellInfo_Private_ActionbarMenuName)
	if menu ~= nil then
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

	ZJSpellInfo_Private_ActionbarButtons = buttons
	return buttons
end

-- Returns the resref of the spell / innate of `sprite` whose name is in the tooltip `text` of an action bar button,
-- (the engine's button data isn't in EEex's bindings, its tooltip is), the longest name that matches, or nil
function ZJSpellInfo_Private_FindSpellByTooltip(sprite, text)

	local best, bestLength = nil, 0

	-- 2 = spells, 4 = innates / special abilities
	for _, buttonType in ipairs({ 2, 4 }) do
		local list = sprite:GetQuickButtons(buttonType, false)
		EEex_Utility_IterateCPtrList(list, function(buttonData)
			local resref = buttonData.m_abilityId.m_res:get():upper()
			local name = ZJSpellInfo_Private_GetSourceName(resref)
			if name ~= "" and #name > bestLength and text:find(name, 1, true) then
				best, bestLength = resref, #name
			end
		end)
		EEex_Utility_FreeCPtrList(list)
	end

	return best
end

-- The area of the action bar button under the cursor while the "Open On" key is held, see ZJSpellInfo_Private_GetAimArea()
function ZJSpellInfo_Private_GetHoverArea()

	if not Infinity_IsMenuOnStack(ZJSpellInfo_Private_ActionbarMenuName) then return nil end

	local index = nil
	for _, button in ipairs(ZJSpellInfo_Private_GetActionbarButtons()) do
		local x, y, w, h = button.item:getArea()
		if EEex_Menu_IsCursorWithinRect(x, y, w, h) then
			index = button.index
			break
		end
	end
	if index == nil then return nil end

	local sprite = EEex_Sprite_GetSelected()
	if not EEex_GameObject_IsSprite(sprite) then return nil end
	local pos = sprite.m_pos

	local buttonType = EEex_Actionbar_GetArray().m_buttonTypes:get(index)
	if ZJSpellInfo_Private_ModalButtonTypes[buttonType] then
		return {
			["gameX"] = pos.x, ["gameY"] = pos.y,
			["range"] = ZJArea_GetModalRange(sprite),
			["sequence"] = ZJSpellInfo_Private_AreaSequences.modal,
		}
	end

	-- A spell button, (in the spell list, or a quick spell): found by its name
	local text = actionBarTooltip ~= nil and actionBarTooltip[index] or nil
	if type(text) ~= "string" or text == "" then return nil end

	local cache = ZJSpellInfo_Private_HoverSpellCache
	local key = string.format("%d:%d:%s", sprite.m_id, index, text)
	if cache.key ~= key then
		cache.key = key
		cache.resref = ZJSpellInfo_Private_FindSpellByTooltip(sprite, text)
	end
	local resref = cache.resref
	if resref == nil then return nil end

	local spellHeader = EEex_Resource_Demand(resref, "SPL")
	if spellHeader == nil then return nil end
	local casterLevel = math.max(sprite:getCasterLevelForSpell(resref, true), 1)
	local ability = spellHeader:getAbilityForLevel(casterLevel) or spellHeader:getAbility(0)
	if ability == nil then return nil end
	local abilityAddress = EEex_UDToPtr(ability)

	-- A spell aimed elsewhere shows its area while it is being aimed
	if not ZJSpellInfo_Private_SelfTargets[EEex_ReadU8(abilityAddress + 0x0C)] then return nil end

	local area = ZJArea_ReadAbilityArea(EEex_UDToPtr(spellHeader), abilityAddress, EEex_ReadU16(abilityAddress + 0x26))
	if not ZJSpellInfo_Private_IsDrawableArea(area) then return nil end

	return {
		["gameX"] = pos.x, ["gameY"] = pos.y,
		["range"] = area.range,
		["sequence"] = ZJSpellInfo_Private_AreaSequences.spell,
	}
end

-- Shows / hides the area label for this frame
function ZJSpellInfo_Private_UpdateArea()

	local entry = ZJSpellInfo_Private_Menu_Area
	local cone = ZJSpellInfo_Private_Menu_Cone
	local area = nil

	entry.enabled = false
	cone.enabled = false

	-- Only while the "Open On" key is held, like the popup
	if ZJSpellInfo_Private_Enabled and ZJSpellInfo_Private_ShowAreas:get() ~= 0 and e:GetActiveEngine() == worldScreen
		and ZJPopup_IsOpenAllowed(ZJSpellInfo_Private_OpenOn)
	then
		area = ZJSpellInfo_Private_GetAimArea() or ZJSpellInfo_Private_GetHoverArea()
	end

	if area == nil then return end

	-- Game pixels to menu pixels, (the vertical axis is stretched by 4/3, so the engine's circles are 4:3 ellipses)
	local originX = EEex_Menu_TranslateXYFromGame(0, 0)
	local edgeX = EEex_Menu_TranslateXYFromGame(area.range, 0)
	local radiusX = edgeX - originX
	local radiusY = math.floor(radiusX * 3 / 4 + 0.5)

	local centerX, centerY = area.uiX, area.uiY
	if area.gameX ~= nil then
		centerX, centerY = EEex_Menu_TranslateXYFromGame(area.gameX, area.gameY)
	end

	if radiusX <= 0 then return end
	local x, y, w, h = centerX - radiusX, centerY - radiusY, radiusX * 2, radiusY * 2

	if area.coneSize ~= nil then

		-- The direction in the engine's stretched space, (the vertical axis stretched by 4/3)
		local aimX = area.aimUIX - centerX
		local aimY = (area.aimUIY - centerY) * 4 / 3

		-- Aimed at the caster's own spot the engine has no direction, and treats the cone as a circle, (see
		-- Attack Info's ZJAttackInfo_Private_IsCastingSpellAt())
		if aimX ~= 0 or aimY ~= 0 then

			local angle = (math.atan2 or math.atan)(aimY, aimX)
			local directions = ZJSpellInfo_Private_ConeDirections
			cone.frame = math.floor(angle / (2 * math.pi) * directions + 0.5) % directions

			local closest, closestDiff = 1, math.huge
			for i, width in ipairs(ZJSpellInfo_Private_ConeWidths) do
				local diff = math.abs(width - area.coneSize)
				if diff < closestDiff then closest, closestDiff = i, diff end
			end
			cone.sequence = closest - 1

			Infinity_SetArea("ZJSpellInfo_Menu_AreaCone", x, y, w, h)
			cone.enabled = true
			return
		end
	end

	Infinity_SetArea("ZJSpellInfo_Menu_AreaLabel", x, y, w, h)
	entry.enabled = true
	entry.sequence = area.sequence
end

-- Over an enabled item the engine doesn't pick the creature under the cursor, and a spell can't be cast on it. The
-- area is only enabled while its menu is being drawn, (see ZJSplInf.menu), so whenever the engine checks the mouse it
-- finds the area disabled.
function ZJSpellInfo_Private_Menu_AreaDrawBegin()
	ZJSpellInfo_Private_Menu_AreaDrawing = true
	return 0
end

function ZJSpellInfo_Private_Menu_AreaDrawEnd()
	ZJSpellInfo_Private_Menu_AreaDrawing = false
	return 0
end

function ZJSpellInfo_Private_Menu_Area_Enabled()
	return ZJSpellInfo_Private_Menu_AreaDrawing and ZJSpellInfo_Private_Menu_Area.enabled
end

function ZJSpellInfo_Private_Menu_Cone_Enabled()
	return ZJSpellInfo_Private_Menu_AreaDrawing and ZJSpellInfo_Private_Menu_Cone.enabled
end

function ZJSpellInfo_Private_DoTick()

	local text = ZJSpellInfo_Private_GetFrameText()

	if text == nil then
		ZJSpellInfo_SetOpen(false)
		return
	end

	ZJSpellInfo_Private_Menu_Text = text
	ZJSpellInfo_SetOpen(true)
	ZJSpellInfo_Private_Layout()
end

-- Called every frame by the ticker menu
function ZJSpellInfo_Private_Tick()

	-- The area is extra, never let it take the popup down
	if not pcall(ZJSpellInfo_Private_UpdateArea) then
		ZJSpellInfo_Private_Menu_Area.enabled = false
		ZJSpellInfo_Private_Menu_Cone.enabled = false
	end

	local ok, err = pcall(ZJSpellInfo_Private_DoTick)

	if not ok then
		pcall(ZJSpellInfo_SetOpen, false)
		-- This runs every frame, don't flood the log
		if not ZJSpellInfo_Private_ErrorReported then
			ZJSpellInfo_Private_ErrorReported = true
			print("[Battle Sense] Spell Info: "..tostring(err))
		end
	end
end

---------------
-- Listeners --
---------------

function ZJSpellInfo_Private_PushTicker()
	-- Pushed first, so the area is drawn below the popup
	if not Infinity_IsMenuOnStack("ZJSpellInfo_Menu_Area") then
		Infinity_PushMenu("ZJSpellInfo_Menu_Area")
	end
	if not Infinity_IsMenuOnStack("ZJSpellInfo_Menu_Ticker") then
		Infinity_PushMenu("ZJSpellInfo_Menu_Ticker")
	end
end

EEex_Menu_AddMainFileLoadedListener(function()
	EEex_Menu_LoadFile("ZJSplInf")
	ZJSpellInfo_Private_Menu_IsOpen = false
	-- The UI was (re)loaded, its items are new
	ZJSpellInfo_Private_ActionbarButtons = nil
	ZJSpellInfo_Private_Menu_TextUD = EEex_Menu_GetItem("ZJSpellInfo_Menu_Text")
end)

-- The ticker is always open while a game is running
EEex_GameState_AddInitializedListener(ZJSpellInfo_Private_PushTicker)
EEex_Menu_AddAfterMainFileReloadedListener(ZJSpellInfo_Private_PushTicker)

EEex.RegisterSlicedRect("ZJSpellInfo_BackgroundRect", {
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

function ZJSpellInfo_Private_Background_Render(item)
	EEex.DrawSlicedRect("ZJSpellInfo_BackgroundRect", { item:getArea() }, 255 * 0.85)
end

EEex_Menu_AddBeforeUIItemRenderListener("ZJSpellInfo_Menu_BackgroundRect", ZJSpellInfo_Private_Background_Render)

-- The creature's own tooltip would sit under the popup
EEex_Utility_NewScope(function()
	local old = EEex_Sprite_Hook_CheckSuppressTooltip
	EEex_Sprite_Hook_CheckSuppressTooltip = function()
		return ZJSpellInfo_Private_Menu_IsOpen or old()
	end
end)
