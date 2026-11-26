--[[
+--------------------------------------------------------------------------------------------------------------+
| ZJArea - The area a spell / item ability affects, read from its projectile, (shared by the modules)         |
+--------------------------------------------------------------------------------------------------------------+
|   An area is { range = radius in pixels, coneSize = degrees or nil, onCaster = boolean or nil }. The engine  |
|   measures distances in pixels, with the vertical axis stretched by 4/3.                                    |
+--------------------------------------------------------------------------------------------------------------+
--]]

-- The area a projectile affects where it lands, read once per projectile:
-- [missile type] = { range, coneSize } / false if it has no area
ZJArea_Private_ProjectileAreas = ZJArea_Private_ProjectileAreas or {}
ZJArea_Private_ProjectileIDS = ZJArea_Private_ProjectileIDS -- PROJECTL.IDS, loaded when first needed

-- Returns nil if the projectile can't be determined
function ZJArea_Private_ReadProjectileArea(missileType)

	-- 1 = no projectile
	if missileType <= 1 then return false end

	if ZJArea_Private_ProjectileIDS == nil then
		ZJArea_Private_ProjectileIDS = EEex_Resource_LoadIDS("PROJECTL")
	end

	-- A missile type is its PROJECTL.IDS value + 1, the symbol is the resref of the .PRO
	local resref = ZJArea_Private_ProjectileIDS:getStart(missileType - 1)
	if resref == nil then return nil end

	resref = resref:gsub("%s+", ""):upper()
	if resref == "" then return nil end

	local projectile = EEex_Resource_Demand(resref, "PRO")
	if projectile == nil then return nil end

	-- 3 = area of effect
	if projectile.m_wFileType ~= 3 then return false end

	return {
		["range"]    = projectile.m_explosionRange,
		-- Bit 11 = cone shaped, the cone starts at the caster
		["coneSize"] = EEex_IsBitSet(projectile.m_dwAreaFlags, 11) and projectile.m_coneSize or nil,
	}
end

-- The area of projectile `missileType`, (an ability's missile type), false if it has none, nil if unknown
function ZJArea_GetProjectileArea(missileType)
	local area = ZJArea_Private_ProjectileAreas[missileType]
	if area == nil then
		area = ZJArea_Private_ReadProjectileArea(missileType)
		ZJArea_Private_ProjectileAreas[missileType] = area
	end
	return area
end

function ZJArea_Private_ReadResref(address)
	local chars = {}
	for i = 0, 7 do
		local byte = EEex_ReadU8(address + i)
		if byte == 0 then break end
		chars[#chars + 1] = string.char(byte)
	end
	return table.concat(chars):upper()
end

-- A spell / item ability without an area of its own can cast a sub-spell that has one, (op146 "Cast spell", op148
-- "Cast spell at point"): Chant casts SPPR203D / SPPR203E on the priest, which affect everyone around the priest.
-- Returns the area of the first such sub-spell, with `onCaster` set if it is cast on the caster itself, false if there
-- is none, or nil if that can't be determined.
function ZJArea_Private_ReadSubSpellArea(headerAddress, abilityAddress)

	-- SPL and ITM files keep their effects offset at 0x6A, an ability its effect count at 0x1E and first effect at 0x20
	local effectsAddress = headerAddress + EEex_ReadU32(headerAddress + 0x6A)
	local count = EEex_ReadU16(abilityAddress + 0x1E)
	local first = EEex_ReadU16(abilityAddress + 0x20)
	local result = false

	for i = first, first + count - 1 do

		local effectAddress = effectsAddress + 0x30 * i
		local opcode = EEex_ReadU16(effectAddress)

		if opcode == 146 or opcode == 148 then

			local resref = ZJArea_Private_ReadResref(effectAddress + 0x14)
			local subHeader = resref ~= "" and EEex_Resource_Demand(resref, "SPL") or nil
			local subAbility = subHeader ~= nil and subHeader:getAbility(0) or nil

			if subAbility == nil then
				result = nil
			else
				local area = ZJArea_GetProjectileArea(subAbility.missileType)
				if area == nil then
					result = nil
				elseif area then
					return {
						["range"]    = area.range,
						["coneSize"] = area.coneSize,
						-- The effect's target, (0x02): 1 = the caster itself
						["onCaster"] = EEex_ReadU8(effectAddress + 0x2) == 1,
					}
				end
			end
		end
	end

	return result
end

-- Returns the area of the ability at `abilityAddress` of the SPL / ITM at `headerAddress`, whose missile type is
-- `missileType`, (0x26 in an SPL ability, 0x2A in an ITM one): its projectile's, or else the one of a sub-spell it
-- casts. False if it has none, nil if that can't be determined.
function ZJArea_ReadAbilityArea(headerAddress, abilityAddress, missileType)
	local area = ZJArea_GetProjectileArea(missileType)
	if area == false then
		area = ZJArea_Private_ReadSubSpellArea(headerAddress, abilityAddress)
	end
	return area
end

-- Whether `area` is a cone, (it starts at the caster and points where the ability is aimed)
function ZJArea_IsCone(area)
	local coneSize = area.coneSize
	return coneSize ~= nil and coneSize > 0 and coneSize < 360
end

-- The radius in pixels around `sprite` that its turn undead / find traps modal action covers. The engine,
-- (CGameSprite::CheckModal()), uses half of GetVisualRange(), (m_nVisualRange * 32 pixels), for both: 224 pixels for
-- a sight of 14. Turn undead also needs the undead to be in sight.
function ZJArea_GetModalRange(sprite)
	local ok, visualRange = pcall(function() return sprite:virtual_GetVisualRange() end)
	if not ok or type(visualRange) ~= "number" then
		visualRange = sprite:getActiveStats().m_nVisualRange * 32
	end
	return math.floor(visualRange / 2)
end
