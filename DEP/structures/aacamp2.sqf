/*  Copyright 2016 Fluit
    
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
private ["_pos", "_dir", "_newpos", "_campgroup", "_soldier", "_ammo","_totalenemies","_groups","_objects"];
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

_objs = [
	["Land_BagFence_01_round_green_F",[-0.0239258,-2.19629,-0.00130129],179.93,1,0,[],"","",true,false], 
	["Land_BagFence_01_round_green_F",[0.0180664,2.56201,-0.00130129],0,1,0,[],"","",true,false], 
	["B_static_AA_F",[0.13623,-3.6123,-0.0702686],179.934,1,0,[],"aa2","",true,false], 
	["B_static_AA_F",[-0.138672,3.97656,-0.0702686],0.00401756,1,0,[],"aa1","",true,false], 
	["Land_BagFence_01_round_green_F",[-1.66064,-3.89014,-0.00130129],89.9072,1,0,[],"","",true,false], 
	["Land_BagFence_01_round_green_F",[1.73682,-3.93115,-0.00130129],269.908,1,0,[],"","",true,false], 
	["Land_BagFence_01_round_green_F",[1.65771,4.24512,-0.00130129],270,1,0,[],"","",true,false], 
	["Land_BagFence_01_round_green_F",[-1.74512,4.2915,-0.00130129],90,1,0,[],"","",true,false], 
	["Land_BagFence_01_round_green_F",[0.0522461,-5.55908,-0.00130129],359.906,1,0,[],"","",true,false], 
	["Land_BagFence_01_round_green_F",[-0.0498047,5.92432,-0.00130129],180,1,0,[],"","",true,false]
];
_return = [_pos, _dir, _objs] call BIS_fnc_ObjectsMapper;

_newpos = getPos aa1;
_newdir = getDir aa1;
deleteVehicle aa1;
_gun1 = createVehicle [dep_static_aa, _newpos, [], 0, "CAN_COLLIDE"];
_objects = _objects + [_gun1];
_gun1 setDir _newdir;
_gunner1 = [_campgroup, dep_u_soldier, _pos] call dep_fnc_createunit;
_totalenemies = _totalenemies + 1;
_gunner1 assignAsGunner _gun1;
_gunner1 moveInGunner _gun1;
_gunner1 setDir _newdir;

_newpos = getPos aa2;
_newdir = getDir aa2;
deleteVehicle aa2;
_gun1 = createVehicle [dep_static_aa, _newpos, [], 0, "CAN_COLLIDE"];
_objects = _objects + [_gun1];
_gun1 setDir _newdir;
_gunner1 = [_campgroup, dep_u_soldier, _pos] call dep_fnc_createunit;
_totalenemies = _totalenemies + 1;
_gunner1 assignAsGunner _gun1;
_gunner1 moveInGunner _gun1;
_gunner1 setDir _newdir;

_newpos = _pos findEmptyPosition[0, 10, dep_box_launchers];
if ((count _newpos) == 3) then {
    _ammo = dep_box_launchers createVehicle _newpos;
    _ammo setDir _dir;
};

_newpos = _pos findEmptyPosition[0, 20, dep_u_sl];
_soldier = [_campgroup, dep_u_sl, _newpos] call dep_fnc_createunit;
doStop _soldier;
_totalenemies = _totalenemies + 1;

for "_c" from 1 to (ceil random (dep_max_ai_loc - _totalenemies)) do
{ 
    _soldiername = [dep_u_aa, dep_u_aaa] call BIS_fnc_selectRandom;
    _newpos = _pos findEmptyPosition[0, 20, _soldiername];
    _soldier = [_campgroup, _soldiername, _newpos] call dep_fnc_createunit;
    doStop _soldier;
    _totalenemies = _totalenemies + 1;
};

[_totalenemies,_groups,_objects];