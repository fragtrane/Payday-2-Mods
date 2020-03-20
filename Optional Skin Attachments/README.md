# Optional Skin Attachments

Latest version [v1.7](https://github.com/fragtrane/Payday-2-Mods/raw/master/Optional%20Skin%20Attachments/Optional_Skin_Attachments_v1.7.zip).

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/25474).

## Overview

A video demo of this mod can be found on [YouTube](https://www.youtube.com/watch?v=LMdNRZA4hpw).

This mod allows you to choose which attachments to use when applying weapon skins and provides improved support for legendary skins. Key features and options:

- **Choose Skin Attachments:** Replaces the apply/remove skin confirmation dialog with a menu that allows you to choose which attachments to use. Attachments that are part of the skin will show up as "Available" to use while the skin is applied (as is the case in the base game).
- **Autobuy Missing Mods:** Automatically buy missing weapon attachments using Continental coins when you choose to keep your current attachments.
- **Autobuy Threshold:** Do not let Continental coins drop below this threshold when autobuying (range 0 to 200).
- **Prefer Shotgun Pack Buckshot:** Give the Gage Shotgun Pack 000 Buckshot priority when applying skins. When skins are applied or removed, the free 000 Buckshot will be replaced by the Gage Shotgun Pack 000 Buckshot if you own the Gage Shotgun Pack DLC.
- **Save Mods On Missing Skins:** Try to keep attachments when skins are removed from Steam inventory.
- **Choose Attachments in Previews:** Enable dialog menu for choosing attachments when previewing weapon skins.
- **Rename Legendary Skins:** Allow legendary skins to be renamed.
- **Customize Legendary Skins:** Allow legendary skins to be unlocked so that they can be customized.
- **Remove Legendary Mod Stats:** Remove stats from legendary weapon attachments.
- **Show Legendary Mods:** Show legendary weapon attachments in weapon customization menu so that they can be selected. Can be set to only show mods from owned legendary skins.

## Additional Changes/Remarks

- Unlike other mods, Optional Skin Attachments does not delete the list of attachments that are associated with a skin. This means that attachments that are part of the skin will show up as "Available" to use while the skin is applied, even if you don't own the DLC for the attachment (as is the case in the base game).
- The list of attachments associated with a skin is used by the game to verify whether a player is allowed to use DLC/legendary attachments. Deleting this list can cause false-positive cheater flags if the checks are not modified. This problem does not occur with Optional Skin Attachments.
- When a skin that contains the Gage Shotgun Pack 000 Buckshot is removed and you opt to keep your attachments, it will be replaced by the free 000 Buckshot if you do not own the Gage Shotgun Pack DLC.
- This mod fixes skins that don't actually have attachments included, so you will not be prompted to "Use Skin Attachments" if the skin does not actually contain attachments.
- This mod adds the ability to preview weapon modifications on locked legendary skins.
- This mod fixes a bug in the base game where weapons could not be renamed even after the legendary skin was removed.

## Installation [BLT]

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`Optional_Skin_Attachments_v1.7.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Optional%20Skin%20Attachments/Optional_Skin_Attachments_v1.7.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

## Contact

Steam: [id/fragtrane](https://steamcommunity.com/id/fragtrane)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v1.7 - 2020-03-20**

- Improved legendary attachment handling for various weapons:
	- Big Kahuna: Big Kahuna Stock now removes the default grip to prevent clipping.
	- Demon: Demon Stock now removes the default grip to prevent clipping.
	- Mars Ultor: Mars Ultor Barrel now removes the default barrel extension to prevent clipping.
	- Astatoz: Astatoz Foregrip's type has been changed to "foregrip" so that it will replace the default AMR-16 foregrip when applied (also to prevent clipping).
	- Vlad's Rodina: the default grip will no longer disappear when the Vlad's Rodina Stock is applied. Other grips can still be applied as normal to replace the default grip.
- Fixed the name of the Santa's Slayers Laser.

**v1.6 - 2020-03-10**

- Choosing stat boosts disabled due to sync issue.

**v1.5 - 2020-02-29**

- Added support for new custom colors.
- Fixed an issue on the Raven Admiral skin where applying the Short Barrel then switching to the Admiral Barrel would cause the foregrip to disappear.
- Compatibility fixes for upcoming mod.

**v1.4 - 2020-01-02**

- Fixed a bug in the base game where weapons could not be renamed even after the legendary skin was removed.
- Fixed a bug where autobuy would purchase stat boosts.
- Reworked code for deducting continental coins when autobuying mods.
- Reworked code for checking skins that don't contain mods.

**v1.3 - 2019-12-04**

- Reworked BlackMarketGui:populate_mods function, most compatibility issues should now be resolved.
- BLT priority reverted to 0.

**v1.2 - 2019-08-08**

- Choose Attachments in Previews: Added option for choosing attachments when previewing weapon skins. Enabled by default.
- Renamed "Unlock Legendary Skins" option to "Customize Legendary Skins" to prevent ambiguity.
- The ability to preview mods on legendary skins is now always enabled.

**v1.1 - 2019-08-07**

- Added automatic updating.
- Changed BLT priority to 11 to make compatible with Blackmarket Persistent Names and WolfHUD.

**v1.0 - 2019-08-04**

- Initial release.
