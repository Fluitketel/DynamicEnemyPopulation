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
// This file spawns an AT camp.

private ["_pos", "_dir", "_newpos", "_newdir", "_campgroup", "_prop", "_soldier", "_numberofbarriers","_totalenemies","_groups","_objects"];
_pos = _this select 0; // Camp position
_dir = _this select 1; // Camp direction

_totalenemies = 0;
_groups = [];
_objects = [];

_campgroup = createGroup dep_side;
_campgroup setFormDir _dir;
_groups = _groups + [_campgroup];

_prop = objNull;
switch (dep_side) do 
{
    case east: {
        _prop = "CamoNet_OPFOR_open_F" createVehicle _pos;
    };
    case west: {
        _prop = "CamoNet_BLUFOR_open_F" createVehicle _pos;
    };
    default {
        _prop = "CamoNet_INDP_open_F" createVehicle _pos;
    };
};
_prop setDir (_dir + 180);

if (random 1 < 0.5) then {
    _gun1 = objNull;
    if (random 1 < 0.3) then {
        _gun1 = dep_static_hmg createVehicle _pos;
    } else {
        _gun1 = dep_static_at createVehicle _pos;
    };
    waitUntil {alive _gun1};
    _gun1 setDir _dir;
    _objects = _objects + [_gun1];
    _newpos = [_pos, 1, (_dir + 180)] call BIS_fnc_relPos;
    _gunner1 = [_campgroup, dep_u_g_soldier, _newpos] call dep_fnc_createunit;
    _gunner1 assignAsGunner _gun1;
    _gunner1 moveInGunner _gun1;
    _gunner1 setDir _dir;
    _totalenemies = _totalenemies + 1;
};

if ((random 1) < 0.6) then
{
    _numberofbarriers = 10;
    _newdir = 0;
    for "_c" from 1 to _numberofbarriers do
    {
        _newpos = [_pos, 9, _newdir] call BIS_fnc_relPos;
        _prop = "Land_CncBarrier_F" createVehicle _newpos;
        _prop setDir _newdir;
        _newdir = _newdir + (360 / _numberofbarriers);
    };
};

_prop = ([dep_box_ammo, dep_box_special, dep_box_weapons, dep_box_ord] call BIS_fnc_selectRandom) createVehicle _pos;
_prop setDir _dir;

_soldier = [_campgroup, dep_u_g_sl, _pos] call dep_fnc_createunit;
doStop _soldier;
for "_c" from 1 to (1 + round (random 1)) do { 
    _newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
    _soldier = [_campgroup, dep_u_g_at, _newpos] call dep_fnc_createunit;
    doStop _soldier;
    _totalenemies = _totalenemies + 1;
    
    _newpos = [_pos, ceil (random 10), random 360] call BIS_fnc_relPos;
    _soldier = [_campgroup, ([dep_u_g_medic, dep_u_g_ar, dep_u_g_gl] call BIS_fnc_selectRandom), _newpos] call dep_fnc_createunit;
    doStop _soldier;
    _totalenemies = _totalenemies + 1;
};
[_totalenemies,_groups,_objects];