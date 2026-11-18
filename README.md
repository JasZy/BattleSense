# Battle Sense

A WeiDU mod for the Infinity Engine Enhanced Editions that shows what is actually happening in a fight: who can hit whom and for how much, where everyone is in their casting or attack round, and why a spell or weapon did nothing.

Battle Sense is built on [EEex](https://github.com/Bubb13/EEex) and requires it.

## Requirements

- Baldur's Gate: Enhanced Edition, Baldur's Gate II: Enhanced Edition, EET, or Icewind Dale: Enhanced Edition
- EEex v1.3.1, installed **before** Battle Sense
- The game must be started with `InfinityLoader.exe`, as with any EEex mod

## Installation

1. Install EEex.
2. Extract this mod so that the `BattleSense` folder and `setup-BattleSense.exe` sit in your game folder.
3. Run `setup-BattleSense.exe` and pick the components you want.

The settings of each component are in the game under Options > EEex Options, in the tabs named "Battle Sense: ...".

## Compatibility

Battle Sense only adds files with the `ZJ` prefix to the override folder, and does not modify any file that belongs to the game, EEex, or another mod.

## Credits

- [Bubb](https://github.com/Bubb13), for EEex
- JasZy, for Battle Sense

## For developers

```
BattleSense/
  BattleSense.tp2          The installer
  language/                Installer strings
  copy/core/               Installed with the first component: startup file, strings, shared sprite helpers
```

- `M_ZJBSen.lua` is run by the engine during startup and starts the installed modules.
- `ZJ-en_US.lua` holds the English strings. A translation goes in a file named after the game's language code, for example `ZJ-de_DE.lua`, and only needs the strings it translates.
- `ZJSprite.lua` holds the functions that read the engine's casting and attack round state. They are also available as methods on `CGameSprite`, prefixed with `zj`.
