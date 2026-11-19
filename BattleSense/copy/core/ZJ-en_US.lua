
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

---------------
-- Item Info --
---------------

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_TabTitle"] = "Battle Sense: Item Info"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_Enable"] = "Enabled"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_Enable_Description"] = [[
Enables the item popup.

The item popup opens when hovering the cursor over an item in a store, or in the quick loot bar, and displays the properties of that item.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_FontPoint"] = "Font Point"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_FontPoint_Description"] = [[
The size of the text in the item popup.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowFullDescription"] = "Show Full Description"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowFullDescription_Description"] = [[
Displays the whole description of the item, instead of only the part that lists its properties, (below "STATISTICS:").
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowComparison"] = "Show Stat Changes"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowComparison_Description"] = [[
Displays how the stats of the selected character would change if they equipped the item, in place of what they have equipped now.

In a store this is the character whose portrait is selected, otherwise it is the first selected character.

The changes are what the items say they do while equipped. Not taken into account: bonuses that don't stack, and what a changed ability score does to other stats.

If the character can't use the item, the popup says so instead.

An item that isn't identified has no stat changes listed.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowWeaponStats"] = "Include Weapon Stats"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowWeaponStats_Description"] = [[
For a weapon, also lists how its damage, THAC0 bonus, speed factor and the character's proficiency points compare with the weapon in hand. The damage, THAC0 bonus and speed factor include what the character's proficiency in the weapon adds, (or the penalty for not being proficient), and what its weapon style adds, (two-handed, sword and shield, single weapon or two weapons). When the style changes, the armor class includes the style's armor class bonus.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInStores"] = "Show In Stores"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInStores_Description"] = [[
Opens the popup when hovering an item in a store's lists.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInQuickLoot"] = "Show In Quick Loot Bar"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInQuickLoot_Description"] = [[
Opens the popup when hovering an item in the quick loot bar.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInContainers"] = "Show In Containers"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInContainers_Description"] = [[
Opens the popup when hovering an item in an opened container, or in the character's inventory beside it.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowOnQuickItems"] = "Show On Quick Items"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowOnQuickItems_Description"] = [[
Opens a popup when hovering a quick item on the action bar that is used on its owner, (a potion): what drinking it does to the selected character, its hit points, stats, and the effects it gains.

Items aimed at a creature, (a wand, a thrown potion), are described by Spell Info once a target is under the cursor.
]]

uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Unidentified"]        = "Not identified"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_IfEquipped"]          = "If %s equips this:"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_IfEquippedReplacing"] = "If %s equips this instead of %s:"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_NoChange"]            = "No stat changes"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_NotUsable"]           = "Not usable by %s"

uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ArmorClass"]         = "Armor Class"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ArmorClassCrushing"] = "Armor Class bonus vs. crushing"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ArmorClassMissile"]  = "Armor Class bonus vs. missile"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ArmorClassPiercing"] = "Armor Class bonus vs. piercing"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ArmorClassSlashing"] = "Armor Class bonus vs. slashing"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_THAC0"]              = "THAC0"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_DamageBonus"]        = "Damage bonus"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_MaxHitPoints"]       = "Maximum Hit Points"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_STR"]                = "Strength"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_DEX"]                = "Dexterity"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_CON"]                = "Constitution"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_INT"]                = "Intelligence"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_WIS"]                = "Wisdom"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_CHR"]                = "Charisma"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_SaveDeath"]          = "Save vs. Death"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_SaveWands"]          = "Save vs. Wands"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_SavePoly"]           = "Save vs. Polymorph"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_SaveBreath"]         = "Save vs. Breath"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_SaveSpell"]          = "Save vs. Spell"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistMagic"]        = "Magic resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistFire"]         = "Fire resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistCold"]         = "Cold resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistElectricity"]  = "Electricity resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistAcid"]         = "Acid resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistPoison"]       = "Poison resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistMagicDamage"]  = "Magic damage resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistMagicFire"]    = "Magical fire resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistMagicCold"]    = "Magical cold resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistSlashing"]     = "Slashing resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistCrushing"]     = "Crushing resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistPiercing"]     = "Piercing resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_ResistMissile"]      = "Missile resistance"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_Luck"]               = "Luck"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_OpenLocks"]          = "Open Locks"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_FindTraps"]          = "Find Traps"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_PickPockets"]        = "Pick Pockets"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_MoveSilently"]       = "Move Silently"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_HideInShadows"]      = "Hide in Shadows"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_HitPoints"]          = "Hit Points"

uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_IfUsed"]             = "If %s uses this:"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Lasts"]              = "Lasts %s"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Permanent"]          = "Permanent"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Turn"]               = "%d turn"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Turns"]              = "%d turns"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Round"]              = "%d round"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Rounds"]             = "%d rounds"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Seconds"]            = "%d seconds"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_AlreadyFull"]    = "already full"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Damage"]         = "Takes %s damage"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Excluded"]       = "No effect: the item excludes %s"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_ImmuneTo"]       = "Immune to %s"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_ImmuneToLevels"] = "Immune to level %s spells"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_CurePoison"]     = "Cures poison"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_CureDisease"]    = "Cures disease"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_CureStun"]       = "Removes stun"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_CureHold"]       = "Removes hold"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Death"]          = "Death"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_DispelMagic"]    = "Dispels magic on the user"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Haste"]          = "Haste"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Invisibility"]   = "Invisibility"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Poison"]         = "Poisoned"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Slow"]           = "Slowed"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Infravision"]    = "Infravision"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Blindness"]      = "Blinded"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Feeblemind"]     = "Feebleminded"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Intoxication"]   = "Intoxicated"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_Regeneration"]   = "Regeneration"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Use_FreeAction"]     = "Free action"

uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Weapon_Damage"]      = "Weapon damage"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Weapon_THAC0Bonus"]  = "THAC0 bonus"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Weapon_SpeedFactor"] = "Speed factor"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Weapon_Proficiency"] = "Proficiency points"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Weapon_Style"]       = "Weapon style"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Style_NONE"]           = "none"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Style_TWOHANDED"]      = "Two-handed"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Style_SWORDANDSHIELD"] = "Sword and shield"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Style_SINGLEWEAPON"]   = "Single weapon"
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Style_TWOWEAPON"]      = "Two weapons"
