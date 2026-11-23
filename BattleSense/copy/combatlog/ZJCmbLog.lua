
--[[
+----------------------------------------------------------------------------------------------------------------+
| ZJCombatLog - Adds explanatory lines to the combat log                                                         |
+----------------------------------------------------------------------------------------------------------------+
|   Effect ends        - "Imoen- Haste wore off" / "Gibberling- Blindness wore off"                              |
|   Failed saves       - "Gnoll- Failed save vs. Spell against Sleep"                                             |
|   Immunities         - "Skeleton- Unaffected by Sleep: immune to sleep"                                        |
|   Weapon ineffective - "Minsc- Long Sword is ineffective against Werewolf: it requires a +1 weapon or better"  |
+----------------------------------------------------------------------------------------------------------------+
|   Everything here is built on existing EEex hooks:                                                             |
|                                                                                                                |
|     * Effect ends / failed saves compare each creature's timed effect list before and after the engine         |
|       resolves it (EEex_Opcode_AddDeferredListsResolvedListener). An effect that carries a saving throw and    |
|       shows up in the list can only have got there because the save was failed.                                |
|                                                                                                                |
|     * Immunities need to see effects the engine is about to throw away, so the module gives every creature     |
|       an op403 (ScreenEffects) effect that points at ZJCLSCRN(). That function never blocks anything, it only  |
|       looks. The op403 effect is saved with the creature like any other effect.                                |
|                                                                                                                |
|     * Weapon ineffective wraps EEex_Opcode_Hook_OnAfterSwingCheckedOp248() / ...Op249().                       |
+----------------------------------------------------------------------------------------------------------------+
--]]

-------------
-- Options --
-------------

ZJCombatLog_Private_Enable = EEex_Options_Register("ZJCombatLog_Enable", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Combat Log" }),
	["onChange"] = function(self, oldValue) ZJCombatLog_Private_OnScreenOptionChanged() end,
}))

-- Report buffs / conditions ending
ZJCombatLog_Private_ReportEffectEnds = EEex_Options_Register("ZJCombatLog_ReportEffectEnds", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Combat Log Module: Report Effect Ends" }),
}))

-- Report failed saving throws
ZJCombatLog_Private_ReportFailedSaves = EEex_Options_Register("ZJCombatLog_ReportFailedSaves", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Combat Log Module: Report Failed Saves" }),
}))

-- Report why a spell did nothing, (adds an op403 effect to every creature)
ZJCombatLog_Private_ReportImmunities = EEex_Options_Register("ZJCombatLog_ReportImmunities", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Combat Log Module: Report Immunities" }),
	["onChange"] = function(self, oldValue) ZJCombatLog_Private_OnScreenOptionChanged() end,
}))

-- Report why a weapon is ineffective
ZJCombatLog_Private_ReportIneffectiveWeapons = EEex_Options_Register("ZJCombatLog_ReportIneffectiveWeapons", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Combat Log Module: Report Ineffective Weapons" }),
}))

-- Only print lines where the party is on one end of what happened
ZJCombatLog_Private_PartyOnly = EEex_Options_Register("ZJCombatLog_PartyOnly", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Combat Log Module: Party Only" }),
}))

-- Seconds before an identical line may be printed again. At least 1: a spell is made of many effects that all arrive
-- in the same tick, and each would print the same line.
ZJCombatLog_Private_RepeatDelay = EEex_Options_Register("ZJCombatLog_RepeatDelay", EEex_Options_Option.new({
	["default"]  = 20,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Combat Log Module: Repeat Delay" }),
}))

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_CombatLog_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCombatLog_Enable",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CombatLog_Enable",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CombatLog_Enable_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCombatLog_ReportEffectEnds",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CombatLog_ReportEffectEnds",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CombatLog_ReportEffectEnds_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCombatLog_ReportFailedSaves",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CombatLog_ReportFailedSaves",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CombatLog_ReportFailedSaves_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCombatLog_ReportImmunities",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CombatLog_ReportImmunities",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CombatLog_ReportImmunities_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCombatLog_ReportIneffectiveWeapons",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CombatLog_ReportIneffectiveWeapons",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CombatLog_ReportIneffectiveWeapons_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCombatLog_PartyOnly",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CombatLog_PartyOnly",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CombatLog_PartyOnly_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCombatLog_RepeatDelay",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CombatLog_RepeatDelay",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CombatLog_RepeatDelay_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"]        = true,
			}),
		}),
	},
} end)

