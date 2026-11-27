
-- The bar colors, (shared with Creature Info)
Infinity_DoFile("ZJBarCol")

-------------
-- Options --
-------------

EEex_Options_Register("ZJTimer_Enable", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Timer" }),
	["onChange"] = function(self, oldValue) ZJTimer_SetEnabled(self:get() ~= 0) end,
}))

ZJTimer_Private_HugPortraits =EEex_Options_Register("ZJTimer_HugPortraits", EEex_Options_Option.new({
	["default"]  = 0,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Timer Module: Hug Portraits" }),
}))

ZJTimer_Private_ShowCastMarker = EEex_Options_Register("ZJTimer_ShowCastMarker", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Timer Module: Show Cast Marker" }),
}))

ZJTimer_Private_ShowAttackMarkers = EEex_Options_Register("ZJTimer_ShowAttackMarkers", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Timer Module: Show Attack Markers" }),
}))

ZJTimer_Private_ShowResistRings = EEex_Options_Register("ZJTimer_ShowResistRings", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Battle Sense", ["key"] = "Timer Module: Show Resist Rings" }),
}))

-- The colors of a resistance ring, (one of the bar colors): the resisted part, and the rest
ZJTimer_Private_ResistedColor   = ZJBarColors_RegisterColorOption("ZJTimer_ResistedColor",   "Timer Module: Resisted Color",   4) -- Green
ZJTimer_Private_UnresistedColor = ZJBarColors_RegisterColorOption("ZJTimer_UnresistedColor", "Timer Module: Unresisted Color", 1) -- Red

EEex_Options_AddTab("ZJBattleSense_Options_TRANSLATION_Timer_TabTitle", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJTimer_HugPortraits",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_Timer_HugPortraits",
			["description"] = "ZJBattleSense_Options_TRANSLATION_Timer_HugPortraits_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		ZJBarColors_DisplayEntry("Cast",
			"ZJBattleSense_Options_TRANSLATION_Timer_CastBar",
			"ZJBattleSense_Options_TRANSLATION_Timer_CastBar_Description"),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJTimer_ShowCastMarker",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_Timer_ShowCastMarker",
			["description"] = "ZJBattleSense_Options_TRANSLATION_Timer_ShowCastMarker_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		ZJBarColors_DisplayEntry("Contingency",
			"ZJBattleSense_Options_TRANSLATION_Timer_ContingencyBar",
			"ZJBattleSense_Options_TRANSLATION_Timer_ContingencyBar_Description"),
		ZJBarColors_DisplayEntry("Modal",
			"ZJBattleSense_Options_TRANSLATION_Timer_ModalBar",
			"ZJBattleSense_Options_TRANSLATION_Timer_ModalBar_Description"),
		ZJBarColors_DisplayEntry("Attack",
			"ZJBattleSense_Options_TRANSLATION_Timer_AttackBar",
			"ZJBattleSense_Options_TRANSLATION_Timer_AttackBar_Description"),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJTimer_ShowAttackMarkers",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_Timer_ShowAttackMarkers",
			["description"] = "ZJBattleSense_Options_TRANSLATION_Timer_ShowAttackMarkers_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJTimer_ShowResistRings",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_Timer_ShowResistRings",
			["description"] = "ZJBattleSense_Options_TRANSLATION_Timer_ShowResistRings_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJTimer_ResistedColor",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_Timer_ResistedColor",
			["description"] = "ZJBattleSense_Options_TRANSLATION_Timer_ResistedColor_Description",
			["widget"]      = ZJBarColors_ColorWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "ZJTimer_UnresistedColor",
			["label"]       = "ZJBattleSense_Options_TRANSLATION_Timer_UnresistedColor",
			["description"] = "ZJBattleSense_Options_TRANSLATION_Timer_UnresistedColor_Description",
			["widget"]      = ZJBarColors_ColorWidget.new(),
		}),
	},
} end)

-----------------------
-- Template Handling --
-----------------------

