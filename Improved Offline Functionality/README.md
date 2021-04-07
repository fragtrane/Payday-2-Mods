# Improved Offline Functionality

Latest version [v2.0](https://github.com/fragtrane/Payday-2-Mods/raw/master/Improved%20Offline%20Functionality/Improved_Offline_Functionality_v2.0.zip).

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/25511).

## Overview

This mod provides various improvements when playing without an internet connection. Key features and options:

- **Community Content:** Enable community and achievement content when offline. Some community content and achievement-locked content normally require an internet connection to use. This mod saves the state of these community groups/achievements so that you can continue to use this content even when there is no internet connection. The saved state is tied to your Steam ID so multiple accounts on the same computer are tracked separately and will all work properly.
- **Block Inventory Update:** Disable Steam inventory update when offline so that your skins don't disappear. Also suppresses inventory load failed dialog.
- **Offline Filters:** Show filter button in Crime.net Offline so that you can change the difficulty of the contracts that spawn.
- **Offline Chat:** Enable chat in single player mode.
- **No Interaction Interrupt:** Prevent pause menu and chat from interrupting interactions in single player mode.
- **No Armor Regen Bonus:** Disable the armor regeneration bonus in single player mode.
- **Enable Winters:** Allow Captain Winters to spawn in single player mode.

Regarding the "Outfit Locked" bug: as of v2.0, IOF only updates your locally saved achievement state when they have been successfully loaded from Steam. In principle, this should be sufficient to prevent the "Outfit Locked" bug. However, if you are still getting this bug, you can enable the "Freeze Achievement State" option. This will prevent your locally saved achievements from ever being removed and will guarantee that you do not get the "Outfit Locked" bug.

Note that in the unlikely event that you reset your Steam achievements and have enabled the "Freeze Achievement State" option, you will need to manually delete your locally saved state file. You can do so using the "Delete Local State File" button in the options menu.

## Installation [BLT]

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`Improved_Offline_Functionality_v2.0.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Improved%20Offline%20Functionality/Improved_Offline_Functionality_v2.0.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

## Acknowledgments

Some parts of this mod (chat, armor regen, Winters) were inspired by Unknown Knight's [Simulate Online](https://modworkshop.net/mod/16175) mod.

## Contact

Steam: [id/fragtrane](https://steamcommunity.com/id/fragtrane)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v2.0 - 2021-04-07**

- Reworked achievement state saving.
	- IOF will now check if achievements were successfully loaded from Steam before saving the achievement state.
	- IOF will now save all achievements, including any achievements added in the future.
- Added new "Freeze Achievement State" option to prevent achievements from ever being removed. Disabled by default.
	- The new achievement checks should, in principle, be sufficient to prevent the "Outfit Locked" bug. However, if you are still getting this bug, you can enable this option.
- Added new "Delete Local State File" button for deleting locally saved achievement state.
	- Enabling the "Freeze Achievement State" option will prevent your locally saved achievements from ever being removed. Therefore, if you choose to reset your Steam achievements at any point, you will need to manually delete your local state file using this button.
- Reworked Captain Winters check to improve stability/compatibility.
- Reworked interaction interrupt check to improve stability/compatibility.
- Reworked offline chat to improve stability/compatibility.

**v1.4 - 2020-03-20**

- Fixed a bug where multiplayer lobbies would appear in Crime.net Offline (thanks realthelift).
- Unnecessary filter options removed from Crime.net Offline. The only option that remains is the difficulty filter.
- Reworked MenuCallbackHandler:is_multiplayer function to prevent unnecessary options from appearing in pause menu of Crime.net Offline.

**v1.3 - 2020-03-04**

- Reworked state loading to prevent locked outfit bug.

**v1.2 - 2020-02-29**

- Added support for the Repairman outfit.
- Added support for the Minstrel outfit and its variations.
- Added support for the PAYDAY 2 Secret.

**v1.1 - 2019-12-04**

- Fixed crash when buying assets (thanks Zed).
- Added support for new achievement-locked oufits.
- Compatibility fixes for update 198.

**v1.0 - 2019-08-15**

- Initial release.
