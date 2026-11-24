
--[[
+--------------------------------------------------------------------------------------------------+
| ZJSprite - Sprite helpers shared by the Battle Sense modules                                     |
+--------------------------------------------------------------------------------------------------+
|   Read the engine's casting / attack round state. Everything is also reachable as a method on    |
|   CGameSprite, prefixed with "zj" so it can never clash with a method EEex adds later.           |
+--------------------------------------------------------------------------------------------------+
--]]

-- ACTION.IDS values that cast a spell over its casting time: Spell(), SpellPoint(), ForceSpell(),
-- ForceSpellPoint(), SpellNoDec(), SpellPointNoDec(), ForceSpellRange(), ForceSpellPointRange(),
-- (and their RES variants)
ZJSprite_Private_SpellActions = {
	[31]  = true,
	[95]  = true,
	[113] = true,
	[114] = true,
	[191] = true,
	[192] = true,
	[318] = true,
	[319] = true,
}

-- Whether the sprite has started casting a spell, (the chant), and hasn't released it yet
function ZJSprite_IsCastingSpell(sprite)
	if not sprite then return false end
	return sprite.m_bStartedCasting ~= 0 and ZJSprite_Private_SpellActions[sprite.m_curAction.m_actionID] == true
end
CGameSprite.zjIsCastingSpell = ZJSprite_IsCastingSpell

-- The casting time, (in tenths of a round), of the spell the sprite is casting, after the sprite's
-- casting speed modifiers have been applied. Only meaningful while sprite:zjIsCastingSpell() is true.
--
-- NOTE: The engine stores this in the same field as the attack round's speed factor.
function ZJSprite_GetCastingTime(sprite)
	if not sprite then return 0 end
	return math.max(0, sprite.m_speedFactor)
end
CGameSprite.zjGetCastingTime = ZJSprite_GetCastingTime

-- [0-99], the cast timer value at which the spell the sprite is casting is released.
-- Returns nil if the sprite isn't casting a spell.
function ZJSprite_GetCastReleaseTimer(sprite)

	if not sprite then return nil end

	if not ZJSprite_Private_SpellActions[sprite.m_curAction.m_actionID] then return nil end

	-- The cooldown of an earlier spell is still running, the release tick would give away the coming spell
	if not ZJSprite_HasCastBegun(sprite) then return nil end

	local flagged = sprite.m_bStartedCasting ~= 0

	-- The engine's own casting state can't be relied on: a spell cast at a point leaves m_bStartedCasting and
	-- m_speedFactor at 0, and m_speedFactor has been seen at 0 during a flagged cast with a casting time. Use the
	-- casting time of the spell in the sprite's action instead. This is cosmetic, never let it raise.
	local ok, castingTime = pcall(ZJSprite_Private_GetActionCastingTime, sprite)

	if not ok or castingTime == nil then
		-- The spell couldn't be read, the engine's value is the only one available
		if not flagged then return nil end
		return math.min(sprite:zjGetCastingTime() * 10, 99)
	end

	local releaseTimer = math.min(castingTime * 10, 99)

	if not flagged then
		-- The action outlasts the release, (and the cooldown of an earlier spell can still be running before the cast starts)
		local castTimer = sprite:getCastTimer()
		if castTimer < 0 or castTimer > releaseTimer then return nil end
	end

	return releaseTimer
end

-- SPELL.IDS prefixes, [spell id / 1000]
ZJSprite_Private_SpellIDPrefixes = { [1] = "SPPR", [2] = "SPWI", [3] = "SPIN", [4] = "SPCL" }

-- Reading a spell's casting time demands its resource, so it is kept for as long as the sprite casts the same spell
ZJSprite_Private_ActionCastingTimeCache = {} -- [sprite id] = { resref, speedFactor }

-- The casting time, (in tenths of a round), of the spell in the sprite's current spell action, after the sprite's
-- casting speed modifiers have been applied. Returns nil if the spell can't be determined.
function ZJSprite_Private_GetActionCastingTime(sprite)

	local curAction = sprite.m_curAction

	local resref = curAction.m_string1.m_pchData:get()
	if resref == nil or resref == "" then
		local spellID = curAction.m_specificID
		local prefix = ZJSprite_Private_SpellIDPrefixes[math.floor(spellID / 1000)]
		if prefix == nil then return nil end
		resref = string.format("%s%03d", prefix, spellID % 1000)
	end
	resref = resref:upper()

	local id = sprite.m_id
	local cache = ZJSprite_Private_ActionCastingTimeCache[id]

	if cache == nil or cache.resref ~= resref then

		cache = { ["resref"] = resref }
		ZJSprite_Private_ActionCastingTimeCache[id] = cache

		local spellHeader = EEex_Resource_Demand(resref, "SPL")
		if spellHeader ~= nil then
			local ability = spellHeader:getAbilityForLevel(sprite:getCasterLevelForSpell(resref, true))
			if ability ~= nil then
				cache.speedFactor = ability.speedFactor
			end
		end
	end

	if cache.speedFactor == nil then return nil end
	return math.max(0, cache.speedFactor - sprite:getActiveStats().m_nMentalSpeed)
