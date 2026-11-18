
-- Battle Sense - English strings. Translations go in ZJ-<language>.lua, (for example ZJ-de_DE.lua).

-----------------
-- Attack Info --
-----------------

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_TabTitle"] = "Battle Sense: Attack Info"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_Enable"] = "Enabled"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_Enable_Description"] = [[
Enables the attack information popup.

The popup opens when hovering the attack cursor over a creature, (see "Open With Attack Cursor"), or when holding the open keybind, (by default 'Left Ctrl'), or the alternate open keybind, (by default 'Left Alt'), over any creature.

It has two panels, with a row for each selected party member:

- Left: what the creature can do to them. The roll it needs to hit each of them, its damage below its name, and timer bars for its attack round, spell casting, contingencies and modal action.

- Right: what they can do to the creature. The roll each of them needs to hit it, the damage of a hit with the creature's resistance to it, any extra on-hit damage, and whether the creature is immune to their weapon.

The right panel's header also lists the creature's stoneskins and mirror images, and the spells affecting it.

-----------

This replaces Bubb's "Attack Info" module that comes with EEex. That module has to be turned off, (Modules tab), or both popups are drawn on top of each other. Battle Sense turns it off by itself when the game starts, which takes effect from the next time the game is started.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_FontPoint"] = "Font Point"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_FontPoint_Description"] = [[
The point (size) of the font used to display the attack information.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_HitDisplayType"] = "Hit Display Type"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_HitDisplayType_Description"] = [[
How the popup displays an attacker's odds of hitting.

'Roll' - The minimum d20 roll needed to land the attack, e.g. "14+". A dash means no roll can hit.

'Percentage' - The chance to hit as a percentage, e.g. "35%".
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_HitDisplayType_Roll"] = "Roll"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_HitDisplayType_Percentage"] = "Percentage"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ImmunityDisplayType"] = "Immunity Display Type"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ImmunityDisplayType_Description"] = [[
The method used to display target immunities in the popup.

'Color' - Show the hit roll and damage in red for entries where the target is immune to the attacker, with "Immune" behind the damage.

'None' - Do not display immunity data.

'Text' - Replace the hit roll and damage for entries where the target is immune to the attacker.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ImmunityDisplayType_Color"] = "Color"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ImmunityDisplayType_None"] = "None"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ImmunityDisplayType_Text"] = "Text"


uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_OpenKeybind"] = "Open Keybind"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_OpenKeybind_Description"] = [[
This keybind opens the attack information popup.

The popup has two panels: the left one shows the attacks of the creature under the cursor, the right one shows the attacks on that creature.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_OpenWithAttackCursor"] = "Open With Attack Cursor"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_OpenWithAttackCursor_Description"] = [[
Determines whether the attack information popup automatically opens when an attack cursor is hovered over a creature.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ReverseKeybind"] = "Alternate Open Keybind"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ReverseKeybind_Description"] = [[
A second keybind that opens the attack information popup, exactly like "Open Keybind".
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowColumnHeaders"] = "Show Column Headers"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowColumnHeaders_Description"] = [[
Determines whether the first line of the popup's information list is used to display column headers.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_HideUnusedOffhandHeader"] = "Hide Unused Offhand Header"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_HideUnusedOffhandHeader_Description"] = [[
Determines whether a panel's offhand column header is hidden when that panel has zero entries to display in that column.
]]

-----------
-- Timer --
-----------

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowTargetAttackTimer"] = "Show Target Attack Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowTargetAttackTimer_Description"] = [[
Adds an orange bar to the left panel while the creature under the cursor is attacking.

This indicator displays how far the creature is through its attack round. The white ticks mark the points in the round where it makes its attack rolls.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowTargetCastTimer"] = "Show Target Cast Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowTargetCastTimer_Description"] = [[
Adds a cyan bar to the left panel while the creature under the cursor is casting a spell or is waiting to be able to use spells / items again.

This indicator displays the creature's cooldown for using spells / items. While a spell is being cast, a white tick marks the point where it is released.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowTargetContingencyTimer"] = "Show Target Contingency Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowTargetContingencyTimer_Description"] = [[
Adds a green bar to the left panel while the creature under the cursor has contingency effects.

This indicator displays the interval at which the creature's contingency conditions are checked.

Note that some mods add contingency effects behind-the-scenes to implement certain behaviors - this may cause the contingency indicator to appear unexpectedly.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowTargetModalTimer"] = "Show Target Modal Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowTargetModalTimer_Description"] = [[
Adds a red bar to the left panel while the creature under the cursor is using a modal action.

This indicator displays the interval of the creature's modal action: bard song, turn undead, etc.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowRowTimers"] = "Show Row Timers"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowRowTimers_Description"] = [[
Adds timer bars below the names in the right panel, for every listed creature that is attacking the creature under the cursor.

The orange bar is displayed while the creature is attacking, and shows how far it is through its attack round. The white ticks mark its attack rolls.

The cyan bar is displayed while the creature is casting a spell or is waiting to be able to use spells / items again. While a spell is being cast, a white tick marks the point where it is released.
]]

-----------------
-- Attack Info --
-----------------

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_CompactForAllies"] = "Compact Popup For Allies"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_CompactForAllies_Description"] = [[
Uses a compact popup for party members and the party's summons / allies.

The compact popup lists the creatures that the creature under the cursor is attacking or is being attacked by, with the roll the creature needs to hit them and the damage it does in the left panel, and their rolls and damage against the creature in the right panel.

A creature is on the same row in both panels. If it is only attacking, or only being attacked, its row in the other panel is left empty.

The compact popup only opens while the open or alternate open keybind is held.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowSpellEffects"] = "Show Spell Effects"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowSpellEffects_Description"] = [[
Lists the spells affecting the creature under the cursor in the right panel's header, one per line. A spell with a set duration shows the time it has left in turns and rounds, e.g. "Haste (1,5)".

These are the spells EEex's Effect Menu module shows: spells from items, permanent spells and spells without an icon are left out. A sub-spell without a name of its own, like the one Chant casts on every creature around, is listed under its parent spell's name.
]]

uiStrings["ZJBattleSense_TRANSLATION_AttackInfo_Immune"] = "Immune"

uiStrings["ZJBattleSense_TRANSLATION_AttackInfo_Mainhand"] = "Main"

uiStrings["ZJBattleSense_TRANSLATION_AttackInfo_Offhand"] = "Offhand"

uiStrings["ZJBattleSense_TRANSLATION_AttackInfo_Stoneskins"] = "Stoneskins"

uiStrings["ZJBattleSense_TRANSLATION_AttackInfo_MirrorImages"] = "Mirror images"

uiStrings["ZJBattleSense_TRANSLATION_AttackInfo_Poison"] = "poison"

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