-- Whether a report option is on, (and the module itself)
function ZJCombatLog_Private_IsOn(option)
	return ZJCombatLog_Private_Enable:get() ~= 0 and option:get() ~= 0
end

---------------
-- Constants --
---------------

-- Name of the global function op403 calls; must be 8 characters or less, and ALL UPPERCASE
ZJCombatLog_Private_ScreenName = "ZJCLSCRN"

-- Opcodes worth naming on their own. Used to describe op101 immunities,
-- and to label effects that don't come from a named spell or item.
ZJCombatLog_Private_OpcodeNames = {
	[  3] = "berserk",
	[  5] = "charm",
	[ 13] = "instant death",
	[ 24] = "fear",
	[ 25] = "poison",
	[ 38] = "silence",
	[ 39] = "sleep",
	[ 40] = "slow",
	[ 45] = "stun",
	[ 55] = "instant death",
	[ 74] = "blindness",
	[ 76] = "feeblemind",
	[ 78] = "disease",
	[ 80] = "deafness",
	[109] = "hold",
	[128] = "confusion",
	[134] = "petrification",
	[135] = "polymorph",
	[154] = "entangle",
	[157] = "web",
	[158] = "grease",
	[175] = "hold",
	[185] = "hold",
	[209] = "instant death",
	[211] = "imprisonment",
	[213] = "maze",
	[216] = "level drain",
	[238] = "disintegration",
}

ZJCombatLog_Private_SchoolNames = {
	[1] = "Abjuration",
	[2] = "Conjuration",
	[3] = "Divination",
	[4] = "Enchantment",
	[5] = "Illusion",
	[6] = "Evocation",
	[7] = "Necromancy",
	[8] = "Alteration",
}

-- { m_savingThrow bit, display name, the save it has to reach }
ZJCombatLog_Private_SaveTypes = {
	{ 0x01, "Spell",     "m_nSaveVSSpell"  },
	{ 0x02, "Breath",    "m_nSaveVSBreath" },
	{ 0x04, "Death",     "m_nSaveVSDeath"  },
	{ 0x08, "Wand",      "m_nSaveVSWands"  },
	{ 0x10, "Polymorph", "m_nSaveVSPoly"   },
}

-------------
-- Globals --
-------------

ZJCombatLog_Private_Tracked       = {} -- [spriteID] = effect groups seen at the last list resolution
ZJCombatLog_Private_ScreenChecked = {} -- [spriteID] = true once the op403 screen has been added / removed
ZJCombatLog_Private_Recent        = {} -- [key] = game time a line / check was last made
ZJCombatLog_Private_RecentCount   = 0
ZJCombatLog_Private_NameCache     = {} -- [resref] = display name ("" if none)
ZJCombatLog_Private_LevelCoverCache = {} -- ["resref|opcode|level"] = whether some version of the effect lands at that level

-------------
-- General --
-------------

function ZJCombatLog_Private_GameTime()
	return EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
end

function ZJCombatLog_Private_Say(sprite, text)
	Infinity_DisplayString(string.format("%s- %s", sprite:getName(), text))
end

function ZJCombatLog_Private_GetSprite(objectID)
	if objectID == nil or objectID == -1 then return nil end
	local object = EEex_GameObject_Get(objectID)
	if object ~= nil and EEex_GameObject_IsSprite(object, true) then return object end
	return nil
end

-- PC, FAMILIAR, ALLY, CONTROLLED, CHARMED, ... up to GOODCUTOFF
function ZJCombatLog_Private_IsPartySide(sprite)
	local ea = sprite.m_typeAI.m_EnemyAlly
	return ea >= 2 and ea <= 30
end

-- Lines are only printed when the party is on one end of whatever happened, (unless the "Party Only" option is off).
-- This keeps the log readable, and doesn't leak what unseen creatures do to each other.
function ZJCombatLog_Private_InvolvesParty(sprite, otherID)
	if ZJCombatLog_Private_PartyOnly:get() == 0 then return true end
	if ZJCombatLog_Private_IsPartySide(sprite) then return true end
	local other = ZJCombatLog_Private_GetSprite(otherID)
	return other ~= nil and ZJCombatLog_Private_IsPartySide(other)
