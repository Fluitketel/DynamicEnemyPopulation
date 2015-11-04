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
// This file spawns an insurgent camp.

private ["_pos", "_dir", "_newpos", "_newdir", "_campgroup", "_prop", "_soldier", "_numberofbarriers","_totalenemies","_groups","_objects"];
_pos = _this select 0; // Camp position
_dir = _this select 1; // Camp direction

_totalenemies = 0;
_groups = [];
_objects = [];

_campgroup = createGroup dep_side;
_campgroup setFormDir _dir;
_groups = _groups + [_campgroup];

_fire = "Campfire_burning_F" createVehicle _pos;
_newpos = [_pos, 2, (_dir - 70)] call BIS_fnc_relPos;
_prop = "Land_WoodPile_F" createVehicle _newpos;

_newpos = [_pos, 5, _dir] call BIS_fnc_relPos;
_gun1 = dep_static_hmg_tri createVehicle _newpos;
waitUntil {alive _gun1};
_gun1 setDir _dir;
_objects = _objects + [_gun1];
_newpos = [_newpos, 1, (_dir + 180)] call BIS_fnc_relPos;
_gunner1 = [_campgroup, dep_u_g_soldier, _newpos] call dep_fnc_createunit;
_gunner1 assignAsGunner _gun1;
_gunner1 moveInGunner _gun1;
_gunner1 setDir _dir;
_totalenemies = _totalenemies + 1;

_newpos = [_pos, 5, (_dir + 70)] call BIS_fnc_relPos;
_prop = "Land_Sleeping_bag_F" createVehicle _newpos;
_prop setDir (_dir + 90);
_newpos = [_pos, 5, (_dir + 110)] call BIS_fnc_relPos;
_prop = "Land_TentDome_F" createVehicle _newpos;
_prop setDir (_dir + 90);

for "_e" from 1 to 3 do {
    _newpos = (getPos _fire) findEmptyPosition [0,20];
    if ((count _newpos) == 0) then { _newpos = (getPos _fire); };
    _soldiername = dep_guer_units call BIS_fnc_selectRandom;
    
    _soldier = [_campgroup, _soldiername, _newpos] call dep_fnc_createunit;
    _soldier setDir (random 360);
	_totalenemies = _totalenemies + 1;
};
[_campgroup] spawn dep_fnc_enemyspawnprotect;
doStop (units _campgroup);

{
    if ((_x distance _fire) <= 5 && (vehicle _x) == _x) then {
        _x setBehaviour "SAFE";
		_x lookAt _fire; 
		_x switchMove "AmovPsitMstpSlowWrflDnon_Smoking"; 
    };
} forEach(units _campgroup);
[_totalenemies,_groups,_objects];