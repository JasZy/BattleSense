
-- Battle Sense - English strings. Translations go in ZJ-<language>.lua, (for example ZJ-de_DE.lua).

-----------------
-- Attack Info --
-----------------

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_TabTitle"] = "Battle Sense: Attack Info"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_Enable"] = "Enabled"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_Enable_Description"] = [[
Enables the attack information popup.

The popup opens when hovering a hostile creature, a neutral creature with the attack cursor, or a party member or ally that is in a fight, (see "Enabled For Friendly").

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


-----------
-- Timer --
-----------

-- The colors a timer bar can have, (ZJBarCol.lua)
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Off"]    = "Off"
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Red"]    = "Red"
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Orange"] = "Orange"
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Yellow"] = "Yellow"
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Green"]  = "Green"
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Cyan"]   = "Cyan"
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Blue"]   = "Blue"
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Purple"] = "Purple"
uiStrings["ZJBattleSense_TRANSLATION_BarColor_Pink"]   = "Pink"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_AttackBar"] = "Attack Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_AttackBar_Description"] = [[
The color of the attack bar, which the left panel shows while the creature under the cursor is attacking. Click to pick the next color, "Off" hides the bar.

This indicator displays how far the creature is through its attack round. The white ticks mark the points in the round where it makes its attack rolls. The right panel's row timers use the same bar.

The color is shared with the attack timer beside the party portraits, (Battle Sense: Timer).
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_CastBar"] = "Cast Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_CastBar_Description"] = [[
The color of the cast bar, which the left panel shows while the creature under the cursor is casting a spell or is waiting to be able to use spells / items again. Click to pick the next color, "Off" hides the bar.

This indicator displays the creature's cooldown for using spells / items. While a spell is being cast, a white tick marks the point where it is released. The right panel's row timers use the same bar.

The color is shared with the cast timer beside the party portraits, (Battle Sense: Timer).
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ContingencyBar"] = "Contingency Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ContingencyBar_Description"] = [[
The color of the contingency bar, which the left panel shows while the creature under the cursor has contingency effects. Click to pick the next color, "Off" hides the bar.

This indicator displays the interval at which the creature's contingency conditions are checked.

Note that some mods add contingency effects behind-the-scenes to implement certain behaviors - this may cause the contingency indicator to appear unexpectedly.

The color is shared with the contingency timer beside the party portraits, (Battle Sense: Timer).
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ModalBar"] = "Modal Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ModalBar_Description"] = [[
The color of the modal bar, which the left panel shows while the creature under the cursor is using a modal action. Click to pick the next color, "Off" hides the bar.

This indicator displays the interval of the creature's modal action: bard song, turn undead, etc.

The color is shared with the modal timer beside the party portraits, (Battle Sense: Timer).
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowRowTimers"] = "Show Row Timers"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowRowTimers_Description"] = [[
Adds timer bars below the names in the right panel, for every listed creature that is attacking the creature under the cursor.

The attack bar is displayed while the creature is attacking, and shows how far it is through its attack round. The white ticks mark its attack rolls.

The cast bar is displayed while the creature is casting a spell or is waiting to be able to use spells / items again. While a spell is being cast, a white tick marks the point where it is released.

The bars have the colors set by "Attack Timer" and "Cast Timer", and a bar whose color is "Off" isn't shown here either.
]]

