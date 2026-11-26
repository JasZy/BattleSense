# Battle Sense

A WeiDU mod for the Infinity Engine Enhanced Editions that shows what is actually happening in a fight: who can hit whom and for how much, where everyone is in their casting or attack round, and why a spell or weapon did nothing.

Battle Sense is built on [EEex](https://github.com/Bubb13/EEex) and requires it.

## Requirements

- Baldur's Gate: Enhanced Edition, Baldur's Gate II: Enhanced Edition, EET, or Icewind Dale: Enhanced Edition
- EEex v1.3.1, installed **before** Battle Sense
- The game must be started with `InfinityLoader.exe`, as with any EEex mod

## Components

Each component can be installed on its own.

The popups open while you hold a key and hover what they describe. It is the same key for all of them: Left Ctrl by default, the "Popup Key" at the top of the "Battle Sense Modules" tab picks another one, (left or right Ctrl, Alt or Shift).

### Attack Info

Hover over an enemy or a neutral creature to open a popup with, for every selected character:

- The chance to hit, as a percentage or as the minimum d20 roll
- Damage per hit, with the target's resistances applied, and extra on-hit damage
- The target's stoneskins and mirror images, and the spells affecting it
- Whether the target is immune to the weapon
- Timer bars for the attack round, spell casting, contingencies and modal actions

The left panel shows the same for the creature attacking your party: the roll it needs to hit each of them and its damage. Hovering a party member or ally opens a compact popup listing who it is fighting. Outside a fight it shows the character on its own: its weapon damage, timers, and the spells affecting it with the time they have left.

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

Hover the cursor over an item in a store, in an opened container, in the quick loot bar, or on the inventory screen, to open a popup with:

- The properties of the item, (the "STATISTICS" part of its description)
- How the stats of the selected character, (on the inventory screen, the character it shows), would change if they equipped it in place of what they have equipped now: `Armor Class: 6 -> 4 (-2)`, and the armor class against each kind of attack the armors change: `Armor Class vs. crushing: 4 -> 3 (-1)`

The stat changes are added up from what the items say they do while equipped. If the character can't use the item, the popup says "Not usable" instead. An item that isn't identified has no stat changes listed.

For a potion, (or any item used on its owner), the popup shows what drinking it does to the selected character. This also works when you hover it in a quick item slot on the action bar: `Hit Points: 12/30 -> 21/30 (+9)`, `Strength: 16 -> 19 (+3)`, the effects it gains, (haste, immunities, ...), and how long they last.

### Spell Info

Pick a spell, wand, scroll or throwable potion, (from the spellbook or a quick item slot), then hover the creature you want to target to open a popup with what it will do to that creature:

- How far it is from the caster, next to the spell's range, and by how much it is out of range
- Its magic resistance, or that the spell ignores it
- The saving throws it gets, and the roll it needs to save
- The spell's damage per element, with the creature's resistance to each
- Why it would be unaffected: immunities, (e.g. an undead's immunity to sleep), the spell's own exclusions, (Sleep doesn't affect elves), and level limits

### Ability Info

On the abilities screen of character creation, hover an ability to open a popup with what the character's current score gives a character of its class:

- Strength: to-hit and damage bonus, weight allowance, bend bars / lift gates
- Dexterity: armor class, missile to-hit bonus, and thieving skills
- Constitution: hit points per level, hours before fatigue
- Intelligence: chance to learn spells and spells known per level, (wizards and bards), and lore
- Wisdom: bonus priest spells, (priests, paladins and rangers), and lore
- Charisma: store prices

For example `Strength 16` with `To-hit bonus +0`, `Damage bonus +1`, `Weight allowance 150`, `Bend bars / lift gates 16%`. The popup follows the score as you reroll it or change it with the + / - buttons.

### Proficiency Info

On the proficiencies screen, (character creation and level up), hover a weapon proficiency or fighting style to open a popup with what its points give now, (values of 0 are left out):

- A weapon: to-hit and damage bonus, speed factor, and the extra attacks per round the points add at the character's level, (with no points: the class's to-hit penalty for using it)
- A fighting style: main hand / off-hand to-hit and damage, armor class, speed factor and critical hit range

For example `Large Sword: 2 points` with `To-hit bonus +1`, `Damage bonus +2`, `Extra attacks per round +1/2`. The popup follows the points as you change them. The values come from the game's tables, so mods that change proficiencies or fighting styles are followed.

### Container Colors

Changes the color of a container's outline, (normally cyan), so you can see at a glance which ones are worth a visit:

- Locked containers are outlined red
- Empty containers are outlined gray, (as EEex's Empty Container module does)

A container that is both is outlined red. The green outline the game shows when a thieving, spell or item cursor can target a container is left alone. Both colors can be changed, and "None" leaves those containers the game's own cyan.

### Lock Info

Hover a locked container or door to open a popup with its lock difficulty, and each selected character's chance to:

- Pick the lock, (characters with Open Locks)
- Force it, (from their strength's Bend Bars / Lift Gates)

A trap that has been found, on a container, door or the floor, adds its difficulty and the chance to disarm it, (characters with Remove Traps). Traps that haven't been found are never mentioned.

For example `Lock difficulty 50 (pick and force)` with `Imoen: pick 40% (45 + d10), force 0% (15 + d10)`. Each chance is followed by the character's skill, so you can see how far off they are. The chances follow the game's own rule: a try succeeds if the skill plus a d10 roll, (0 to 9, raised by Luck), is above the difficulty, and a difficulty of 100 never gives way. Picking and forcing use the same lock difficulty.

## Installation

1. Install EEex.
2. Extract this mod so that the `BattleSense` folder and `setup-BattleSense.exe` sit in your game folder.
3. Run `setup-BattleSense.exe` and pick the components you want.

The settings of each component are in the game under Options > EEex Options. The "Battle Sense Modules" tab holds the key that opens the popups, and switches each installed component on or off, and the tabs named "Battle Sense: ..." hold each component's other settings. A component that is switched off isn't loaded the next time the game starts; switching it back on then takes a restart.

## Good to know

- **EEex's own modules are switched off.** When the Attack Info, Timer or Container Colors component is installed and EEex's module of the same name, (Empty Container for Container Colors), is enabled, Battle Sense turns the EEex one off, so that nothing is drawn twice. If you uninstall Battle Sense, turn EEex's module back on under Options > EEex Options > Modules.
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
- `ZJPopup.lua` holds the one popup the modules share, and its key. While the key is held, the modules' panels are asked in order of priority whether they have something to say about what is under the cursor, and the first one that does fills the popup, (`ZJPopup_AddPanel()`). It also holds the popup of the abilities and proficiencies screens, (`ZJPopup.menu`).
- `ZJSprite.lua` holds the functions that read the engine's casting and attack round state. They are also available as methods on `CGameSprite`, prefixed with `zj`.
