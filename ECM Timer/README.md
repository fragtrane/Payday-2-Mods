# ECM Timer

Latest version [v3.0](https://github.com/fragtrane/Payday-2-Mods/raw/master/ECM%20Timer/ECM_Timer_v3.0.zip).

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/25509).

## Overview

Key features and options:

- **ECM Timer:** Adds a timer to the HUD when an ECM or Pocket ECM is active. If multiple ECMs are active, the longest duration is used. No distinction is made between basic and pager-blocking ECMs.

## Known Issues

When an ECM is despawned (and thus is no longer active), the ECM timer still continues counting down. Due to the low likelihood of this occurring during typical gameplay and the fact that this issue isn't game-breaking, there are no plans to change it at this time.

When joining a game while an ECM is already active, the ECM timer will not be shown (but any new ECMs placed after joining will work fine). This cannot be fixed because the game does not sync the remaining ECM time to clients who drop in.

## Installation [BLT]

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`ECM_Timer_v3.0.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/ECM%20Timer/ECM_Timer_v3.0.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

## Acknowledgments

This mod has been adapted from LazyOzzy's ECM duration timer which can be found [here](https://www.unknowncheats.me/forum/payday-2-a/122868-ecm-duration-timer.html).

## Contact

Steam: [id/fragtrane](https://steamcommunity.com/id/fragtrane)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v3.0 - 2021-04-29**

- Timer position will now move with the police assault banner.
- Reworked code.

**v2.0 - 2020-01-07**

- Implemented new method for calculating remaining ECM time.
- Added support for Pocket ECMs.

**v1.0 - 2019-08-15**

- Initial release.