-----------------
-- Attack Info --
-----------------

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_CompactForAllies"] = "Enabled For Friendly"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_CompactForAllies_Description"] = [[
Enables a compact attack information popup over party members and the party's summons / allies, (only while "Enabled" is on).

The compact popup lists the creatures that the creature under the cursor is attacking or is being attacked by, with the roll the creature needs to hit them and the damage it does in the left panel, and their rolls and damage against the creature in the right panel.

A creature is on the same row in both panels. If it is only attacking, or only being attacked, its row in the other panel is left empty.

The compact popup opens by itself when hovering a party member or ally that is attacking, or being attacked by, another creature. Turn this off to not open a popup over them at all.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowSpellEffects"] = "Show Spell Effects"

uiStrings["ZJBattleSense_Options_TRANSLATION_AttackInfo_ShowSpellEffects_Description"] = [[
Lists the spells affecting the creature under the cursor in the right panel's header, one per line. A spell with a set duration shows the time it has left in turns and rounds, e.g. "Haste (1,5)".

These are the spells EEex's Effect Menu module shows: spells from items, permanent spells and spells without an icon are left out. A sub-spell without a name of its own, like the one Chant casts on every creature around, is listed under its parent spell's name.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_TabTitle"] = "Battle Sense: Spell Info"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_Enable"] = "Enabled"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_Enable_Description"] = [[
While a spell, wand, scroll or other item ability is waiting for a target, hovering a creature shows what it will do to that creature: its magic resistance, the saving throws it gets and the roll it needs, the damage with its resistance to each element, and why it would be unaffected, (immunities, the spell's own exclusions and level limits).
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_FontPoint"] = "Font Point"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_FontPoint_Description"] = [[
The size of the popup's text.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType"] = "Save Display Type"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType_Description"] = [[
How the popup displays the creature's odds of making its saving throw.

'Roll' - The minimum d20 roll the creature needs to save, e.g. "saves on 14+".

'Percentage' - The chance the creature saves, e.g. "35% to save".

'Both' - The roll followed by the chance, e.g. "saves on 14+ (35%)".
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType_Roll"] = "Roll"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType_Percentage"] = "Percentage"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_SaveDisplayType_Both"] = "Both"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowMagicResistance"] = "Show Magic Resistance"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowMagicResistance_Description"] = [[
Displays the creature's magic resistance, and whether the spell ignores it.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowSavingThrows"] = "Show Saving Throws"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowSavingThrows_Description"] = [[
Displays the saving throws the creature gets against the spell, with the spell's bonus or penalty to them, and the creature's odds of saving, (see "Save Display Type").
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowDamage"] = "Show Damage"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowDamage_Description"] = [[
Displays the damage the spell does, per element, with the creature's resistance to that element.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowImmunities"] = "Show Immunities"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowImmunities_Description"] = [[
Displays why the creature would be unaffected by the spell: its immunities to the effect, the spell, the spell's level or school, the spell's own exclusions, (e.g. Sleep doesn't affect elves), and level limits.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowOnParty"] = "Show On Party Members"

uiStrings["ZJBattleSense_Options_TRANSLATION_SpellInfo_ShowOnParty_Description"] = [[
Also opens the popup when the creature under the cursor is a party member, or one of the party's summons / allies.

Turn this off to keep the popup out of the way while healing or buffing the party.
]]

uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_Title"]              = "%s on %s"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_MagicResistance"]    = "Magic resistance"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_Bypassed"]           = "this spell ignores it"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SaveVs"]             = "Save vs."
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SaveSpell"]          = "Spell"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SaveBreath"]         = "Breath"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SaveDeath"]          = "Death"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SaveWand"]           = "Wand"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SavePolymorph"]      = "Polymorph"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SavesOn"]            = "saves on %d+ (%d%%)"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SavesOnRoll"]        = "saves on %d+"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_SavesChance"]        = "%d%% to save"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_AlwaysSaves"]        = "always saves"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_CannotSave"]         = "cannot save"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_Damage"]             = "%s damage"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_Immune"]             = "Immune"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_AboveLevel"]         = "Unaffected by %s: level %d is above the limit of %d"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_BelowLevel"]         = "Unaffected by %s: level %d is below the minimum of %d"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_ImmuneTo"]           = "Immune to %s"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_ImmuneToLevel"]      = "Immune to level %d spells"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_ImmuneToSchool"]     = "Immune to %s spells"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_ImmuneToType"]       = "Immune to this type of spell"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_ProtectedFromSpell"] = "Protected from this spell"
uiStrings["ZJBattleSense_TRANSLATION_SpellInfo_Excludes"]           = "Unaffected: the spell excludes %s"

uiStrings["ZJBattleSense_TRANSLATION_AttackInfo_Immune"] = "Immune"

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

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_CastBar"] = "Cast Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_CastBar_Description"] = [[
The color of the cast bar next to party member portraits. Click to pick the next color, "Off" hides the bar.

This indicator displays the cooldown for using spells / items.

The color is shared with the attack info popup's cast timer, (Battle Sense: Attack Info).
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowCastMarker"] = "Show Cast Marker"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ShowCastMarker_Description"] = [[
Adds a white tick to the cast timer at the point where the spell being cast is released.

The tick is only shown while a party member is casting a spell.
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ContingencyBar"] = "Contingency Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ContingencyBar_Description"] = [[
The color of the contingency bar next to party member portraits. Click to pick the next color, "Off" hides the bar.

This indicator displays the interval at which contingency conditions are checked.

Note that some mods add contingency effects behind-the-scenes to implement certain behaviors - this may cause the contingency indicator to appear unexpectedly.

The color is shared with the attack info popup's contingency timer, (Battle Sense: Attack Info).
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ModalBar"] = "Modal Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_ModalBar_Description"] = [[
The color of the modal bar next to party member portraits. Click to pick the next color, "Off" hides the bar.

This indicator displays the interval of modal actions: find traps, turn undead, etc.

The color is shared with the attack info popup's modal timer, (Battle Sense: Attack Info).
]]

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_AttackBar"] = "Attack Timer"

