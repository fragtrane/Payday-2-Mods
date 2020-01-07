# ECM Timer

Latest version [v2.0](https://github.com/fragtrane/Payday-2-Mods/raw/master/ECM%20Timer/ECM_Timer_v2.0.zip).

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/25509).

## Overview

Key features and options:

- **ECM Timer:** Adds a timer to the HUD when an ECM or Pocket ECM is active. If multiple ECMs are active, the longest duration is used. No distinction is made between basic and pager-blocking ECMs.

## Known Issues

- When an ECM is despawned (and thus is no longer active), the ECM timer still continues counting down normally.
- When the police assault banner is active, the hostage panel is moved down and obscures the ECM timer.

Due to the low likelihood of these occurrences during typical gameplay and the fact that these issues are not game-breaking, there are no plans to fix them at this time.

## Installation

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`ECM_Timer_v2.0.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/ECM%20Timer/ECM_Timer_v2.0.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files\Steam\steamapps\common\PAYDAY 2\mods
```

## Acknowledgments

This mod is based on LazyOzzy's ECM duration timer which can be found here [here](https://www.unknowncheats.me/forum/payday-2-a/122868-ecm-duration-timer.html).

The code used for calculating the remaining ECM time was written by me.

The code used for displaying the time on the HUD was written by LazyOzzy (`hudmanagerpd2.lua`). I have made a few adjustments to the icon and counter.

Modified version:

<a href="https://i.imgur.com/B07Y85A.jpg"><img src="https://i.imgur.com/B07Y85A.jpg" alt="Modified ECM timer" height="180"></a>

LazyOzzy's original version:

<a href="https://i.imgur.com/O3twITA.jpg"><img src="https://i.imgur.com/O3twITA.jpg" alt="LazyOzzy's ECM timer" height="180"></a>

## Contact

Steam Group: [steamcommunity.com/groups/frag_pd2](https://steamcommunity.com/groups/frag_pd2)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v2.0 - 2020-01-07**

- Implemented new method for calculating remaining ECM time.
- Added support for Pocket ECMs.

**v1.0 - 2019-08-15**

- Initial release.
