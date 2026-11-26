
-- The bar colors, (shared with Timer)
Infinity_DoFile("ZJBarCol")
-- The popup and its key, (shared by every module with a popup)
Infinity_DoFile("ZJPopup")
-- The areas of spells / items, (shared with Spell Info)
Infinity_DoFile("ZJArea")

-------------
-- Options --
-------------

-- The module's on / off switch, in the "Battle Sense Modules" tab
EEex_Options_Register("ZJCreatureInfo_Enable", ZJPopup_NewSwitch("Creature Info", {
	["onChange"] = function(self, oldValue) ZJCreatureInfo_SetEnabled(self:get() ~= 0) end,
}))

-- "Enabled For Friendly": the compact popup, over party members and allies that are in a fight
ZJCreatureInfo_Private_CompactForAllies = EEex_Options_Register("ZJCreatureInfo_CompactForAllies", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Creature Info Module: Compact For Allies" }),
}))

ZJCreatureInfo_Private_FontPoint = EEex_Options_Register("ZJCreatureInfo_FontPoint", EEex_Options_Option.new({
	["default"]  = 11,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 99 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Creature Info Module: Font Point" }),
}))

-- 0 = Minimum d20 roll needed to hit, 1 = Hit chance percentage
ZJCreatureInfo_Private_HitDisplayType = EEex_Options_Register("ZJCreatureInfo_HitDisplayType", EEex_Options_Option.new({
	["default"]  = 0,
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Creature Info Module: Hit Display Type" }),
}))

-- The colors of the resistance and immunity labels, one of the bar colors, (ZJBarCol.lua), option value 0 is Off: the
-- damage is shown as if the target had no resistance / immunity
local registerLabelColorOption = function(name, default)
	return EEex_Options_Register("ZJCreatureInfo_"..name.."Color", EEex_Options_Option.new({
		["default"]  = default,
		["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = #ZJBarColors_Colors }),
		["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Creature Info Module: "..name.." Color" }),
	}))
end

ZJCreatureInfo_Private_ResistanceColor = registerLabelColorOption("Resistance", 1) -- Red
ZJCreatureInfo_Private_ImmunityColor   = registerLabelColorOption("Immunity",   7) -- Purple

-- The text color code of a label color option's value, (half as bright if `dim`), "" if it is Off
function ZJCreatureInfo_Private_LabelColorStr(value, dim)
	local color = ZJBarColors_Colors[value]
	if color == nil then return "" end
	local scale = dim and 0.5 or 1
	return string.format("^0xFF%02X%02X%02X", math.floor(color.b * scale), math.floor(color.g * scale), math.floor(color.r * scale))
end

ZJCreatureInfo_Private_ShowSpellEffects = EEex_Options_Register("ZJCreatureInfo_ShowSpellEffects", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Creature Info Module: Show Spell Effects" }),
}))

ZJCreatureInfo_Private_ShowRowTimers = EEex_Options_Register("ZJCreatureInfo_ShowRowTimers", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Creature Info Module: Show Row Timers" }),
}))

-- 1 = Include the party's summons and other allies, 0 = Only the party members, (companions)
ZJCreatureInfo_Private_ShowAllies = EEex_Options_Register("ZJCreatureInfo_ShowAllies", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Creature Info Module: Show Allies" }),
}))

-- The most creatures listed in the popup: [option value] = the limit, option value 0 is Off, (no limit)
ZJCreatureInfo_Private_MaxRowsChoices = { 6, 10, 15, 20 } -- 6 = a full party
ZJCreatureInfo_Private_MaxRows = EEex_Options_Register("ZJCreatureInfo_MaxRows", EEex_Options_Option.new({
	["default"]  = 0,
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = #ZJCreatureInfo_Private_MaxRowsChoices }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Creature Info Module: Max Creatures" }),
}))

-- A button showing "Off" or the limit, clicking it steps Off, 6, 10, 15, 20, and back to Off
ZJCreatureInfo_MaxRowsWidget = {}
ZJCreatureInfo_MaxRowsWidget.__index = ZJCreatureInfo_MaxRowsWidget
setmetatable(ZJCreatureInfo_MaxRowsWidget, ZJBarColors_CycleWidget)

ZJCreatureInfo_MaxRowsWidget.new = function(o)
	if o == nil then o = {} end
	setmetatable(o, ZJCreatureInfo_MaxRowsWidget)
	o:_init()
	return o
end

function ZJCreatureInfo_MaxRowsWidget:_getCount()
	return #ZJCreatureInfo_Private_MaxRowsChoices
end

function ZJCreatureInfo_MaxRowsWidget:_getText(value)
	local maxRows = ZJCreatureInfo_Private_MaxRowsChoices[value]
	return maxRows and tostring(maxRows) or getUiString(ZJBarColors_OffName)
end

function ZJCreatureInfo_MaxRowsWidget:_getColor(value)
	return EEex_Options_Private_GetFontStyleColor(styles["EEex_Options_Normal"])
end

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_CreatureInfo_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_CompactForAllies",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_CompactForAllies",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_CompactForAllies_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_ShowAllies",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ShowAllies",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ShowAllies_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_MaxRows",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_MaxRows",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_MaxRows_Description",
			["widget"]      = ZJCreatureInfo_MaxRowsWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_FontPoint",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_FontPoint",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_FontPoint_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"]        = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_HitDisplayType",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_HitDisplayType",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_HitDisplayType_Description",
			["widget"]      = EEex_Options_HorizontalMultiToggleWidget.new({
				["toggles"] = {
					{
						["label"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_HitDisplayType_Roll",
						["data"] = { ["toggleValue"] = 0 },
					},
					{
						["label"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_HitDisplayType_Percentage",
						["data"] = { ["toggleValue"] = 1 },
					},
				},
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_ResistanceColor",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ResistanceColor",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ResistanceColor_Description",
			["widget"]      = ZJBarColors_CycleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_ImmunityColor",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ImmunityColor",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ImmunityColor_Description",
			["widget"]      = ZJBarColors_CycleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_ShowSpellEffects",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ShowSpellEffects",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ShowSpellEffects_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJCreatureInfo_ShowRowTimers",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ShowRowTimers",
			["description"] = "ZJBattleSense_Options_TRANSLATION_CreatureInfo_ShowRowTimers_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		ZJBarColors_DisplayEntry("Attack",
			"ZJBattleSense_Options_TRANSLATION_CreatureInfo_AttackBar",
			"ZJBattleSense_Options_TRANSLATION_CreatureInfo_AttackBar_Description"),
		ZJBarColors_DisplayEntry("Cast",
			"ZJBattleSense_Options_TRANSLATION_CreatureInfo_CastBar",
			"ZJBattleSense_Options_TRANSLATION_CreatureInfo_CastBar_Description"),
		ZJBarColors_DisplayEntry("Contingency",
			"ZJBattleSense_Options_TRANSLATION_CreatureInfo_ContingencyBar",
			"ZJBattleSense_Options_TRANSLATION_CreatureInfo_ContingencyBar_Description"),
		ZJBarColors_DisplayEntry("Modal",
			"ZJBattleSense_Options_TRANSLATION_CreatureInfo_ModalBar",
			"ZJBattleSense_Options_TRANSLATION_CreatureInfo_ModalBar_Description"),
	},
} end)

-------------
-- Globals --
-------------

ZJCreatureInfo_Private_CombatantSearchRange = 896 -- Twice a sprite's default visual range
ZJCreatureInfo_Private_GoodCutoff = 30 -- EA.IDS, everything up to this value is on the party's side
ZJCreatureInfo_Private_ObjectTypes = {} -- [script object string] = CAIObjectType
ZJCreatureInfo_Private_CurrentTargetID = -1
ZJCreatureInfo_Private_Enabled = false
ZJCreatureInfo_Private_LastTargetID = -1
ZJCreatureInfo_Private_OpenDelayTarget = -1

-------------
-- General --
-------------

-- @bubb_doc { ZJCreatureInfo_SetEnabled }
--
-- @summary: Temporarily changes the enable state of the creature info popup.
--
-- @note: To persist this change, instead modify the ``ZJCreatureInfo_Enable`` option.
--
-- @param { enabled / type=boolean }: The enable / disable state to set.

function ZJCreatureInfo_SetEnabled(enabled)
	ZJCreatureInfo_Private_Enabled = enabled
	if not enabled then ZJCreatureInfo_Private_Menu_SetOpen(false) end
end

-- Whether `sprite` is a party member, (has a portrait), as opposed to a summon or other ally
function ZJCreatureInfo_Private_IsPartyMember(sprite)
	return EEex_Sprite_GetPortraitIndex(sprite) ~= -1
end