end

-- Returns true if `key` was already marked within the repeat delay; otherwise marks it
function ZJCombatLog_Private_WasRecent(key, now)

	local last = ZJCombatLog_Private_Recent[key]
	if last ~= nil and math.abs(now - last) < ZJCombatLog_Private_RepeatDelay:get() * 15 then -- 15 game ticks per second
		return true
	end

	if last == nil then
		if ZJCombatLog_Private_RecentCount >= 2000 then
			ZJCombatLog_Private_Recent = {}
			ZJCombatLog_Private_RecentCount = 0
		end
		ZJCombatLog_Private_RecentCount = ZJCombatLog_Private_RecentCount + 1
	end

	ZJCombatLog_Private_Recent[key] = now
	return false
end

function ZJCombatLog_Private_FetchString(strref)
	if strref == nil or strref == -1 or strref == 0xFFFFFFFF then return "" end
	return Infinity_FetchString(strref) or ""
end

function ZJCombatLog_Private_GetItemName(itemHeader)
	local name = ZJCombatLog_Private_FetchString(itemHeader.identifiedName)
	if name == "" then name = ZJCombatLog_Private_FetchString(itemHeader.genericName) end
	return name
end

-- Returns the display name of the spell / item `resref`, or "" if it has none
function ZJCombatLog_Private_GetSourceName(resref, sourceType)

	local cached = ZJCombatLog_Private_NameCache[resref]
	if cached ~= nil then return cached end

	local lookup = function(toLookup)

		local trySpell = function()
			local spellHeader = EEex_Resource_Demand(toLookup, "SPL")
			return spellHeader and ZJCombatLog_Private_FetchString(spellHeader.genericName) or ""
		end

		local tryItem = function()
			local itemHeader = EEex_Resource_Demand(toLookup, "ITM")
			return itemHeader and ZJCombatLog_Private_GetItemName(itemHeader) or ""
		end

		local name
		if sourceType == 2 then
			name = tryItem()
			if name == "" then name = trySpell() end
		else
			name = trySpell()
			if name == "" then name = tryItem() end
		end
		return name
	end

	local name = lookup(resref)

	-- Subspells are conventionally named after their parent with a trailing letter, (SPWI112 -> SPWI112A)
	if name == "" and #resref == 8 then
		name = lookup(resref:sub(1, 7))
	end

	ZJCombatLog_Private_NameCache[resref] = name
	return name
end

-- Returns the name of the spell / item `resref` that a protection comes from, or "" if it isn't worth naming.
-- A creature's built-in immunities come from hidden items it can't drop, (a skeleton's "Ring"); naming those
-- would suggest it wears something that protects it.
function ZJCombatLog_Private_GetProtectionSourceName(resref, sourceType)
	if sourceType == 2 or EEex_Resource_Demand(resref, "SPL") == nil then
		local itemHeader = EEex_Resource_Demand(resref, "ITM")
		if itemHeader ~= nil and (EEex_BAnd(itemHeader.itemFlags, 0x4) == 0 -- BIT2 = droppable
			or ZJCombatLog_Private_FetchString(itemHeader.identifiedName) == "")
		then
			return ""
		end
	end
	return ZJCombatLog_Private_GetSourceName(resref, sourceType)
end

-------------------------------
-- Effect ends / Failed saves --
-------------------------------

-- Collapses the sprite's timed effects into one entry per spell / item / condition
function ZJCombatLog_Private_Snapshot(sprite)

	local groups = {}

	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)

		-- Skip completely permanent effects (behind-the-scenes effects)
		local durationType = effect.m_durationType
		if durationType == 9 then return end -- Continue EEex_Utility_IterateCPtrList

		local label = ""

		local sourceResref = effect.m_sourceRes:get()
		if sourceResref ~= "" then
			label = ZJCombatLog_Private_GetSourceName(sourceResref, effect.m_sourceType)
		end

		if label == "" then
			local opcodeName = ZJCombatLog_Private_OpcodeNames[effect.m_effectId]
			if opcodeName == nil then return end -- Continue EEex_Utility_IterateCPtrList
			label = opcodeName:sub(1, 1):upper()..opcodeName:sub(2)
		end

		local group = groups[label]
		if group == nil then
			group = { ["label"] = label, ["sourceID"] = effect.m_sourceId }
			groups[label] = group
		end

		if durationType == 0x1000 then
			-- Applied timed effects store the game time they expire at
			local expiry = effect.m_duration
			if group.expiry == nil or expiry > group.expiry then group.expiry = expiry end
		else
			group.openEnded = true
		end

		if group.saveName == nil then
			local savingThrow = effect.m_savingThrow
			for _, saveType in ipairs(ZJCombatLog_Private_SaveTypes) do
				if EEex_BAnd(savingThrow, saveType[1]) ~= 0 then
					group.saveName = saveType[2]
					group.saveType = saveType
					group.saveMod = effect.m_saveMod
					break
				end
			end
		end
	end)

	return groups
