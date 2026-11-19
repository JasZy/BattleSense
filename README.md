# Battle Sense

A WeiDU mod for the Infinity Engine Enhanced Editions that shows what is actually happening in a fight: who can hit whom and for how much, where everyone is in their casting or attack round, and why a spell or weapon did nothing.

Battle Sense is built on [EEex](https://github.com/Bubb13/EEex) and requires it.

## Requirements

- Baldur's Gate: Enhanced Edition, Baldur's Gate II: Enhanced Edition, EET, or Icewind Dale: Enhanced Edition
- EEex v1.3.1, installed **before** Battle Sense
- The game must be started with `InfinityLoader.exe`, as with any EEex mod

## Components

Each component can be installed on its own.

### Attack Info

Hover the attack cursor over a creature to open a popup with, for every selected character:

- The chance to hit, as a percentage or as the minimum d20 roll
- Damage per hit, with the target's resistances applied, and extra on-hit damage
- The target's stoneskins and mirror images, and the spells affecting it
- Whether the target is immune to the weapon
- Timer bars for the attack round, spell casting, contingencies and modal actions

The left panel shows the same for the creature attacking your party: the roll it needs to hit each of them and its damage. Hold `Left Ctrl` or `Left Alt`, (the two open keybinds), to open the popup over any creature, without the attack cursor.

This is an extended version of EEex's own "Attack Info" module, and replaces it.

### Timer

Adds indicators beside the party portraits:

- Casting timer, with a marker where the spell is released
- Attack round bar, with a marker for every attack roll
- Modal action and contingency timers
- Rings that show active elemental resistances

This is an extended version of EEex's own "Timer" module, and replaces it.

### Combat Log

Adds lines to the combat log that explain:

- Spells and conditions ending: `Imoen- Haste wore off`
- Failed saving throws: `Gnoll- Failed save vs. Spell against Sleep`
- Why a spell did nothing: `Skeleton- Unaffected by Sleep: immune to sleep`
- Why a weapon is ineffective: `Minsc- Long Sword is ineffective against Werewolf: it requires a +1 weapon or better`

### Item Info

Hover the cursor over an item in a store, in an opened container, or in the quick loot bar, to open a popup with:

- The properties of the item, (the "STATISTICS" part of its description)
- How the stats of the selected character would change if they equipped it in place of what they have equipped now: `Armor Class: 6 -> 4 (-2)`

The stat changes are added up from what the items say they do while equipped. If the character can't use the item, the popup says "Not usable" instead. An item that isn't identified has no stat changes listed.

For a potion, (or any item used on its owner), the popup shows what drinking it does to the selected character. This also works when you hover it in a quick item slot on the action bar: `Hit Points: 12/30 -> 21/30 (+9)`, `Strength: 16 -> 19 (+3)`, the effects it gains, (haste, immunities, ...), and how long they last.

### Spell Info

Pick a spell, wand, scroll or throwable potion, (from the spellbook or a quick item slot), then hover the creature you want to target to open a popup with what it will do to that creature:

- Its magic resistance, or that the spell ignores it
- The saving throws it gets, and the roll it needs to save
- The spell's damage per element, with the creature's resistance to each
- Why it would be unaffected: immunities, (e.g. an undead's immunity to sleep), the spell's own exclusions, (Sleep doesn't affect elves), and level limits

## Installation

1. Install EEex.
2. Extract this mod so that the `BattleSense` folder and `setup-BattleSense.exe` sit in your game folder.
3. Run `setup-BattleSense.exe` and pick the components you want.

The settings of each component are in the game under Options > EEex Options, in the tabs named "Battle Sense: ...".

## Good to know

- **EEex's own modules are switched off.** When the Attack Info or Timer component is installed and EEex's module of the same name is enabled, Battle Sense turns the EEex one off, so that nothing is drawn twice. If you uninstall Battle Sense, turn EEex's module back on under Options > EEex Options > Modules.
- **Battle Sense has its own settings.** They are stored separately from EEex's; settings you changed for EEex's Attack Info or Timer module are not carried over.
- **The Combat Log component changes save games.** To report why a spell did nothing, it adds a hidden effect to every creature, and that effect is saved with the creature. Keep the component installed for saves that were made with it.

## Compatibility

Battle Sense only adds files with the `ZJ` prefix to the override folder, and does not modify any file that belongs to the game, EEex, or another mod.

## Credits

- [Bubb](https://github.com/Bubb13), for EEex, and for the Attack Info and Timer modules that the components of the same name are built on
- JasZy, for Battle Sense

## For developers

```
BattleSense/
  BattleSense.tp2          The installer
  language/                Installer strings
  copy/core/               Installed with the first component: startup file, strings, shared sprite helpers
  copy/attackinfo/         Attack Info component
  copy/timer/              Timer component
  copy/combatlog/          Combat Log component
```

- `M_ZJBSen.lua` is run by the engine during startup and starts the installed modules.
- `ZJ-en_US.lua` holds the English strings. A translation goes in a file named after the game's language code, for example `ZJ-de_DE.lua`, and only needs the strings it translates.
- `ZJSprite.lua` holds the functions that read the engine's casting and attack round state. They are also available as methods on `CGameSprite`, prefixed with `zj`.