ZJTimer_Private_TemplateInstances = {}

function ZJTimer_Private_CreateInstance(menuName, templateName, x, y, w, h)

	local menuEntry = ZJTimer_Private_TemplateInstances[menuName]
	if not menuEntry then
		menuEntry = {}
		ZJTimer_Private_TemplateInstances[menuName] = menuEntry
	end

	local entry = menuEntry[templateName]
	if not entry then
		entry = {["maxID"] = 0, ["instanceData"] = {}}
		menuEntry[templateName] = entry
	end

	local newID = entry.maxID + 1
	entry.maxID = newID

	local instanceEntry = {["id"] = newID}
	entry.instanceData[newID] = instanceEntry

	local oldAnimationID = currentAnimationID
	currentAnimationID = newID
	EEex_Menu_InjectTemplate(menuName, templateName, x, y, w, h)
	currentAnimationID = oldAnimationID

	return instanceEntry
end

ZJTimer_Private_TemplateInstancesByPortrait = {}

-- Gives `entry` the portrait it belongs to, and lists it under `name` for that portrait
function ZJTimer_Private_AddToPortrait(entry, name, portraitItem)
	entry.portraitItem = portraitItem
	entry.portraitEnabledFunc = EEex_Menu_GetItemFunction(portraitItem.reference_enabled)
	entry.portraitIndex = EEex_Menu_GetItemVariant(portraitItem.button.portrait)
	entry.enabled = false
	local portraitEntry = EEex_Utility_GetOrCreate(ZJTimer_Private_TemplateInstancesByPortrait, entry.portraitIndex, {})
	local entries = EEex_Utility_GetOrCreate(portraitEntry, name, {})
	table.insert(entries, entry)
end

function ZJTimer_Private_CreateInstanceForPortrait(menuName, templateName, x, y, w, h, portraitItem)
	local instanceEntry = ZJTimer_Private_CreateInstance(menuName, templateName, x, y, w, h)
	ZJTimer_Private_AddToPortrait(instanceEntry, templateName, portraitItem)
	return instanceEntry
end

-- One instance per color of the templates `baseName`..1 - 8, (one per bar color, see ZJTimer.menu), each enabled when
-- the ring they show is shown in that color: returns { [color] = instance entry }
function ZJTimer_Private_CreateColorInstances(menuName, baseName, w, h)
	local colorEntries = {}
	for color = 1, #ZJBarColors_Colors do
		local instanceEntry = ZJTimer_Private_CreateInstance(menuName, baseName..color, nil, nil, w, h)
		instanceEntry.enabled = false
		colorEntries[color] = instanceEntry
	end
	return colorEntries
end

-- Finds the menu item of every instance, so ZJTimer_Private_SetInstanceArea() doesn't have to look for it
function ZJTimer_Private_FindInstanceItems(menuName)
	local menuEntry = ZJTimer_Private_TemplateInstances[menuName]
	local menu = EEex_Menu_Find(menuName)
	if menuEntry == nil or menu == nil then return end
	local item = menu.items
	while item do
		local templateEntry = menuEntry[item.templateName:get()]
		local instanceEntry = templateEntry and templateEntry.instanceData[item.instanceId]
		if instanceEntry then
			instanceEntry.lightItem = EEex_UDToLightUD(item)
		end
		item = item.next
	end
end

-- Moves an instance of `templateName`, only when it has to: EEex_Menu_SetTemplateArea() walks the whole menu, and
-- with a template per color the menu has hundreds of instances. `w` / `h` nil keep the instance's own.
function ZJTimer_Private_SetInstanceArea(templateName, instanceEntry, x, y, w, h)
	if instanceEntry.x == x and instanceEntry.y == y and instanceEntry.w == w and instanceEntry.h == h then return end
	instanceEntry.x, instanceEntry.y, instanceEntry.w, instanceEntry.h = x, y, w, h
	if instanceEntry.lightItem then
		nameToItem["ZJTimer_Private_StoredInstance"] = instanceEntry.lightItem
		Infinity_SetArea("ZJTimer_Private_StoredInstance", x, y, w, h)
	else
		EEex_Menu_SetTemplateArea(ZJTimer_Private_InjectingMenu, templateName, instanceEntry.id, x, y, w, h)
	end