end

function ZJCombatLog_Private_ReportEnded(sprite, oldGroups, newGroups, now)

	local woreOff = {}
	local ended = {}

	for label, group in pairs(oldGroups) do
		if newGroups[label] == nil and ZJCombatLog_Private_InvolvesParty(sprite, group.sourceID) then
			if not group.openEnded and group.expiry ~= nil and group.expiry <= now + 1 then
				table.insert(woreOff, label)
			else
				-- Dispelled, cured, used up (Stoneskin, Mirror Image), ...
				table.insert(ended, label)
			end
		end
	end

	if woreOff[1] ~= nil then
		table.sort(woreOff)
		ZJCombatLog_Private_Say(sprite, string.format("%s wore off", table.concat(woreOff, ", ")))
	end

	if ended[1] ~= nil then
		table.sort(ended)
		ZJCombatLog_Private_Say(sprite, string.format("%s ended", table.concat(ended, ", ")))
	end
end

-- Returns " (needed 12+)" for the save `group` was let through by, or "" if it can't be read.
--
-- The creature saves when its d20 roll plus the effect's save bonus reaches its save, (the same sum Spell Info shows
-- before casting). The roll itself isn't shown: the one the engine keeps on the creature has often been rerolled by
-- the time the effect turns up in the list. The engine's own "Save vs. Death : 12" line is a different thing: it is
-- only printed when the creature *makes* its save, and shows the roll plus the save bonus, (CGameEffect::CheckSave
-- saves when roll + bonuses >= save).
function ZJCombatLog_Private_DescribeSaveNeed(sprite, group)

	local saveType = group.saveType
	if saveType == nil then return "" end

	local ok, need = pcall(function()
		return sprite:getActiveStats()[saveType[3]] - (group.saveMod or 0)
	end)
	if not ok or type(need) ~= "number" then return "" end

	return string.format(" (needed %d+)", need)
end

-- (Not named ..._ReportFailedSaves: that is the option, and a function by the same name would replace it)
function ZJCombatLog_Private_PrintFailedSaves(sprite, oldGroups, newGroups)

	local spriteID = sprite.m_id
	local lines = {}

	for label, group in pairs(newGroups) do

		if oldGroups[label] == nil and group.saveName ~= nil and group.sourceID ~= spriteID
			and ZJCombatLog_Private_InvolvesParty(sprite, group.sourceID)
		then
			table.insert(lines, string.format("Failed save vs. %s against %s%s", group.saveName, label,
				ZJCombatLog_Private_DescribeSaveNeed(sprite, group)))
		end
	end

	table.sort(lines)
	for _, line in ipairs(lines) do
		ZJCombatLog_Private_Say(sprite, line)
	end
end