-- Whether the popup may open over `targetSprite`, (`compact` = the target is on the party's side)
function ZJCreatureInfo_Private_IsPopupAllowed(compact, targetSprite)
	if not compact then return true end
	return ZJCreatureInfo_Private_CompactForAllies:get() ~= 0
		and (ZJCreatureInfo_Private_ShowAllies:get() ~= 0 or ZJCreatureInfo_Private_IsPartyMember(targetSprite))
end

----------
-- Misc --
----------

function ZJCreatureInfo_Private_GetCursorRenderData()

	local vidMode = EngineGlobals.g_pBaldurChitin.cVideo.pCurrentMode
	local cursorCell = vidMode.pPointerVidCell
	if cursorCell == nil then return end

	local centerX, centerY = cursorCell:GetCurrentCenterPoint()
	local w, h = cursorCell:GetCurrentFrameSize()
	return EEex_Menu_ScaleX(centerX), EEex_Menu_ScaleY(centerY), EEex_Menu_ScaleX(w), EEex_Menu_ScaleY(h)
end

function ZJCreatureInfo_Private_GetSelectedSprites(targetSprite)

	local selectedSprites = {}
	local addedIDs = {}
	local showAllies = ZJCreatureInfo_Private_ShowAllies:get() ~= 0

	local add = function(sprite)
		if sprite == nil or EEex_UDEqual(sprite, targetSprite) then return end
		-- With "Show Allies" off, selected summons are left out too
		if not showAllies and not ZJCreatureInfo_Private_IsPartyMember(sprite) then return end
		local id = sprite.m_id
		if addedIDs[id] then return end
		addedIDs[id] = true
		table.insert(selectedSprites, sprite)
	end

	EEex_Sprite_IterateSelected(function(sprite)
		add(sprite)
	end)

	-- Always include party members that are attacking the target, or are being attacked by it, even if they aren't selected
	for portraitIndex = 0, 5 do
		local sprite = EEex_Sprite_GetInPortrait(portraitIndex)
		if EEex_GameObject_IsSprite(sprite)
			and (ZJCreatureInfo_Private_IsEngaging(sprite, targetSprite) or ZJCreatureInfo_Private_IsEngaging(targetSprite, sprite))
		then
			add(sprite)
		end
	end

	-- The same goes for the party's summons and other allies near the target
	if showAllies then
		ZJCreatureInfo_Private_IterateCombatants(targetSprite, "[GOODCUTOFF]", add)
	end

	EEex_Utility_AlphanumericSortTable(selectedSprites, function(sprite)
		return sprite:getName()
	end)

	return selectedSprites
end

-- Calls `func` for every creature near `targetSprite` that matches `objectTypeString`, (as per a script object),
-- and is attacking `targetSprite` or is being attacked by it
function ZJCreatureInfo_Private_IterateCombatants(targetSprite, objectTypeString, func)

	local objectType = ZJCreatureInfo_Private_ObjectTypes[objectTypeString]
	if objectType == nil then
		-- Kept for the lifetime of the Lua state so the string isn't parsed every tick
		objectType = EEex_Object_ParseString(objectTypeString)
		ZJCreatureInfo_Private_ObjectTypes[objectTypeString] = objectType
	end

	targetSprite:forAllOfTypeInRange(objectType, ZJCreatureInfo_Private_CombatantSearchRange, function(sprite)
		if EEex_GameObject_IsSprite(sprite)
			and not EEex_UDEqual(sprite, targetSprite)
			and (ZJCreatureInfo_Private_IsEngaging(sprite, targetSprite) or ZJCreatureInfo_Private_IsEngaging(targetSprite, sprite))
		then
			func(sprite)
		end
	end, 0) -- 0 = Don't require line of sight from the target
end

-- Returns every creature that `targetSprite` is attacking or is being attacked by
function ZJCreatureInfo_Private_GetCombatants(targetSprite)

	local combatants = {}

	ZJCreatureInfo_Private_IterateCombatants(targetSprite, "[ANYONE]", function(sprite)
		table.insert(combatants, sprite)
	end)

	EEex_Utility_AlphanumericSortTable(combatants, function(sprite)
		return sprite:getName()
	end)

	return combatants
end

-- The compact popup is used for the party and its summons / allies. Instead of the selected party members,
-- it lists the creatures the target is fighting.
function ZJCreatureInfo_Private_IsCompactTarget(targetSprite)
	return targetSprite.m_typeAI.m_EnemyAlly <= ZJCreatureInfo_Private_GoodCutoff
end

-- With the "Max Creatures" option set, keeps that many of `sprites`: the ones closest to `targetSprite`,
-- still in alphabetical order
function ZJCreatureInfo_Private_LimitRowSprites(sprites, targetSprite)

	local maxRows = ZJCreatureInfo_Private_MaxRowsChoices[ZJCreatureInfo_Private_MaxRows:get()]
	if maxRows == nil or #sprites <= maxRows then return sprites end

	local targetPos = targetSprite.m_pos
	local targetX, targetY = targetPos.x, targetPos.y
	local distances = {}
	for _, sprite in ipairs(sprites) do
		local pos = sprite.m_pos
		local dx, dy = pos.x - targetX, pos.y - targetY
		distances[sprite.m_id] = dx * dx + dy * dy
	end

	local byDistance = {}
	for i, sprite in ipairs(sprites) do byDistance[i] = sprite end
	table.sort(byDistance, function(a, b) return distances[a.m_id] < distances[b.m_id] end)

	local kept = {}
	for i = 1, maxRows do kept[byDistance[i].m_id] = true end

	local limited = {}
	for _, sprite in ipairs(sprites) do
		if kept[sprite.m_id] then table.insert(limited, sprite) end
	end
	return limited
end

-- Returns the sprites to list for `targetSprite`, and whether the compact popup should be used
-- `attackCursor`: the cursor is an attack cursor, the full popup is used then, (the selected creatures attacking an ally)
function ZJCreatureInfo_Private_GetRowSprites(targetSprite, attackCursor)
	if not attackCursor and ZJCreatureInfo_Private_IsCompactTarget(targetSprite) then
		return ZJCreatureInfo_Private_LimitRowSprites(ZJCreatureInfo_Private_GetCombatants(targetSprite), targetSprite), true
	end
	return ZJCreatureInfo_Private_LimitRowSprites(ZJCreatureInfo_Private_GetSelectedSprites(targetSprite), targetSprite), false
end

function ZJCreatureInfo_Private_GetWeaponHitChance(sourceSprite, targetSprite, leftHand)

	local sourceSpriteEquipment = sourceSprite.m_equipment

	local nSourceSpriteSelectedWeapon
	local nSourceSpriteSelectedWeaponAbility
	local sourceSpriteSelectedWeapon

	if leftHand then
		nSourceSpriteSelectedWeapon = 9
		nSourceSpriteSelectedWeaponAbility = 0
		sourceSpriteSelectedWeapon = sourceSpriteEquipment.m_items:get(nSourceSpriteSelectedWeapon)
	else
		nSourceSpriteSelectedWeapon = sourceSpriteEquipment.m_selectedWeapon
		nSourceSpriteSelectedWeaponAbility = sourceSpriteEquipment.m_selectedWeaponAbility
		sourceSpriteSelectedWeapon = sourceSpriteEquipment.m_items:get(nSourceSpriteSelectedWeapon)
	end

	-- With the "Immunity Color" option Off, an immune target is shown as if it weren't immune
	local isImmune = ZJCreatureInfo_Private_ImmunityColor:get() ~= 0
		and EEex.IsImmuneToWeapon(sourceSprite, targetSprite, nSourceSpriteSelectedWeapon, sourceSpriteSelectedWeapon, nSourceSpriteSelectedWeaponAbility)
	local hitChance, reasoning = EEex.GetWeaponHitChance(sourceSprite, targetSprite, sourceSpriteSelectedWeapon, nSourceSpriteSelectedWeaponAbility, leftHand)

	-- Reading the weapon's damage is cosmetic, never let it take the popup down
	local ok, damageStr, extras, damageType, iconDamageType = pcall(ZJCreatureInfo_Private_GetWeaponDamageString,
		sourceSprite, sourceSpriteSelectedWeapon, nSourceSpriteSelectedWeaponAbility, leftHand)

	if not ok or damageStr == nil then
		return hitChance, isImmune, reasoning, nil, nil
	end

	-- The target's resistance to the weapon's damage type reduces what a hit does, (or increases it, if it is negative).
	-- If the target is immune to the weapon, a hit does nothing at all, the resistance makes no difference then and
	-- "Immune" is shown in its place. With the "Resistance Color" option Off, the resistance isn't shown.
	local okResistance, resistance = pcall(ZJCreatureInfo_Private_GetDamageResistance, targetSprite, damageType)
	if isImmune then
		damageStr = string.format("%s %s", damageStr, uiStrings["ZJBattleSense_TRANSLATION_CreatureInfo_Immune"])
	elseif okResistance and resistance ~= 0 and ZJCreatureInfo_Private_ResistanceColor:get() ~= 0 then
		damageStr = string.format("%s %s", damageStr, ZJCreatureInfo_Private_FormatResistance(resistance))
	end

	-- The icons and the extra damage that go behind the damage
	local okDisplay, handDisplay = pcall(ZJCreatureInfo_Private_GetHandDisplay, iconDamageType, extras, targetSprite)

	return hitChance, isImmune, reasoning, damageStr, okDisplay and handDisplay or nil
end

-- ITM ability damage type => the icon(s) that show it, (ZJCREDMG.BAM: frame = icon * 4 + variant, the variants are
-- 0 = green, 1 = red, 2 = dimmed red, 3 = dimmed green; the green ones face the other way).
--   0 = sword (slashing), 1 = mace (crushing), 2 = spear (piercing), 3 = bow (missile), 4 = slingshot (sling ammunition), 5 = fist
-- The file also has: 6 = spell, 7 = item
ZJCreatureInfo_Private_DamageTypeIcons = {
	[1] = { 2 },
	[2] = { 1 },
	[3] = { 0 },
	[4] = { 3 },
	[5] = { 5 },
	[6] = { 2, 1 },
	[7] = { 2, 0 },
	[8] = { 1, 0 },
	[9] = { 4 },
}

-- op12 damage type => { the icon of its element, the resistance stat of the target that applies to it }
-- The icon is the frame in ZJCREELM.BAM: 0 = fire, 1 = cold, 2 = electricity, 3 = acid, 4 = magic
ZJCreatureInfo_Private_EffectDamageTypeIcons = {
	[0x8]   = { 0, "m_nResistFire" },
	[0x200] = { 0, "m_nResistMagicFire" },
	[0x2]   = { 1, "m_nResistCold" },
	[0x400] = { 1, "m_nResistMagicCold" },
	[0x4]   = { 2, "m_nResistElectricity" },
	[0x1]   = { 3, "m_nResistAcid" },
	[0x40]  = { 4, "m_nResistMagic" },
}

ZJCreatureInfo_Private_MaxHandIcons = 2 -- The menu has this many damage type icons, and this many extra damage icons, per hand

-- Returns what is shown behind a weapon's damage:
--
--   typeIcons  => Array of the icons of its damage type(s), (see ZJCreatureInfo_Private_DamageTypeIcons)
--   extraText  => The extra damage it applies on a hit, e.g. "+1D6 -50% +poison", ("" if there is none)
--   extraIcons => Array of the icons of the elements of that extra damage, (see ZJCreatureInfo_Private_EffectDamageTypeIcons)
--
-- If `targetSprite` is given, its resistance to an element is shown behind the amount of that element, as its
-- resistance to the weapon's damage type is behind the weapon's damage: "-50%" does half, "+25%" does a quarter more.
function ZJCreatureInfo_Private_GetHandDisplay(damageType, extras, targetSprite)

	local display = {
		["typeIcons"]  = ZJCreatureInfo_Private_DamageTypeIcons[damageType] or {},
		["extraText"]  = "",
		["extraIcons"] = {},
	}

	-- With the "Resistance Color" option Off, the resistances aren't shown
	local targetStats = targetSprite and ZJCreatureInfo_Private_ResistanceColor:get() ~= 0 and targetSprite:getActiveStats() or nil
	local textParts = {}

	-- The extra damage that has an icon comes first, so the amounts are in the order of the icons
	for pass = 1, 2 do
		for _, extra in ipairs(extras) do

			local iconInfo = ZJCreatureInfo_Private_EffectDamageTypeIcons[extra.typeID]
			local useIcon = iconInfo ~= nil and #display.extraIcons < ZJCreatureInfo_Private_MaxHandIcons

			if pass == 1 and useIcon then

				local text = "+"..extra.amount

				local resistance = targetStats and math.min(targetStats[iconInfo[2]], 100) or 0
				if resistance ~= 0 then
					text = string.format("%s %s", text, ZJCreatureInfo_Private_FormatResistance(resistance))
				end

				table.insert(display.extraIcons, iconInfo[1])
				table.insert(textParts, text)
				extra.shown = true

			elseif pass == 2 and not extra.shown then
				table.insert(textParts, "+"..(extra.amount ~= "" and extra.amount.." " or "")..extra.typeName)
			end
		end
	end

	for _, extra in ipairs(extras) do
		extra.shown = nil
	end

	display.extraText = table.concat(textParts, " ")
	return display
end

-- A resistance that takes damage away is shown in red, one that adds damage, (a negative resistance), in green.
-- The colors depend on the row the text ends up in, (a greyed out row has darker colors), so the text is marked
-- here and colored by ZJCreatureInfo_Private_ColorResistance().
ZJCreatureInfo_Private_ResistanceLessStart = "\1"
ZJCreatureInfo_Private_ResistanceMoreStart = "\3"
ZJCreatureInfo_Private_ResistanceColorEnd  = "\2"

-- Formats what a resistance of `resistance` percent does to damage, e.g. "-50%", or "+25%" for a negative resistance
function ZJCreatureInfo_Private_FormatResistance(resistance)
	local text = string.format("%+d%%", -resistance)
	if resistance > 0 then
		text = ZJCreatureInfo_Private_ResistanceLessStart..text..ZJCreatureInfo_Private_ResistanceColorEnd
	elseif resistance < 0 then
		text = ZJCreatureInfo_Private_ResistanceMoreStart..text..ZJCreatureInfo_Private_ResistanceColorEnd
	end
	return text
end

-- Colors the resistances that ZJCreatureInfo_Private_FormatResistance() marked in `text`:
--   lessColorStr => The color code for the ones that take damage away
--   moreColorStr => The color code for the ones that add damage
--   baseColorStr => The color code of the text around them, ("" if it has the item's own color)
function ZJCreatureInfo_Private_ColorResistance(text, lessColorStr, moreColorStr, baseColorStr)
	text = text:gsub(ZJCreatureInfo_Private_ResistanceLessStart, lessColorStr)
	text = text:gsub(ZJCreatureInfo_Private_ResistanceMoreStart, moreColorStr)
	text = text:gsub(ZJCreatureInfo_Private_ResistanceColorEnd, baseColorStr ~= "" and baseColorStr or "^-")
	return text
end

-- op12 damage types, (the high word of the effect's second parameter)
ZJCreatureInfo_Private_EffectDamageTypeNames = {
	[0x0]   = "crushing",
	[0x1]   = "acid",
	[0x2]   = "cold",
	[0x4]   = "electricity",
	[0x8]   = "fire",
	[0x10]  = "piercing",
	[0x20]  = "poison",
	[0x40]  = "magic",
	[0x80]  = "missile",
	[0x100] = "slashing",
	[0x200] = "magic fire",
	[0x400] = "magic cold",
	[0x800] = "stunning",
}

-- Returns an array of the extra damage the weapon's ability applies to what it hits, each:
--
--   amount   => e.g. "1D6+1", ("" if it has none)
--   typeID   => The op12 damage type, (nil for poison)
--   typeName => e.g. "fire"
--
-- These are effects of the item: saving throws and their chance to apply aren't looked at.
function ZJCreatureInfo_Private_GetOnHitDamage(weaponHeader, ability)

	local extras = {}
	local seen = {}

	local add = function(amount, typeID, typeName)
		local key = amount.." "..typeName
		if not seen[key] then
			seen[key] = true
			table.insert(extras, { ["amount"] = amount, ["typeID"] = typeID, ["typeName"] = typeName })
		end
	end

	local effectsAddress = EEex_UDToPtr(weaponHeader) + weaponHeader.effectsOffset

	for i = ability.startingEffect, ability.startingEffect + ability.effectCount - 1 do

		local effect = EEex_PtrToUD(effectsAddress + Item_effect_st.sizeof * i, "Item_effect_st")
		local opcode = effect.effectID

		if opcode == 12 then -- Damage

			local typeID = EEex_RShift(effect.dwFlags, 16)
			local typeName = ZJCreatureInfo_Private_EffectDamageTypeNames[typeID] or "damage"
			local numDice = effect.numDice
			local diceSize = effect.diceSize
			local amount = effect.effectAmount

			local amountStr = ""
			if numDice > 0 and diceSize > 0 then
				amountStr = string.format("%dD%d", numDice, diceSize)
				if amount ~= 0 then
					amountStr = amountStr..string.format("%+d", amount)
				end
			elseif amount ~= 0 then
				amountStr = string.format("%d", amount)
			end

			add(amountStr, typeID, typeName)

		elseif opcode == 25 then -- Poison
			add("", nil, uiStrings["ZJBattleSense_TRANSLATION_CreatureInfo_Poison"])
		end
	end

	return extras
end

-- ITM ability damage type => the resistance stat(s) of the target that apply to it. An attack with two damage types
-- uses the one the target resists least.
ZJCreatureInfo_Private_DamageTypeResistances = {
	[1] = { "m_nResistPiercing" },
	[2] = { "m_nResistCrushing" },
	[3] = { "m_nResistSlashing" },
	[4] = { "m_nResistMissile" },
	[5] = { "m_nResistCrushing" },
	[6] = { "m_nResistPiercing", "m_nResistCrushing" },
	[7] = { "m_nResistPiercing", "m_nResistSlashing" },
	[8] = { "m_nResistCrushing", "m_nResistSlashing" },
	[9] = { "m_nResistCrushing" },
}

-- Returns the percentage of a weapon's damage of `damageType` that `targetSprite` resists, (at most 100, can be negative)
function ZJCreatureInfo_Private_GetDamageResistance(targetSprite, damageType)

	local statNames = ZJCreatureInfo_Private_DamageTypeResistances[damageType]
	if statNames == nil then return 0 end

	local stats = targetSprite:getActiveStats()
	local resistance = nil

	for _, statName in ipairs(statNames) do
		local statResistance = stats[statName]
		if resistance == nil or statResistance < resistance then
			resistance = statResistance
		end
	end

	return math.min(resistance or 0, 100)
end

-- Returns the lowest d20 roll that lands the attack, derived from the hit chance, (every face of the die is worth 5%).
-- Returns 21 if no roll can hit, and 1 if every roll hits.
function ZJCreatureInfo_Private_GetMinimumHitRoll(hitChance)
	local hittingFaces = math.floor(hitChance / 5 + 0.5)
	return math.max(1, math.min(21 - hittingFaces, 21))
end

ZJCreatureInfo_Private_StrengthDamageBonusCache = {} -- [STR * 1000 + exceptional STR] = bonus

-- The STRMOD.2DA + STRMODEX.2DA damage bonus of `stats`
function ZJCreatureInfo_Private_GetStrengthDamageBonus(stats)

	local strength = stats.m_nSTR
	local strengthExtra = stats.m_nSTRExtra

	local cacheKey = strength * 1000 + strengthExtra
	local bonus = ZJCreatureInfo_Private_StrengthDamageBonusCache[cacheKey]

	if bonus == nil then
		local ruleTables = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_ruleTables
		bonus = (tonumber(ruleTables.m_tStrengthMod:getAtLabels("DAMAGE", tostring(strength))) or 0)
		      + (tonumber(ruleTables.m_tStrengthModExtra:getAtLabels("DAMAGE", tostring(strengthExtra))) or 0)
		ZJCreatureInfo_Private_StrengthDamageBonusCache[cacheKey] = bonus
	end

	return bonus
end

-- Returns, for the weapon `sprite` attacks with, (nil if the ability doesn't deal damage):
--
--   * The damage it rolls on a hit, e.g. "1D8+4"
--   * The extra damage it applies on a hit, see ZJCreatureInfo_Private_GetOnHitDamage()
--   * The ITM damage type
--   * The ITM damage type to show the icon(s) of, (see below)
--
-- This follows CGameSprite::Damage(), the dice and bonus of the weapon, (and of its launcher), are increased by:
--
--   * The attacker's damage bonus, (op73, etc.)
--
--   * The attacker's bonus for the hand the weapon is in. The engine maintains this, it holds the bonus from the weapon's
--     proficiency, (WSPECIAL.2DA), the weapon style, (STYLBONU.2DA), and the melee / missile / fist damage bonuses.
--
--   * The attacker's strength, if the weapon / launcher asks for it
--
--   * Being berserk
--
-- Not included: Everything that depends on the roll or the target, (critical hits, backstabs, damage bonuses against specific
-- creatures, the target's resistances), and the effects the weapon applies on hit, (e.g. extra elemental damage).
function ZJCreatureInfo_Private_GetWeaponDamageString(sprite, weapon, abilityNum, leftHand)

	if weapon == nil then return nil end

	local weaponRes = weapon.pRes
	local weaponHeader = weaponRes and weaponRes.pHeader
	if weaponHeader == nil or abilityNum < 0 or abilityNum >= weaponHeader.abilityCount then return nil end

	local ability = weapon:getAbility(abilityNum)
	if ability == nil then return nil end

	local diceCount = ability.damageDiceCount
	local diceSize = ability.damageDice
	local bonus = ability.damageDiceBonus

	local hasDice = diceCount > 0 and diceSize > 0
	if not hasDice and bonus == 0 then
		return nil -- Not a damaging ability
	end

	local diceStr = hasDice and string.format("%dD%d", diceCount, diceSize) or nil
	local addStrength = EEex_BAnd(ability.abilityFlags, 0x5) ~= 0 -- BIT0 = strength bonus, BIT2 = strength bonus to damage only

	-- Only the main hand fires a launcher
	if not leftHand then

		local launcher = sprite:getLauncher(ability)
		local launcherRes = launcher and launcher.pRes
		local launcherHeader = launcherRes and launcherRes.pHeader
		local launcherAbility = launcherHeader and launcherHeader.abilityCount > 0 and launcher:getAbility(0) or nil

		if launcherAbility ~= nil then

			bonus = bonus + launcherAbility.damageDiceBonus

			local launcherDiceCount = launcherAbility.damageDiceCount
			local launcherDiceSize = launcherAbility.damageDice

			if launcherDiceCount > 0 and launcherDiceSize > 0 then
				if diceStr == nil then
					diceStr = string.format("%dD%d", launcherDiceCount, launcherDiceSize)
				elseif launcherDiceSize == diceSize then
					diceStr = string.format("%dD%d", diceCount + launcherDiceCount, diceSize)
				else
					diceStr = string.format("%s+%dD%d", diceStr, launcherDiceCount, launcherDiceSize)
				end
			end

			if EEex_BAnd(launcherAbility.abilityFlags, 0x5) ~= 0 then
				addStrength = true
			end
		end
	end

	local stats = sprite:getActiveStats()

	bonus = bonus + stats.m_nDamageBonus + (leftHand and stats.m_DamageBonusLeft or stats.m_DamageBonusRight)

	if addStrength then
		bonus = bonus + ZJCreatureInfo_Private_GetStrengthDamageBonus(stats)
	end

	if EEex_BAnd(stats.m_generalState, 0x2) ~= 0 then -- STATE_BERSERK
		bonus = bonus + 2
	end

	local damageStr

	if diceStr == nil then
		damageStr = tostring(bonus)
	elseif bonus ~= 0 then
		damageStr = diceStr..string.format("%+d", bonus)
	else
		damageStr = diceStr
	end

	local damageType = ability.damageType

	-- Elemental damage, poison, etc. that the weapon applies on a hit. This is an extra, it may not take the damage down with it.
	local okOnHit, extras = pcall(ZJCreatureInfo_Private_GetOnHitDamage, weaponHeader, ability)
	if not okOnHit then
		extras = {}
	end

	-- The game's sling bullets do missile damage like arrows, the "blunt missile" type isn't used by its items.
	-- A sling's ammunition is shown with that type's icon anyway, to tell it from a bow's.
	local iconDamageType = damageType
	if damageType == 4 and ability.launcherType == 3 then -- 3 = Sling
		iconDamageType = 9
	end

	return damageStr, extras, damageType, iconDamageType
end

-- Attack(), GroupAttack(), AttackNoSound(), AttackOneRound(), AttackReevaluate()
ZJCreatureInfo_Private_AttackActions = {
	[  3] = true,
	[ 94] = true,
	[ 98] = true,
	[105] = true,
	[134] = true,
}

-- Returns true if `attackerSprite` is currently executing an attack action against `targetSprite`
function ZJCreatureInfo_Private_IsAttacking(attackerSprite, targetSprite)

	local curAction = attackerSprite.m_curAction
	if not ZJCreatureInfo_Private_AttackActions[curAction.m_actionID] then return false end

	local acteeId = curAction.m_acteeID.m_Instance
	if acteeId == nil or acteeId <= 0 then
		-- The action's object hasn't been resolved to an instance, fall back to the sprite's attack target
		acteeId = attackerSprite.m_targetId
	end

	return acteeId == targetSprite.m_id
end

-- Spell(), UseItem(), ForceSpell(), SpellNoDec(), ForceSpellRange(), (and their RES / slot variants)
ZJCreatureInfo_Private_TargetedCastActions = {
	[ 31] = true,
	[ 34] = true,
	[113] = true,
	[191] = true,
	[318] = true,
}

-- SpellPoint(), ForceSpellPoint(), SpellPointNoDec(), ForceSpellPointRange(), (and their RES variants)
ZJCreatureInfo_Private_PointCastActions = {
	[ 95] = true,
	[114] = true,
	[192] = true,
	[319] = true,
}

-- The spell action ends before the caster's spell cooldown does, so the creature a sprite cast at is remembered for
-- as long as that cooldown runs.
ZJCreatureInfo_Private_CastTargets = {} -- [caster id] = target id, emptied when the popup closes

-- Returns true if `casterSprite` is casting a spell / using an item on `targetSprite`, or is still in the
-- cooldown of having done so
function ZJCreatureInfo_Private_IsCastingAt(casterSprite, targetSprite)

	local casterId = casterSprite.m_id
	local curAction = casterSprite.m_curAction
	local actionID = curAction.m_actionID
	-- A queued spell that waits for the cooldown of the earlier one doesn't count yet, that cooldown still belongs to
	-- the earlier spell's target
	local begun = casterSprite:zjHasCastBegun()

	if begun and ZJCreatureInfo_Private_TargetedCastActions[actionID] then
		ZJCreatureInfo_Private_CastTargets[casterId] = curAction.m_acteeID.m_Instance
	elseif (begun and ZJCreatureInfo_Private_PointCastActions[actionID]) or casterSprite:getCastTimerPercentage() <= 0 then
		ZJCreatureInfo_Private_CastTargets[casterId] = nil
	end

	return ZJCreatureInfo_Private_CastTargets[casterId] == targetSprite.m_id
end

-- UseItem(), UseItemPoint()
ZJCreatureInfo_Private_ItemActions = {
	[ 34] = true,
	[ 97] = true,
}

-- Returns what `sprite` is doing: 1 = attacking, 2 = casting a spell, 3 = using an item, false = something else
function ZJCreatureInfo_Private_GetActionIcon(sprite)
	local actionID = sprite.m_curAction.m_actionID
	if ZJCreatureInfo_Private_AttackActions[actionID] then return 1 end
	-- Don't give away the spell / item a creature queued until the round it is used in begins
	if not sprite:zjHasCastBegun() then return false end
	if ZJCreatureInfo_Private_ItemActions[actionID] then return 3 end
	if ZJCreatureInfo_Private_TargetedCastActions[actionID] or ZJCreatureInfo_Private_PointCastActions[actionID] then return 2 end
	return false
end

-- SPELL.IDS prefixes, [spell id / 1000]
ZJCreatureInfo_Private_SpellIDPrefixes = { [1] = "SPPR", [2] = "SPWI", [3] = "SPIN", [4] = "SPCL" }

-- Reading a name demands the spell / item, so it is kept for as long as the sprite executes the same action
ZJCreatureInfo_Private_ActionNameCaches = {} -- [sprite id] = { key, name }, emptied when the popup closes

-- Returns the first of the given strrefs that has text
function ZJCreatureInfo_Private_FetchName(...)
	for _, strref in ipairs({...}) do
		if strref >= 0 and strref < 0x7FFFFFFF then
			local name = Infinity_FetchString(strref)
			if name ~= nil and name ~= "" then return name end
		end
	end
	return nil
end

function ZJCreatureInfo_Private_ReadActionName(sprite)

	local curAction = sprite.m_curAction
	local actionID = curAction.m_actionID
	local resref = (curAction.m_string1.m_pchData:get() or ""):upper()
	local specificID = curAction.m_specificID

	local cacheKey = string.format("%d:%s:%d", actionID, resref, specificID)
	local id = sprite.m_id
	local cache = ZJCreatureInfo_Private_ActionNameCaches[id]

	if cache ~= nil and cache.key == cacheKey then
		return cache.name
	end

	cache = { ["key"] = cacheKey }
	ZJCreatureInfo_Private_ActionNameCaches[id] = cache

	if ZJCreatureInfo_Private_ItemActions[actionID] then

		local itemHeader = nil
		local identified = true

		if resref ~= "" then
			itemHeader = EEex_Resource_Demand(resref, "ITM")
		elseif specificID >= 0 and specificID <= 38 then
			-- The item is given by its inventory slot
			local item = sprite.m_equipment.m_items:get(specificID)
			if item ~= nil then
				itemHeader = item.pRes.pHeader
				identified = EEex_IsBitSet(item.m_flags, 0)
			end
		end

		if itemHeader ~= nil then
			if identified then
				cache.name = ZJCreatureInfo_Private_FetchName(itemHeader.identifiedName, itemHeader.genericName)
			else
				cache.name = ZJCreatureInfo_Private_FetchName(itemHeader.genericName)
			end
		end
	else
		if resref == "" then
			-- The spell is given by its SPELL.IDS value
			local prefix = ZJCreatureInfo_Private_SpellIDPrefixes[math.floor(specificID / 1000)]
			if prefix ~= nil then
				resref = string.format("%s%03d", prefix, specificID % 1000)
			end
		end

		if resref ~= "" then
			local spellHeader = EEex_Resource_Demand(resref, "SPL")
			if spellHeader ~= nil then
				cache.name = ZJCreatureInfo_Private_FetchName(spellHeader.genericName)
			end
		end
	end

	-- A spell / item without a name is shown by its resref
	if cache.name == nil and resref ~= "" then
		cache.name = resref
	end

	return cache.name
end

-- Returns the name of the spell `sprite` is casting / the item it is using, or nil if that can't be determined.
-- Only meaningful while ZJCreatureInfo_Private_GetActionIcon() returns 2 or 3 for `sprite`.
function ZJCreatureInfo_Private_GetActionName(sprite)
	-- The name is cosmetic, never let it take the popup down
	local ok, name = pcall(ZJCreatureInfo_Private_ReadActionName, sprite)
	return ok and name or nil
end

-- Reading an area demands the spell / item, so it is kept for as long as the sprite executes the same action
ZJCreatureInfo_Private_ActionAreaCaches = {} -- [sprite id] = { key, area }, emptied when the popup closes

-- Returns the area, (see ZJArea.lua), of the spell `sprite` is casting / the item it is using, false if it has none,
-- or nil if that can't be determined.
function ZJCreatureInfo_Private_ReadActionArea(sprite)

	local curAction = sprite.m_curAction
	local actionID = curAction.m_actionID
	local resref = (curAction.m_string1.m_pchData:get() or ""):upper()
	local specificID = curAction.m_specificID
	local specificID2 = curAction.m_specificID2

	local cacheKey = string.format("%d:%s:%d:%d", actionID, resref, specificID, specificID2)
	local id = sprite.m_id
	local cache = ZJCreatureInfo_Private_ActionAreaCaches[id]

	if cache ~= nil and cache.key == cacheKey then
		return cache.area
	end

	cache = { ["key"] = cacheKey }
	ZJCreatureInfo_Private_ActionAreaCaches[id] = cache

	local missileType = nil
	local header, ability = nil, nil

	if actionID == 97 or actionID == 34 then -- UseItemPoint(), UseItem()

		local itemHeader = nil
		local abilityNum = specificID

		if resref ~= "" then
			itemHeader = EEex_Resource_Demand(resref, "ITM")
		elseif specificID >= 0 and specificID <= 38 then
			-- The item is given by its inventory slot, followed by the ability
			local item = sprite.m_equipment.m_items:get(specificID)
			if item ~= nil then
				itemHeader = item.pRes.pHeader
			end
			abilityNum = specificID2
		end

		if itemHeader ~= nil and abilityNum >= 0 and abilityNum < itemHeader.abilityCount then
			header = itemHeader
			ability = EEex_PtrToUD(
				EEex_UDToPtr(itemHeader) + itemHeader.abilityOffset + Item_ability_st.sizeof * abilityNum, "Item_ability_st")
			missileType = ability.missileType
		end
	else
		if resref == "" then
			-- The spell is given by its SPELL.IDS value
			local prefix = ZJCreatureInfo_Private_SpellIDPrefixes[math.floor(specificID / 1000)]
			if prefix ~= nil then
				resref = string.format("%s%03d", prefix, specificID % 1000)
			end
		end

		if resref ~= "" then
			local spellHeader = EEex_Resource_Demand(resref, "SPL")
			if spellHeader ~= nil then
				ability = spellHeader:getAbilityForLevel(sprite:getCasterLevelForSpell(resref, true))
				if ability ~= nil then
					header = spellHeader
					missileType = ability.missileType
				end
			end
		end
	end

	if missileType ~= nil then
		cache.area = ZJArea_ReadAbilityArea(EEex_UDToPtr(header), EEex_UDToPtr(ability), missileType)
	end

	return cache.area
end

-- Returns true if `casterSprite` is currently executing a spell / item action that is aimed at `targetSprite`, or at a
-- point with `targetSprite` standing in the area the spell / item affects. That is where the creature stands now: it
-- can still walk in or out before the spell lands.
function ZJCreatureInfo_Private_IsCastingSpellAt(casterSprite, targetSprite)

	local curAction = casterSprite.m_curAction
	local actionID = curAction.m_actionID

	-- A queued spell that waits for the cooldown of the earlier one isn't aimed at anything yet
	if not casterSprite:zjHasCastBegun() then return false end

	if ZJCreatureInfo_Private_TargetedCastActions[actionID] then
		return curAction.m_acteeID.m_Instance == targetSprite.m_id
	end

	if not ZJCreatureInfo_Private_PointCastActions[actionID] and actionID ~= 97 then -- UseItemPoint()
		return false
	end

	-- An area that can't be determined counts for everyone, never let it take the popup down
	local ok, area = pcall(ZJCreatureInfo_Private_ReadActionArea, casterSprite)
	if not ok or area == nil then return true end

	-- Nothing lands on a creature, (a summon, a teleport)
	if area == false then return false end

	-- The engine measures distances in pixels, with the vertical axis stretched by 4/3
	local casterPos = casterSprite.m_pos
	local targetPos = targetSprite.m_pos
	local dest = curAction.m_dest

	local aimX = dest.x - casterPos.x
	local aimY = (dest.y - casterPos.y) * 4 / 3
	local aimLength = math.sqrt(aimX * aimX + aimY * aimY)

	-- A cone starts at the caster and points at the destination, everything else is centered on the destination
	local coneSize = area.coneSize
	-- A sub-spell cast on the caster, (Chant), is centered on the caster too
	local isCone = coneSize ~= nil and coneSize > 0 and coneSize < 360 and aimLength > 0
	local origin = (isCone or area.onCaster) and casterPos or dest

	local offsetX = targetPos.x - origin.x
	local offsetY = (targetPos.y - origin.y) * 4 / 3
	local distance = math.sqrt(offsetX * offsetX + offsetY * offsetY)

	if distance > area.range then return false end
	if not isCone or distance == 0 then return true end

	-- Inside the cone if the angle between the aim and the creature is at most half the cone's width
	local cosAngle = (offsetX * aimX + offsetY * aimY) / (distance * aimLength)
	return cosAngle >= math.cos(math.rad(coneSize / 2))
end

-- Returns true if `sprite` is attacking or casting at `targetSprite`
function ZJCreatureInfo_Private_IsEngaging(sprite, targetSprite)
	return ZJCreatureInfo_Private_IsAttacking(sprite, targetSprite) or ZJCreatureInfo_Private_IsCastingAt(sprite, targetSprite)
end

-- The attack roll frames only change when the sprite's attacks per round / weapon speed / animation changes.
-- Reading them takes a hundred engine calls, so the result is kept per sprite and refreshed periodically.
ZJCreatureInfo_Private_AttackRollFramesCaches = {} -- [sprite id] = cache, emptied when the popup closes
ZJCreatureInfo_Private_TargetAttackRollFramesLifetime = 2000 -- Milliseconds
ZJCreatureInfo_Private_MaxTargetAttackMarkers = 5

-- Returns the attack frames [0-99] on which `sprite` makes an attack roll in its current round
function ZJCreatureInfo_Private_GetAttackRollFrames(sprite)

	local curTick = Infinity_GetClockTicks()

	local id = sprite.m_id
	local tableIndex = sprite:zjGetCombatRoundTableIndex()
	local speedFactor = sprite:zjGetAttackSpeedFactor()

	local cache = ZJCreatureInfo_Private_AttackRollFramesCaches[id]
	if cache == nil then
		cache = {}
		ZJCreatureInfo_Private_AttackRollFramesCaches[id] = cache
	end

	if cache.frames == nil
		or cache.tableIndex ~= tableIndex
		or cache.speedFactor ~= speedFactor
		or curTick >= cache.expireTick
	then
		cache.tableIndex = tableIndex
		cache.speedFactor = speedFactor
		cache.expireTick = curTick + ZJCreatureInfo_Private_TargetAttackRollFramesLifetime
		cache.frames = sprite:zjGetAttackRollFrames(tableIndex, speedFactor)

		-- With a half attack, (1/2, 3/2, etc.), the last attack roll in the table is only made every other round
		local lastFrame = cache.frames[#cache.frames]
		if lastFrame and sprite:zjHasHalfAttack() then
			cache.halfIndex = #cache.frames
			cache.halfSwingStartFrame = sprite:zjGetAttackSwingStartFrame(lastFrame, tableIndex, speedFactor)
		else
			cache.halfIndex = nil
			cache.halfSwingStartFrame = nil
		end
	end

	-- Leave out the half attack during the rounds where its swing is cosmetic
	if cache.halfIndex and not sprite:zjIsHalfAttackRealThisRound(cache.halfSwingStartFrame) then
		local frames = {}
		for i, frame in ipairs(cache.frames) do
			if i ~= cache.halfIndex then table.insert(frames, frame) end
		end
		return frames
	end

	return cache.frames
end

-- The bars that can be shown for the target, in the order they are stacked, and how many markers each one has in the menu
ZJCreatureInfo_Private_TargetBarNames = { "Attack", "Cast", "Modal", "Contingency" }
ZJCreatureInfo_Private_TargetBarMaxMarkers = {
	["Attack"]      = ZJCreatureInfo_Private_MaxTargetAttackMarkers,
	["Cast"]        = 1,
	["Modal"]       = 0,
	["Contingency"] = 0,
}

-- The rows of the right panel that can have timer bars at the same time, (the menu has this many sets of bar items)
ZJCreatureInfo_Private_MaxRowBars = 8
ZJCreatureInfo_Private_RowBarNames = { "Attack", "Cast" }

-- Where `sprite` is in its attack round, the ticks are its attack rolls. Returns nil if the sprite isn't attacking,
-- or the attack bar's color is Off.
function ZJCreatureInfo_Private_GetAttackBar(sprite)
	if not ZJBarColors_IsShown("Attack") or not sprite:zjIsAttacking() then return nil end
	return {
		["name"]       = "Attack",
		["percentage"] = sprite:zjGetAttackTimerPercentage(),
		["markers"]    = ZJCreatureInfo_Private_GetAttackRollFrames(sprite),
	}
end

-- The spell / item cooldown of `sprite`, the tick is where the spell being cast is released.
-- Returns nil if the cooldown isn't running, or the cast bar's color is Off.
function ZJCreatureInfo_Private_GetCastBar(sprite)
	if not ZJBarColors_IsShown("Cast") then return nil end
	local percentage = sprite:getCastTimerPercentage()
	if percentage <= 0 then return nil end
	local releaseTimer = sprite:zjGetCastReleaseTimer()
	return {
		["name"]       = "Cast",
		-- The cast bar is (cast timer + 1) / 100 full, see EEex_Sprite_GetCastTimerPercentage()
		["percentage"] = percentage,
		["markers"]    = releaseTimer and { releaseTimer + 1 } or {},
	}
end

-- Returns the attack and cast bars that currently apply to a sprite listed in the right panel, (same format as below)
-- The attack bar is only included if `includeAttack`, (the sprite is attacking the target)
function ZJCreatureInfo_Private_GetRowBars(sprite, includeAttack)
	local bars = {}
	if includeAttack then
		bars[#bars + 1] = ZJCreatureInfo_Private_GetAttackBar(sprite)
	end
	bars[#bars + 1] = ZJCreatureInfo_Private_GetCastBar(sprite)
	return bars
end

-- Returns an array of the timer bars that currently apply to `sprite`:
--   name       => The bar's name in ZJCreatureInfo_Private_TargetBarNames
--   percentage => [0-1], how full the bar is
--   markers    => Array of the points [0-100] along the bar that have a tick
function ZJCreatureInfo_Private_GetTargetBars(sprite)

	local bars = {}

	bars[#bars + 1] = ZJCreatureInfo_Private_GetAttackBar(sprite)
	bars[#bars + 1] = ZJCreatureInfo_Private_GetCastBar(sprite)

	-- The interval of the sprite's modal action
	if ZJBarColors_IsShown("Modal") and sprite:getModalState() ~= 0 then
		table.insert(bars, {
			["name"]       = "Modal",
			["percentage"] = sprite:getModalTimerPercentage(),
			["markers"]    = {},
		})
	end

	-- The interval at which the sprite's contingency conditions are checked
	if ZJBarColors_IsShown("Contingency") and sprite:getActiveStats().m_cContingencyList.m_nCount > 0 then
		table.insert(bars, {
			["name"]       = "Contingency",
			["percentage"] = sprite:getContingencyTimerPercentage(),
			["markers"]    = {},
		})
	end

	return bars
end

-- The name of a spell as the Effect Menu module of EEex shows it, or false if it hides the spell:
-- ["<resref>:<caster level>"] = name / false. Kept for the whole session, a spell's name doesn't change.
ZJCreatureInfo_Private_SpellEffectNames = {}

function ZJCreatureInfo_Private_ReadSpellEffectName(resref, casterLevel)

	local spellHeader = EEex_Resource_Demand(resref, "SPL")
	if spellHeader == nil then return false end

	-- If the caster shouldn't have been able to cast the spell, the first ability is used
	local ability = spellHeader:getAbilityForLevel(casterLevel) or spellHeader:getAbility(0)
	if ability == nil then return false end

	-- A spell without an icon is a behind-the-scenes spell
	if ability.quickSlotIcon:get() == "" then return false end

	local name = Infinity_FetchString(spellHeader.genericName)

	if name == "" then
		-- A sub-spell often has no name of its own, like Chant's SPPR203D that it casts on every creature around.
		-- Its parent spell has the same resref without the letters at the end.
		local parentResref = resref:match("^(.-%d)%a+$")
		if parentResref == nil then return false end

		local parentHeader = EEex_Resource_Demand(parentResref, "SPL")
		if parentHeader == nil then return false end

		name = Infinity_FetchString(parentHeader.genericName)
		if name == "" then return false end
	end

	return name
end

-- The name of portrait icon `icon` as the character record shows it, (STATDESC.2DA), or false if it has none:
-- [icon] = name / false
ZJCreatureInfo_Private_StatusIconNames = {}

function ZJCreatureInfo_Private_GetStatusIconName(icon)
	local name = ZJCreatureInfo_Private_StatusIconNames[icon]
	if name ~= nil then return name end
	name = false
	local ok, strref = pcall(function() return tonumber(EEex_Resource_Load2DA("STATDESC"):getAtPoint(0, icon)) end)
	if ok and strref ~= nil and strref >= 0 then
		local str = Infinity_FetchString(strref)
		if str ~= nil and str ~= "" then name = str end
	end
	ZJCreatureInfo_Private_StatusIconNames[icon] = name
	return name
end

-- Returns the names of the spells affecting `sprite`, sorted, with the same spells the Effect Menu module of EEex lists:
-- no item effects, no permanent spells, no spells without an icon. Spells that give stoneskins or mirror images are left
-- out, their count is shown on its own.
--
-- A condition from something that isn't listed, (a creature's or weapon's on-hit effect, a hidden spell), is listed by
-- the name of its portrait icon instead, (op142, "Confused", "Feebleminded"), as the character record shows it.
function ZJCreatureInfo_Private_GetSpellEffectNames(sprite)

	local names = {}
	local seenResrefs = {}
	local skipResrefs = {}
	local expiries = {}   -- [resref] = latest game time one of the spell's timed effects expires at
	local icons = {}      -- [icon] = { resref = the source, expiry = game time it expires at, or false if it has no end }

	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)

		-- 142 = display portrait icon, 9 = permanent
		if effect.m_effectId == 142 and effect.m_durationType ~= 9 then
			local icon = effect.m_dWFlags
			local expiry = effect.m_durationType == 0x1000 and effect.m_duration or false
			local known = icons[icon]
			if known == nil then
				icons[icon] = { ["resref"] = effect.m_sourceRes:get(), ["expiry"] = expiry }
			elseif known.expiry ~= false and (expiry == false or expiry > known.expiry) then
				known.expiry = expiry
			end
		end

		-- 2 = item
		if effect.m_sourceType == 2 then return end

		local resref = effect.m_sourceRes:get()
		if resref == "" then return end

		-- 218 = stoneskin, 119 = mirror image
		local effectId = effect.m_effectId
		if effectId == 218 or effectId == 119 then
			skipResrefs[resref] = true
		end

		-- 9 = permanent
		local durationType = effect.m_durationType
		if durationType == 9 then return end

		-- 0x1000 = applied timed effect, which stores the game time it expires at
		if durationType == 0x1000 then
			local expiry = effect.m_duration
			if expiries[resref] == nil or expiry > expiries[resref] then expiries[resref] = expiry end
		end

		if seenResrefs[resref] ~= nil then return end

		local casterLevel = math.max(effect.m_casterLevel, 1)
		local cacheKey = resref..":"..casterLevel
		local name = ZJCreatureInfo_Private_SpellEffectNames[cacheKey]

		if name == nil then
			name = ZJCreatureInfo_Private_ReadSpellEffectName(resref, casterLevel)
			ZJCreatureInfo_Private_SpellEffectNames[cacheKey] = name
		end

		seenResrefs[resref] = name
	end)

	-- [name] = latest expiry of the spells with that name, or false if one of them has no end
	local nameExpiries = {}

	for resref, name in pairs(seenResrefs) do
		if name and not skipResrefs[resref] then

			-- A spell with a timed effect lasts as long as that effect: its "until dispelled" effects are often only
			-- visuals that go with it, (Invisibility's glow). Only a spell with nothing timed has no end.
			local expiry = expiries[resref]
			if expiry == nil then expiry = false end

			local known = nameExpiries[name]
			if known == nil then
				table.insert(names, name)
				nameExpiries[name] = expiry
			elseif known ~= false and (expiry == false or expiry > known) then
				nameExpiries[name] = expiry
			end
		end
	end

	-- The conditions whose source isn't listed above, (a sub-spell counts as its parent spell, SPPR203D as SPPR203)
	local isListed = function(resref)
		return resref ~= nil and seenResrefs[resref] and not skipResrefs[resref]
	end
	for icon, entry in pairs(icons) do
		if not isListed(entry.resref) and not isListed(entry.resref:match("^(.-%d)%a+$")) then
			local name = ZJCreatureInfo_Private_GetStatusIconName(icon)
			if name then
				local known = nameExpiries[name]
				if known == nil then
					table.insert(names, name)
					nameExpiries[name] = entry.expiry
				elseif known ~= false and (entry.expiry == false or entry.expiry > known) then
					nameExpiries[name] = entry.expiry
				end
			end
		end
	end

	table.sort(names)

	local now = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime

	for i, name in ipairs(names) do
		local expiry = nameExpiries[name]
		if expiry then
			names[i] = name.." "..ZJCreatureInfo_Private_FormatRemaining(expiry - now)
		end
	end

	return names
end

-- Formats the game ticks an effect still lasts as "(<turns>,<rounds>)". 15 ticks are a second, a round is 6 seconds
-- and a turn 10 rounds. Rounds are rounded up, so an effect that is about to end still shows "(0,1)".
function ZJCreatureInfo_Private_FormatRemaining(ticks)
	local totalRounds = math.max(math.ceil(ticks / 90), 0)
	return string.format("(%d,%d)", math.floor(totalRounds / 10), totalRounds % 10)
end

-----------
-- Panel --
-----------

-- Whether the world screen's action bar is open: the panel only shows while it is, (see the listeners at the end)
ZJCreatureInfo_Private_ActionbarOpen = false

-- The popup has two panels next to each other: the left one lists the attacks of `targetSprite` on `selectedSprites`,
-- the right one lists their attacks on the target.
--
-- `compact` is used for the party and its summons / allies: `selectedSprites` are then the creatures the target is fighting.
function ZJCreatureInfo_Private_Layout(selectedSprites, targetSprite, compact)

	--------------------------
	--     Read options     --
	--------------------------

	local fontPoint                     = ZJCreatureInfo_Private_FontPoint:get()
	local hitDisplayType                = ZJCreatureInfo_Private_HitDisplayType:get()
	local resistanceColor               = ZJCreatureInfo_Private_ResistanceColor:get()
	local immunityColor                 = ZJCreatureInfo_Private_ImmunityColor:get()
	local showRowTimers                 = ZJCreatureInfo_Private_ShowRowTimers:get() ~= 0

	------------------------------
	--     Layout constants     --
	------------------------------

	local measure = function(text)
		return EEex_Menu_GetTextWidthHeight(text, styles["normal"].font, fontPoint, styles["normal"].useFontZoom)
	end

	local spaceW, spaceH = measure(" ")

	-----------
	-- Popup --
	-----------

	local popupLeftSideAdjust  = 5
	local popupRightSideAdjust = 5

	----------------
	-- Background --
	----------------

	local backgroundPad = 12

	------------
	-- Panels --
	------------

	local panelGap        = 10 -- On both sides of the separator between the panels
	local panelSeparatorW = 2

	------------
	-- Header --
	------------

	local headerHorizontalSepPadTop    = 5
	local headerHorizontalSepH         = 2
	local headerHorizontalSepPadBottom = 8

	-----------------
	-- Target bars --
	-----------------

	-- Below the left panel's header
	local targetBarsPadTop = 4
	local targetBarH       = 6
	local targetBarGap     = 3
	local targetBarMarkerW = 2

	--------------
	-- Row bars --
	--------------

	-- Below the names in the right panel
	local rowBarsPadTop    = 1
	local rowBarH          = 4
	local rowBarGap        = 2
	local rowBarsPadBottom = 4
	local rowBarMarkerW    = 2

	---------------
	-- List rows --
	---------------

	local rowHeightPad = 0

	------------------
	-- List columns --
	------------------

	local divider1ColumnW       = 3
	local divider2ColumnPadLeft = spaceW
	local divider2ColumnW       = 2
	local divider3ColumnPadLeft = spaceW
	local divider3ColumnW       = 2

	local nameColumnIndex       = 1
	local mainHandColumnIndex   = 2
	local offHandColumnIndex    = 3

	local divider1ColumnIndex   = 2
	local divider2ColumnIndex   = 3
	local divider3ColumnIndex   = 4

	-- Extra (non-text) field in each list entry: false, or the icon to show in front of the name, (left list only):
	-- what the target is doing to the creature on that row. It is an icon of ZJCREDMG.BAM, see
	-- ZJCreatureInfo_Private_DamageTypeIcons.
	local attackIconEntryIndex  = 4
	local attackIconPadRight    = 4

	-- Extra fields in each list entry: the weapon damage of each hand, which is drawn right-aligned in the hand's column
	local mainHandDamageEntryIndex = 5
	local offHandDamageEntryIndex  = 6

	-- A hand's column has two sub-columns: the roll, and to the right of the widest roll, the damage. Both are
	-- left-aligned, so the rolls line up with each other and so do the damages. This is the room between the two.
	local hitDamageGapStr = "   "
	local hitDamageGapW = measure(hitDamageGapStr)

	-- Behind the damage are more sub-columns: the icons of the damage type(s), the extra damage the weapon applies on a
	-- hit, and the icons of the elements of that extra damage. Each is as wide as the row that needs the most of it.
	local _, handIconSize = measure("X")
	local handIconGapW = 3

	-- Extra fields in each list entry: what is behind the damage of each hand, (see ZJCreatureInfo_Private_GetHandDisplay()),
	-- with `variant` added: the color of the damage type icons, 0 = green, 1 = red, 2 = dimmed red, 3 = dimmed green
	local handDisplayEntryIndexes = { [mainHandColumnIndex] = 8, [offHandColumnIndex] = 9 }

	local panels = ZJCreatureInfo_Private_Menu_Panels

	---------------------------------------
	--     Calculate header labels       --
	---------------------------------------

	-- 1 = attacking, 2 = casting a spell, 3 = using an item, false = something else
	local targetActionIcon = ZJCreatureInfo_Private_GetActionIcon(targetSprite)
	local targetIsCasting = targetActionIcon == 2 or targetActionIcon == 3

	-- The left panel's header has the target's name and what it attacks with, the right panel's header has the text below
	local labelTexts = { "", "" }

	-- The right panel's header shows what stands between the attacks on the target and its hit points
	do
		local ok, defensesStr = pcall(function()

			local defenses = {}

			local targetStats = targetSprite:getActiveStats()
			local stoneSkins = targetStats.m_nStoneSkins + targetStats.m_nStoneSkinsGolem
			if stoneSkins > 0 then
				table.insert(defenses, string.format("%s: %d", uiStrings["ZJBattleSense_TRANSLATION_CreatureInfo_Stoneskins"], stoneSkins))
			end

			local mirrorImages = targetSprite.m_nMirrorImages
			if mirrorImages > 0 then
				table.insert(defenses, string.format("%s: %d", uiStrings["ZJBattleSense_TRANSLATION_CreatureInfo_MirrorImages"], mirrorImages))
			end

			return table.concat(defenses, ", ")
		end)

		if ok then
			labelTexts[2] = defensesStr
		end
	end

	-- The spells affecting the target are listed below the right panel's header, (see "Lay out spell effects")
	local spellEffectNames = {}

	if ZJCreatureInfo_Private_ShowSpellEffects:get() ~= 0 then
		local ok, names = pcall(ZJCreatureInfo_Private_GetSpellEffectNames, targetSprite)
		if ok then
			spellEffectNames = names
		end
	end

	-- The target is the attacker on every row of the left panel, so what it attacks with isn't repeated on the rows.
	-- It is in the left panel's header, below the target's name: the spell it is casting / the item it is using, or
	-- else, for each hand, its weapon damage, the icons of the damage type(s) and the extra damage.
	--
	-- `targetAttackHands` => Array of { text, icons, extra, extraIcons, textX, textW, iconsX, extraX, extraW, extraIconsX },
	--                        the x's from the start of the left panel's header
	-- `targetAttackW`     => The width of all of it
	local targetAttackHands = {}
	local targetAttackSeparatorStr = " / "
	local targetAttackSeparatorXs = {}
	local targetAttackW = 0

	if targetIsCasting then
		local actionName = ZJCreatureInfo_Private_GetActionName(targetSprite)
		if actionName ~= nil then
			table.insert(targetAttackHands, { ["text"] = actionName, ["icons"] = {}, ["extra"] = "", ["extraIcons"] = {} })
		end
	else
		local equipment = targetSprite.m_equipment
		local items = equipment.m_items

		local addHand = function(weapon, abilityNum, leftHand)

			-- Reading the weapon's damage is cosmetic, never let it take the popup down
			local ok, damageStr, extras, _, iconDamageType = pcall(ZJCreatureInfo_Private_GetWeaponDamageString,
				targetSprite, weapon, abilityNum, leftHand)

			if not ok or damageStr == nil then return end

			local okDisplay, handDisplay = pcall(ZJCreatureInfo_Private_GetHandDisplay, iconDamageType, extras)

			table.insert(targetAttackHands, {
				["text"]       = damageStr,
				["icons"]      = okDisplay and handDisplay.typeIcons or {},
				["extra"]      = okDisplay and handDisplay.extraText or "",
				["extraIcons"] = okDisplay and handDisplay.extraIcons or {},
			})
		end

		addHand(items:get(equipment.m_selectedWeapon), equipment.m_selectedWeaponAbility, false)

		if EEex.CanAttackWithLeftHand(targetSprite) then
			addHand(items:get(9), 0, true)
		end
	end

	for i, hand in ipairs(targetAttackHands) do

		if i > 1 then
			targetAttackSeparatorXs[i - 1] = targetAttackW
			targetAttackW = targetAttackW + measure(targetAttackSeparatorStr)
		end

		hand.textX = targetAttackW
		hand.textW = measure(hand.text)
		targetAttackW = hand.textX + hand.textW

		hand.iconsX = targetAttackW + handIconGapW
		if #hand.icons > 0 then
			targetAttackW = hand.iconsX + #hand.icons * handIconSize
		end

		hand.extraX = targetAttackW + spaceW
		hand.extraW = 0
		if hand.extra ~= "" then
			hand.extraW = measure(hand.extra)
			targetAttackW = hand.extraX + hand.extraW
		end

		hand.extraIconsX = targetAttackW + handIconGapW
		if #hand.extraIcons > 0 then
			targetAttackW = hand.extraIconsX + #hand.extraIcons * handIconSize
		end
	end

	-- The icon of what the target attacks with, (the first damage type of its main hand weapon), for the rows of the
	-- left list where it is attacking
	local targetTypeIcon = targetAttackHands[1] and targetAttackHands[1].icons[1] or 0

	-- The left header starts with the target's name, in front of the icon and the text above
	-- `targetNameText` used in layout
	local targetNameText = ""
	do
		local ok, name = pcall(function()
			return targetSprite:getName()
		end)

		if ok and type(name) == "string" then
			targetNameText = name
		end
	end

	-------------------------------------
	--     Calculate panel lists       --
	-------------------------------------

	-- A row is greyed out if its attack isn't taking place. That is per panel: on the left, the rows of the creatures
	-- the target isn't attacking / casting at, on the right, the rows of the creatures that aren't attacking / casting
	-- at the target. A creature that is being attacked without fighting back is white on the left and grey on the right.
	local dimColorStr       = "^0xFF808080"
	local greenColorStr     = "^0xFF40E040" -- The resistances that add damage
	local dimGreenColorStr  = "^0xFF207020"

	-- The "Immunity Color" and "Resistance Color" options, (the resistances that take damage away). When Off, there is
	-- nothing to color: ZJCreatureInfo_Private_GetWeaponHitChance() leaves the immunity / resistances out.
	local immuneColorStr       = ZJCreatureInfo_Private_LabelColorStr(immunityColor, false)
	local dimImmuneColorStr    = ZJCreatureInfo_Private_LabelColorStr(immunityColor, true)
	local resistColorStr       = ZJCreatureInfo_Private_LabelColorStr(resistanceColor, false)
	local dimResistColorStr    = ZJCreatureInfo_Private_LabelColorStr(resistanceColor, true)

	local dimRowsLeft  = {} -- [index in selectedSprites] = true
	local dimRowsRight = {} -- [index in selectedSprites] = true

	do
		local rows = {}

		for spriteIndex, selectedSprite in ipairs(selectedSprites) do
			rows[spriteIndex] = {
				["sprite"] = selectedSprite,
				["index"]  = spriteIndex,
				["dimLeft"]  = not (
					   ZJCreatureInfo_Private_IsEngaging(targetSprite, selectedSprite)
					or ZJCreatureInfo_Private_IsCastingSpellAt(targetSprite, selectedSprite)
				),
				["dimRight"] = not (
					   ZJCreatureInfo_Private_IsEngaging(selectedSprite, targetSprite)
					or ZJCreatureInfo_Private_IsCastingSpellAt(selectedSprite, targetSprite)
				),
			}

			-- 1 = party member, 2 = the party's summons / allies, 3 = everything else
			local portraitIndex = selectedSprite:getPortraitIndex()
			rows[spriteIndex].portraitIndex = portraitIndex
			rows[spriteIndex].group = portraitIndex ~= -1 and 1
				or selectedSprite.m_typeAI.m_EnemyAlly <= ZJCreatureInfo_Private_GoodCutoff and 2
				or 3
		end

		-- The party members are listed first, in the order of their portraits, then the party's summons / allies, then
		-- everything else. Within the last two groups the order stays as it was, (by name). A creature keeps its row
		-- whether it is fighting the target or not, that is what the greying out shows.
		table.sort(rows, function(a, b)
			if a.group ~= b.group then return a.group < b.group end
			if a.group == 1 and a.portraitIndex ~= b.portraitIndex then return a.portraitIndex < b.portraitIndex end
			return a.index < b.index
		end)

		selectedSprites = {}
		for spriteIndex, row in ipairs(rows) do
			selectedSprites[spriteIndex] = row.sprite
			dimRowsLeft[spriteIndex] = row.dimLeft
			dimRowsRight[spriteIndex] = row.dimRight
		end
	end

	-- Formats a hand's column as the minimum roll needed to hit, (or the hit chance, depending on the "Hit Display Type"
	-- option), and the weapon's damage, e.g. " 14+" and "1D8+1 C". The roll is on the left of the column, the damage
	-- to the right of it. The damage is left out of the left panel, where it is the same on every row and shown in the header.
	-- Returns:
	--   The text that is measured to size the column
	--   The roll text
	--   The damage text
	--   Whether the roll text isn't a roll, (it then doesn't push the damage of the other rows to the right)
	-- `dim` => The row isn't part of the fight, its text is greyed out
	local formatChanceStr = function(chance, immune, weaponDamageStr, dim)

		local rollStr

		if hitDisplayType == 1 then
			rollStr = string.format("%d%%", chance)
		else
			local minimumRoll = ZJCreatureInfo_Private_GetMinimumHitRoll(chance)
			if minimumRoll > 20 then
				rollStr = "-" -- No roll can hit
			else
				rollStr = string.format("%d+", minimumRoll)
			end
		end

		local colorStr
		if immune then
			colorStr = dim and dimImmuneColorStr or immuneColorStr
		else
			colorStr = dim and dimColorStr or ""
		end
		rollStr = string.format(" %s%s", colorStr, rollStr)

		if weaponDamageStr == nil then
			if not immune then
				return rollStr, rollStr, "", false
			end
			-- Without the damage, (the left panel), "Immune" still takes its place
			weaponDamageStr = uiStrings["ZJBattleSense_TRANSLATION_CreatureInfo_Immune"]
		end

		weaponDamageStr = ZJCreatureInfo_Private_ColorResistance(weaponDamageStr,
			dim and dimResistColorStr or resistColorStr, dim and dimGreenColorStr or greenColorStr, colorStr)

		return rollStr..hitDamageGapStr..weaponDamageStr, rollStr, colorStr..weaponDamageStr, false
	end

	-- Builds the list of a panel. `reverse` => the target's attacks on the listed sprites, (the left panel).
	-- Returns:
	--   entries          => The list's rows, (ZJCreatureInfo_Private_Menu_InfoList[2]_Table)
	--   columnWidths     => The width every column needs
	--   tallestRowHeight => The height of the tallest row
	--   anyAttackIcon    => Whether any row shows the "currently attacking" icon
	--   rowBars          => [index in selectedSprites] = The timer bars below that sprite's name, (right panel only)
	--   maxRowBars       => The highest number of timer bars any row has
	local buildPanel = function(panel, reverse)

		local build = {
			["entries"]          = {},
			["columnWidths"]     = {},
			["tallestRowHeight"] = 0,
			["anyAttackIcon"]    = false,
			["rowBars"]          = {},
			["maxRowBars"]       = 0,
		}

		local rowBarsCount = 0

		local columnWidths = build.columnWidths
		for i = 1, panel.columnUDsSize do
			columnWidths[i] = 0
		end

		-- The widest roll and the widest damage of each hand's column, [column index] = width
		build.rollWidths   = { [mainHandColumnIndex] = 0, [offHandColumnIndex] = 0 }
		build.damageWidths = { [mainHandColumnIndex] = 0, [offHandColumnIndex] = 0 }

		-- Around the roll and the damage: the most icons in front of the roll, (damage types / spell / item), the widest
		-- extra damage, the most extra damage icons
		build.typeIconCounts  = { [mainHandColumnIndex] = 0, [offHandColumnIndex] = 0 }
		build.extraWidths     = { [mainHandColumnIndex] = 0, [offHandColumnIndex] = 0 }
		build.extraIconCounts = { [mainHandColumnIndex] = 0, [offHandColumnIndex] = 0 }

		-- The widest text that isn't a roll, (a spell / item name, "Immune"): it starts where the rolls
		-- do, and runs over the sub-columns behind them
		build.spanWidths = { [mainHandColumnIndex] = 0, [offHandColumnIndex] = 0 }

		local measureHand = function(columnIndex, rollString, damageString, spans, handDisplay)
			if not spans then
				build.rollWidths[columnIndex] = math.max(build.rollWidths[columnIndex], (measure(rollString)))
			elseif rollString ~= "" then
				build.spanWidths[columnIndex] = math.max(build.spanWidths[columnIndex], (measure(rollString)))
			end
			if damageString ~= "" then
				build.damageWidths[columnIndex] = math.max(build.damageWidths[columnIndex], (measure(damageString)))
			end
			if handDisplay ~= nil then
				build.typeIconCounts[columnIndex] = math.max(build.typeIconCounts[columnIndex], #handDisplay.typeIcons)
				build.extraIconCounts[columnIndex] = math.max(build.extraIconCounts[columnIndex], #handDisplay.extraIcons)
				if handDisplay.extraText ~= "" then
					build.extraWidths[columnIndex] = math.max(build.extraWidths[columnIndex], (measure(handDisplay.extraText)))
				end
			end
		end

		-- Stores the icons and extra damage of a hand in a list entry. `dim` => greyed out, like the row's text
		local setHandDisplay = function(entry, columnIndex, handDisplay, dim)
			if handDisplay == nil then return end
			handDisplay.variant = reverse and (dim and 3 or 0) or (dim and 2 or 1)
			if dim and handDisplay.extraText ~= "" then
				handDisplay.extraText = dimColorStr..handDisplay.extraText
			end
			entry[handDisplayEntryIndexes[columnIndex]] = handDisplay
		end

		-- Measures a row, and returns its list entry
		local calculate = function(columnsText)

			---------------------------------
			-- Calculate column dimensions --
			---------------------------------

			local columnsDimensions = {}
			local infoListTableEntry = {}

			for i, columnText in ipairs(columnsText) do
				local columnW, columnH = measure(columnText)
				columnsDimensions[i] = { columnW, columnH }
				infoListTableEntry[i] = columnText
			end

			infoListTableEntry[mainHandDamageEntryIndex] = ""
			infoListTableEntry[offHandDamageEntryIndex] = ""

			-----------------------
			-- Apply column pads --
			-----------------------

			local divider1ColumnDimensions = columnsDimensions[divider1ColumnIndex]
			divider1ColumnDimensions[1] = divider1ColumnDimensions[1] + divider1ColumnW

			local divider2ColumnDimensions = columnsDimensions[divider2ColumnIndex]
			if divider2ColumnDimensions[1] > 0 then
				divider2ColumnDimensions[1] = divider2ColumnPadLeft + divider2ColumnW + divider2ColumnDimensions[1]
			end

			---------------------------------------------
			-- Calculate max column widths and heights --
			---------------------------------------------

			for i, columnDimensions in ipairs(columnsDimensions) do

				if columnDimensions[1] > columnWidths[i] then
					columnWidths[i] = columnDimensions[1]
				end

				if columnDimensions[2] > build.tallestRowHeight then
					build.tallestRowHeight = columnDimensions[2]
				end
			end

			return infoListTableEntry
		end

		-- Both panels have a row for every listed sprite, in the same order, so a sprite is on the same row in both
		for spriteIndex, selectedSprite in ipairs(selectedSprites) do

			-- Left panel:  Target vs Listed sprite
			-- Right panel: Listed sprite vs Target
			local attackerSprite = reverse and targetSprite or selectedSprite
			local defenderSprite = reverse and selectedSprite or targetSprite

			-- Left panel:  Is the target currently attacking this sprite?
			-- Right panel: Is this sprite currently attacking the target?
			local isAttacking = ZJCreatureInfo_Private_IsAttacking(attackerSprite, defenderSprite)

			-- Casting a spell at the defender counts as fighting it too, (for the timer bars and the compact popup)
			local isEngaging = isAttacking or ZJCreatureInfo_Private_IsCastingAt(attackerSprite, defenderSprite)

			local entry

			if compact and not isEngaging then

				-- The compact popup lists the creatures fighting the target: the ones it attacks on the left, the ones
				-- attacking it on the right. A creature that is only in one of the two leaves its row in the other panel empty.
				entry = calculate({"", "", ""})
				entry[attackIconEntryIndex] = false
			else
				local dim = (reverse and dimRowsLeft or dimRowsRight)[spriteIndex]

				local rightHandString, rightHandRollString, rightHandDamageString, rightHandSpans = "", "", "", true
				local leftHandString, leftHandRollString, leftHandDamageString, leftHandSpans = "", "", "", true
				local rightHandDisplay, leftHandDisplay = nil, nil
				local rightHandIneffective, leftHandIneffective = false, false

				local attackerIsCasting = targetIsCasting
				local attackerActionIcon = targetActionIcon
				if not reverse then
					attackerActionIcon = ZJCreatureInfo_Private_GetActionIcon(attackerSprite)
					attackerIsCasting = attackerActionIcon == 2 or attackerActionIcon == 3
				end

				if attackerIsCasting then

					-- A creature that is casting a spell / using an item isn't swinging its weapon: the roll it needs to hit and
					-- its weapon damage are replaced by the name of the spell / item. In the left panel that name is in the header.
					if not reverse then
						local actionName = ZJCreatureInfo_Private_GetActionName(attackerSprite)
						if actionName ~= nil then
							rightHandString = string.format(" %s%s", dim and dimColorStr or "", actionName)
							rightHandRollString = rightHandString
						end

						-- With the spell / item icon in front of it
						rightHandDisplay = {
							["typeIcons"]  = { attackerActionIcon == 3 and 7 or 6 },
							["extraText"]  = "",
							["extraIcons"] = {},
						}
					end
				else
					local rightHandChance, rightHandDamage
					rightHandChance, rightHandIneffective, _, rightHandDamage, rightHandDisplay =
						ZJCreatureInfo_Private_GetWeaponHitChance(attackerSprite, defenderSprite, false)

					rightHandString, rightHandRollString, rightHandDamageString, rightHandSpans = formatChanceStr(
						rightHandChance, rightHandIneffective, not reverse and rightHandDamage or nil, dim)

					if EEex.CanAttackWithLeftHand(attackerSprite) then

						local leftHandChance, leftHandDamage
						leftHandChance, leftHandIneffective, _, leftHandDamage, leftHandDisplay =
							ZJCreatureInfo_Private_GetWeaponHitChance(attackerSprite, defenderSprite, true)

						leftHandString, leftHandRollString, leftHandDamageString, leftHandSpans = formatChanceStr(
							leftHandChance, leftHandIneffective, not reverse and leftHandDamage or nil, dim)
					end

					-- What is behind the damage is left out with it: in the left panel, and where "Immune" replaces it
					if reverse or rightHandDamageString == "" then rightHandDisplay = nil end
					if reverse or leftHandDamageString == "" then leftHandDisplay = nil end

					-- An immune target isn't hurt by the extra damage of a hit either
					if rightHandIneffective and rightHandDisplay ~= nil then
						rightHandDisplay.extraText, rightHandDisplay.extraIcons = "", {}
					end
					if leftHandIneffective and leftHandDisplay ~= nil then
						leftHandDisplay.extraText, leftHandDisplay.extraIcons = "", {}
					end

					for _, handDisplay in pairs({ rightHandDisplay, leftHandDisplay }) do
						handDisplay.extraText = ZJCreatureInfo_Private_ColorResistance(handDisplay.extraText,
							dim and dimResistColorStr or resistColorStr, dim and dimGreenColorStr or greenColorStr, dim and dimColorStr or "")
					end
				end

				measureHand(mainHandColumnIndex, rightHandRollString, rightHandDamageString, rightHandSpans, rightHandDisplay)
				measureHand(offHandColumnIndex, leftHandRollString, leftHandDamageString, leftHandSpans, leftHandDisplay)

				-- The columns are sized for the roll and the damage next to each other
				entry = calculate({
					[nameColumnIndex]     = string.format("%s%s ", dim and dimColorStr or "", selectedSprite:getName()),
					[mainHandColumnIndex] = rightHandString,
					[offHandColumnIndex]  = leftHandString,
				})

				setHandDisplay(entry, mainHandColumnIndex, rightHandDisplay, dim)
				setHandDisplay(entry, offHandColumnIndex, leftHandDisplay, dim)

				-- They are drawn by separate items
				entry[mainHandColumnIndex]      = rightHandRollString
				entry[mainHandDamageEntryIndex] = rightHandDamageString
				entry[offHandColumnIndex]       = leftHandRollString
				entry[offHandDamageEntryIndex]  = leftHandDamageString

				-- The left list has an icon in front of the names the target is attacking / casting at, for what it attacks
				-- them with. The right list has no need for it: there the icon of each hand is in front of its roll.
				-- Every row of the compact popup is an ongoing attack / cast, the icon would only repeat that.
				local attackIcon = false
				if reverse and not compact then
					if isAttacking then
						attackIcon = targetTypeIcon
					elseif ZJCreatureInfo_Private_IsCastingSpellAt(attackerSprite, defenderSprite) then
						attackIcon = targetActionIcon == 3 and 7 or 6
					end
				end

				entry[attackIconEntryIndex] = attackIcon
				build.anyAttackIcon = build.anyAttackIcon or attackIcon ~= false

				-- The left panel shows the target's timer bars below the sprite it is attacking / casting at
				if reverse and isEngaging and build.targetBarsSpriteIndex == nil then
					build.targetBarsSpriteIndex = spriteIndex
				end

				-- The right panel shows the attack round of every listed sprite that is attacking the target, and the
				-- spell cooldown of every listed sprite, (a spell cast at a point has no target to check against)
				if showRowTimers and not reverse and rowBarsCount < ZJCreatureInfo_Private_MaxRowBars then
					local rowBars = ZJCreatureInfo_Private_GetRowBars(selectedSprite, isAttacking)
					if rowBars[1] ~= nil then
						rowBarsCount = rowBarsCount + 1
						build.rowBars[spriteIndex] = rowBars
						build.maxRowBars = math.max(build.maxRowBars, #rowBars)
					end
				end
			end

			table.insert(build.entries, entry)
		end

		-- A hand's column has to fit the widest of each of its sub-columns next to each other, which can be on different
		-- rows. Stores where each sub-column starts, (from the left of the column), for the layout of its items.
		local fitHand = function(columnIndex, padW)

			local x = padW
			local offsets = {}

			-- The icons come first: the damage type(s) of the weapon, or the spell / item icon
			offsets.typeIcons = x + spaceW
			if build.typeIconCounts[columnIndex] > 0 then
				x = offsets.typeIcons + build.typeIconCounts[columnIndex] * handIconSize
			end

			offsets.roll = x
			x = offsets.roll + build.rollWidths[columnIndex]

			offsets.damage = x + hitDamageGapW
			if build.damageWidths[columnIndex] > 0 then
				x = offsets.damage + build.damageWidths[columnIndex]
			end

			offsets.extraText = x + hitDamageGapW
			if build.extraWidths[columnIndex] > 0 then
				x = offsets.extraText + build.extraWidths[columnIndex]
			end

			offsets.extraIcons = x + handIconGapW
			if build.extraIconCounts[columnIndex] > 0 then
				x = offsets.extraIcons + build.extraIconCounts[columnIndex] * handIconSize
			end

			build.handOffsets[columnIndex] = offsets

			-- The text that isn't a roll starts where the rolls do
			x = math.max(x, offsets.roll + build.spanWidths[columnIndex])

			-- Only widen the column if it has something besides the rolls
			if x > padW + build.rollWidths[columnIndex] then
				columnWidths[columnIndex] = math.max(columnWidths[columnIndex], x)
			end
		end

		build.handOffsets = {}
		fitHand(mainHandColumnIndex, divider1ColumnW)
		fitHand(offHandColumnIndex, divider2ColumnPadLeft + divider2ColumnW)

		return build
	end

	local builds = {}
	for panelIndex, panel in ipairs(panels) do
		builds[panelIndex] = buildPanel(panel, panelIndex == 1)
	end

	-----------------------------------------
	--     Calculate shared dimensions     --
	-----------------------------------------

	-- The header keeps its height when it has no text
	-- `maxHeaderLabelH` used in layout
	local _, minHeaderLabelH = measure("X")
	local maxHeaderLabelH = minHeaderLabelH

	-- The rows of both panels are the same height so they line up
	local tallestRowHeight = 0

	for panelIndex, build in ipairs(builds) do

		build.labelText = labelTexts[panelIndex]

		local labelW, labelH = measure(build.labelText)
		build.labelW = labelW

		maxHeaderLabelH = math.max(maxHeaderLabelH, labelH)
		tallestRowHeight = math.max(tallestRowHeight, build.tallestRowHeight)
	end

	-- The target's name is the left header's first line. What the target attacks with, (its damage / spell), is on a
	-- second line below it. The right header only has the first line, its spell effects start right below it.
	-- `targetNameW`, `headerLine2H` and `headerTextH` used in layout
	local targetNameW = 0
	local hasHeaderLine2 = targetAttackW > 0

	if targetNameText ~= "" then
		local nameW, nameH = measure(targetNameText)
		targetNameW = nameW
		maxHeaderLabelH = math.max(maxHeaderLabelH, nameH)
	end

	-- Both lines are as tall as the tallest header text
	local headerLine2H = hasHeaderLine2 and maxHeaderLabelH or 0
	local headerTextH = maxHeaderLabelH + headerLine2H

	-- The text of a row is at its top, the room below it is for the timer bars of the right panel.
	-- Every row is as tall as the row with the most bars, as a list's rows are all the same height.
	-- `textRowHeight` used in layout
	local textRowHeight = tallestRowHeight + rowHeightPad
	local maxRowBars = builds[2].maxRowBars

	-- The bars show where the target is in its attack round, spell cast, etc. Each is only present while it applies.
	-- They are stacked below the name of the sprite the target is attacking, in the left panel. If it isn't attacking
	-- any of the listed sprites, they are stacked below the left panel's header, which makes that header taller.
	-- `targetBars` and `targetBarsSpriteIndex` used in layout
	local targetBars = ZJCreatureInfo_Private_GetTargetBars(targetSprite)
	local targetBarsCount = #targetBars
	local targetBarsSpriteIndex = builds[1].targetBarsSpriteIndex
	local targetBarsHeaderH = 0

	if targetBarsCount > 0 then
		if targetBarsSpriteIndex ~= nil then
			maxRowBars = math.max(maxRowBars, targetBarsCount)
		else
			targetBarsHeaderH = targetBarsPadTop + targetBarsCount * targetBarH + (targetBarsCount - 1) * targetBarGap
		end
	end
	local rowBarsTotalH = 0

	if maxRowBars > 0 then
		rowBarsTotalH = rowBarsPadTop + maxRowBars * rowBarH + (maxRowBars - 1) * rowBarGap + rowBarsPadBottom
	end

	-- `rowHeight` and `attackIconSize` used in layout
	local rowHeight = textRowHeight + rowBarsTotalH
	local attackIconSize = textRowHeight


	-- Both lists have a row for every listed sprite
	-- `infoListH` used in layout
	local infoListH = #builds[1].entries * rowHeight

	-----------------------------------
	--     Finalize panel lists      --
	-----------------------------------

	ZJCreatureInfo_Private_Menu_TargetName = targetNameText
	ZJCreatureInfo_Private_Menu_TargetNameUD.text.point = fontPoint

	for _, textItemUD in ipairs(ZJCreatureInfo_Private_Menu_TargetAttackTextUDs) do
		textItemUD.text.point = fontPoint
	end

	for panelIndex, panel in ipairs(panels) do

		local build = builds[panelIndex]
		local columnWidths = build.columnWidths
		local columnUDs = panel.columnUDs

		_G[panel.tableVarName] = build.entries
		_G[panel.labelVarName] = build.labelText

		panel.labelUD.text.point = fontPoint
		panel.listUD.list.rowheight = rowHeight

		-- `totalHeaderW` used in layout
		local totalHeaderW = build.labelW

		if panelIndex == 1 then
			-- The target's name, with what the target attacks with below it
			totalHeaderW = math.max(targetNameW, targetAttackW)
		end

		----------------------------------
		-- Reserve room for attack icon --
		----------------------------------

		if build.anyAttackIcon then
			columnWidths[nameColumnIndex] = columnWidths[nameColumnIndex] + attackIconSize + attackIconPadRight
		end

		-------------------------
		-- Calculate row width --
		-------------------------

		local rowWidth = 0
		for _, columnWidth in ipairs(columnWidths) do
			rowWidth = rowWidth + columnWidth
		end

		-- Close the list with a divider if the header is wide enough to leave room for it
		local divider3ColumnNeededW = divider3ColumnPadLeft + divider3ColumnW
		local divider3NeededRowWidth = rowWidth + divider3ColumnNeededW

		if totalHeaderW >= divider3NeededRowWidth then
			columnWidths[divider3ColumnIndex] = divider3ColumnNeededW
			rowWidth = divider3NeededRowWidth
		end

		local infoListW = math.max(rowWidth, 1) -- The width is divided by below

		---------------------------
		-- Adjust column layouts --
		---------------------------

		local nameColumnTextItem = columnUDs[nameColumnIndex].items
		nameColumnTextItem.text.point = fontPoint
		nameColumnTextItem.area.y = 0
		nameColumnTextItem.area.h = textRowHeight

		-- Only the left list has an icon in front of the names
		if panelIndex == 1 then
			local nameColumnIconItem = nameColumnTextItem.next
			nameColumnIconItem.area.x = 0
			nameColumnIconItem.area.y = 0
			nameColumnIconItem.area.w = attackIconSize
			nameColumnIconItem.area.h = attackIconSize
		end

		local divider1Item = columnUDs[divider1ColumnIndex].items
		divider1Item.area.w = divider1ColumnW

		local diver1TextItem = divider1Item.next
		diver1TextItem.area.x = divider1ColumnW

		local mainHandColumnTextItem = columnUDs[mainHandColumnIndex].items.next
		mainHandColumnTextItem.text.point = fontPoint
		mainHandColumnTextItem.area.y = 0
		mainHandColumnTextItem.area.h = textRowHeight

		-- Places the items of a hand's column: the icons in front of the roll, the roll, the damage, the extra damage
		-- and the extra damage icons. Returns the last of them.
		local layoutHandItems = function(rollTextItem, columnIndex)

			local offsets = build.handOffsets[columnIndex]
			local iconY = math.floor((textRowHeight - handIconSize) / 2)

			rollTextItem.area.x = offsets.roll

			local damageItem = rollTextItem.next
			damageItem.text.point = fontPoint
			damageItem.area.x = offsets.damage
			damageItem.area.y = 0
			damageItem.area.h = textRowHeight

			local item = damageItem

			for slot = 1, ZJCreatureInfo_Private_MaxHandIcons do
				item = item.next
				item.area.x = offsets.typeIcons + (slot - 1) * handIconSize
				item.area.y = iconY
				item.area.w = handIconSize
				item.area.h = handIconSize
			end

			item = item.next
			item.text.point = fontPoint
			item.area.x = offsets.extraText
			item.area.y = 0
			item.area.h = textRowHeight

			for slot = 1, ZJCreatureInfo_Private_MaxHandIcons do
				item = item.next
				item.area.x = offsets.extraIcons + (slot - 1) * handIconSize
				item.area.y = iconY
				item.area.w = handIconSize
				item.area.h = handIconSize
			end

			return item
		end

		layoutHandItems(mainHandColumnTextItem, mainHandColumnIndex)

		local divider2Item = columnUDs[divider2ColumnIndex].items
		divider2Item.area.x = columnWidths[divider2ColumnIndex] > 0 and divider2ColumnPadLeft or 0
		divider2Item.area.w = columnWidths[divider2ColumnIndex] > 0 and divider2ColumnW or 0

		local diver2TextItem = divider2Item.next
		diver2TextItem.area.x = divider2ColumnPadLeft + divider2ColumnW

		local offHandColumnTextItem = columnUDs[offHandColumnIndex].items.next
		offHandColumnTextItem.text.point = fontPoint
		offHandColumnTextItem.area.y = 0
		offHandColumnTextItem.area.h = textRowHeight

		layoutHandItems(offHandColumnTextItem, offHandColumnIndex)

		local divider3Item = columnUDs[divider3ColumnIndex].items
		divider3Item.area.x = columnWidths[divider3ColumnIndex] > 0 and divider3ColumnPadLeft or 0
		divider3Item.area.w = columnWidths[divider3ColumnIndex] > 0 and divider3ColumnW or 0

		-----------------------------------------------------------------------------
		-- Convert and set calculated column lengths to percentages for the engine --
		-----------------------------------------------------------------------------

		local columnWidthPercentages = {}

		while true do

			local needGrow = false
			local totalPercent = 0

			for i, columnWidth in ipairs(columnWidths) do

				local columnWidthPercent = math.ceil(columnWidth * 100 / infoListW)
				local resultingColumnWidth = math.floor(infoListW * columnWidthPercent / 100)

				columnWidthPercentages[i] = columnWidthPercent
				totalPercent = totalPercent + columnWidthPercent

				if resultingColumnWidth < columnWidth then
					needGrow = true
					break
				end
			end

			if needGrow or totalPercent > 100 then
				infoListW = infoListW + 1
			else
				break
			end
		end

		for i, columnUD in ipairs(columnUDs) do
			EEex_Menu_SetItemVariant(columnUD.reference_width, columnWidthPercentages[i])
		end

		build.infoListW = infoListW
		build.panelW = math.max(totalHeaderW, infoListW)
	end

	----------------------------------
	--      Lay out spell effects    --
	----------------------------------

	-- The spells affecting the target are listed below the right panel's header, one per line. A name that is wider
	-- than the panel widens it.
	-- `spellEffectsText`, `spellEffectsW` and `spellEffectsH` used in layout
	local spellEffectsText = ""
	local spellEffectsW = 0
	local spellEffectsH = 0

	if #spellEffectNames > 0 then

		local lines = spellEffectNames

		for _, lineText in ipairs(lines) do
			spellEffectsW = math.max(spellEffectsW, (measure(lineText)))
		end

		-- Room for rounding, so the engine doesn't wrap a line that just fits a second time
		spellEffectsW = spellEffectsW + 2
		spellEffectsText = table.concat(lines, "\n")

		local _, textH = EEex_Menu_GetTextWidthHeight(spellEffectsText, styles["normal"].font, fontPoint,
			styles["normal"].useFontZoom, spellEffectsW)
		spellEffectsH = textH

		builds[2].panelW = math.max(builds[2].panelW, spellEffectsW)
	end

	ZJCreatureInfo_Private_Menu_SpellEffects = spellEffectsText
	ZJCreatureInfo_Private_Menu_SpellEffectsUD.text.point = fontPoint

	----------------------------
	--     Layout panels      --
	----------------------------

	local headerY = backgroundPad

	-- The left header's lines are followed by its target bars, the right header's line by its spell effects, the
	-- separator is below whichever side is taller
	-- `headerHorizontalSepY` and `infoListY` used in layout
	-- Without defenses, the right header's line is empty and the spell effects take its place
	-- `spellEffectsY` used in layout
	local rightHeaderLineH = labelTexts[2] ~= "" and maxHeaderLabelH or 0
	local spellEffectsY = headerY + rightHeaderLineH
	local headerHorizontalSepY = math.max(headerY + headerTextH + targetBarsHeaderH, spellEffectsY + spellEffectsH)
		+ headerHorizontalSepPadTop
	local infoListY = headerHorizontalSepY + headerHorizontalSepH + headerHorizontalSepPadBottom

	local panelX = backgroundPad

	for panelIndex, panel in ipairs(panels) do

		local build = builds[panelIndex]

		if panelIndex > 1 then
			-- The separator runs from the top of the headers to the bottom of the lists
			local panelSeparatorX = panelX + panelGap
			local panelSeparatorH = infoListY + infoListH - headerY
			Infinity_SetArea("ZJCreatureInfo_Menu_PanelSeparator", panelSeparatorX, headerY, panelSeparatorW, panelSeparatorH)
			panelX = panelSeparatorX + panelSeparatorW + panelGap
		end

		build.panelX = panelX

		local headerLabelX = panelX
		local headerLabelY = headerY

		if panelIndex == 1 then
			Infinity_SetArea("ZJCreatureInfo_Menu_TargetName", panelX, headerY, targetNameW, maxHeaderLabelH)

			-- What the target attacks with is on the second line
			local line2Y = headerY + maxHeaderLabelH
			local iconY = line2Y + math.floor((maxHeaderLabelH - handIconSize) / 2)

			for handIndex = 1, 2 do

				local hand = targetAttackHands[handIndex]
				local handState = ZJCreatureInfo_Private_Menu_TargetAttack[handIndex]
				local itemPrefix = "ZJCreatureInfo_Menu_TargetAttack"..handIndex

				handState.text  = hand and hand.text or ""
				handState.icons = hand and hand.icons or {}
				handState.extra = hand and hand.extra or ""
				handState.extraIcons = hand and hand.extraIcons or {}

				if hand ~= nil then
					Infinity_SetArea(itemPrefix.."Text", panelX + hand.textX, line2Y, hand.textW, maxHeaderLabelH)
					Infinity_SetArea(itemPrefix.."Extra", panelX + hand.extraX, line2Y, hand.extraW, maxHeaderLabelH)
					for slot = 1, ZJCreatureInfo_Private_MaxHandIcons do
						Infinity_SetArea(itemPrefix.."Icon"..slot, panelX + hand.iconsX + (slot - 1) * handIconSize, iconY, handIconSize, handIconSize)
						Infinity_SetArea(itemPrefix.."ExtraIcon"..slot, panelX + hand.extraIconsX + (slot - 1) * handIconSize, iconY, handIconSize, handIconSize)
					end
				end
			end

			local separatorX = targetAttackSeparatorXs[1]
			ZJCreatureInfo_Private_Menu_TargetAttackSeparator = separatorX and targetAttackSeparatorStr or ""
			if separatorX ~= nil then
				Infinity_SetArea("ZJCreatureInfo_Menu_TargetAttackSeparator", panelX + separatorX, line2Y,
					measure(targetAttackSeparatorStr), maxHeaderLabelH)
			end
		end
		Infinity_SetArea(panel.labelName, headerLabelX, headerLabelY, build.labelW, maxHeaderLabelH)

		if panelIndex == 2 then
			Infinity_SetArea("ZJCreatureInfo_Menu_SpellEffects", panelX, spellEffectsY, spellEffectsW, spellEffectsH)
		end

		Infinity_SetArea(panel.listName, panelX, infoListY, build.infoListW, infoListH)

		panelX = panelX + build.panelW
	end

	-- `backgroundWidth` used in layout
	local backgroundWidth = panelX + backgroundPad

	------------------------------------
	--     Layout label separator     --
	------------------------------------

	local headerHorizontalSepX = backgroundPad
	local headerHorizontalSepW = backgroundWidth - backgroundPad * 2

	Infinity_SetArea("ZJCreatureInfo_Menu_LabelSeparator", headerHorizontalSepX, headerHorizontalSepY, headerHorizontalSepW, headerHorizontalSepH)

	-------------------------------
	--     Layout background     --
	-------------------------------

	local backgroundHeight = infoListY + infoListH + backgroundPad

	local cursorX, cursorY = EEex_Menu_GetMousePos()
	local cursorCenterX, cursorCenterY, cursorW, cursorH = ZJCreatureInfo_Private_GetCursorRenderData()

	local cursorRenderX = cursorX - cursorCenterX
	local cursorRenderY = cursorY - cursorCenterY

	local backgroundX = cursorRenderX + cursorW + popupRightSideAdjust
	local backgroundY = cursorRenderY

	local screenW, screenH = Infinity_GetScreenSize()

	if backgroundX + backgroundWidth > screenW then
		backgroundX = cursorRenderX - backgroundWidth - popupLeftSideAdjust
	end

	-- Two panels can be wider than the room on either side of the cursor
	if backgroundX < 0 then
		backgroundX = math.max(0, screenW - backgroundWidth)
	end

	local backgroundBottom = backgroundY + backgroundHeight

	if backgroundBottom > screenH then
		backgroundY = backgroundY - (backgroundBottom - screenH)
	end

	Infinity_SetOffset("ZJCreatureInfo_Menu", backgroundX, backgroundY)
	Infinity_SetArea("ZJCreatureInfo_Menu_BackgroundRect", 0, 0, backgroundWidth, backgroundHeight)

	-------------------------
	--     Layout bars     --
	-------------------------

	local hideBar = function(barState)
		barState.track = false
		barState.fill = false
		for i in pairs(barState.markers) do
			barState.markers[i] = false
		end
	end

	-- Places the items of a bar, (`itemPrefix`.."Track" / "Fill" / "Marker<n>"), and enables them through `barState`
	local layoutBar = function(itemPrefix, barState, bar, barX, barY, barW, barH, markerW)

		barState.track = true
		Infinity_SetArea(itemPrefix.."Track", barX, barY, barW, barH)

		-- The bar fills from left to right
		local percentage = math.max(0, math.min(bar.percentage, 1))
		local fillW = math.floor(barW * percentage + 0.5)

		if fillW > 0 then
			barState.fill = true
			Infinity_SetArea(itemPrefix.."Fill", barX, barY, fillW, barH)
		end

		-- White ticks, (attack rolls / spell release)
		for i, value in ipairs(bar.markers) do

			if i > ZJCreatureInfo_Private_TargetBarMaxMarkers[bar.name] then break end

			local markerX = barX + math.floor(barW * value / 100 + 0.5) - math.floor(markerW / 2)
			markerX = math.max(barX, math.min(markerX, barX + barW - markerW))

			barState.markers[i] = true
			Infinity_SetArea(itemPrefix.."Marker"..i, markerX, barY, markerW, barH)
		end
	end

	-----------------
	-- Target bars --
	-----------------

	local targetBarStates = ZJCreatureInfo_Private_Menu_TargetBars

	for _, barName in ipairs(ZJCreatureInfo_Private_TargetBarNames) do
		hideBar(targetBarStates[barName])
	end

	-- The bars belong to the target, so they are in the left panel, which lists its attacks
	local targetBarX = builds[1].panelX
	local targetBarY, targetBarW, targetBarStepH, targetBarStepGap, targetBarStepMarkerW

	if targetBarsSpriteIndex ~= nil then
		-- Below the name of the sprite the target is attacking, laid out like the row bars of the right panel
		local rowY = infoListY + (targetBarsSpriteIndex - 1) * rowHeight
		targetBarY = rowY + textRowHeight + rowBarsPadTop
		targetBarW = math.max(builds[1].columnWidths[nameColumnIndex] - spaceW, 1)
		targetBarStepH, targetBarStepGap, targetBarStepMarkerW = rowBarH, rowBarGap, rowBarMarkerW
	else
		-- Below the panel's header, as wide as the panel
		targetBarY = headerY + headerTextH + targetBarsPadTop
		targetBarW = builds[1].panelW
		targetBarStepH, targetBarStepGap, targetBarStepMarkerW = targetBarH, targetBarGap, targetBarMarkerW
	end

	for _, targetBar in ipairs(targetBars) do
		local barName = targetBar.name
		layoutBar("ZJCreatureInfo_Menu_Target"..barName.."Bar", targetBarStates[barName], targetBar,
			targetBarX, targetBarY, targetBarW, targetBarStepH, targetBarStepMarkerW)
		targetBarY = targetBarY + targetBarStepH + targetBarStepGap
	end

	--------------
	-- Row bars --
	--------------

	local rowBarStates = ZJCreatureInfo_Private_Menu_RowBars

	for _, rowBarState in ipairs(rowBarStates) do
		for _, barName in ipairs(ZJCreatureInfo_Private_RowBarNames) do
			hideBar(rowBarState[barName])
		end
	end

	-- The bars of a row are below its name in the right panel, and as wide as the name column, (less its trailing space)
	local rowBarX = builds[2].panelX
	local rowBarW = math.max(builds[2].columnWidths[nameColumnIndex] - spaceW, 1)

	-- Every row with bars uses the next set of bar items in the menu
	local rowBarSet = 0

	for spriteIndex = 1, #selectedSprites do

		local rowBars = builds[2].rowBars[spriteIndex]

		if rowBars ~= nil then

			rowBarSet = rowBarSet + 1

			local rowY = infoListY + (spriteIndex - 1) * rowHeight
			local rowBarY = rowY + textRowHeight + rowBarsPadTop

			for _, rowBar in ipairs(rowBars) do
				local barName = rowBar.name
				layoutBar("ZJCreatureInfo_Menu_Row"..rowBarSet..barName.."Bar", rowBarStates[rowBarSet][barName], rowBar,
					rowBarX, rowBarY, rowBarW, rowBarH, rowBarMarkerW)
				rowBarY = rowBarY + rowBarH + rowBarGap
			end
		end
	end
end

-- The panel's "show", (see ZJPopup_AddPanel()): called every frame while the "Popup Key" is held and no panel that
-- comes first, (Spell Info), shows. Lays out and opens the popup over the creature under the cursor and returns true, or
-- closes it and returns false if there is nothing to show. The popup opens over any creature: the compact popup over an
-- ally, the full one over anyone else, (hostile or neutral, whatever the cursor's shape).
function ZJCreatureInfo_Private_Panel_Show()

	-- Only on the world screen, while its action bar is open
	if not ZJCreatureInfo_Private_Enabled or not ZJCreatureInfo_Private_ActionbarOpen then
		ZJCreatureInfo_Private_Menu_SetOpen(false)
		return false
	end

	local targetSprite = EEex_GameObject_GetUnderCursor()

	if not EEex_GameObject_IsSprite(targetSprite) then
		-- Hide the popup if no sprite is under the cursor
		ZJCreatureInfo_Private_LastTargetID = -1
		ZJCreatureInfo_Private_Menu_SetOpen(false)
		return false
	end

	local lastTargetId = ZJCreatureInfo_Private_LastTargetID
	local targetId = targetSprite.m_id
	ZJCreatureInfo_Private_LastTargetID = targetId

	local chitin = EngineGlobals.g_pBaldurChitin

	if (chitin.m_pObjectGame.m_nState ~= 2 and EEex_Key_IsDown(SDL_Keycode.SDLK_TAB)) or (B3EffectMenu_IsOpen ~= nil and B3EffectMenu_IsOpen()) then
		-- Hide the popup if a tooltip is being forced or the effect menu popup is open
		ZJCreatureInfo_Private_Menu_SetOpen(false)
		return false
	end

	local nCurrentCursor = chitin.m_pObjectCursor.nCurrentCursor
	local attackCursor = nCurrentCursor == 12 or (nCurrentCursor == 101 and EEex.IsDefaultAttackCursor())

	local selectedSprites, compact = ZJCreatureInfo_Private_GetRowSprites(targetSprite, attackCursor)

	if (selectedSprites[1] == nil and not compact) or not ZJCreatureInfo_Private_IsPopupAllowed(compact, targetSprite) then
		-- Hide the popup if no currently selected sprites are eligible, or the popup is turned off for this side.
		-- The compact popup also opens over an ally that isn't fighting anyone: it then only has its headers, (the
		-- ally's weapon damage, timers and the spells affecting it).
		ZJCreatureInfo_Private_Menu_SetOpen(false)
		return false
	end

	local waiting = true

	-- Delay opening by 1 tick to wait for the cursor shape to update
	if targetId ~= lastTargetId or ZJCreatureInfo_Private_OpenDelayTarget == -1 then
		ZJCreatureInfo_Private_OpenDelayTarget = Infinity_GetFrameCounter() + 1
	elseif Infinity_GetFrameCounter() >= ZJCreatureInfo_Private_OpenDelayTarget then
		waiting = false
	end

	if waiting then

		-- Attempt to layout with the previous target if we are currently waiting
		local lastTarget = EEex_GameObject_Get(ZJCreatureInfo_Private_CurrentTargetID)
		local lastSelectedSprites, lastCompact
		if EEex_GameObject_IsSprite(lastTarget) then
			lastSelectedSprites, lastCompact = ZJCreatureInfo_Private_GetRowSprites(lastTarget, attackCursor)
		end

		if lastSelectedSprites ~= nil and (lastSelectedSprites[1] ~= nil or lastCompact)
			and ZJCreatureInfo_Private_IsPopupAllowed(lastCompact, lastTarget)
		then
			ZJCreatureInfo_Private_Layout(lastSelectedSprites, lastTarget, lastCompact)
		else
			ZJCreatureInfo_Private_Menu_SetOpen(false, true)
		end

		-- The creature is this panel's, even while it waits: no panel after it describes creatures
		return true
	end

	ZJCreatureInfo_Private_CurrentTargetID = targetId
	ZJCreatureInfo_Private_Layout(selectedSprites, targetSprite, compact)
	ZJCreatureInfo_Private_Menu_SetOpen(true)
	return true
end

-- The panel's "hide": another panel shows, or the "Popup Key" isn't held
function ZJCreatureInfo_Private_Panel_Hide()
	ZJCreatureInfo_Private_Menu_SetOpen(false)
end

-----------------------
-- ZJCreatureInfo_Menu --
-----------------------

ZJCreatureInfo_Private_Menu_SpellEffects          = ""    -- The spells affecting the target, one or more lines
ZJCreatureInfo_Private_Menu_SpellEffectsUD        = nil   -- uiItem
ZJCreatureInfo_Private_Menu_InfoList_SelectedRow  = 0
ZJCreatureInfo_Private_Menu_InfoList_Table        = {}    -- Left panel:  The target's attacks on the listed sprites
ZJCreatureInfo_Private_Menu_InfoList2_SelectedRow = 0
ZJCreatureInfo_Private_Menu_InfoList2_Table       = {}    -- Right panel: The listed sprites' attacks on the target
ZJCreatureInfo_Private_Menu_IsOpen                = false
ZJCreatureInfo_Private_Menu_Label                 = ""    -- Left panel's header
ZJCreatureInfo_Private_Menu_Label2                = ""    -- Right panel's header
ZJCreatureInfo_Private_Menu_Panels                = nil   -- table, see the main file loaded listener
ZJCreatureInfo_Private_Menu_TargetName            = ""    -- The target's name, at the start of the left panel's header
ZJCreatureInfo_Private_Menu_TargetNameUD          = nil   -- uiItem

-- What the target attacks with, below the target's name in the left panel's header: for each hand, its damage, the icons of
-- the damage type(s), (see ZJCreatureInfo_Private_DamageTypeIcons), the extra damage, and the icons of the elements
-- of that extra damage, (frames in ZJCREELM.BAM)
ZJCreatureInfo_Private_Menu_TargetAttack = {
	{ ["text"] = "", ["icons"] = {}, ["extra"] = "", ["extraIcons"] = {} },
	{ ["text"] = "", ["icons"] = {}, ["extra"] = "", ["extraIcons"] = {} },
}
ZJCreatureInfo_Private_Menu_TargetAttackSeparator = ""    -- Between the two hands
ZJCreatureInfo_Private_Menu_TargetAttackTextUDs   = {}    -- Array of uiItem, the text items of the above

-- Which items of a timer bar are shown: { track = boolean, fill = boolean, markers = { [markerIndex] = boolean } }
ZJCreatureInfo_Private_Menu_TargetBars            = {}    -- table, [barName] = bar state, below the left panel's header
ZJCreatureInfo_Private_Menu_RowBars               = {}    -- table, [bar set][barName] = bar state, below the right panel's names

for _, barName in ipairs(ZJCreatureInfo_Private_TargetBarNames) do
	ZJCreatureInfo_Private_Menu_TargetBars[barName] = { ["track"] = false, ["fill"] = false, ["markers"] = {} }
end

for rowBarSet = 1, ZJCreatureInfo_Private_MaxRowBars do
	local rowBarState = {}
	for _, barName in ipairs(ZJCreatureInfo_Private_RowBarNames) do
		rowBarState[barName] = { ["track"] = false, ["fill"] = false, ["markers"] = {} }
	end
	ZJCreatureInfo_Private_Menu_RowBars[rowBarSet] = rowBarState
end

-- The frame in ZJCREDMG.BAM of the icon in front of a name in the left list, nil if the row has none
function ZJCreatureInfo_Private_Menu_InfoList_RowIcon(infoListTable, rowNumber)
	local entry = infoListTable[rowNumber]
	local icon = entry and entry[4]
	if not icon then return nil end
	return icon * 4 -- The green variant
end

-- The frame in ZJCREDMG.BAM of an icon in front of the roll of a hand, nil if that slot isn't used
function ZJCreatureInfo_Private_Menu_InfoList_TypeIcon(infoListTable, rowNumber, handEntryIndex, slot)
	local entry = infoListTable[rowNumber]
	local handDisplay = entry and entry[handEntryIndex]
	local icon = handDisplay and handDisplay.typeIcons[slot]
	if icon == nil then return nil end
	return icon * 4 + handDisplay.variant
end

-- The extra damage behind the damage of a hand
function ZJCreatureInfo_Private_Menu_InfoList_ExtraText(infoListTable, rowNumber, handEntryIndex)
	local entry = infoListTable[rowNumber]
	local handDisplay = entry and entry[handEntryIndex]
	return handDisplay and handDisplay.extraText or ""
end

-- The frame in ZJCREELM.BAM of an extra damage icon behind the damage of a hand, nil if that slot isn't used
function ZJCreatureInfo_Private_Menu_InfoList_ExtraIcon(infoListTable, rowNumber, handEntryIndex, slot)
	local entry = infoListTable[rowNumber]
	local handDisplay = entry and entry[handEntryIndex]
	return handDisplay and handDisplay.extraIcons[slot] or nil
end

function ZJCreatureInfo_Private_Menu_Open()
	EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_tempCursor = 4 -- Clear tooltip
	Infinity_PushMenu("ZJCreatureInfo_Menu")
	ZJCreatureInfo_Private_Menu_IsOpen = true
end

function ZJCreatureInfo_Private_Menu_Close()
	Infinity_PopMenu("ZJCreatureInfo_Menu")
	ZJCreatureInfo_Private_Menu_IsOpen = false
	ZJCreatureInfo_Private_AttackRollFramesCaches = {}
	ZJCreatureInfo_Private_CastTargets = {}
	ZJCreatureInfo_Private_ActionNameCaches = {}
	ZJCreatureInfo_Private_ActionAreaCaches = {}
end

function ZJCreatureInfo_Private_Menu_SetOpen(open, dontResetOpenDelay)
	if open then
		if not ZJCreatureInfo_Private_Menu_IsOpen then
			ZJCreatureInfo_Private_Menu_Open()
		end
	elseif ZJCreatureInfo_Private_Menu_IsOpen then
		if not dontResetOpenDelay then
			ZJCreatureInfo_Private_OpenDelayTarget = -1
		end
		ZJCreatureInfo_Private_CurrentTargetID = -1
		ZJCreatureInfo_Private_Menu_Close()
	end
end

---------------------
-- Other Listeners --
---------------------

function ZJCreatureInfo_Private_OnActionbarOpened()
	ZJCreatureInfo_Private_ActionbarOpen = true
end

function ZJCreatureInfo_Private_OnActionbarClosed()
	ZJCreatureInfo_Private_ActionbarOpen = false
	ZJCreatureInfo_Private_Menu_SetOpen(false)
end

EEex_Menu_AddMainFileLoadedListener(function()

	EEex_Menu_LoadFile("ZJCreInf")

	---------------
	-- Store UDs --
	---------------

	ZJCreatureInfo_Private_Menu_TargetNameUD = EEex_Menu_GetItem("ZJCreatureInfo_Menu_TargetName")
	ZJCreatureInfo_Private_Menu_SpellEffectsUD = EEex_Menu_GetItem("ZJCreatureInfo_Menu_SpellEffects")

	ZJCreatureInfo_Private_Menu_TargetAttackTextUDs = {
		EEex_Menu_GetItem("ZJCreatureInfo_Menu_TargetAttack1Text"),
		EEex_Menu_GetItem("ZJCreatureInfo_Menu_TargetAttack1Extra"),
		EEex_Menu_GetItem("ZJCreatureInfo_Menu_TargetAttack2Text"),
		EEex_Menu_GetItem("ZJCreatureInfo_Menu_TargetAttack2Extra"),
		EEex_Menu_GetItem("ZJCreatureInfo_Menu_TargetAttackSeparator"),
	}
	-- The left and right panel, whose items and variables only differ by a suffix
	ZJCreatureInfo_Private_Menu_Panels = {}

	for panelIndex, suffix in ipairs({ "", "2" }) do

		local listUD = EEex_Menu_GetItem("ZJCreatureInfo_Menu_InfoList"..suffix)

		local columnUDs = {}
		local columnUDsSize = 0

		local columnUD = listUD.list.columns
		while true do
			if columnUD == nil then break end
			columnUDsSize = columnUDsSize + 1
			columnUDs[columnUDsSize] = columnUD
			columnUD = columnUD.next
		end

		ZJCreatureInfo_Private_Menu_Panels[panelIndex] = {
			["labelName"]     = "ZJCreatureInfo_Menu_Label"..suffix,
			["labelUD"]       = EEex_Menu_GetItem("ZJCreatureInfo_Menu_Label"..suffix),
			["labelVarName"]  = "ZJCreatureInfo_Private_Menu_Label"..suffix,
			["listName"]      = "ZJCreatureInfo_Menu_InfoList"..suffix,
			["listUD"]        = listUD,
			["columnUDs"]     = columnUDs,
			["columnUDsSize"] = columnUDsSize,
			["tableVarName"]  = "ZJCreatureInfo_Private_Menu_InfoList"..suffix.."_Table",
		}
	end

	--------------------------------------
	-- Listen to actionbar open / close --
	--------------------------------------

	local listenToEngineEvent = function(eventRef, listener)
		local oldFunc = EEex_Menu_GetItemFunction(eventRef) or function() end
		EEex_Menu_SetItemFunction(eventRef, function()
			local toReturn = oldFunc()
			listener()
			return toReturn
		end)
	end

	local menu = EEex_Menu_Find("WORLD_ACTIONBAR")
	listenToEngineEvent(menu.reference_onOpen, ZJCreatureInfo_Private_OnActionbarOpened)
	listenToEngineEvent(menu.reference_onClose, ZJCreatureInfo_Private_OnActionbarClosed)
end)

EEex.RegisterSlicedRect("ZJCreatureInfo_BackgroundRect", {
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

function ZJCreatureInfo_Private_Background_Render(item)
	EEex.DrawSlicedRect("ZJCreatureInfo_BackgroundRect", { item:getArea() }, 255 * 0.85)
end

EEex_Menu_AddBeforeUIItemRenderListener("ZJCreatureInfo_Menu_BackgroundRect", ZJCreatureInfo_Private_Background_Render)

EEex_Utility_NewScope(function()
	local old = EEex_Sprite_Hook_CheckSuppressTooltip
	EEex_Sprite_Hook_CheckSuppressTooltip = function()
		return ZJCreatureInfo_Private_Menu_IsOpen or old()
	end
end)

-- Between Spell Info, (a spell waiting for a target describes the creature instead), and Lock Info, (never a creature)
ZJPopup_AddPanel({
	["name"]     = "Creature Info",
	["priority"] = 20,
	["show"]     = ZJCreatureInfo_Private_Panel_Show,
	["hide"]     = ZJCreatureInfo_Private_Panel_Hide,
})
