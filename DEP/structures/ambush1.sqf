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
// This file spawns an ambush at the given location.
private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_gate", "_groups", "_totalenemies", "_objects"];
_pos    = _this select 0;
_dir    = _this select 1;

_groups = [];
_totalenemies = 0;
_objects = [];

if ((random 1) < 0.5 && dep_mines) then 
{
	_newpos = _pos;
	_newpos set [2, 0.01];
	_mine = createMine ["ATMine", _newpos, [], 0];
	if (dep_debug) then {
		_m = createMarker[format["ambush%1", (str _newpos)], _newpos];
		_m setMarkerType "Minefield";
	};
};

_campgroup = createGroup dep_side;
_groups = _groups + [_campgroup];
_campgroup setFormDir _dir;

_vegetation = [_pos, 20] call dep_fnc_vegetation;

_y = count _vegetation;
if (_y > dep_max_ai_loc) then { _y = dep_max_ai_loc; };
if (_y < 4) then { _y = 4; };

{
	if (_totalenemies >= dep_max_ai_loc) exitWith {};
	_soldiername = dep_guer_units call BIS_fnc_selectRandom;
	_newpos = getPos _x;
	_newpos set [2, 0];
	_soldier = [_campgroup, _soldiername, _newpos] call dep_fnc_createunit;
	doStop _soldier;
	_soldier lookAt _pos;
	_soldier setUnitPos "DOWN";
	_soldier setVariable ["dep_restore_init", [[_pos], {doStop (_this select 0); (_this select 0) lookAt (_this select 1); (_this select 0) setUnitPos "DOWN";}]];
	_totalenemies = _totalenemies + 1;
} forEach _vegetation;
[_campgroup] spawn dep_fnc_enemyspawnprotect;

[_totalenemies, _groups, _objects];