function ZJCombatLog_Private_OnListsResolved(sprite)

	-- The engine resolves effect lists on temporary copies of sprites, (item comparison); ignore those
	local spriteID = sprite.m_id
	local realSprite = EEex_GameObject_Get(spriteID)
	if realSprite == nil or not EEex_UDEqual(realSprite, sprite) then return end

	ZJCombatLog_Private_UpdateScreen(sprite)

	local reportFailedSaves = ZJCombatLog_Private_IsOn(ZJCombatLog_Private_ReportFailedSaves)
	local reportEffectEnds = ZJCombatLog_Private_IsOn(ZJCombatLog_Private_ReportEffectEnds)

	if not reportEffectEnds and not reportFailedSaves then
		-- What is tracked would be stale once a report is turned back on
		ZJCombatLog_Private_Tracked[spriteID] = nil
		return
	end

	-- Everything falls off a dying creature; that isn't news
	if EEex_BAnd(sprite.m_baseStats.m_generalState, 0xFC0) ~= 0 then
		ZJCombatLog_Private_Tracked[spriteID] = nil
		return
	end

	local newGroups = ZJCombatLog_Private_Snapshot(sprite)
	local oldGroups = ZJCombatLog_Private_Tracked[spriteID]
	ZJCombatLog_Private_Tracked[spriteID] = newGroups

	-- First time seeing this sprite, nothing to compare against
	if oldGroups == nil then return end

	if reportFailedSaves then
		ZJCombatLog_Private_PrintFailedSaves(sprite, oldGroups, newGroups)
	end

	if reportEffectEnds then
		ZJCombatLog_Private_ReportEnded(sprite, oldGroups, newGroups, ZJCombatLog_Private_GameTime())
	end
end

----------------
-- Immunities --
----------------

function ZJCombatLog_Private_HasScreen(sprite)
	local found = false
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_effectId == 403 and effect.m_res:get() == ZJCombatLog_Private_ScreenName then
			found = true
			return true -- Break EEex_Utility_IterateCPtrList
		end
	end)
	return found
end

-- Adds the op403 screen to a sprite the first time it is seen,
-- or removes a previously saved one if the feature has been turned off
function ZJCombatLog_Private_UpdateScreen(sprite)

	local spriteID = sprite.m_id
	if ZJCombatLog_Private_ScreenChecked[spriteID] then return end
	ZJCombatLog_Private_ScreenChecked[spriteID] = true

	local hasScreen = ZJCombatLog_Private_HasScreen(sprite)
	local wantScreen = ZJCombatLog_Private_IsOn(ZJCombatLog_Private_ReportImmunities)

	if wantScreen and not hasScreen then
		sprite:applyEffect({
			["effectID"]     = 403, -- ScreenEffects
			["durationType"] = 9,
			["res"]          = ZJCombatLog_Private_ScreenName,
			["m_sourceRes"]  = ZJCombatLog_Private_ScreenName,
			["sourceID"]     = spriteID,
		})
	elseif not wantScreen and hasScreen then
		sprite:applyEffect({
			["effectID"]     = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"]          = ZJCombatLog_Private_ScreenName,
			["sourceID"]     = spriteID,
		})
	end

	-- A save made with the EEex fork Battle Sense started in has that fork's version of the screen on every creature.
	-- It is removed, unless the fork's Combat Log is running and still uses it, (see M_ZJBSen.lua).
	if B3CLSCRN == ZJBattleSense_Private_LegacyCombatLogScreen then
		local legacyName = "B3CLSCRN"
		local hasLegacyScreen = false
		EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
			if effect.m_effectId == 403 and effect.m_res:get() == legacyName then
				hasLegacyScreen = true
				return true -- Break EEex_Utility_IterateCPtrList
			end
		end)
		if hasLegacyScreen then
			sprite:applyEffect({
				["effectID"]     = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"]          = legacyName,
				["sourceID"]     = spriteID,
			})
		end
	end
end

-- Returns whether the spell / item `resref` has an effect with `opcode` whose level range includes `level`.
-- Some spells have one version of an effect for low levels and another for high levels, (Command: no save up to
-- level 5, a save from level 6), so an effect skipped for its level range only means the creature is unaffected
-- when no other version of it lands. Every ability is looked at, which can only make this say "covered" more often.
function ZJCombatLog_Private_SourceCoversLevel(resref, sourceType, opcode, level)

	local key = string.format("%s|%d|%d", resref, opcode, level)
	local cached = ZJCombatLog_Private_LevelCoverCache[key]
	if cached ~= nil then return cached end

	local scan = function(extension, abilitySize)

		local header = EEex_Resource_Demand(resref, extension)
		if header == nil then return nil end

		-- SPL and ITM headers share these offsets; only the size of an ability differs
		local headerAddress = EEex_UDToPtr(header)
		local effectsAddress = headerAddress + EEex_ReadU32(headerAddress + 0x6A)

		local checkRange = function(first, count)
			for i = first, first + count - 1 do
				local address = effectsAddress + 0x30 * i
				if EEex_ReadU16(address) == opcode then
					local maxLevel = EEex_ReadU32(address + 0x1C)
					local minLevel = EEex_ReadU32(address + 0x20)
					if (maxLevel == 0 or level <= maxLevel) and (minLevel == 0 or level >= minLevel) then
						return true
					end
				end
			end
			return false
		end

		if checkRange(EEex_ReadU16(headerAddress + 0x6E), EEex_ReadU16(headerAddress + 0x70)) then return true end

		local abilitiesAddress = headerAddress + EEex_ReadU32(headerAddress + 0x64)
		for j = 0, EEex_ReadU16(headerAddress + 0x68) - 1 do
			local abilityAddress = abilitiesAddress + abilitySize * j
			if checkRange(EEex_ReadU16(abilityAddress + 0x20), EEex_ReadU16(abilityAddress + 0x1E)) then return true end
		end
		return false
	end

	local covers
	if sourceType == 2 then
		covers = scan("ITM", 0x38)
		if covers == nil then covers = scan("SPL", 0x28) end
	else
		covers = scan("SPL", 0x28)
		if covers == nil then covers = scan("ITM", 0x38) end
	end
	covers = covers == true

	ZJCombatLog_Private_LevelCoverCache[key] = covers
	return covers