end
CGameSprite.zjGetCastReleaseTimer = ZJSprite_GetCastReleaseTimer

-- ACTION.IDS values that wait for the sprite's spell cooldown before they start: the spell actions above,
-- (and their point variants), UseItem(), UseItemPoint()
ZJSprite_Private_CooldownActions = {
	[31]  = true,
	[34]  = true,
	[95]  = true,
	[97]  = true,
	[113] = true,
	[114] = true,
	[191] = true,
	[192] = true,
	[318] = true,
	[319] = true,
}

-- A creature's AI queues its next spell the moment the previous one is released, and that action then waits for the
-- previous spell's cooldown to run out. The cast timer and game time at the moment each spell / item action became
-- the sprite's action tell whether the cooldown it waits on has run out since.
ZJSprite_Private_CooldownActionStarts = {} -- [sprite id] = { actionID, castTimer, gameTime }

function ZJSprite_Private_GetGameTime()
	return EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
end

function ZJSprite_Private_OnSpriteStartedAction(sprite, action)
	local actionID = action.m_actionID
	if not ZJSprite_Private_CooldownActions[actionID] then
		ZJSprite_Private_CooldownActionStarts[sprite.m_id] = nil
		return
	end
	ZJSprite_Private_CooldownActionStarts[sprite.m_id] = {
		["actionID"]  = actionID,
		["castTimer"] = sprite:getCastTimer(),
		["gameTime"]  = ZJSprite_Private_GetGameTime(),
	}
end
EEex_Action_AddSpriteStartedActionListener(ZJSprite_Private_OnSpriteStartedAction)
EEex_GameState_AddDestroyedListener(function() ZJSprite_Private_CooldownActionStarts = {} end)

-- Returns false while the sprite's spell / item action is still waiting for the cooldown of an earlier spell, (the
-- round in which it is cast hasn't begun yet), true otherwise.
function ZJSprite_HasCastBegun(sprite)

	if not sprite then return false end

	local start = ZJSprite_Private_CooldownActionStarts[sprite.m_id]
	-- Not seen starting, (it was already running when the game was loaded): nothing to go on
	if start == nil or start.actionID ~= sprite.m_curAction.m_actionID then return true end

	local castTimer = sprite:getCastTimer()
	-- -1 = no cooldown running: the cast starts on the sprite's next update
	if castTimer < 0 then return false end
	-- There was no cooldown to wait for
	if start.castTimer < 0 then return true end
	-- The timer has been restarted, (it only counts up during a cooldown)
	if castTimer < start.castTimer then return true end
	-- A restarted timer can count past where the old cooldown was, but only after the whole old cooldown, (the rest
	-- of a round), and that much of the new cast have run: more than a round since the action started
	return ZJSprite_Private_GetGameTime() - start.gameTime >= 90
end
CGameSprite.zjHasCastBegun = ZJSprite_HasCastBegun

-- ACTION.IDS values that run the engine's attack round: Attack(), GroupAttack(),
-- AttackNoSound(), AttackOneRound(), AttackReevaluate()
ZJSprite_Private_AttackActions = {
	[3]   = true,
	[94]  = true,
	[98]  = true,
	[105] = true,
	[134] = true,
}

function ZJSprite_IsAttacking(sprite)
	if not sprite then return false end
	return ZJSprite_Private_AttackActions[sprite.m_curAction.m_actionID] == true
end
CGameSprite.zjIsAttacking = ZJSprite_IsAttacking

-- [0-100], the sprite's position in its current attack round
function ZJSprite_GetAttackTimer(sprite)
	if not sprite then return 0 end
	return sprite.m_attackFrame
end
CGameSprite.zjGetAttackTimer = ZJSprite_GetAttackTimer

-- [0-1]
function ZJSprite_GetAttackTimerPercentage(sprite)
	if not sprite then return 0 end
	return math.max(0, math.min(sprite:zjGetAttackTimer() / 100, 1))
end
CGameSprite.zjGetAttackTimerPercentage = ZJSprite_GetAttackTimerPercentage

-- [0-10], the row of the RNDBASE*-like .BMP the engine reads for the sprite
function ZJSprite_GetAttackSpeedFactor(sprite)
	if not sprite then return 0 end
	return math.max(0, math.min(sprite.m_speedFactor, 10))
end
CGameSprite.zjGetAttackSpeedFactor = ZJSprite_GetAttackSpeedFactor

