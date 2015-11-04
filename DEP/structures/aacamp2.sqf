/*  Copyright 2014 Fluit
    
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
// This file spawns anti air camp 2.
private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_ammo","_totalenemies","_groups","_objects"];
_pos = _this select 0; // Camp position
_dir = _this select 1; // Camp direction

// Try to align the camp with the nearest road
_road = [_pos, 100] call dep_fnc_nearestroad;
if !(isNull _road) then {
    _dir = [_road] call dep_fnc_roaddir;
};

_totalenemies = 0;
_groups = [];
_objects = [];

_campgroup = createGroup dep_side;
_campgroup setFormDir _dir + 180;
_groups = _groups + [_campgroup];

_ammo = dep_box_launchers createVehicle _pos;
_ammo setDir _dir;

_newpos = [_ammo, 6, _dir + 90] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
_prop = "Land_HBarrier_5_F" createVehicle _newpos;
_prop setDir _dir + 90;

_newpos = [_ammo, 6, _dir + 90] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir + 180] call BIS_fnc_relPos;
_prop = "Land_HBarrier_5_F" createVehicle _newpos;
_prop setDir _dir + 90;

_newpos = [_ammo, 5, _dir - 90] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir] call BIS_fnc_relPos;
_prop = "Land_HBarrier_5_F" createVehicle _newpos;
_prop setDir _dir - 90;

_newpos = [_ammo, 5, _dir - 90] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir + 180] call BIS_fnc_relPos;
_prop = "Land_HBarrier_5_F" createVehicle _newpos;
_prop setDir _dir - 90;

_newpos = [_ammo, 10, _dir] call BIS_fnc_relPos;
_tower = (["Land_HBarrier_5_F","Land_Cargo_House_V3_F"] call BIS_fnc_selectRandom) createVehicle _newpos;
_tower setDir _dir;

_newpos = [_ammo, 5, _dir + 180] call BIS_fnc_relPos;
_gun1 = dep_static_aa createVehicle _newpos;
waitUntil {alive _gun1};
_gun1 setDir _dir + 180;
_objects = _objects + [_gun1];
_newpos = [_newpos, 1, _dir] call BIS_fnc_relPos;
_gunner1 = [_campgroup, dep_u_soldier, _newpos] call dep_fnc_createunit;
waitUntil {alive _gunner1};
_gunner1 assignAsGunner _gun1;
_gunner1 moveInGunner _gun1;
_totalenemies = _totalenemies + 1;

_newpos = [_ammo, 11, _dir + 180] call BIS_fnc_relPos;
_prop = "Land_CncBarrier_stripes_F" createVehicle _newpos;
_prop setDir _dir;

_newpos = [_ammo, 10, _dir + 180] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir - 90] call BIS_fnc_relPos;
_prop = "Land_CncBarrier_F" createVehicle _newpos;
_prop setDir _dir + 30;

_newpos = [_ammo, 10, _dir + 180] call BIS_fnc_relPos;
_newpos = [_newpos, 4, _dir + 90] call BIS_fnc_relPos;
_prop = "Land_CncBarrier_F" createVehicle _newpos;
_prop setDir _dir - 30;

_soldier = [_campgroup, dep_u_sl, getPos _tower] call dep_fnc_createunit;
doStop _soldier;

_totalenemies = _totalenemies + 1;
for "_c" from 1 to (1 + round (random 1)) do
{ 
    _newpos = [_pos, round (random 5), random 360] call BIS_fnc_relPos;
    _soldier = [_campgroup, dep_u_aa, _newpos] call dep_fnc_createunit;
    doStop _soldier;
    _totalenemies = _totalenemies + 1;
    
    _newpos = [_pos, round (random 5), random 360] call BIS_fnc_relPos;
    _soldier = [_campgroup, dep_u_aaa, _newpos] call dep_fnc_createunit;
    doStop _soldier;
    _totalenemies = _totalenemies + 1;
};
[_totalenemies,_groups,_objects];