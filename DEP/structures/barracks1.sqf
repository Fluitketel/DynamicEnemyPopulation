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
// This file spawns barracks type 1.

private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_building","_totalenemies","_groups","_objects"];
_pos 				= _this select 0; // Camp position
_dir 				= _this select 1; // Camp direction

// Try to align the camp with the nearest road
_road = [_pos, 50] call dep_fnc_nearestroad;
if !(isNull _road) then {
    _dir = [_road] call dep_fnc_roaddir;
};

_totalenemies = 0;
_groups = [];
_objects = [];

_building = (["Land_Cargo_HQ_V1_F","Land_Cargo_HQ_V2_F","Land_Cargo_HQ_V3_F"] call BIS_fnc_selectRandom) createVehicle _pos;
_building setDir (_dir);

_newpos = [_building, 13, _dir] call BIS_fnc_relPos;
_prop = "Land_HBarrier_5_F" createVehicle _newpos;
_prop setDir (_dir);

_newpos = [_building, 13, (_dir + 90)] call BIS_fnc_relPos;
_prop = "Land_HBarrierBig_F" createVehicle _newpos;
_prop setDir (_dir + 90);

_newpos = [_building, 13, (_dir + 180)] call BIS_fnc_relPos;
_prop = "Land_HBarrier_5_F" createVehicle _newpos;
_prop setDir (_dir + 180);

_newpos = [_building, 13, (_dir + 270)] call BIS_fnc_relPos;
_prop = "Land_HBarrierBig_F" createVehicle _newpos;
_prop setDir (_dir + 270);

if ((random 1) < 0.5) then
{
    _newpos = [_building, 15, (_dir + 45)] call BIS_fnc_relPos;
    _prop = "Land_HBarrier_5_F" createVehicle _newpos;
    _prop setDir (_dir + 45);

    _newpos = [_building, 15, (_dir + 135)] call BIS_fnc_relPos;
    _prop = "Land_HBarrier_5_F" createVehicle _newpos;
    _prop setDir (_dir + 135);

    _newpos = [_building, 15, (_dir + 225)] call BIS_fnc_relPos;
    _prop = "Land_HBarrier_5_F" createVehicle _newpos;
    _prop setDir (_dir + 225);

    _newpos = [_building, 15, (_dir + 315)] call BIS_fnc_relPos;
    _prop = "Land_HBarrier_5_F" createVehicle _newpos;
    _prop setDir (_dir + 315);
};

_buildpos = _building call dep_fnc_buildingpositions;
_num_buildpos = ceil (random dep_max_ai_loc);
if (_num_buildpos < 4) then { _num_buildpos = 4; };

_campgroup = createGroup dep_side;
_groups = _groups + [_campgroup];
_totalenemies = _totalenemies + _num_buildpos;

for "_e" from 1 to _num_buildpos do {
    _newbuildpos = [];
    if ((count _buildpos) > 0) then {
        _newbuildpos = _buildpos call BIS_fnc_selectRandom;
        _buildpos = _buildpos - [_newbuildpos];
    } else {
        _newbuildpos = (getPos _building) findEmptyPosition [0,20];
        if ((count _newbuildpos) == 0) then { _newbuildpos = (getPos _building); };
    };
    _soldiername = dep_guer_units call BIS_fnc_selectRandom;
    
    _soldier = [_campgroup, _soldiername, _newbuildpos] call dep_fnc_createunit;
    _soldier setDir (random 360); 
};
doStop (units _campgroup);

{
    if ((_x select 2) > 3) exitWith
    {
        _newpos = ATLToASL _x;
        _gun1 = objNull;
        if (random 1 < 0.3) then {
            _gun1 = dep_static_gmg createVehicle _newpos;
        } else {
            _gun1 = dep_static_hmg createVehicle _newpos;
        };
        _gun1 setPosASL _newpos;
        _gun1 setDir _dir;
        _objects = _objects + [_gun1];
        _gunner1 = [_campgroup, dep_u_g_soldier, _x] call dep_fnc_createunit;
        _gunner1 assignAsGunner _gun1;
        _gunner1 moveInGunner _gun1;
        _gunner1 setDir _dir;
        _totalenemies = _totalenemies + 1;
    };
} foreach _buildpos;
[_campgroup] spawn dep_fnc_enemyspawnprotect;

[_totalenemies,_groups,_objects];