end

-- Returns why `sprite` ignores `effect`, and the resref / source type of whatever grants that protection
function ZJCombatLog_Private_FindBlocker(sprite, effect, opcode, sourceResref)

	local opcodeName = ZJCombatLog_Private_OpcodeNames[opcode]

	-- The named effects can be limited to a level range, (Sleep only affects creatures up to level 4)
	if opcodeName ~= nil then

		local level = sprite.m_derivedStats.m_nLevel1
		local minLevel = effect.m_minLevel
		local maxLevel = effect.m_maxLevel
		local outside = (maxLevel > 0 and level > maxLevel) or (minLevel > 0 and level < minLevel)

		if outside then
			local ok, covered = pcall(ZJCombatLog_Private_SourceCoversLevel, sourceResref, effect.m_sourceType, opcode, level)
			if ok and covered then return nil end

			if maxLevel > 0 and level > maxLevel then
				return string.format("level %d is above the limit of %d", level, maxLevel)
			end
			return string.format("level %d is below the minimum of %d", level, minLevel)
		end
	end

	local spellLevel = effect.m_spellLevel
	local school = effect.m_school
	local secondaryType = effect.m_secondaryType

	local reason, blockerResref, blockerSourceType

	local scan = function(list)

		EEex_Utility_IterateCPtrList(list, function(protection)

			local protectionOpcode = protection.m_effectId

			if protectionOpcode == 101 then -- Immunity to effect
				if opcodeName ~= nil and protection.m_dWFlags == opcode then
					reason = string.format("immune to %s", opcodeName)
				end
			elseif protectionOpcode == 102 then -- Immunity to spell level
				if spellLevel > 0 and protection.m_effectAmount == spellLevel then
					reason = string.format("immune to level %d spells", spellLevel)
				end
			elseif protectionOpcode == 204 then -- Protection from spell school
				if school > 0 and protection.m_dWFlags == school then
					local schoolName = ZJCombatLog_Private_SchoolNames[school]
					reason = schoolName and string.format("immune to %s spells", schoolName) or "immune to this school of magic"
				end
			elseif protectionOpcode == 205 then -- Protection from spell type
				if secondaryType > 0 and protection.m_dWFlags == secondaryType then
					reason = "immune to this type of spell"
				end
			elseif protectionOpcode == 206 then -- Protection from spell
				if protection.m_res:get() == sourceResref then
					reason = "protected from this spell"
				end
			end

			if reason ~= nil then
				blockerResref = protection.m_sourceRes:get()
				blockerSourceType = protection.m_sourceType
				return true -- Break EEex_Utility_IterateCPtrList
			end
		end)
	end

	scan(sprite.m_equipedEffectList)
	if reason == nil then scan(sprite.m_timedEffectList) end

	return reason, blockerResref, blockerSourceType
end

