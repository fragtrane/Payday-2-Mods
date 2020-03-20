# Normal Hold for Bernetti Auto and Czech 92 (WIP)

Latest version [v0.2](https://github.com/fragtrane/Payday-2-Mods/raw/master/Normal%20Hold%20for%20Bernetti%20Auto%20and%20Czech%2092/Normal_Hold_for_Bernetti_Auto_and_Czech_92_v0.2.zip).

## Overview

Demo (Bernetti Auto): https://www.youtube.com/watch?v=d3NDrSQLgEk

Changes the Bernetti Auto and Czech 92 so that the the gun is held with both hands on the grip instead of one hand on the foregrip/front magazine. Uses the 5/7 AP's animations because it works the best. With other pistol animations, the magazine will appear to be floating during the reload. This is much less apparent with 5/7 AP's animations and may not even be visible depending on your FOV settings.

## Known Issues

_Update 2020-03-20: A solution for the silent reload sound is now available (requires BeardLib)._

The reload sound is silent when the application is first launched. You need to equip a 5/7 AP and join a game. Afterwards, you can leave and the reload sound will work until you exit the application. This is because [some sounds don't play until the original weapon has been loaded into memory](https://www.unknowncheats.me/forum/1055533-post3.html?s=ff1847d9a1c1b61c568822c76cdef7a0).

I have already tried changing the reload animation using mod_overrides instead, but that just makes the reload permamently silent.

## Installation [BLT]

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`Normal_Hold_for_Bernetti_Auto_and_Czech_92_v0.2.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Normal%20Hold%20for%20Bernetti%20Auto%20and%20Czech%2092/Normal_Hold_for_Bernetti_Auto_and_Czech_92_v0.2.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

## Reload Sound Fix (Requires BeardLib)

The reload sound fix makes the Bernetti Auto and Czech 92 load the 5/7 AP's soundbanks, so you do not need to equip a 5/7 AP every time you launch the application. It requires [BeardLib](https://modworkshop.net/mod/14924) to work.

After you have installed BeardLib, download [`Normal_Hold_Reload_Sound_Fix.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Normal%20Hold%20for%20Bernetti%20Auto%20and%20Czech%2092/Normal_Hold_Reload_Sound_Fix.zip) and extract the entire contents to your `mod_overrides` folder.

The location of the `mod_overrides` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\assets\mod_overrides
```

Reload sound fix does not support automatic updates.

## Contact

Steam: [id/fragtrane](https://steamcommunity.com/id/fragtrane)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v0.2 - 2020-03-08**

- Fixed alignment of sight attachments.

**v0.1 - 2020-03-03**

- WIP release.
