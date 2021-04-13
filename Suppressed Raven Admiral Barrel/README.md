# Suppressed Raven Admiral Barrel

Latest version [v1.1](https://github.com/fragtrane/Payday-2-Mods/raw/master/Suppressed%20Raven%20Admiral%20Barrel/Suppressed_Raven_Admiral_Barrel_v1.1.zip).

This mod can also be found on [Mod Workshop](https://modworkshop.net/mod/26914).

## Overview

Demo: https://www.youtube.com/watch?v=AyhWtQ63WyQ

This mod turns the Raven Admiral's legendary barrel into a silencer. It does not let you use the barrel without owning the skin. It also does not give any stats that are not possible in the base game. Stat changes:

- Admiral Barrel: equal to the combined stats of the Short Barrel and The Silent Killer Suppressor. By happy accident, this results in a net effect of +2 concealment, so the Optical Illusions aced bug will give you +3 concealment which is exactly what you would get if you were using The Silent Killer Suppressor in the base game. So stats-wise, it is completely identical to a vanilla stealth Raven.

Key features and options:

- **Silencer Effect for Raven Admiral Barrel:** The Raven Admiral's legendary barrel now has a silencer effect, allowing you to use it in stealth without equipping a suppressor and destroying the look of the gun. As with all silencers, Dragon's Breath rounds are not allowed.
- **OSA/SDSS Integration:** Both [Optional Skin Attachments](https://github.com/fragtrane/Payday-2-Mods/tree/master/Optional%20Skin%20Attachments) and [Super Duper Skin Swapper](https://github.com/fragtrane/Payday-2-Mods/tree/master/Super%20Duper%20Skin%20Swapper) have the option to display legendary weapon mods in the weapon modification menu. If you are using the Suppressed Raven Admiral Barrel mod, the name of the legendary barrel will be changed to "Admiral Suppressed Barrel".
- **AOLA Compatible**: If you use the [Add-On Legendary Attachments](https://github.com/fragtrane/Payday-2-Mods/tree/master/Add-On%20Legendary%20Attachments) mod, the stats of the add-on attachments will also be changed.

## IMPORTANT: Client Detection Risk

The mod works as both host and client. However, if you are a client, the host will see you with the wrong detection risk which can cause problems in stealth if you are not aware, because the host calculates the detection. This happens because you have modified the stats of your attachments, but other players can only see the original stats. TLDR:

- Real Admiral Barrel: other players see your concealment DECREASED by 2 points, i.e. HIGHER detection risk (bad).
- Add-On Admiral Barrel: other players will see your concealment INCREASED by 2 points, i.e. LOWER detection risk (good).

The real Admiral Barrel only decreases your concealment by 2 points so this should not be a big issue. The Add-On Admiral Barrel is safe to use as a client.

Note: if the host has also installed the mod, then the real legendary attachments will have their stats calculated correctly by the host and can be safely used. The add-on legendary attachments will still have the wrong stats because they are synced as different parts.

## Host/Client Interactions

This mod has been tested both as client and host with vanilla and modded peers.

Silencer effect:
- The silencer effect works as both client and host for both the real and add-on barrel, regardless of whether or not the host as the mod. Guards will not be alerted, so you can safely use it in stealth.

Gunshot sound:
- Real Admiral Barrel: gunshots from the real Admiral Barrel will always sound suppressed to you. If someone without the mod shoots with the real Admiral Barrel, it will still sound suppressed to you (when it is in fact loud and will alert guards).
- Add-On Admiral Barrel: if you have AOLA installed, gunshots from the Add-On Admiral Barel will always sound suppressed to you. If someone without the mod shoots with the Add-On Admiral Barrel, it will sound suppressed to you (when it is in fact loud and will alert guards). Players who do not have AOLA will always hear a loud gunshot from the Add-On Admiral Barrel.

Silencer icon in crew setup:
- Real Admiral Barrel: when using the mod, anyone with the real Admiral Barrel equipped will show a silencer icon, even if they do not have the mod (so their shots will alert guards).
- Add-On Admiral Barrel: if you equip the Add-On Admiral Barrel while using the mod, the gun will show a silencer icon for you. For other players, it is not possible to see the silencer icon for the Add-On Admiral Barrel.

In order to reduce the detection risk offset with AOLA attachments, this mod has changed the synced parts (based-on parts) for the following AOLA attachments:

- Add-On Admiral Barrel: synced as Short Barrel.

## Installation [BLT]

This mod requires [SuperBLT](https://superblt.znix.xyz) for automatic updates.

This is a BLT mod. Download [`Suppressed_Raven_Admiral_Barrel_v1.1.zip`](https://github.com/fragtrane/Payday-2-Mods/raw/master/Suppressed%20Raven%20Admiral%20Barrel/Suppressed_Raven_Admiral_Barrel_v1.1.zip) and extract the entire contents to your `mods` folder.

The location of the `mods` folder depends on where you installed the game; typically it can be found here:

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

## Contact

Steam: [id/fragtrane](https://steamcommunity.com/id/fragtrane)

Reddit: [/u/fragtrane](https://www.reddit.com/user/fragtrane)

## Changelog

**v1.1 - 2021-04-11**

- Added sync override for based-on part when using AOLA to reduce detection risk sync issues.
- Compatibility improvements/futureproofing.

**v1.0 - 2020-03-21**

- Initial release.