function ZJCombatLog_Private_Screen(effect, sprite)

	-- Only spell / item effects
	local sourceResref = effect.m_sourceRes:get()
	if sourceResref == "" then return end

	-- Only effects coming from someone else
	local spriteID = sprite.m_id
	local sourceID = effect.m_sourceId
	if sourceID == spriteID then return end

	-- Spells are made of many effects, and area spells reapply every round; only look once in a while
	local opcode = effect.m_effectId
	local now = ZJCombatLog_Private_GameTime()
	if ZJCombatLog_Private_WasRecent(string.format("check|%d|%s|%d", spriteID, sourceResref, opcode), now) then return end

	if not ZJCombatLog_Private_InvolvesParty(sprite, sourceID) then return end

	local reason, blockerResref, blockerSourceType = ZJCombatLog_Private_FindBlocker(sprite, effect, opcode, sourceResref)
	if reason == nil then return end

	local label = ZJCombatLog_Private_GetSourceName(sourceResref, effect.m_sourceType)
	if label == "" then return end

	if ZJCombatLog_Private_WasRecent(string.format("line|%d|%s|%s", spriteID, label, reason), now) then return end

	local origin = ""
	if blockerResref ~= nil and blockerResref ~= "" then
		local blockerName = ZJCombatLog_Private_GetProtectionSourceName(blockerResref, blockerSourceType)
		if blockerName ~= "" then origin = string.format(" (%s)", blockerName) end
	end

	ZJCombatLog_Private_Say(sprite, string.format("Unaffected by %s: %s%s", label, reason, origin))
end

-- Called by op403 for every effect about to be added to a creature; never blocks anything.
-- This must stay defined even when the feature is off, as saved creatures may still reference it.
function ZJCLSCRN(op403, effect, sprite)
	if ZJCombatLog_Private_IsOn(ZJCombatLog_Private_ReportImmunities) then
		EEex_Utility_TryIgnore(ZJCombatLog_Private_Screen, effect, sprite)
	end
	return false
end

------------------------
-- Weapon ineffective --
------------------------

-- Returns why op120 (immunity to weapons) with the given parameters stops a weapon, or nil if it doesn't
function ZJCombatLog_Private_DescribeWeaponImmunity(immunityType, immunityEnchantment, itemFlags, enchantment)

	local magical   = EEex_BAnd(itemFlags, 0x40)  ~= 0
	local silver    = EEex_BAnd(itemFlags, 0x100) ~= 0
	local coldIron  = EEex_BAnd(itemFlags, 0x200) ~= 0
	local twoHanded = EEex_BAnd(itemFlags, 0x2)   ~= 0
	local cursed    = EEex_BAnd(itemFlags, 0x10)  ~= 0

	if immunityType == 0 then
		if enchantment <= immunityEnchantment then
			return string.format("it requires a +%d weapon or better, (this is +%d)", immunityEnchantment + 1, enchantment)
		end
	elseif immunityType == 1 then
		if magical then return "it is immune to magical weapons" end
	elseif immunityType == 2 then
		if not magical then return "it requires a magical weapon" end
	elseif immunityType == 3 then
		if silver then return "it is immune to silver weapons" end
	elseif immunityType == 4 then
		if not silver then return "it requires a silver weapon" end
	elseif immunityType == 5 then
		if not silver and not magical then return "it requires a silver or magical weapon" end
	elseif immunityType == 6 then
		if twoHanded then return "it is immune to two-handed weapons" end
	elseif immunityType == 7 then
		if not twoHanded then return "it is immune to one-handed weapons" end
	elseif immunityType == 8 then
		if cursed then return "it is immune to cursed weapons" end
	elseif immunityType == 9 then
		if not cursed then return "it is immune to non-cursed weapons" end
	elseif immunityType == 10 then
		if coldIron then return "it is immune to cold iron weapons" end
	elseif immunityType == 11 then
		if not coldIron then return "it requires a cold iron weapon" end
	end

	return nil
end

