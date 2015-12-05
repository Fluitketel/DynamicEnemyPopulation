/*  Copyright 2015 Fluit
    
    This file is part of Dynamic Enemy Population.

    Dynamic Enemy Population is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation version 3 of the License.

    Dynamic Enemy Population is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Dynamic Enemy Population.  If not, see <http://www.gnu.org/licenses/>.
*/
// This file creates all the server functions

dep_fnc_log         			= compile preprocessFileLineNumbers (dep_directory+"functions\log.sqf");
dep_fnc_random_position         = compile preprocessFileLineNumbers (dep_directory+"functions\randommappos.sqf");
dep_fnc_outsidesafezone         = compile preprocessFileLineNumbers (dep_directory+"functions\outsidesafezone.sqf");
dep_fnc_createunit              = compile preprocessFileLineNumbers (dep_directory+"functions\createunit.sqf");
dep_fnc_createcivilian          = compile preprocessFileLineNumbers (dep_directory+"functions\createcivilian.sqf");
dep_fnc_isenterable             = compile preprocessFileLineNumbers (dep_directory+"functions\isenterable.sqf");
dep_fnc_setwaypoints            = compile preprocessFileLineNumbers (dep_directory+"functions\setwaypoints.sqf");
dep_fnc_getwaypoints            = compile preprocessFileLineNumbers (dep_directory+"functions\getwaypoints.sqf");
dep_fnc_vehiclepatrol           = compile preprocessFileLineNumbers (dep_directory+"functions\vehiclepatrol.sqf");
dep_fnc_housepatrol             = compile preprocessFileLineNumbers (dep_directory+"functions\housepatrol.sqf");
dep_fnc_unitpatrol              = compile preprocessFileLineNumbers (dep_directory+"functions\unitpatrol.sqf");
dep_fnc_enterablehouses         = compile preprocessFileLineNumbers (dep_directory+"functions\enterablehouses.sqf");
dep_fnc_findmilitarybuildings   = compile preprocessFileLineNumbers (dep_directory+"functions\findmilitarybuildings.sqf");
dep_fnc_findnearhouses          = compile preprocessFileLineNumbers (dep_directory+"functions\findnearhouses.sqf");
dep_fnc_buildingpositions       = compile preprocessFileLineNumbers (dep_directory+"functions\buildingpositions.sqf");
dep_fnc_vehicledamage           = compile preprocessFileLineNumbers (dep_directory+"functions\vehicledamage.sqf");
dep_fnc_nearestroad             = compile preprocessFileLineNumbers (dep_directory+"functions\nearestroad.sqf");
dep_fnc_roaddir                 = compile preprocessFileLineNumbers (dep_directory+"functions\roaddir.sqf");
dep_fnc_roadblock               = compile preprocessFileLineNumbers (dep_directory+"structures\roadblock.sqf");
dep_fnc_ambush1               	= compile preprocessFileLineNumbers (dep_directory+"structures\ambush1.sqf");
dep_fnc_ambush2               	= compile preprocessFileLineNumbers (dep_directory+"structures\ambush2.sqf");
dep_fnc_atcamp                  = compile preprocessFileLineNumbers (dep_directory+"structures\atcamp.sqf");
dep_fnc_mortarcamp              = compile preprocessFileLineNumbers (dep_directory+"structures\mortarcamp.sqf");
dep_fnc_barracks1               = compile preprocessFileLineNumbers (dep_directory+"structures\barracks1.sqf");
dep_fnc_barracks2               = compile preprocessFileLineNumbers (dep_directory+"structures\barracks2.sqf");
dep_fnc_insurgentcamp1          = compile preprocessFileLineNumbers (dep_directory+"structures\insurgentcamp1.sqf");
dep_fnc_aacamp1                 = compile preprocessFileLineNumbers (dep_directory+"structures\aacamp1.sqf");
dep_fnc_aacamp2                 = compile preprocessFileLineNumbers (dep_directory+"structures\aacamp2.sqf");
dep_fnc_restore                 = compile preprocessFileLineNumbers (dep_directory+"functions\restore.sqf");
dep_fnc_activate                = compile preprocessFileLineNumbers (dep_directory+"functions\activate.sqf");
dep_fnc_activate_aacamp         = compile preprocessFileLineNumbers (dep_directory+"functions\activate_aacamp.sqf");
dep_fnc_deactivate              = compile preprocessFileLineNumbers (dep_directory+"functions\deactivate.sqf");
dep_fnc_garrison                = compile preprocessFileLineNumbers (dep_directory+"functions\garrison.sqf");
dep_fnc_enemyspawnprotect       = compile preprocessFileLineNumbers (dep_directory+"functions\enemyspawnprotect.sqf");
dep_fnc_disable_ied             = compile preprocessFileLineNumbers (dep_directory+"functions\disable_ied.sqf");
dep_fnc_disable_ied_action      = compile preprocessFileLineNumbers (dep_directory+"functions\disable_ied_action.sqf");
dep_fnc_bridges      			= compile preprocessFileLineNumbers (dep_directory+"functions\bridges.sqf");
dep_fnc_vegetation      		= compile preprocessFileLineNumbers (dep_directory+"functions\vegetation.sqf");
dep_fnc_airpatrols      		= compile preprocessFileLineNumbers (dep_directory+"functions\airpatrols.sqf");