-- [1-5], which RNDBASE*-like .BMP (combat_round_<n-1>) the sprite's attacks-per-round stat selects.
-- Stat values 6-10 are the half-attack values (1/2, 3/2, 5/2, 7/2, 9/2), which use the next table up.
--
-- NOTE: The stat already accounts for off-hand weapons and haste. (Haste runs the attack round at double
--       speed and adjusts the stat, e.g. 2 attacks => 3/2 attacks per half-length round).
function ZJSprite_GetCombatRoundTableIndex(sprite)
	if not sprite then return 1 end
	local numAttacks = sprite:getActiveStats().m_nNumberOfAttacks
	if numAttacks > 5 then numAttacks = numAttacks - 5 end
	return math.max(1, math.min(numAttacks, 5))
end
CGameSprite.zjGetCombatRoundTableIndex = ZJSprite_GetCombatRoundTableIndex

-- Returns the palette index the engine reads from the sprite's RNDBASE*-like .BMP for the given
-- table [1-5], speed factor [0-10], and attack frame [0-100].
--
-- NOTE: This asks the animation directly, so op342 (param2=5) combat round overrides are not seen.
function ZJSprite_GetAttackFrameType(sprite, tableIndex, speedFactor, frame)
	if not sprite then return 0 end
	local animation = sprite.m_animation.m_animation
	if not animation then return 0 end
	return animation:virtual_GetAttackFrameType(tableIndex, speedFactor, frame)
end
CGameSprite.zjGetAttackFrameType = ZJSprite_GetAttackFrameType

-- The palette index that marks an attack roll in the RNDBASE*.BMP files. A row of these files reads, (in hex):
--
--     ...0000A777779888888880000...
--
--   A-E => The start of attack #1-#5's swing
--   7   => The swing is in progress
--   9   => The attack roll is made
--   8/0 => Nothing is happening
--   6   => The start of a cosmetic swing, (no attack roll)
--
-- Change this if a mod's combat round tables use a different index for the attack roll.
ZJSprite_AttackRollFrameType = 9
ZJSprite_AttackSwingFrameType = 7

function ZJSprite_GetAttackRollFrameType(sprite, speedFactor)
	return ZJSprite_AttackRollFrameType
end
CGameSprite.zjGetAttackRollFrameType = ZJSprite_GetAttackRollFrameType

-- Returns an array of the attack frames [0-99] on which the sprite makes an attack roll during a round.
-- tableIndex and speedFactor default to the sprite's current values.
function ZJSprite_GetAttackRollFrames(sprite, tableIndex, speedFactor)

	local frames = {}
	if not sprite then return frames end

	tableIndex = tableIndex or sprite:zjGetCombatRoundTableIndex()
	speedFactor = speedFactor or sprite:zjGetAttackSpeedFactor()

	local rollType = sprite:zjGetAttackRollFrameType(speedFactor)
	if not rollType then return frames end

	for frame = 0, 99 do
		if sprite:zjGetAttackFrameType(tableIndex, speedFactor, frame) == rollType then
			table.insert(frames, frame)
		end
	end

	return frames
end
CGameSprite.zjGetAttackRollFrames = ZJSprite_GetAttackRollFrames

-- Returns the attack frame on which the swing that leads to the attack roll at rollFrame starts,
-- (the "A"-"E" pixel in front of the run of "swing in progress" pixels).
function ZJSprite_GetAttackSwingStartFrame(sprite, rollFrame, tableIndex, speedFactor)

	if not sprite then return rollFrame end

	tableIndex = tableIndex or sprite:zjGetCombatRoundTableIndex()
	speedFactor = speedFactor or sprite:zjGetAttackSpeedFactor()

	local frame = rollFrame
	while frame > 0 and sprite:zjGetAttackFrameType(tableIndex, speedFactor, frame - 1) == ZJSprite_AttackSwingFrameType do
		frame = frame - 1
	end

	return math.max(0, frame - 1)
end
CGameSprite.zjGetAttackSwingStartFrame = ZJSprite_GetAttackSwingStartFrame

-- Half attacks, (1/2, 3/2, 5/2, etc.): The last attack in the round's table is only real every other round;
-- in the other rounds the swing is cosmetic. The engine increments m_nHalfSwingCounter when that swing starts,
-- and makes the attack roll if the counter is now odd.
ZJSprite_HalfAttackRealParity = 1

function ZJSprite_HasHalfAttack(sprite)
	if not sprite then return false end
	return sprite:getActiveStats().m_nNumberOfAttacks > 5
end
CGameSprite.zjHasHalfAttack = ZJSprite_HasHalfAttack

-- Returns true if the sprite's half attack is / was real in the current round.
-- halfSwingStartFrame is the frame on which the half attack's swing starts, see ZJSprite_GetAttackSwingStartFrame().
function ZJSprite_IsHalfAttackRealThisRound(sprite, halfSwingStartFrame)
	if not sprite then return false end
	local counter = sprite.m_nHalfSwingCounter
	-- The counter hasn't been incremented yet this round
	if sprite.m_attackFrame < halfSwingStartFrame then counter = counter + 1 end
	return counter % 2 == ZJSprite_HalfAttackRealParity
end
CGameSprite.zjIsHalfAttackRealThisRound = ZJSprite_IsHalfAttackRealThisRound
