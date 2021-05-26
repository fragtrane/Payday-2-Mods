# Super Duper Skin Swapper

**Note: Super Duper Skin Swapper is NOT compatible with Optional Skin Attachments or Hide Duplicate Skins. Legendary skin support and duplicate hiding are already built into Super Duper Skin Swapper.**

Latest version [v2.3](https://github.com/fragtrane/Payday-2-Mods/raw/master/Super%20Duper%20Skin%20Swapper/Super_Duper_Skin_Swapper_v2.3.zip).

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/26919).

## Overview

Weapon previews can be viewed [here](https://github.com/fragtrane/Payday-2-Mods/blob/master/Super%20Duper%20Skin%20Swapper/Weapon%20Previews.md).

Key features and options:

- **Use Any Skin on Any Weapon:** Weapon skins can be applied to any weapon. Note: this will not unlock weapon skins that you do not own.
- ~~**No Duplicated Immortal Pythons:** Each weapon will only have access to one Immortal Python skin.~~ Immortal Python has been changed in the base game to use the weapon color system.
- **Use Default Weapon Icon for Swapped Skins:** When you use apply a skin that is meant for a different weapon, the inventory will display the actual weapon instead of the weapon skin icon so you know what gun you are using. It will still apply the rarity background so you know that you have a skin equipped, and the weapon skin icon will be displayed as a mini-icon when the weapon is selected. In the weapon customization menu, weapon skin icons are displayed normally so you know which skin you are applying.
- **Hide Unowned Skins:** Hide skins that you do not own.
- **Allow Legendary Mods on Variants:** Allow legendary weapon attachments to be used on akimbo/single variants.
- **Clean Duplicates:** Hide duplicate copies of skins and only show the ones with the best quality. Can be configured to prefer stat boosted skins, prefer the best quality, show both the best stat boosted and non-stat boosted, or show all variants of the skin.
- **Customize Default Weapon Color Settings**: Set default paint scheme, wear, and pattern scale used for weapon colors.

## Additional Changes/Remarks

- ~~The Golden AK.762, Jacket's Piece, and Akimbo Jacket's Piece do not have Immortal Python skins so they use the Immortal Python skin of the AK.762, Mark 10, and Akimbo Mark 10 respectively.~~ Immortal Python has been changed in the base game to use the weapon color system.
- The Golden AK.762 is allowed to equip weapon colors.
- Attachments have been removed from weapons skins for compatibility reasons (so they are not automatically added when you apply a skin and you won't be able to equip them for free). The anti-piracy check has been updated to prevent false-positive cheater tags. However, when previewing a skin from Steam inventory or when opening safes, weapons skins will display their normal included attachments.
- The "MODIFICATIONS INCLUDED" description has been removed from all skins.
- Legendary weapon skins have their attachments removed as well and can be customized as normal.
- Legendary weapon attachments are displayed in the weapon customization menu but can only be used when the corresponding skin is equipped to prevent cheater tags.
- Legendary weapon skins have their unique names removed and can be renamed as normal.
- AI can equip weapons with swapped skins. Other players will be able to see it as well.

## Compatibility

**Note: compatibility was originally checked about 1 year ago in April 2020. Some of the information here may have changed; this section is currently being updated.**

When using a swapped skin, unmodded peers will see the weapon skin icon in the loadout screen. Modded peers will see the real weapon with a rarity background (like you do). When in-game, they will be able to see the skin applied on your gun.

~~SDSS overwrites the BlackMarketManager:get_weapon_icon_path() function used by BeardLib, but retains support for BeardLib's universal skin icons. However, in inventory screens, SDSS will keep using the real weapon with the rarity background (like with swapped skins). Otherwise, you don't know what weapon you are using because the universal skin icon system uses one icon for all weapons. The universal skin icon is only used when applying weapon skins.~~ BeardLib universal skins now use the weapon color system so this function is only used by SDSS.

SDSS supports custom weapon skins, I tested it on the [AK.762 | Cyber Midnight Reborn](https://modworkshop.net/mod/25718).

~~SDSS supports BeardLib's universal skins, I tested it on the [Case Hardened Universal Skin](https://modworkshop.net/mod/25610). For universal skins, the inventory icon will display the real weapon and the universal skin icon will be displayed as a mini-icon.~~ BeardLib universal skins now use the weapon color system and should not be affected by SDSS.

~~For the [BUFF Universal Skin](https://modworkshop.net/mod/24358), you need to download the SDSS compatible version which uses BeardLib's univeral skins. The other version does not use BeardLib's universal skin system so you will end up with duplicated skins.~~ BeardLib universal skins now use the weapon color system and should not be affected by SDSS.

SDSS should be compatible with most custom weapons, but not all custom weapons will support skins properly. I tested it with the [Akimbo Steakout 12G](https://modworkshop.net/mod/19092) mod. ~~However, the Immortal Python skin will not be available. If you want give your custom weapon an Immortal Python skin, you can do so using this template:~~ Immortal Python has been changed in the base game to use the weapon color system.

SDSS is compatible with [WolfHUD](https://github.com/Kamikaze94/WolfHUD). Big thanks to Kamikaze94 for taking the time to update WolfHUD to be compatible.

SDSS is NOT compatible with [Optional Skin Attachments](https://github.com/fragtrane/Payday-2-Mods/tree/master/Optional%20Skin%20Attachments). Default attachments are disabled by SDSS anyways and the legendary skin features are already included in SDSS.

SDSS is NOT compatible with [Hide Duplicate Skins](https://github.com/fragtrane/Payday-2-Mods/tree/master/Hide%20Duplicate%20Skins). Duplicate hiding is already built into SDSS.

## Equipping Legendary Attachments on Akimbo/Single Variants

- The Alamo Dallas Barrel can be seen by other players (both vanilla and modded) when equipped on the Akimbo Kobus 90s. This works in-game as well as in the lobby.
- ~~I do not own the Anarcho skin so I could not test its attachments on the Akimbo Judges. It _should_ work fine though.~~ The Anarcho Barrel and Anarcho Grip also work fine on the Akimbo Judges.
- The legendary attachments on the Santa's Slayers and Midas Touch do not sync properly when equipped on the single/akimbo variant and have been disabled as of v1.3.1.
	- Update 2020-04-07: legendary attachments can be equipped on the single Crosskill and Akimbo Deagle using the [Add-On Legendary Attachments](https://github.com/fragtrane/Payday-2-Mods/tree/master/Add-On%20Legendary%20Attachments) mod. However, they cannot be seen by other players.

Legendary attachments are only available for use when the corresponding legendary skin is equipped, so it will not cause a cheater tag. Any false-positive cheater tags are due to other players using mods that delete attachments without changing the piracy check (e.g. Customizable Legendary Skins or the original Super Skin Swapper). If players run these mods, you will be marked as a cheater for using any legendary attachment, regardless of what weapon it is equipped on. Therefore, there is no harm in using the attachments on single/akimbo variants.

## Installation [BLT]

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`Super_Duper_Skin_Swapper_v2.3.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Super%20Duper%20Skin%20Swapper/Super_Duper_Skin_Swapper_v2.3.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

## Acknowledgments

Credit goes to SAR_Boats for writing the original [Super Skin Swapper](https://modworkshop.net/mod/17343). Note: this mod is outdated and it can also trigger false-positive cheater tags.

Big thanks to Kamikaze94 for updating WolfHUD to be compatible with this mod.

Thanks to GreenGhost21 for feedback during development.

## Contact

Steam: [id/fragtrane](https://steamcommunity.com/id/fragtrane)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v2.3 - 2021-05-26**

- Fixed an issue where rarity backgrounds could be set incorrectly for BeardLib universal skins.
- Tempfix for an issue where the Immortal Python default weapon color option wasn't being set.

**v2.2 - 2021-04-26**

- Filter buttons are now enabled by default. Filter options have been extended.
	- Option to filter by safe.
	- Option to filter by rarity.
	- Option to filter by wear.
	- Option to filter by weapon family.
- Unowned skins are no longer hidden by default. "Hide Unowned Skin" setting has been removed and is now available as a filter button instead.
- Added "Fast Previews" option. When enabled, double clicking an owned skin will preview it instead of applying it. Disabled by default.
- Added a slider to limit number of page buttons. Doesn't need to be changed unless your page numbers are still getting cut off.
- Changed some default settings, only affects new users.
	- Default duplicate hiding mode changed to "Best Normal & Stat".
	- Legendary attachments will be allowed on akimbo variants by default.

**v2.1.1 - 2021-04-24**

- Fixed a small bug in duplicate hiding that could cause crashes (thanks =THT= Communismo).

**v2.1 - 2021-04-23**

- Added a page number scaling option to prevent page numbers from being cut off due to too many skins. Enabled by default.
	- Note: if you have a ridiculous amount of duplicate skins, page numbers might still be cut off. Turn on duplicate skin hiding if this is happening to you. This works even if you own every skin in the game.
- Added an option to preview different wears on skins. Enabled by default.
- Added an option to filter which skins are shown. This option is still in beta and is disabled by default.
	- Added an option to save the chosen filter settings after the game is reloaded (e.g. after playing a heist or closing the game). This option is still in beta and is disabled by default.
- Removed the option to enable/disable skin swapping for normal skins. This is being replaced by the filter settings.
- Removed the option to enable/disable skin swapping for BeardLib skins. This option is now always enabled.

**v2.0.3 - 2021-04-11**

- Remove stats option has been modified to remove all weapon stats except for concealment in order to prevent detection risk sync issues.
- Midas Touch Barrel will now use the default position for the front sight post when equipping the Marksman Sight (to prevent the front sight post from floating in the air).

**v2.0.2 - 2021-04-08**

- Fixed an issue where default color pattern scale was being applied to weapon skins (thanks Sydney).
- Internal changes:
	- Reworked hiding of legendary skins on akimbo weapon variants.
	- Removed a useless quickplay check.

**v2.0.1 - 2021-04-06**

- Hotfix for a crash related to weapons skins without attachments.

**v2.0 - 2021-04-05**

- Updated the mod to work with the latest version of the game (U205).
	- Crashfix: resolved compatibility issues with BeardLib's updated universal weapon skin system.
	- Crashfix: resolved compatibility issues with U201 changes to the weapon color system.
	- Fixed an issue where the rarity background for weapon colors was not being set properly (thanks GreenGhost21).
- Attachments which are part of weapon skins can now be equipped for free like in the base game.
- DLC attachments which are part of weapons skins can now be equipped even if you do not own the DLC (like in the base game).
- Added option to set Immortal Python as default weapon color. Disabled by default.
- Added option to choose default default paint scheme for weapon colors.
- Added option to choose default wear for weapon colors.
- Added option to choose default pattern scale for weapon colors.

**v1.5 - 2020-04-27**

- Added option to enable/disable skin swapping in options menu.
- Fixed a crash that could occur if custom skins were uninstalled without first removing them from weapons.

**v1.4 - 2020-03-30**

- Added the ability to customize the laser color on legendary attachments. Vlad's Rodina Laser and Santa's Slayers Laser could already use custom colors and have not been changed. List of affected attachments:
	- Admiral Barrel
	- Anarcho Barrel
	- Apex Barrel
	- Astatoz Foregrip
	- Demon Barrel
	- Mars Ultor Barrel
	- Plush Phoenix Barrel
- Added option to allow BeardLib custom skins to be used on all weapons. Does not affect BeardLib universal skins. Enabled by default.
- Added option to remove stats from legendary attachments. Disabled by default.
- Minor/internal changes:
	- Reworked localization integration with Suppressed Raven Admiral Barrel mod.
	- Reworked BlackMarketManager:player_owns_silenced_weapon() check when SRAB is in use.
	- Visible skins are set after BlackMarketManager:load() even when online.

**v1.3.1 - 2020-03-26**

- Legendary attachments on single Crosskill and Akimbo Deagle disabled due to sync issues. Will look into bringing them back in the future.
- Legendary attachments are still available on the Akimbo Kobus 90 and Akimbo Judge. Legendary attachments applied on Akimbo Kobus 90 and Akimbo Judge are now validated.

**v1.3 - 2020-03-26**

- Reworked method for validating weapon modifications.
- Reworked method for removing legendary attachments from Akimbo Kobus 90 and Akimbo Judge when "Allow Variants" is off to prevent sync issues.
- Reworked method for adding legendary attachments to single Crosskill and Akimbo Deagle to prevent sync issues.

**v1.2 - 2020-03-24**

- Added support for custom skins.

**v1.1.1 - 2020-03-22**

- Skin mini-icon now supports BeardLib's universal skins.

**v1.1 - 2020-03-22**

- Real skin will be displayed as a mini-icon when a weapon is selected in inventory.
- Wear override option removed.

**v1.0 - 2020-03-21**

- Initial release.