function ZJCombatLog_Private_ExplainWeapon(sprite, targetSprite, item, abilityNum)

	if item == nil then return false end

	local pRes = item.pRes
	if pRes == nil then return false end

	local itemHeader = pRes.pHeader
	if itemHeader == nil then return false end

	local itemFlags = itemHeader.itemFlags
	local enchantment = itemHeader.attributes

	-- A launcher lends its enchantment to its ammunition
	local ability = item:getAbility(abilityNum)
	if ability ~= nil then
		local launcher = sprite:getLauncher(ability)
		local launcherRes = launcher and launcher.pRes
		local launcherHeader = launcherRes and launcherRes.pHeader
		if launcherHeader and launcherHeader.attributes > enchantment then
			enchantment = launcherHeader.attributes
		end
	end

	local reason

	local scan = function(list)
		EEex_Utility_IterateCPtrList(list, function(effect)
			if effect.m_effectId == 120 then
				reason = ZJCombatLog_Private_DescribeWeaponImmunity(effect.m_dWFlags, effect.m_effectAmount, itemFlags, enchantment)
				if reason ~= nil then return true end -- Break EEex_Utility_IterateCPtrList
			end
		end)
	end

	scan(targetSprite.m_equipedEffectList)
	if reason == nil then scan(targetSprite.m_timedEffectList) end
	if reason == nil then return false end

	local itemName = ZJCombatLog_Private_GetItemName(itemHeader)
	if itemName == "" then itemName = "Weapon" end

	local targetName = targetSprite:getName()
	local key = string.format("weapon|%d|%d|%s|%s", sprite.m_id, targetSprite.m_id, itemName, reason)

	if not ZJCombatLog_Private_WasRecent(key, ZJCombatLog_Private_GameTime()) then
		ZJCombatLog_Private_Say(sprite, string.format("%s is ineffective against %s: %s", itemName, targetName, reason))
	end

	return true
end

function ZJCombatLog_Private_OnWeaponBlocked(sprite, targetSprite)

	if not ZJCombatLog_Private_IsOn(ZJCombatLog_Private_ReportIneffectiveWeapons) then return end
	if not ZJCombatLog_Private_InvolvesParty(sprite, targetSprite.m_id) then return end

	local equipment = sprite.m_equipment
	local items = equipment.m_items

	-- The hook doesn't say which hand swung; explain whichever weapon(s) the target shrugs off
	ZJCombatLog_Private_ExplainWeapon(sprite, targetSprite, items:get(equipment.m_selectedWeapon), equipment.m_selectedWeaponAbility)

	if EEex.CanAttackWithLeftHand(sprite) then
		ZJCombatLog_Private_ExplainWeapon(sprite, targetSprite, items:get(9), 0)
	end
end

---------------
-- Listeners --
---------------

function ZJCombatLog_Private_Reset()
	ZJCombatLog_Private_Tracked       = {}
	ZJCombatLog_Private_ScreenChecked = {}
	ZJCombatLog_Private_Recent        = {}
	ZJCombatLog_Private_RecentCount   = 0
end

-- The op403 screen is only on creatures while immunities are reported; have every creature checked again
function ZJCombatLog_Private_OnScreenOptionChanged()
	ZJCombatLog_Private_ScreenChecked = {}
end

function ZJCombatLog_Private_Forget(spriteID)
	ZJCombatLog_Private_Tracked[spriteID] = nil
	ZJCombatLog_Private_ScreenChecked[spriteID] = nil
end

EEex_Opcode_AddDeferredListsResolvedListener(ZJCombatLog_Private_OnListsResolved)
EEex_GameState_AddDestroyedListener(ZJCombatLog_Private_Reset)

EEex_Utility_NewScope(function()

	-- Object ids are reused, forget what was known about a deleted object
	local oldOnDeleting = EEex_GameObject_Hook_OnDeleting
	EEex_GameObject_Hook_OnDeleting = function(objectID)
		ZJCombatLog_Private_Forget(objectID)
		return oldOnDeleting(objectID)
	end

	local oldOp248 = EEex_Opcode_Hook_OnAfterSwingCheckedOp248
	EEex_Opcode_Hook_OnAfterSwingCheckedOp248 = function(sprite, targetSprite, bBlocked)
		if bBlocked then
			EEex_Utility_TryIgnore(ZJCombatLog_Private_OnWeaponBlocked, sprite, targetSprite)
		end
		return oldOp248(sprite, targetSprite, bBlocked)
	end

	local oldOp249 = EEex_Opcode_Hook_OnAfterSwingCheckedOp249
	EEex_Opcode_Hook_OnAfterSwingCheckedOp249 = function(sprite, targetSprite, bBlocked)
		if bBlocked then
			EEex_Utility_TryIgnore(ZJCombatLog_Private_OnWeaponBlocked, sprite, targetSprite)
		end
		return oldOp249(sprite, targetSprite, bBlocked)
	end
end)
