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
// This file cleans up a location after it is deactivated.

private ["_location", "_waypoints", "_loccacheitem", "_loccachegrp", "_hasplayers"];
_location = dep_locations select _this;
["Despawning location %1 (%2)", _this, (_location select 1)] spawn dep_fnc_log;

// If location is not clear, store all objects
if (!(_location select 7)) then {
    _loccache = [];
    _loccacheobjs = [];
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
    _loccache set [0, _loccacheobjs];
    
    // Store all groups
    _loccachegrps = [];
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
    _loccache set [1, _loccachegrps];
    
    // Store all civilians
    _loccachegrps = [];
    {
        _loccachegrp = [];
        _group = _x;
        _waypoints = [_group] call dep_fnc_getwaypoints;
        {
            if (alive _x) then {
                _loccacheitem = [];
                _loccacheitem set [0, getPosATL _x];            // Position
                _loccacheitem set [1, direction _x];            // Direction
                _loccacheitem set [2, typeOf _x];               // Kind
                _loccacheitem set [3, damage _x];               // Health
                _loccacheitem set [4, []];                      // Crew
                _loccacheitem set [5, _waypoints];              // Waypoints
                _loccachegrp = _loccachegrp + [_loccacheitem];
            };
        } foreach (units _group); // foreach unit in group
        if ((count _loccachegrp) > 0) then { _loccachegrps = _loccachegrps + [_loccachegrp]; };
    } foreach (_location select 10); // foreach civilian group
    _loccache set [2, _loccachegrps];
    
    dep_loc_cache set [_this , _loccache];
} else {
    dep_loc_cache set [_this , []];
};

// Groups
{
    {
        if (!isNull _x) then { 
            deleteVehicle _x; 
        };
    } forEach (units _x);
    if ((count units _x) == 0) then {
        deleteGroup _x;
    };
} foreach (_location select 4);

// Civilians
{
    {
        if (!isNull _x) then {
            if (vehicle _x != _x) then { deleteVehicle (vehicle _x); }; 
            deleteVehicle _x; 
        };
    } forEach (units _x);
    if ((count units _x) == 0) then {
        deleteGroup _x;
    };
} foreach (_location select 10);

// Objects
if (!(_location select 7)) then {
    // Clear all objects if location is not clear
    {
        _obj = _x;
        if (!isNull _obj) then {
            if (_obj isKindOf "Tank" || _obj isKindOf "Car") then {
                dep_total_veh = dep_total_veh - 1;
            };
            _hasplayers = false;
            {
                _unit = _x;
                if (isPlayer _unit) exitWith { _hasplayers = true; };
            } foreach (crew _obj);
            if (!_hasplayers) then { deleteVehicle _obj; }; // Don't clean up objects when players are in it
        };
    } foreach (_location select 8);
};

_location set [3, false];
_location set [4, []];
_location set [6, 0];
_location set [8, []];
_location set [10, []];
dep_locations set [_this, _location];
true;