uiStrings["ZJBattleSense_Options_TRANSLATION_Timer_AttackBar_Description"] = [[
The color of the attack bar next to party member portraits. Click to pick the next color, "Off" hides the bar.

This indicator displays how far a party member is through their attack round.

The color is shared with the attack info popup's attack timer, (Battle Sense: Attack Info).
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

The item popup opens when hovering the cursor over an item in a store, a container, the quick loot bar, or the inventory screen, and displays the properties of that item.
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
For a weapon, also lists how its damage, THAC0 bonus, speed factor and the character's proficiency points compare with the weapon in hand. The damage, THAC0 bonus and speed factor include the character's strength bonus, (melee weapons, and ranged weapons that add it, like slings and thrown weapons), what the character's proficiency in the weapon adds, (or the penalty for not being proficient), and what its weapon style adds, (two-handed, sword and shield, single weapon or two weapons). When the style changes, the armor class includes the style's armor class bonus.
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

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInInventory"] = "Show In Inventory"

uiStrings["ZJBattleSense_Options_TRANSLATION_ItemInfo_ShowInInventory_Description"] = [[
Opens the popup when hovering an item on the inventory screen: in the backpack, on the ground, or worn.

An item the character is wearing, (or the weapon in hand), has no stat changes listed.
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
uiStrings["ZJBattleSense_TRANSLATION_ItemInfo_Stat_AttacksPerRound"]    = "Attacks per round"
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

------------------
-- Ability Info --
------------------

uiStrings["ZJBattleSense_Options_TRANSLATION_AbilityInfo_TabTitle"] = "Battle Sense: Ability Info"

uiStrings["ZJBattleSense_Options_TRANSLATION_AbilityInfo_Enable"] = "Enabled"

uiStrings["ZJBattleSense_Options_TRANSLATION_AbilityInfo_Enable_Description"] = [[
Enables the ability overview.

The overview is shown at the top of the help text of the abilities screen of character creation. It lists what each of the character's current ability scores gives: to-hit and damage bonus, armor class, hit points per level, chance to learn spells, bonus priest spells, lore, store prices, ...

Values that only matter to some classes, (spells, thieving skills), are only listed for those classes. The overview follows the scores as they are rerolled or changed.
]]

uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_None"] = "none"

uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_ToHit"]             = "To-hit bonus"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_Damage"]            = "Damage bonus"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_WeightAllowance"]   = "Weight allowance"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_BendBars"]          = "Bend bars / lift gates"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_ArmorClass"]        = "Armor Class modifier"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_Missile"]           = "Missile to-hit bonus"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_PICK_POCKETS"]      = "Pick Pockets"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_OPEN_LOCKS"]        = "Open Locks"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_FIND_TRAPS"]        = "Find Traps"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_MOVE_SILENTLY"]     = "Move Silently"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_HIDE_IN_SHADOWS"]   = "Hide in Shadows"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_DETECT_ILLUSION"]   = "Detect Illusion"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_SET_TRAPS"]         = "Set Traps"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_HitPointsPerLevel"] = "Hit points per level"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_MinimumRoll"]       = "Lowest hit point roll"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_FatigueBonus"]      = "Hours before fatigue"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_LearnSpell"]        = "Chance to learn spells"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_MaxSpellsPerLevel"] = "Spells known per level"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_Lore"]              = "Lore"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_BonusPriestSpells"] = "Bonus priest spells per level"
uiStrings["ZJBattleSense_TRANSLATION_AbilityInfo_Stat_StorePrices"]       = "Store prices"

----------------------
-- Proficiency Info --
----------------------

uiStrings["ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_TabTitle"] = "Battle Sense: Proficiency Info"

uiStrings["ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_Enable"] = "Enabled"

uiStrings["ZJBattleSense_Options_TRANSLATION_ProficiencyInfo_Enable_Description"] = [[
Enables the proficiency information.

On the proficiencies screen, at character creation and level up, the top of the help text gets two rows: the last weapon proficiency, and the last fighting style, that was clicked or changed. A row shows what the points give now, (values of 0 are left out).

For a weapon: the to-hit and damage bonus, the speed factor, and the extra attacks per round the points add at the character's level, (with no points: the class's penalty for using it). For a fighting style: its damage, to-hit, armor class, speed factor and critical hit bonuses.
]]

uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Title"]   = "%s: %d points"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_NoBonus"] = "No bonuses or penalties"

uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_ToHit"]             = "To-hit bonus"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_Damage"]            = "Damage bonus"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_SpeedFactor"]       = "Speed factor"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_ExtraAttacks"]      = "Extra attacks per round"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_MainHandToHit"]     = "Main hand to-hit bonus"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_OffHandToHit"]      = "Off-hand to-hit bonus"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_MainHandDamage"]    = "Main hand damage bonus"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_OffHandDamage"]     = "Off-hand damage bonus"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_ArmorClass"]        = "Armor Class modifier"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_AgainstMissiles"]        = "(%+d against missiles)"
uiStrings["ZJBattleSense_TRANSLATION_ProficiencyInfo_Stat_CriticalRange"]     = "Critical hit range"
