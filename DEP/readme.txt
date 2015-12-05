DYNAMIC ENEMY POPULATION 
  by Fluit 
    bugs & feedback :   https://github.com/Fluitketel/DynamicEnemyPopulation or fluitketel@outlook.com
      last revision :   2015-12-05
            version :   0.5.1
    
This script creates enemies all across the map including:
 - units in buildings
 - units patroling outside buildings
 - patroling vehicles
 - roadblocks
 - anti-air camps
 - mortar camps
 - anti-tank camps
 - IED's
 - mines (AT & APERS)

Installation
==============================
 - Copy the DEP folder to your mission root folder
 - Put this code in your mission's init.sqf: 
   [] execVM "DEP\init.sqf";
 - Modify the DEP\settings.sqf file to set custom units and vehicles, custom enemy amounts and more!
 
Debug map info
==============================
When using debug mode, enemy zones will be visible on the map.
Reference the following list for the color codes:
- Red           patrol area (vehicular and/or infantry)
- Blue          AA camp
- Brown         various types of camps
- Pink          military area
- Green         roadblock
- Yellow        residential
- Blue lines    safe zones

Settings
==============================
For a complete list of possible settings visit:
https://fluitarma.wordpress.com/dep-settings/

Credits
============================== 
I would like to thank all my Arma buddies for helping me improve my scripts and for all the fun we have while playing!