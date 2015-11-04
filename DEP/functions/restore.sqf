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
// This file restores a previously activated location.

private ["_loccache","_objects","_groups","_civilians","_grp","_obj","_pos","_unit","_waypoints","_totalgroups","_totalgroupsciv","_totalenemies","_totalobjects","_crewunit","_objeach","_vehname","_veh"];

_loccache = dep_loc_cache select _this;
if ((count _loccache) == 0) exitWith { false; };

_location = dep_locations select _this;

["Restoring location %1 (%2)", _this, (_location select 1)] spawn dep_fnc_log;

_locpos = _location select 0;

_objects = _loccache select 0;
_groups = _loccache select 1;
_civilians = _loccache select 2;

_totalgroups = [];
_totalgroupsciv = [];
_totalenemies = 0;
_totalobjects = [];

{
    _objeach = _x;
    _pos = _objeach select 0;
    _obj = objNull;
    switch (_objeach select 2) do {
        case "ATMine": {
            _obj = createMine ["ATMine", _pos, [], 0];
            dep_side revealMine _obj;
        };
        default {
            if (_pos distance _locpos > (_location select 2)) then {
                // Prevent objects from spawning outside the location
                _list = _locpos nearRoads (_location select 2);
                if ((count _list) > 0) then
                {
                    _road = _list call BIS_fnc_selectRandom;
                    _pos = (getPos _road);
                } else {
                    _pos = _locpos findEmptyPosition[0, _location select 2];
                };
            };
            _obj = (_objeach select 2) createVehicle _pos;
            _newpos = ATLToASL _pos;
            _obj setPosASL _newpos;
        };
    };
    _totalobjects = _totalobjects + [_obj];
    _obj setDir (_objeach select 1);
    _damage = (_objeach select 3);
    if (typeName (_damage) == "ARRAY") then 
    {
        _selections = _damage select 0;
        _gethit = _damage select 1;
        _obj setVariable ["selections", _selections];
        _obj setVariable ["gethit", _gethit];
        {
            _damageloc = _x;
            _index = _selections find _damageloc;
            _setdamage = _gethit select _index;
            if (_setdamage > 0) then
            {
                _obj setHit [_damageloc, _setdamage];
            };
        } forEach _selections;
    } else {
        _obj setDamage _damage;
    };
    if (_obj isKindOf "Tank" || _obj isKindOf "Car") then { [_obj] spawn dep_fnc_vehicledamage; };
    
    if ((count (_objeach select 4)) > 0) then {
        _grp = createGroup dep_side;
        _totalgroups = _totalgroups + [_grp];
        {
            _crewunit = _x;
            if ((count _crewunit) > 0) then
            {
                _unit = [_grp, (_crewunit select 0), _pos] call dep_fnc_createunit;
                _totalenemies = _totalenemies + 1;
                _roles = _crewunit select 1;
                
                if ((count _roles) > 0) then {
                    _role = _roles select 0;
                    switch (_role) do {
                        case "Driver";
                        case "driver": {
                            _unit assignAsDriver _obj;
                            _unit moveInDriver _obj;
                        };
                        case "Turret";
                        case "turret": {
                            _unit assignAsGunner _obj;
                            _unit moveInGunner _obj;
                        };
                        case "Cargo";
                        case "cargo": {
                            _unit assignAsCargo _obj;
                            _unit moveInCargo _obj;
                        };
                        default {
                            _unit assignAsCommander _obj;
                            _unit moveInCommander _obj;
                        };
                    };
                };
            };
        } foreach (_objeach select 4); // respawn crew
        _return = [_locpos, _grp] call dep_fnc_vehiclepatrol;
    };
} foreach _objects;

{
    _grp = createGroup dep_side;
    _totalgroups = _totalgroups + [_grp];
    _waypoints = [];
    _group = _x;
    {
        _obj = [_grp, (_x select 2), (_x select 0)] call dep_fnc_createunit;
        _newpos = ATLToASL (_x select 0);
        _obj setPosASL _newpos;
        _totalenemies = _totalenemies + 1;
        _obj setDir (_x select 1);
        _obj setDamage (_x select 3);
		_restore_init = (_x select 6);
		if (typeName _restore_init == "ARRAY") then
		{
			_vars = [_obj];
			_vars = _vars + (_restore_init select 0);
			_vars spawn (_restore_init select 1);
		};
    } foreach _group;
    switch ((_location select 1)) do
    {
        default { 
            _unit = _group select 0;
            if (count _unit > 5) then {
                _waypoints = _unit select 5;
                if (count _waypoints > 0) then {
                    [_grp, _waypoints] spawn dep_fnc_setwaypoints;
                };
            };
        };
    };
    
    // If the group has no waypoints, stop them from moving into formation
    if ((count (waypoints (leader _grp))) <= 1 && (count _waypoints) <= 1 ) then
    {
        doStop (units _grp);
    };
} foreach _groups;

{
    _grp = createGroup civilian;
    _totalgroupsciv = _totalgroupsciv + [_grp];
    _group = _x;
    _obj = objNull;
    
    {
        _pos = (_x select 0);
        // Prevent objects from spawning outside the location
        if (_pos distance _locpos > (_location select 2)) then {
            _pos = _locpos findEmptyPosition[0, 20];
        };
        _obj = [_grp, (_x select 2), _pos] call dep_fnc_createcivilian;
        _newpos = ATLToASL (_pos);
        _obj setPosASL _newpos;
        _obj setDir (_x select 1);
        _obj setDamage (_x select 3);
    } foreach _group;
    [_grp] spawn dep_fnc_enemyspawnprotect;

    _unit = _group select 0;
    if (count _unit > 5) then {
        _waypoints = _unit select 5;
        if (count _waypoints > 0) then {
            [_grp, _waypoints] spawn dep_fnc_setwaypoints;              
        };
    };
    
    if ((_location select 1) == "patrol") then 
    {
        _vehname = dep_civ_veh call BIS_fnc_selectRandom;
        _veh = _vehname createVehicle ((position _obj) findEmptyPosition[0, 20, _vehname]);
        _obj assignAsDriver _veh;
        _obj moveInDriver _veh;
        [_veh] spawn dep_fnc_vehicledamage;
    };
} foreach _civilians;

_location set [3, true];
_location set [4, _totalgroups];
_location set [6, _totalenemies];
_location set [8, _totalobjects];
_location set [10, _totalgroupsciv];
dep_locations set [_this, _location];

true;