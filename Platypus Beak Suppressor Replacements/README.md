# Platypus Beak Suppressor Replacements

Latest version [v1.0](https://github.com/fragtrane/Payday-2-Mods/raw/master/Platypus%20Beak%20Suppressor%20Replacements/Platypus_Beak_Suppressor_Replacements_v1.0.zip).

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/31852).

## Overview

When you equip the Platypus 70's legendary Don Pastrami Barrel with a Beak Suppressor, the suppressor model becomes invisible and only appears intermittently when you inspect your weapon. This mod lets you choose a different suppressor model to use when the Don Pastrami Barrel is equipped. By default, it uses the Rattlesnake's Sniper Suppressor but you can select a different option in the menu.

Note: a proper fix for this issue requires BeardLib and is included in the [Add-On Legendary Attachments mod](https://github.com/fragtrane/Payday-2-Mods/tree/master/Add-On%20Legendary%20Attachments). This mod is mainly intended for those that are unable to use BeardLib.

Key features and options:

- **Beak Suppressor Model Replacement:** Choose a different suppressor model to use when equipping the Beak Suppressor on the Don Pastrami Barrel.
- **Always Use Replacement:** Option to use the chosen suppressor model even when not using the Don Pastrami barrel. Enabling this option will also make skin textures on the replacement part visible (if you are using [Super Duper Skin Swapper](https://github.com/fragtrane/Payday-2-Mods/tree/master/Super%20Duper%20Skin%20Swapper)).
- **Override AOLA Fix:** Option to override the AOLA Beak Suppressor fix and use the chosen replacement model instead.

## Known Issues
- When sprinting, the Rattlesnake Sniper Suppressor might become invisible for a few frames.
- All of the other suppressor replacements are visible when aiming down sights with a sniper scope, but it tends not to be too intrusive.

## Installation [BLT]

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`Platypus_Beak_Suppressor_Replacements_v1.0.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Platypus%20Beak%20Suppressor%20Replacements/Platypus_Beak_Suppressor_Replacements_v1.0.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

## Alternative Asset-Override Don Pastrami Beak Suppressor Fix

A proper fix for the Beak Suppressor glitch requires BeardLib and is included in AOLA. If you can't use BeardLib for whatever reason and you really don't like the replacement options in this mod, you can use a `mod_overrides` version of AOLA's edited model.

The problem with asset overrides is that they can only replace models in the game, so the Beak Suppressor will use the edited model even when you have the default Platypus barrel equipped. This causes a visual bug when using the Platyus with a default barrel and Beak Suppressor where you will see a floating suppressor when aiming down sights with a sniper scope (default scope, Theia, or Box Buddy). The bug only occurs with the default barrel; if you are using the Don Pastrami Barrel the mod works fine. If this does not bother you, you can download the `mod_overrides` Don Pastrami Beak Suppressor Fix here:

- https://github.com/fragtrane/Payday-2-Mods/raw/master/Platypus%20Beak%20Suppressor%20Replacements/Asset-Override_Don_Pastrami_Beak_Suppressor_Fix_v1.0.zip

## Contact

Steam: [id/fragtrane](https://steamcommunity.com/id/fragtrane)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v1.0 - 2021-04-15**

- Initial release.
