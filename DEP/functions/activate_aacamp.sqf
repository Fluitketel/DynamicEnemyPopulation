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
// This file activates an anti-air camp.

private ["_location","_pos","_return"];

_cache = dep_loc_cache select _this;
if ((count _cache) > 0) exitWith {
    _result = _this call dep_fnc_restore;
    true;
};

_location = dep_locations select _this;
_pos = _location select 0;

["Spawning location %1 (%2)", _this, (_location select 1)] spawn dep_fnc_log;

_return = [];
if ((random 1) <= 0.5) then {
    _return = [_pos, random 360] call dep_fnc_aacamp1;
} else {
    _return = [_pos, random 360] call dep_fnc_aacamp2;
};

["%2 enemies created at location %1", _this, (_return select 0)] spawn dep_fnc_log;

_location set [3, true];
_location set [4, (_return select 1)];
_location set [6, (_return select 0)];
_location set [8, (_return select 2)];
// In case respawn in enabled, save units and objects
_loccacheobjs = [];
_loccachegrps = [];
// Store all objects
{
    _obj = _x;
    _hasplayers = false;
    if (!isNull _obj) then {
        if (alive _obj) then {
            _loccacheitem = [];
            _loccacheitem set [0, getPosATL _obj];             // Position
            _loccacheitem set [1, direction _obj];            // Direction
            _loccacheitem set [2, typeOf _obj];               // Kind
            if (_obj isKindOf "Tank" || _obj isKindOf "Car") then {
                _selections = _obj getVariable ["selections", []];
                _gethit = _obj getVariable "gethit";
                _loccacheitem set [3, [_selections, _gethit]];
            } else {
                _loccacheitem set [3, damage _obj];               // Health
            };
            
            _crew = [];
            {
                _unit = _x;
                if (isPlayer _unit) exitWith { _hasplayers = true; }; // Don't clean up objects when players are in it
                
                _crewunit = [];
                if (alive _unit) then {
                    _crewunit set [0, typeOf _unit];
                    _crewunit set [1, assignedVehicleRole _unit];
                };
                _crew = _crew + [_crewunit];
            } foreach (crew _obj);
            _loccacheitem set [4, _crew];                 // Optional crew
            if (!_hasplayers) then
            {
                _loccacheobjs = _loccacheobjs + [_loccacheitem];
            };
        };            
    };
} foreach (_location select 8);
// Store all groups
{
    _loccachegrp = [];
    _group = _x;
    _waypoints = [_group] call dep_fnc_getwaypoints;
    {
        if (alive _x && vehicle _x == _x) then {
            _pos = getPosATL _x;
            if !(isNil {_x getVariable "dep_position"}) then
            {
                _pos = _x getVariable "dep_position";
            };
            _restore_init = "";
            if !(isNil {_x getVariable "dep_restore_init"}) then
            {
                _restore_init = _x getVariable "dep_restore_init";
            };
            _loccacheitem = [];
            _loccacheitem set [0, _pos];                    // Position
            _loccacheitem set [1, direction _x];            // Direction
            _loccacheitem set [2, typeOf _x];               // Kind
            _loccacheitem set [3, damage _x];               // Health
            _loccacheitem set [4, []];                      // Crew
            _loccacheitem set [5, _waypoints];              // Waypoints
            _loccacheitem set [6, _restore_init];           // Code to execute on restore
            _loccachegrp = _loccachegrp + [_loccacheitem];
        };
    } foreach (units _group); // foreach unit in group
    if ((count _loccachegrp) > 0) then { _loccachegrps = _loccachegrps + [_loccachegrp]; };
} foreach (_location select 4); // foreach group

_location set [13, _loccacheobjs];
_location set [14, _loccachegrps];
dep_locations set [_this, _location];
true;