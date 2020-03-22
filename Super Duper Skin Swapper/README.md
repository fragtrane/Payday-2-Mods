# Super Duper Skin Swapper

**Note: Super Duper Skin Swapper is NOT compatible with Optional Skin Attachments or Hide Duplicate Skins. Legendary skin support and duplicate hiding are already built into Super Duper Skin Swapper.**

Latest version [v1.1](https://github.com/fragtrane/Payday-2-Mods/raw/master/Super%20Duper%20Skin%20Swapper/Super_Duper_Skin_Swapper_v1.1.zip).

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/26919).

## Overview

Weapon previews can be viewed [here](https://github.com/fragtrane/Payday-2-Mods/blob/master/Super%20Duper%20Skin%20Swapper/Weapon%20Previews.md).

Key features and options:

- **Use Any Skin on Any Weapon:** Weapon skins can be applied to any weapon. Note: this will not unlock weapon skins that you do not own.
- **No Duplicated Immortal Pythons:** Each weapon will only have access to one Immortal Python skin.
- **Use Default Weapon Icon for Swapped Skins:** When you use apply a skin that is meant for a different weapon, the inventory will display the actual weapon instead of the weapon skin icon so you know what gun you are using. It will still apply the rarity background so you know that you have a skin equipped. In the weapon customization menu, weapon skin icons are displayed so you know which skin you are applying.
- **Hide Unowned Skins:** Hide skins that you do not own.
- **Allow Legendary Mods on Variants:** Allow legendary weapon attachments to be used on akimbo/single variants (not fully tested).
- **Clean Duplicates:** Hide duplicate copies of skins and only show the ones with the best quality. Can be configured to prefer stat boosted skins, prefer the best quality, show both the best stat boosted and non-stat boosted, or show all variants of the skin.

## Additional Changes/Remarks

- The Golden AK.762, Jacket's Piece, and Akimbo Jacket's Piece do not have Immortal Python skins so they use the Immortal Python skin of the AK.762, Mark 10, and Akimbo Mark 10 respectively.
- The Golden AK.762 is allowed to equip custom colors.
- Attachments have been removed from weapons skins for compatibility reasons (so they are not automatically added when you apply a skin and you won't be able to equip them for free). The anti-piracy check has been updated to prevent false-positive cheater tags. However, when previewing a skin from Steam inventory or when opening safes, weapons skins will display their normal included attachments.
- The "MODIFICATIONS INCLUDED" description has been removed from all skins.
- Legendary weapon skins have their attachments removed as well and can be customized as normal.
- Legendary weapon attachments are displayed in the weapon customization menu but can only be used when the corresponding skin is equipped to prevent cheater tags.
- Legendary weapon skins have their unique names removed and can be renamed as normal.
- AI can equip weapons with swapped skins. Other players will be able to see it as well.

## Compatibility

When using a swapped skin, unmodded peers will see the weapon skin icon in the loadout screen. Modded peers will see the real weapon with a rarity background (like you do). When in-game, they will be able to see the skin applied on your gun.

SDSS overwrites the BlackMarketManager:get_weapon_icon_path() function used by BeardLib, but retains support for BeardLib's universal skin icons. However, in inventory screens, SDSS will keep using the real weapon with the rarity background (like with swapped skins). Otherwise, you don't know what weapon you are using because the universal skin icon system uses one icon for all weapons. The universal skin icon is only used when applying weapon skins.

I have tested SDSS with the [BUFF Universal Skin](https://modworkshop.net/mod/24358) and the [Case Hardened Universal Skin](https://modworkshop.net/mod/25610). Case Hardened Universal Skin uses BeardLib's universal skin icon feature, so it will be replaced by the real weapon in the inventory screen. The BUFF Universal Skin does not use this but it just has the same icon copied across all skins, so unfortunately you are not able to tell which gun you are using.

SDSS should be compatible with most custom weapons, but not all custom weapons will support skins properly. I tested it with the [Akimbo Steakout 12G](https://modworkshop.net/mod/19092) mod. However, the Immortal Python skin will not be available. If you want give your custom weapon an Immortal Python skin, you can do so using this template:

```
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "Some_Unique_Identifier_For_Your_Hook", function(self)
	local weapon_id = "x_aa12"--ID of custom weapon. In this example, Akimbo Steakout 12G.
	local skin_id = "aa12_tam"--ID of Immortal Python skin you want to use. In this case, Steakout 12G.
	--Do it like this so you don't overwrite other weapons that want to use this skin
	self.weapon_skins[skin_id].extra_weapon_ids = self.weapon_skins[skin_id].extra_weapon_ids or {}
	table.insert(self.weapon_skins[skin_id].extra_weapon_ids, weapon_id)
end)
```

SDSS is compatible with [WolfHUD](https://github.com/Kamikaze94/WolfHUD). Big thanks to Kamikaze94 for taking the time to update WolfHUD to be compatible.

SDSS is NOT compatible with [Optional Skin Attachments](https://github.com/fragtrane/Payday-2-Mods/tree/master/Optional%20Skin%20Attachments). Default attachments are disabled by SDSS anyways and the legendary skin features are already included in SDSS.

SDSS is NOT compatible with [Hide Duplicate Skins](https://github.com/fragtrane/Payday-2-Mods/tree/master/Hide%20Duplicate%20Skins). Duplicate hiding is already built into SDSS.

## Equipping Legendary Attachments on Akimbo/Single Variants

- The Alamo Dallas Barrel can be seen by other players (both vanilla and modded) when equipped on the Akimbo Kobus 90s.
- The Santa's Slayers Grip and Santa's Slayers Laser are invisible for other players when equipped on the single Crosskill. It will just look like a normal Crosskill with a skin.
- The Midas Touch Barrel is invisible for other players when equipped on the Akimbo Deagles. It looks very strange because the Akimbo Deagles will have no barrel.
- I do not own the Anarcho skin so I could not test its attachments on the Akimbo Judges.

Legendary attachments are only available for use when the corresponding legendary skin is equipped, so it will not cause a cheater tag. Any false-positive cheater tags are due to other players using mods that delete attachments without changing the piracy check (e.g. Customizable Legendary Skins or the original Super Skin Swapper). If players run these mods, you will be marked as a cheater for using any legendary attachment, regardless of what weapon it is equipped on. Therefore, there is no harm in using the attachments on single/akimbo variants.

## Installation [BLT]

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`Super_Duper_Skin_Swapper_v1.1.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Super%20Duper%20Skin%20Swapper/Super_Duper_Skin_Swapper_v1.1.zip) and extract the entire contents to your `mods` folder.

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

**v1.1 - 2020-03-22**

- Real skin will be displayed as a mini-icon when a weapon is selected in inventory.
- Wear override option removed.

**v1.0 - 2020-03-21**

- Initial release.
