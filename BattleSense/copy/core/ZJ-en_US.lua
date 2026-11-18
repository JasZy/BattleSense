
-- Battle Sense - English strings. Translations go in ZJ-<language>.lua, (for example ZJ-de_DE.lua).

-----------
-- Timer --
-----------

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_TabTitle"] = "Battle Sense: Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_Enable"] = "Enabled"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_Enable_Description"] = [[
Shows the timers beside the party portraits: the casting timer, the attack round bar, the modal action and contingency timers, and the rings for active elemental resistances. Each can also be turned off on its own below.

-----------

This replaces Bubb's "Timer" module that comes with EEex. That module has to be turned off, (Modules tab), or both sets of timers are drawn on top of each other. Battle Sense turns it off by itself when the game starts, which takes effect from the next time the game is started.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_HugPortraits"] = "Hug Portraits"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_HugPortraits_Description"] = [[
Removes the gap between timer bars and their respective portrait.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowCastTimer"] = "Show Cast Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowCastTimer_Description"] = [[
Enables a cyan bar next to party member portraits.

This indicator displays the cooldown for using spells / items.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowCastMarker"] = "Show Cast Marker"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowCastMarker_Description"] = [[
Adds a white tick to the cast timer at the point where the spell being cast is released.

The tick is only shown while a party member is casting a spell.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowContingencyTimer"] = "Show Contingency Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowContingencyTimer_Description"] = [[
Enables a green bar next to party member portraits.

This indicator displays the interval at which contingency conditions are checked.

Note that some mods add contingency effects behind-the-scenes to implement certain behaviors - this may cause the contingency indicator to appear unexpectedly.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowModalTimer"] = "Show Modal Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowModalTimer_Description"] = [[
Enables a red bar next to party member portraits.

This indicator displays the interval of modal actions: find traps, turn undead, etc.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowAttackTimer"] = "Show Attack Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowAttackTimer_Description"] = [[
Enables an orange bar next to party member portraits.

This indicator displays how far a party member is through their attack round.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowAttackMarkers"] = "Show Attack Markers"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowAttackMarkers_Description"] = [[
Adds white ticks to the attack timer at the points in the round where attack rolls are made.

The ticks move with the character's weapon speed, which the engine decides at the start of every round. With a half attack, (3/2, 5/2, etc.), the last tick is only shown in the rounds where that attack is made.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowResistRings"] = "Show Resistance Rings"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowResistRings_Description"] = [[
Adds a ring beside the portrait for every element the character has resistance to, and for magic resistance. From top to bottom: fire, cold, electricity, acid, and magic, each displayed as its protection icon.

The green part of the ring, starting at the top and going clockwise, displays the resistance percentage. The ring is completely green at 100% or more, and isn't shown at 0%.
]]

----------------
-- Combat Log --
----------------

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_TabTitle"] = "Battle Sense: Combat Log"

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_Enable"] = "Enabled"

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_Enable_Description"] = [[
Adds lines to the combat log that explain what happened: effects ending, failed saving throws, why a spell did nothing, and why a weapon is ineffective. Each can also be turned off on its own below.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_ReportEffectEnds"] = "Report Effects Ending"

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_ReportEffectEnds_Description"] = [[
Reports spells and conditions ending on a creature.

"Imoen- Haste wore off" when its duration ran out, "Imoen- Stoneskin ended" when it ended early: dispelled, cured, used up, etc.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_ReportFailedSaves"] = "Report Failed Saves"

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_ReportFailedSaves_Description"] = [[
Reports a creature failing its saving throw against a spell, with the d20 roll it needed to save, e.g. "Gnoll- Failed save vs. Spell against Sleep (needed 12+)".
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_ReportImmunities"] = "Report Immunities"

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_ReportImmunities_Description"] = [[
Reports why a spell did nothing to a creature, and what protects it, e.g. "Skeleton- Unaffected by Sleep: immune to sleep".

To see the effects the engine throws away, this adds an invisible effect to every creature, which is saved with the game. Turning this off removes it again as creatures are seen.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_ReportIneffectiveWeapons"] = "Report Ineffective Weapons"

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_ReportIneffectiveWeapons_Description"] = [[
Reports why a weapon can't hurt a creature, e.g. "Minsc- Long Sword is ineffective against Werewolf: it requires a +1 weapon or better".
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_PartyOnly"] = "Party Only"

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_PartyOnly_Description"] = [[
Only reports what happens when the party, (or its summons / allies), is on one end of it.

Turned off, the log also reports what creatures do to each other, including creatures the party can't see.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_RepeatDelay"] = "Repeat Delay"

uiStrings["ZJBattleSense_Options_TRANSLATION_CombatLog_RepeatDelay_Description"] = [[
The number of seconds, (game time), before an identical immunity or ineffective weapon line may be printed again. Keeps area spells that hit every round, and attacks that keep failing, from flooding the log.

The lowest value is 1.
]]
