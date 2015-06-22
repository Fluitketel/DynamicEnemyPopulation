DYNAMIC ENEMY POPULATION for Arma 3
===================================
  by Fluit
    
Dynamic Enemy Population or DEP is a script for Arma 3 which creates enemy zones all across the island 
in a multiplayer environment. DEP uses it's own caching system and only generates enemies when players
are close to the location and cleans up the enemies if players leave the area.

> **DEP includes:**
> - units in buildings
> - units patroling outside buildings
> - patroling vehicles
> - roadblocks
> - anti-air camps
> - mortar camps
> - anti-tank camps
> - IED's
> - mines (AT & APERS)

Installation
==============================
 - Copy the DEP folder to your mission root folder
 - Put the following code in your mission's init.sqf:
```sqf
  [] execVM "DEP\init.sqf";
```
 - Modify the DEP/settings.sqf file to set custom units and vehicles, custom enemy amounts and more!
 
Credits
==============================
I would like to thank the Dedicated Rejects community for the powerful server to test and play on.
Special thanks to the Arma section for helping me improve my scripts and for all the fun we have while playing!
  ~ Fluit

Donate
==============================
If you like my work, please [donate on paypal](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PV5587YLXXZPA).