end

---------------
-- Listeners --
---------------

ZJTimer_Private_InjectingMenu = "RIGHT_SIDEBAR"

EEex_Menu_AddMainFileLoadedListener(function()
	EEex_Menu_LoadFile("ZJTimer")
	local item = EEex_Menu_Find(ZJTimer_Private_InjectingMenu).items
	while item do
		local portrait = item.button.portrait
		if portrait then
			local area = item.area
			local backgroundEntry = ZJTimer_Private_CreateInstanceForPortrait(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_Background", nil, nil, 10, nil, item)

			-- One resistance ring per resistance, each with a fixed slot beside the portrait: the element's icon, and the
			-- ring around it in the "not resisted" color with the resisted part on top, (injected in that order, so
			-- they are drawn in that order)
			local size = ZJTimer_Private_ResistRingSize
			backgroundEntry.resistRings = {}
			for i = 1, #ZJTimer_Private_ResistRingStats do
				local ringEntry = ZJTimer_Private_CreateInstance(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_ResistIcon", nil, nil, size, size)
				ringEntry.enabled = false
				ringEntry.frame = i - 1 -- The element's icon in ZJCREELM.BAM
				ringEntry.unresisted = ZJTimer_Private_CreateColorInstances(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_ResistUnresisted", size, size)
				ringEntry.resisted = ZJTimer_Private_CreateColorInstances(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_ResistResisted", size, size)
				backgroundEntry.resistRings[i] = ringEntry
			end

			ZJTimer_Private_CreateInstanceForPortrait(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_TimerModal",       nil, nil, 2, nil, item)
			ZJTimer_Private_CreateInstanceForPortrait(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_TimerContingency", nil, nil, 2, nil, item)

			-- Markers are injected after their bar so that they render on top of it
			local castEntry = ZJTimer_Private_CreateInstanceForPortrait(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_TimerCast", nil, nil, 2, nil, item)
			castEntry.marker = ZJTimer_Private_CreateInstance(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_CastMarker", nil, nil, 2, ZJTimer_Private_MarkerHeight)
			castEntry.marker.enabled = false

			local attackEntry = ZJTimer_Private_CreateInstanceForPortrait(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_TimerAttack", nil, nil, 2, nil, item)
			attackEntry.markers = {}
			attackEntry.rollFramesCache = {}
			for i = 1, ZJTimer_Private_MaxAttackMarkers do
				local markerEntry = ZJTimer_Private_CreateInstance(ZJTimer_Private_InjectingMenu, "ZJTimer_Menu_TEMPLATE_AttackMarker", nil, nil, 2, ZJTimer_Private_MarkerHeight)
				markerEntry.enabled = false
				attackEntry.markers[i] = markerEntry
			end
		end
		item = item.next
	end
	ZJTimer_Private_FindInstanceItems(ZJTimer_Private_InjectingMenu)
end)

function ZJTimer_Private_PushMenuListener()
	Infinity_PushMenu("ZJTimer_Menu")
end
EEex_GameState_AddInitializedListener(ZJTimer_Private_PushMenuListener)
EEex_Menu_AddAfterMainFileReloadedListener(ZJTimer_Private_PushMenuListener)

-------------
-- Markers --
-------------

ZJTimer_Private_MaxAttackMarkers = 5
ZJTimer_Private_MarkerHeight = 2
ZJTimer_Private_AttackRollFramesLifetime = 2000 -- Milliseconds

-- Moves a marker onto its bar, at the point the bar reaches when it is value / maxValue full
function ZJTimer_Private_PlaceMarker(templateName, markerEntry, barEntry, value, maxValue)

	local portraitArea = barEntry.portraitItem.area
	local barX = barEntry.barX
	local barY = portraitArea.y
	local barW = barEntry.barW or 2
	local barH = portraitArea.h
	local markerH = ZJTimer_Private_MarkerHeight

	-- The bar fills from the bottom of the portrait to the top
	local y = barY + barH - math.floor(barH * value / maxValue + 0.5) - math.floor(markerH / 2)
	y = math.max(barY, math.min(y, barY + barH - markerH))

	ZJTimer_Private_SetInstanceArea(templateName, markerEntry, barX, y, barW, markerH)
	markerEntry.enabled = true
end

-- Shows where on the cast bar the spell that is being cast will be released
function ZJTimer_Private_UpdateCastMarker(sprite, castEntry)

	local releaseTimer = nil
	if castEntry.enabled and ZJTimer_Private_ShowCastMarker:get() == 1 then
		releaseTimer = sprite:zjGetCastReleaseTimer()
	end

	if releaseTimer then
		-- The cast bar is (cast timer + 1) / 100 full, see EEex_Sprite_GetCastTimerPercentage()
		ZJTimer_Private_PlaceMarker("ZJTimer_Menu_TEMPLATE_CastMarker", castEntry.marker, castEntry, releaseTimer + 1, 100)
	else
		castEntry.marker.enabled = false
	end
end

-- The attack roll frames only change when the sprite's attacks per round / weapon speed / animation changes.
-- Reading them takes a hundred engine calls, so the result is kept per portrait and refreshed periodically.
function ZJTimer_Private_GetAttackRollFrames(sprite, cache, curTick)

	local id = sprite.m_id
	local tableIndex = sprite:zjGetCombatRoundTableIndex()
	local speedFactor = sprite:zjGetAttackSpeedFactor()

	if cache.frames == nil
		or cache.id ~= id
		or cache.tableIndex ~= tableIndex
		or cache.speedFactor ~= speedFactor
		or curTick >= cache.expireTick
	then
		cache.id = id
		cache.tableIndex = tableIndex
		cache.speedFactor = speedFactor
		cache.expireTick = curTick + ZJTimer_Private_AttackRollFramesLifetime
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

	return cache.frames
end

function ZJTimer_Private_DisableAttackMarkers(attackEntry)
	for _, markerEntry in ipairs(attackEntry.markers) do
		markerEntry.enabled = false
	end
end

function ZJTimer_Private_UpdateAttackMarkers(sprite, attackEntry, curTick)

	if not attackEntry.enabled or ZJTimer_Private_ShowAttackMarkers:get() ~= 1 then
		ZJTimer_Private_DisableAttackMarkers(attackEntry)
		return
	end

	local cache = attackEntry.rollFramesCache
	local frames = ZJTimer_Private_GetAttackRollFrames(sprite, cache, curTick)

	-- Don't show the half attack's marker during the rounds where its swing is cosmetic
	local hiddenIndex = nil
	if cache.halfIndex and not sprite:zjIsHalfAttackRealThisRound(cache.halfSwingStartFrame) then
		hiddenIndex = cache.halfIndex
	end

	for i, markerEntry in ipairs(attackEntry.markers) do

		local frame = frames[i]
		if frame and i ~= hiddenIndex then
			-- The attack bar is empty at frame 0 and full at frame 100
			ZJTimer_Private_PlaceMarker("ZJTimer_Menu_TEMPLATE_AttackMarker", markerEntry, attackEntry, frame, 100)
		else
			markerEntry.enabled = false
		end
	end
end

----------------------
-- Resistance Rings --
----------------------

-- Derived stats field read for each ring, the index - 1 is the frame of the element's icon in ZJCREELM.BAM
ZJTimer_Private_ResistRingStats = { "m_nResistFire", "m_nResistCold", "m_nResistElectricity", "m_nResistAcid", "m_nResistMagic" }
ZJTimer_Private_ResistRingSize = 13 -- Same as the portrait icons in STATES.BAM, which the rings are made from
ZJTimer_Private_ResistRingGap = 2
ZJTimer_Private_ResistRingMaxFrame = 60 -- ZJTRRING.BAM frame N has N/60 of the ring, clockwise from the top

-- Hides a ring, (its icon and every color of it)
function ZJTimer_Private_DisableResistRing(ringEntry)
	ringEntry.enabled = false
	for color = 1, #ZJBarColors_Colors do
		ringEntry.unresisted[color].enabled = false
		ringEntry.resisted[color].enabled = false
	end
end

function ZJTimer_Private_DisableResistRings(backgroundEntry)
	for _, ringEntry in ipairs(backgroundEntry.resistRings) do
		ZJTimer_Private_DisableResistRing(ringEntry)
	end
end

-- Shows a ring for every resistance, (the elements and magic), the sprite has. The ring is fully in the "resisted"
-- color at 100% or more and isn't shown at 0% or less. `stripLeftX` is the left edge of the timer bars beside the
-- portrait.
function ZJTimer_Private_UpdateResistRings(sprite, backgroundEntry, stripLeftX)

	local portraitEnabledFunc = backgroundEntry.portraitEnabledFunc
	if ZJTimer_Private_ShowResistRings:get() ~= 1 or (portraitEnabledFunc and not portraitEnabledFunc()) then
		ZJTimer_Private_DisableResistRings(backgroundEntry)
		return
	end

	local size = ZJTimer_Private_ResistRingSize
	local maxFrame = ZJTimer_Private_ResistRingMaxFrame
	local stats = sprite:getActiveStats()
	local x = stripLeftX - 1 - size
	local portraitY = backgroundEntry.portraitItem.area.y

	local resistedColor = ZJTimer_Private_ResistedColor:get()
	local unresistedColor = ZJTimer_Private_UnresistedColor:get()

	for i, ringEntry in ipairs(backgroundEntry.resistRings) do

		local percentage = stats[ZJTimer_Private_ResistRingStats[i]]

		if percentage > 0 then

			local frame = maxFrame
			if percentage < 100 then
				-- A partial resistance never rounds to a completely unresisted or completely resisted ring
				frame = math.max(1, math.min(math.floor(maxFrame * percentage / 100 + 0.5), maxFrame - 1))
			end

			local y = portraitY + (i - 1) * (size + ZJTimer_Private_ResistRingGap)
			ZJTimer_Private_SetInstanceArea("ZJTimer_Menu_TEMPLATE_ResistIcon", ringEntry, x, y, size, size)
			ringEntry.enabled = true

			-- The whole ring in the "not resisted" color, (not needed when the resisted part covers it), and the
			-- resisted part on top of it
			for color = 1, #ZJBarColors_Colors do
				local unresistedEntry = ringEntry.unresisted[color]
				unresistedEntry.enabled = color == unresistedColor and frame < maxFrame
				if unresistedEntry.enabled then
					ZJTimer_Private_SetInstanceArea("ZJTimer_Menu_TEMPLATE_ResistUnresisted"..color, unresistedEntry, x, y, size, size)
				end

				local resistedEntry = ringEntry.resisted[color]
				resistedEntry.enabled = color == resistedColor
				if resistedEntry.enabled then
					resistedEntry.frame = frame
					ZJTimer_Private_SetInstanceArea("ZJTimer_Menu_TEMPLATE_ResistResisted"..color, resistedEntry, x, y, size, size)
				end
			end
		else
			ZJTimer_Private_DisableResistRing(ringEntry)
		end
	end
end

--------------------
-- Menu Functions --
--------------------

ZJTimer_Private_NextUpdateTick = -1

-- Set by the "ZJTimer_Enable" option, (the "Battle Sense Modules" tab), once the file has loaded. While it is off, every bar, marker and ring is hidden,
-- (see the TEMPLATE functions below), and the tick does nothing.
ZJTimer_Private_Enabled = false

-- @bubb_doc { ZJTimer_SetEnabled }
-- @summary: Temporarily shows / hides the timers. To persist this, change the ``ZJTimer_Enable`` option instead.
function ZJTimer_SetEnabled(enabled)
	ZJTimer_Private_Enabled = enabled
end

function ZJTimer_Private_Menu_Tick()

	if not ZJTimer_Private_Enabled then return end

	-- Game lags when this function is spammed, limit to 30tps.
	local curTick = Infinity_GetClockTicks()
	if curTick < ZJTimer_Private_NextUpdateTick then
		return
	end
	ZJTimer_Private_NextUpdateTick = curTick + 33

	for portraitIndex = 0, 5, 1 do

		local portraitEntry = ZJTimer_Private_TemplateInstancesByPortrait[portraitIndex]
		local sprite = EEex_Sprite_GetInPortrait(portraitIndex)

		if sprite then

			local portraitInstanceStartX = {}
			local portraitInstanceCurX = {}

			-- A bar is a fill in its color, (ZJTimer.menu), from the bottom of the portrait up to how full it is:
			-- `getPercentage(sprite)`, 0 - 1
			local updateTimerBar = function(templateName, condition, getPercentage)

				for i, bar in ipairs(portraitEntry[templateName]) do

					local portraitArea = bar.portraitItem.area

					local curX = portraitInstanceCurX[i]
					if not curX then
						local startX = (ZJTimer_Private_HugPortraits:get() == 1 and portraitArea.x or 0) - 3

						--Infinity UI++ modern hud compatibility
						if RgUISkin and RgIsModernHud == 1 then
							startX = portraitArea.x + portraitArea.w
						end

						curX = startX
						portraitInstanceStartX[i] = startX
						portraitInstanceCurX[i] = curX
					end

					local portraitEnabledFunc = bar.portraitEnabledFunc
					if (not portraitEnabledFunc or portraitEnabledFunc()) and condition then

						--Infinity UI++ modern hud compatibility
						local rgDif = 3
						local rgWidth = nil
						if RgUISkin and RgIsModernHud == 1 then
							rgDif = 2
							rgWidth = 1
						end

						bar.enabled = true
						bar.barX = curX
						bar.barW = rgWidth
						portraitInstanceCurX[i] = curX - rgDif
						local fillH = math.floor(portraitArea.h * math.max(0, math.min(getPercentage(sprite), 1)) + 0.5)
						ZJTimer_Private_SetInstanceArea(templateName, bar, curX, portraitArea.y + portraitArea.h - fillH, rgWidth, fillH)
					else
						bar.enabled = false
					end
				end
			end

			updateTimerBar( "ZJTimer_Menu_TEMPLATE_TimerCast",        ZJBarColors_IsShown("Cast")        and sprite:getCastTimerPercentage() > 0,                     EEex_Sprite_GetCastTimerPercentage        )
			updateTimerBar( "ZJTimer_Menu_TEMPLATE_TimerContingency", ZJBarColors_IsShown("Contingency") and sprite:getActiveStats().m_cContingencyList.m_nCount > 0, EEex_Sprite_GetContingencyTimerPercentage )
			updateTimerBar( "ZJTimer_Menu_TEMPLATE_TimerModal",       ZJBarColors_IsShown("Modal")       and sprite:getModalState() ~= 0,                             EEex_Sprite_GetModalTimerPercentage       )
			updateTimerBar( "ZJTimer_Menu_TEMPLATE_TimerAttack",      ZJBarColors_IsShown("Attack")      and sprite:zjIsAttacking(),                                  ZJSprite_GetAttackTimerPercentage         )

			for _, castEntry in ipairs(portraitEntry["ZJTimer_Menu_TEMPLATE_TimerCast"]) do
				ZJTimer_Private_UpdateCastMarker(sprite, castEntry)
			end

			for _, attackEntry in ipairs(portraitEntry["ZJTimer_Menu_TEMPLATE_TimerAttack"]) do
				ZJTimer_Private_UpdateAttackMarkers(sprite, attackEntry, curTick)
			end

			for i, backgroundEntry in ipairs(portraitEntry["ZJTimer_Menu_TEMPLATE_Background"]) do
				local startX = portraitInstanceStartX[i]
				local curX = portraitInstanceCurX[i]
				if curX ~= startX then
					backgroundEntry.enabled = true
					local portraitArea = backgroundEntry.portraitItem.area

					--Infinity UI++ modern hud compatibility
					local rgDif = 1
					if RgUISkin and RgIsModernHud == 1 then
						rgDif = 0
					end

					ZJTimer_Private_SetInstanceArea("ZJTimer_Menu_TEMPLATE_Background", backgroundEntry, curX + 2, portraitArea.y, startX - curX + rgDif, portraitArea.h)
				else
					backgroundEntry.enabled = false
				end

				-- The rings sit to the left of the timer bars, or in their place if there are none
				ZJTimer_Private_UpdateResistRings(sprite, backgroundEntry, curX + 2)
			end
		else
			for _, backgroundEntry in ipairs(portraitEntry["ZJTimer_Menu_TEMPLATE_Background"]) do
				backgroundEntry.enabled = false
			end
			for _, templateName in ipairs({
				"ZJTimer_Menu_TEMPLATE_TimerModal",
				"ZJTimer_Menu_TEMPLATE_TimerContingency",
				"ZJTimer_Menu_TEMPLATE_TimerCast",
				"ZJTimer_Menu_TEMPLATE_TimerAttack"
			})
			do
				for _, bar in ipairs(portraitEntry[templateName]) do
					bar.enabled = false
				end
			end
			for _, castEntry in ipairs(portraitEntry["ZJTimer_Menu_TEMPLATE_TimerCast"]) do
				castEntry.marker.enabled = false
			end
			for _, attackEntry in ipairs(portraitEntry["ZJTimer_Menu_TEMPLATE_TimerAttack"]) do
				ZJTimer_Private_DisableAttackMarkers(attackEntry)
			end
			for _, backgroundEntry in ipairs(portraitEntry["ZJTimer_Menu_TEMPLATE_Background"]) do
				ZJTimer_Private_DisableResistRings(backgroundEntry)
			end
		end
	end
end

-- The instance of `templateName` that is being drawn, (the engine sets `instanceId`)
function ZJTimer_Private_Menu_TEMPLATE_Instance(templateName)
	return ZJTimer_Private_TemplateInstances[ZJTimer_Private_InjectingMenu][templateName].instanceData[instanceId]
end

-- For the bars, and the ring's icon and its templates per color
function ZJTimer_Private_Menu_TEMPLATE_Enabled(templateName)
	return ZJTimer_Private_Enabled and ZJTimer_Private_Menu_TEMPLATE_Instance(templateName).enabled
end

function ZJTimer_Private_Menu_TEMPLATE_Frame(templateName)
	return ZJTimer_Private_Menu_TEMPLATE_Instance(templateName).frame
end

function ZJTimer_Private_Menu_TEMPLATE_Background_Enabled()
	return ZJTimer_Private_Enabled and ZJTimer_Private_Menu_TEMPLATE_Instance("ZJTimer_Menu_TEMPLATE_Background").enabled
end

function ZJTimer_Private_Menu_TEMPLATE_CastMarker_Enabled()
	return ZJTimer_Private_Enabled and ZJTimer_Private_Menu_TEMPLATE_Instance("ZJTimer_Menu_TEMPLATE_CastMarker").enabled
end

function ZJTimer_Private_Menu_TEMPLATE_AttackMarker_Enabled()
	return ZJTimer_Private_Enabled and ZJTimer_Private_TemplateInstances[ZJTimer_Private_InjectingMenu]["ZJTimer_Menu_TEMPLATE_AttackMarker"].instanceData[instanceId].enabled
end
