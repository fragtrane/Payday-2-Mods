# Add-On Legendary Attachments

Latest version v1.3.

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/27211).

## Overview

Weapon previews can be viewed [here](https://github.com/fragtrane/Payday-2-Mods/blob/master/Add-On%20Legendary%20Attachments/Weapon%20Previews.md).

Adds a standalone copy of legendary attachments that can be used if you own the corresponding legendary skin. Add-on legendary attachments are synced to peers as a non-legendary vanilla game attachment and will not trigger cheater tags. You can safely use them even if you do not have the legendary skin equipped.

It is recommended to also use [Super Duper Skin Swapper](https://github.com/fragtrane/Payday-2-Mods/tree/master/Super%20Duper%20Skin%20Swapper) **OR** [Optional Skin Attachments](https://github.com/fragtrane/Payday-2-Mods/tree/master/Optional%20Skin%20Attachments), as either of these mods will prevent clipping on some legendary attachments while also providing better support for skins. Do NOT install both because they are not compatible with each other.

Peers will see a vanilla game attachment. Typically, this is either a default part or a base game (non-DLC) attachment. There are a few exceptions where a DLC attachment is used, but only if it belongs to the same DLC as the weapon. A full list can be found [here](https://github.com/fragtrane/Payday-2-Mods/blob/master/Add-On%20Legendary%20Attachments/Based-On%20Parts.md).

## IMPORTANT: Client Detection Risk

Due to the fact that add-on legendary attachments are synced as different parts, your concealment (and thus detection risk) will be incorrectly calculated by the host if the add-on part does not have the same concealment as the synced part. This can be a problem when stealthing as a client because detection is calculated by the host. For loud, it doesn't matter because crit chance is handled locally.

As of v1.3, some based-on attachments have been changed to mitigate this problem as much as possible. However, the following add-on attachments will still DECREASE your concealment and give you HIGHER detection risk when playing as a client:

- Don Pastrami Stock: other players see your concealment DECREASED by 1 point, i.e. HIGHER detection risk (bad).
- Mars Ultor Barrel: other players see your concealment DECREASED by 4 points, i.e. HIGHER detection risk (bad).
	- Note: when combined with the Mars Ultor Stock, your concealment is effectively only DECREASED by 1 point which cancels out most of the negative effects.
- Santa's Slayers Laser: other players see your concealment DECREASED by 2 points, i.e. HIGHER detection risk (bad).
- The Gimp Barrel: other players see your concealment DECREASED by 3 points, i.e. HIGHER detection risk (bad).
	- Note: when combined with The Gimp Body Kit, the concealment effects cancel out and the host sees the correct concealment.
- Vlad's Rodina Laser: other players see your concealment DECREASED by 1 point, i.e. HIGHER detection risk (bad).
	- Note: when combined with the Vlad's Rodina Stock, your concealment is effectively INCREASED by 1 point which actually benefits you.

The following add-on attachments will still INCREASE your concealment and give you LOWER detection risk when playing as a client:

- Astatoz Stock: other players will see your concealment INCREASED by 6 points, i.e. LOWER detection risk (good).
- Big Kahuna Stock: other players will see your concealment INCREASED by 3 points, i.e. LOWER detection risk (good).
- Mars Ultor Stock: other players will see your concealment INCREASED by 3 points, i.e. LOWER detection risk (good).
- Midas Touch Barrel: other players will see your concealment INCREASED by 10 points, i.e. LOWER detection risk (good).
- Plush Phoenix Stock: other players will see your concealment INCREASED by 2 points, i.e. LOWER detection risk (good).
- The Gimp Body Kit: other players will see your concealment INCREASED by 3 points, i.e. LOWER detection risk (good).
- Vlad's Rodina Stock: other players will see your concealment INCREASED by 2 points, i.e. LOWER detection risk (good).

## Known Issues

The Vlad's Rodina Laser and Santa's Slayers Laser can be seen by other players. However, the integrated laser found on non-gadget legendary attachments cannot be seen by other players. Full list of attachments with lasers that do not sync:
- Admiral Barrel
- Anarcho Barrel
- Apex Barrel
- Astatoz Foregrip
- Demon Barrel
- Mars Ultor Barrel
- Plush Phoenix Barrel

May add the option to hide unowned add-on attachments in the future.

Add-on legendary attachments use a white version of the legendary skin icon. I have no plans to change the icons at this time, mainly because OSA/SDSS use a colored version of the legendary skin icon and this is a nice way to differentiate the add-on attachments while preserving the style. Also because I really can't be bothered to make 40 icons.

## Installation [BLT with Self-Downloading Asset Override]

This mod requires [SuperBLT](https://superblt.znix.xyz) and [BeardLib](https://modworkshop.net/mod/14924); it will not work if you do not have them installed.

This mod consists of a BLT part and an asset override part. The asset overrides can be downloaded automatically so you only need to install the BLT part of the mod. Download [`Add-On_Legendary_Attachments_v1.3.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Add-On%20Legendary%20Attachments/Add-On_Legendary_Attachments_v1.3.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

You will automatically be prompted to install the assets overrides through SuperBLT's Download Manager when you start the game.

If you run into issues, you can also install the asset overrides manually. Download [`Add-On_Legendary_Attachments_Assets_v1.3.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Add-On%20Legendary%20Attachments/Add-On_Legendary_Attachments_Assets_v1.3.zip) and extract the entire contents to your `mod_overrides` folder.

The location of the `mod_overrides` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\assets\mod_overrides
```

## Uninstallation

Before uninstalling, you should remove all add-on legendary parts from your weapons. If you delete the assets folder, the BLT mod will automatically remove the attachments the next time you launch the game. Step by step instructions:

1. Delete the `AOLA Assets` folder found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\assets\mod_overrides\AOLA Assets
```

2. Launch the game and the attachments will be removed. Ignore the pop-up asking to download assets.

3. Open your inventory, then go back to the main menu so the game saves.

4. Exit the game. You can now delete the `Add-On Legendary Attachments` BLT mod folder:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods\Add-On Legendary Attachments
```

## Contact

Steam: [id/fragtrane](https://steamcommunity.com/id/fragtrane)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v1.3 - 2021-04-11**

- Changed some based-on parts to reduce detection risk sync issues:
	- Admiral Barrel now synced as default barrel.
	- Astatoz Barrel now synced as default barrel.
	- Astatoz Foregrip now synced as default foregrip.
	- Mars Ultor Stock now synced as Folding Stock.
	- The Gimp Body Kit now synced as I'll Take Half That Kit.
- Updated localizations for suppressed legendary attachment mods.

**v1.2 - 2021-04-08**

- Assets folder has been migrated to `mod_overrides/AOLA Assets`. After updating to v1.2 and restarting your game, the assets folder will be automatically migrated and you will be prompted to restart your game once more. Your currently equipped attachments should not be affected. Please update to v1.2 as soon as possible, because asset downloads through SuperBLT is currently broken because the old file path is too long.

**v1.1 - 2020-04-09**

- Fixed a sync issue that could cause peers to crash if add-on barrels were equipped with barrel extensions.

**v1.0 - 2020-04-07**

- Initial release.
