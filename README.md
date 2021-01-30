# GZDoom_Utilities
A list of useful stand-alone utilities I wrote for GZDoom. Detailed usage instructions of each utility is included in each folder, on the main file. Be sure to read the check the permissions on the files inside as well.

## MD5
A class to obtain the MD5 class of a string. This is specifically intended to be used with the output of `Wads.ReadLump`, but can be used with any string. Originally written for [Fullscreen Status Bar Mod](https://github.com/3saster/fullscrn_huds).

## GhostMonsterHandler
An event handler to allow restoring the ghost monster bug as if it was exposed to MAPINFO (this replicates the effect of GZDoom's `vileghosts` compat parameter, which is not exposed to MAPINFO at the moment, and does not appear will be exposed anytime soon). Note this still requires the `compat_corpsegibs` compatibility option to be set.

## AnimatedHandler
An event handler that determines what textures are animated, by parsing the ANIMDEFS and ANIMATED lumps. The animated textures are determined once, at start-up, then one can use the handler's `isAnimated` method to check if a texture is animated. Originally written for [Beautiful Doom](https://github.com/jekyllgrim/Beautiful-Doom).

## DEHACKEDHandler
An event handler that determines what actors were likely modified by DEHACKED, by parsing the DEHACKED lumps. The suspected modified actors are determined once, at start-up, then one can use the handler's `isDehacked` method to check if a class has likely been modified. It is relatively simple in what it checks (and does not provide specific information on what was modified for each actor), but is fairly effective. False negatives should not occur, but false positives may rarely occur. Originally written for [Beautiful Doom](https://github.com/jekyllgrim/Beautiful-Doom).