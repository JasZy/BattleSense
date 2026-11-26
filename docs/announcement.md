# Battle Sense – see what is really happening in a fight (EEex, looking for beta testers)

Baldur's Gate hides most of what decides a fight. You see a swing and a number in the log, but not what your fighter needed to roll, how far the enemy mage is from finishing a spell, or why your Sleep did nothing to half the room. For a long time none of it made sense to me, so I built the tools to show it.

**Battle Sense** is a WeiDU mod, built on [EEex](https://github.com/Bubb13/EEex), that puts that information on screen. It doesn't change any rule; every number it shows is one the game already calculates and keeps hidden.

## Why this isn't a release (yet)

I made Battle Sense for myself, for the way I like to play: I would rather see everything and have the challenge come from somewhere else than have a fight be hard because I can't tell what is going on.

Up until now I have only tested it in my own game, in the first part of Baldur's Gate 1. That is too little to call it a release: later on there are spells, items and creatures it hasn't met yet, and BG2:EE, EET and IWD:EE haven't been tried at all.

If you are interested, or willing to help test it, please let me know and I will provide the download. More about that at the end of this post.

It has five components, and you can install any combination of them:

1. **Attack Info** – who can hit whom, and for how much, when you hover a creature
2. **Timer** – casting, attack round and other timers beside the party portraits
3. **Combat Log** – extra log lines that explain failed saves, immunities and effects ending
4. **Item Info** – what an item would change for your character, in stores, containers, the quick loot bar and the inventory
5. **Spell Info** – what a spell will do to the creature you are about to target

Under Options > EEex Options, the "Battle Sense Modules" tab switches each component on or off, and every component has its own tab ("Battle Sense: ..."), where each part of it can be switched on or off.

The three popups, (Attack Info, Item Info and Spell Info), only open while you hold a key, so they stay out of the way until you want them. The key is Left Ctrl by default; the "Battle Sense Modules" tab can change it to Right Ctrl, or the left or right Alt or Shift.

---

## 1. Attack Info

Hold Left Ctrl and hover over an enemy, and a popup opens with two panels.

`[image: Attack Info with Resistances.jpg]`

**The right panel is what you can do to the creature.** For each selected party member:

- an icon for the damage type of their weapon
- the roll they need to hit, (or the chance as a percentage)
- the damage of a hit, with the creature's resistance behind it: the skeleton above takes half from Haakon's sword, and only a tenth from Montaron's arrows
- extra damage the weapon applies on a hit, such as fire or cold, with the creature's resistance to that element
- whether the creature is immune to the weapon: the row turns red and says `Immune`

`[image: Attack Info with Immunities.jpg]`

*Xzar's quarterstaff does nothing to a werewolf.*

**The left panel is what the creature can do to you:** the roll it needs to hit each of your characters, and in the header its own damage and damage type.

**The header** also shows the creature's stoneskins or mirror images, and the spells affecting it with the time they have left, (turns, rounds). While it casts, the spell's name and a casting bar appear there.

`[image: Attack Info with Mirror images.jpg]`

*Tarnesh, three mirror images up and already casting Horror; the bar under Xzar's name shows who it is aimed at.*

**Timer bars.** Under your characters' names, bars show how far along they are: orange for the attack round, with a tick for every attack roll, and cyan for spell casting. A character using a wand or another item shows that item instead of a weapon.

`[image: Attack Info with Item.jpg]`

**Hovering over a friend** opens a compact form that lists who that character is fighting. Outside a fight it shows just that character: their weapon damage, their timers, and the spells on them with the time they have left, which is handy to see which buffs are about to run out.

## 2. Timer

Bars beside the party portraits that show what each character is in the middle of:

- **Casting** (cyan): the time before the character can cast or use an item again, with a marker where the spell is released
- **Attack round** (orange): with a marker for every attack roll. With a half attack, (3/2, 5/2), the last marker only shows in the rounds where that attack is made
- **Modal action** (red) and **contingency** (green)
- **Resistance rings**: a ring for every element the character resists, and for magic resistance; the green part is the percentage

Each bar's color can be changed in the options, or set to Off to hide the bar. The Attack Info popup's bars use the same colors.

`[image: Timer bars while Fighting 1x.jpg]`

*Mid-fight: Montaron's attack round, Haakon between rounds with a marker for each of his attacks, and Xzar starting a spell. The rings show their resistances.*

`[image: Cast timer 3x.jpg]`

*Three casters, each at a different point of their spell.*

## 3. Combat Log

Extra lines in the combat log that explain what the game leaves out:

- **Spells and conditions ending:** `Imoen- Haste wore off` when the duration ran out, `Imoen- Stoneskin ended` when it was dispelled or used up
- **Failed saves, with the roll that was needed**
- **Why a spell did nothing:** `Skeleton- Unaffected by Sleep: immune to sleep`
- **Why a weapon is ineffective:** `Minsc- Long Sword is ineffective against Werewolf: it requires a +1 weapon or better`

`[image: Combat Log Failed Save.jpg]`

By default, lines are only printed when your party is involved, so the log stays readable and you learn nothing about creatures you can't see.

## 4. Item Info

Hold Left Ctrl and hover an item in a store, an opened container, the quick loot bar or your inventory, and a popup shows its properties. If a character is selected, it also lists how their stats would change if they equipped it, in green for better and red for worse: armor class, (also against crushing, missile, piercing and slashing), THAC0, saves, ability scores, resistances, and for a weapon its damage, speed and the character's proficiency in it.

`[image: Store Weapon Popup.jpg]`

For a potion, the popup shows what drinking it would do to that character: hit points, ability scores, the effects it gives and how long they last. This also works on the quick item slots of the action bar.

`[image: Quick Bar Popup.jpg]`

## 5. Spell Info

Pick a spell, wand, scroll or throwable potion, then hold Left Ctrl and hover the creature you want to target. Before you click, a popup shows what it will do:

- **Magic resistance**, or that the spell ignores it
- **Saving throws**: which save, the spell's bonus or penalty, and the roll the creature needs
- **Damage** per element, with the creature's resistance to each
- **Why it would be unaffected**: an immunity, (naming the item or spell it comes from), the spell's own exclusions, or a level limit, (Sleep only affects creatures up to level 4)

`[image: Spell Info.jpg]`
`[image: Spell Popup with Save.jpg]`
`[image: Spell Popup Immune.jpg]`

*Command won't work on Dorotea, who is an elf.*

---

## Beta testing

**Requires:** EEex v1.3.1, installed before Battle Sense.
**Should work on:** BG:EE, BG2:EE, EET and IWD:EE. So far I have only tested it in the first part of BG:EE, so the rest of the saga and the other games are exactly where testers would help.

Good to know before you install:

- **Attack Info and Timer replace EEex's own modules of the same name.** They started from Bubb's modules, and Battle Sense switches the EEex ones off so nothing is drawn twice.
- **The Combat Log component adds a hidden effect to every creature,** which is how it sees spells being blocked. That effect is stored in your saves, so keep the component installed for saves made with it.
- **Everything is read-only.** Battle Sense never changes a roll, a spell or an item. It only adds files with the `ZJ` prefix to the override folder.
- **English only.**

If you are interested or willing to test, let me know here or send me a message, and I will provide the download. In return, I'd love to hear:

- which game you play, and which other mods you have installed
- anything that looks wrong: a number that doesn't match what happens, a popup that doesn't open, or text that runs off the screen
- any line in the combat log that starts with `[Battle Sense]`: that is an error, and a screenshot of it tells me exactly where to look

## Credits

Battle Sense is built on [EEex](https://github.com/Bubb13/EEex) by Bubb, and the Attack Info and Timer components started from his modules of the same name. Thank you, Bubb, for making all of this possible.
