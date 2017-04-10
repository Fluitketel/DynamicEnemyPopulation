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
 
// SETTINGS
_handle = [] execVM dep_directory+"settings.sqf";
waitUntil{scriptDone _handle};

// PUBLIC VARIABLES
_handle = [] execVM dep_directory+"init\server_variables.sqf";
waitUntil{scriptDone _handle};

// FUNCTIONS
_handle = [] execVM dep_directory+"init\server_functions.sqf";
waitUntil{scriptDone _handle};

if (dep_debug) then {
    waitUntil {time > 0};
};

private ["_locations","_pos","_flatPos","_building","_units","_createdzones"];
"Initializing DEP . . ." call dep_fnc_log;

_totaltime = 0;
_starttime = 0;
_parttime = 0;
_createdzones = 0;

// *********************
// MILITARY BUILDINGS
// *********************
if (dep_military > 0) then
{
	if (dep_debug) then {
		"Finding military buildings" spawn dep_fnc_log;
		_starttime = time;
	};
	_buildings = [];
	if (dep_military > 0) then {
		_buildings = [dep_map_center, dep_map_radius] call dep_fnc_findmilitarybuildings;
	};
	_numbuildings = (count _buildings);

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
		_starttime = time;
		"Creating military areas" spawn dep_fnc_log;
	};
	_createdzones = 0;
	for [{_x=0}, {_x<=_numbuildings}, {_x=_x+1}] do {
		if (_createdzones >= dep_military) exitWith {};
		if (count _buildings == 0) exitWith {};
		_building = _buildings call BIS_fnc_selectRandom;
		_buildings = _buildings - [_building];
		_pos = getPos _building;
		_ownradius = 75 + (round random 50);
		_safe = [_pos, dep_safe_rad + _ownradius] call dep_fnc_outsidesafezone;
		if (_safe) then {
			_distance = true;
			{
				_loc_pos    = _x select 0;
				_radius     = _x select 2;
				if ((_pos distance _loc_pos) < (_radius + _ownradius)) exitWith { _distance = false; };
			} foreach dep_locations;
			if (_distance) then {
				_milbuild = [_pos, _ownradius] call dep_fnc_findmilitarybuildings;
				if (count _milbuild > 2) then {
					_location = [];
					_location set [0, _pos];            // position
					_location set [1, "military"];      // location type
					_location set [2, _ownradius];      // radius
					_location set [3, false];           // location active
					_location set [4, []];              // enemy groups
					_location set [5, 0];               // time last active
					_location set [6, 0];               // enemy amount
					_location set [7, false];           // location cleared
					_location set [8, []];              // objects to cleanup
					_location set [9, 0];               // possible direction of objects
					_location set [10, []];             // civilians
					_location set [11, ""];             // marker
                    _location set [12, 0];              // time last cleared
					dep_locations = dep_locations + [_location];
					dep_loc_cache = dep_loc_cache + [[]];
					_createdzones = _createdzones + 1;
				};
			};
		};
		//sleep 0.005;
	};
	_buildings = nil;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// TOWN OCCUPATION
// *********************
if (dep_town_occupation > 0 && dep_town_occupation <= 1) then
{
	if (dep_debug) then {
		_starttime = time;
		"Finding towns" spawn dep_fnc_log;
	};
	_towns = [dep_map_center, dep_map_radius] call dep_fnc_towns;
    //_towns = _towns call dep_fnc_shuffle;
    _numberoftowns = ceil ((count _towns) * dep_town_occupation);
    _ownradius = 200;
    _createdzones = 0;
    for "_c" from 0 to (_numberoftowns - 1) do {
        _pos = _towns call BIS_fnc_selectRandom;
        _towns = _towns - [_pos];
        _safe = [_pos, dep_safe_rad + _ownradius] call dep_fnc_outsidesafezone;
		if (_safe) then {
            _location = [];
            _location set [0, _pos];            // position
            _location set [1, "town"];          // location type
            _location set [2, _ownradius];      // radius
            _location set [3, false];           // location active
            _location set [4, []];              // enemy groups
            _location set [5, 0];               // time last active
            _location set [6, 0];               // enemy amount
            _location set [7, false];           // location cleared
            _location set [8, []];              // objects to cleanup
            _location set [9, 0];               // possible direction of objects
            _location set [10, []];             // civilians
            _location set [11, ""];             // marker
            _location set [12, 0];              // time last cleared
            dep_locations = dep_locations + [_location];
            dep_loc_cache = dep_loc_cache + [[]];
            _createdzones = _createdzones + 1;
        };
    };

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.1;
};

// *********************
// NORMAL BUILDINGS
// *********************
if (dep_housepop > 0) then
{
	if (dep_debug) then {
		_starttime = time;
		"Finding buildings" spawn dep_fnc_log;
	};
	_buildings = nearestObjects [dep_map_center, ["House"], dep_map_radius];
	_createdzones = 0;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
		_starttime = time;
		"Populating buildings" spawn dep_fnc_log;
	};
    
	while {_createdzones < dep_housepop} do {
		_building = _buildings call BIS_fnc_selectRandom;
		if (count _buildings == 0) exitWith { 
			["Not enough buildings, found %1 of %2.", _createdzones, dep_housepop] spawn dep_fnc_log; 
		};
		_buildings = _buildings - [_building];
		_pos = getPos _building;
		_ownradius = 100 + (round random 100);
		_safe = [_pos, dep_safe_rad + _ownradius] call dep_fnc_outsidesafezone;
		if (_safe) then {
			_distance = true;
			{
				_loc_pos    = _x select 0;
				_radius     = _x select 2;
                _spacing = 150;
                if ((_x select 1) == "roadpop") then { _spacing = 50; };
				if ((_pos distance _loc_pos) < (_radius + _spacing + _ownradius)) exitWith { _distance = false; };
			} foreach dep_locations;
			if (_distance) then {
				_houses = [_pos, _ownradius] call dep_fnc_enterablehouses;
				if ((count _houses) > 1) then {
					_location = [];
					_location set [0, _pos];            // position
					_location set [1, "roadpop"];       // location type
					_location set [2, _ownradius];      // radius
					_location set [3, false];           // location active
					_location set [4, []];              // enemy groups
					_location set [5, 0];               // time last active
					_location set [6, 0];               // enemy amount
					_location set [7, false];           // location cleared
					_location set [8, []];              // objects to cleanup
					_location set [9, 0];               // possible direction of objects
					_location set [10, []];             // civilians
					_location set [11, ""];             // marker
                    _location set [12, 0];              // time last cleared
					dep_locations = dep_locations + [_location];
					dep_loc_cache = dep_loc_cache + [[]];
					_createdzones = _createdzones + 1;
				};
			};
		};
		//sleep 0.005;
	};
	_buildings = nil;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// ROADBLOCKS
// *********************
if (dep_roadblocks > 0) then
{
	_starttime = time;
    if (dep_debug) then {
		"Finding roadblocks" spawn dep_fnc_log;
	};

	if (isNil "dep_roads") then { dep_roads = [dep_map_center, dep_map_radius] call dep_fnc_findroads; };
	_fckit = false;
    _createdzones = 0;
	for [{_x=1}, {_x<=dep_roadblocks}, {_x=_x+1}] do {
		_valid = false;
		if ((count dep_roads) == 0) exitWith { "Not enough roads!" spawn dep_fnc_log; };
		while {!_valid} do {
			if ((time - _starttime) > 30) exitWith {
				_fckit = true;
			};
			_road = dep_roads call BIS_fnc_selectRandom;
			_pos = getPos _road;
			_safe = [_pos, dep_safe_rad + 100] call dep_fnc_outsidesafezone;
			if (_safe) then {
				_distance = true;
				{
					// Ignore distance to patrols, towns, roadpop
                    if !((_x select 1) == "patrol" || (_x select 1) == "town" || (_x select 1) == "roadpop") then {
                        _loc_pos    = _x select 0;
                        _radius     = _x select 2;
                        _spacing    = 0;
                        if ((_x select 1) == "roadblock") then { _spacing = 700; };
                        if ((_pos distance _loc_pos) < (_spacing + _radius + 100)) exitWith { _distance = false; };
                    };
				} foreach dep_locations;
				if (_distance) then {
					_flatPos = _pos isFlatEmpty [12, 0, 0.3, 12, 0, false];
					if (count _flatPos == 3) then {
						_dir = [_road] call dep_fnc_roaddir;
						_location = [];
						_location set [0, _pos];            // position
						_location set [1, "roadblock"];     // location type
						_location set [2, 100];             // radius
						_location set [3, false];           // location active
						_location set [4, []];              // enemy groups
						_location set [5, 0];               // time last active
						_location set [6, 0];               // enemy amount
						_location set [7, false];           // location cleared
						_location set [8, []];              // objects to cleanup
						_location set [9, _dir];            // possible direction of objects
						_location set [10, []];             // civilians
						_location set [11, ""];             // marker
						_location set [12, 0];              // time last cleared
						dep_locations = dep_locations + [_location];
						dep_loc_cache = dep_loc_cache + [[]];
						_valid = true;
                        _createdzones = _createdzones + 1;
					};
				};
			};
			//sleep 0.01;
		};
		if (_fckit) exitWith {
			"Roadblocks not found in time" spawn dep_fnc_log;
		};
	};

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// AMBUSHES
// *********************
if (dep_ambushes > 0) then 
{
	_starttime = time;
    if (dep_debug) then {
		"Finding ambushes" spawn dep_fnc_log;
	};
	
    if (isNil "dep_roads") then { dep_roads = [dep_map_center, dep_map_radius] call dep_fnc_findroads; };
	_fckit = false;
    _createdzones = 0;
	for [{_x=1}, {_x<=dep_ambushes}, {_x=_x+1}] do {
		_valid = false;
		if ((count dep_roads) == 0) exitWith { "Not enough roads!" spawn dep_fnc_log; };
		while {!_valid} do {
			if ((time - _starttime) > 20) exitWith {
				_fckit = true;
			};
			
			_road = dep_roads call BIS_fnc_selectRandom;
			_pos = getPos _road;
			_vegetation = [_pos, 20] call dep_fnc_vegetation;
			_safe = [_pos, dep_safe_rad + 100, 1000] call dep_fnc_outsidesafezone;
			if (_safe && (count _vegetation) > 5) then {
				_distance = true;
				{
					if !((_x select 1) in ["patrol"]) then
					{
						_loc_pos    = _x select 0;
						_radius     = _x select 2;
						_spread = 200;
						if ((_x select 1) == "ambush") then { _spread = 1000; };
						if ((_pos distance _loc_pos) < (_spread + _radius)) exitWith { _distance = false; };
					};
				} foreach dep_locations;
				if (_distance) then {
					_valid = true;
				};
			};
			
			if (_valid) then {
				_dir = [_road] call dep_fnc_roaddir;
				_location = [];
				_location set [0, _pos];            // position
				_location set [1, "ambush"];     	// location type
				_location set [2, 25];             	// radius
				_location set [3, false];           // location active
				_location set [4, []];              // enemy groups
				_location set [5, 0];               // time last active
				_location set [6, 0];               // enemy amount
				_location set [7, false];           // location cleared
				_location set [8, []];              // objects to cleanup
				_location set [9, _dir];            // possible direction of objects
				_location set [10, []];             // civilians
				_location set [11, ""];             // marker
                _location set [12, 0];              // time last cleared
				dep_locations = dep_locations + [_location];
				dep_loc_cache = dep_loc_cache + [[]];
                _createdzones = _createdzones + 1;
			};
		};
		if (_fckit) exitWith {
			"Ambushes not found in time" spawn dep_fnc_log;
		};
	};

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
	};
	sleep 0.5;
};

// *********************
// AA CAMPS
// *********************
if (dep_aa_camps > 0) then
{
	_starttime = time;
    if (dep_debug) then {
		"Finding aa camps" spawn dep_fnc_log;
	};

	_aacamps = [];
	_fckit = false;
    _createdzones = 0;
	for "_c" from 1 to dep_aa_camps do {
		_valid = false;
		while {!_valid} do {
			if ((time - _starttime) > 30) exitWith {
				_fckit = true;
			};
			_pos = [] call dep_fnc_random_position;
			_safe = [_pos, dep_safe_rad + 50] call dep_fnc_outsidesafezone;
			if (_safe) then {
				_flatPos = _pos isFlatEmpty [15, 0, 0.2, 12, 0, false];
				// Check if position is flat and empty
				if (count _flatPos == 3) then {
                    _distance = true;
                    {
                        // Ignore distance to patrols, towns, roadpop
                        if !((_x select 1) == "patrol" || (_x select 1) == "town" || (_x select 1) == "roadpop") then {
                            _loc_pos    = _x select 0;
                            _radius     = _x select 2;
                            _spacing    = 100;
                            if ((_x select 1) == "antiair") then { _spacing = 1000; };
                            if ((_pos distance _loc_pos) < (_spacing + _radius)) exitWith { _distance = false; };
                        };
                    } foreach dep_locations;
					if (_distance) then {
						_valid = true;
						_aacamps = _aacamps + [_pos];
						_location = [];
						_location set [0, _pos];            // position
						_location set [1, "antiair"];       // location type
						_location set [2, 50];              // radius
						_location set [3, false];           // location active
						_location set [4, []];              // enemy groups
						_location set [5, 0];               // time last active
						_location set [6, 0];               // enemy amount
						_location set [7, false];           // location cleared
						_location set [8, []];              // objects to cleanup
						_location set [9, 0];               // possible direction of objects
						_location set [10, []];             // civilians
						_location set [11, ""];             // marker
                        _location set [12, 0];              // time last cleared
						dep_locations = dep_locations + [_location];
						dep_loc_cache = dep_loc_cache + [[]];
                        _createdzones = _createdzones + 1;
					};
				};
			};
		};
		if (_fckit) exitWith {
			"AA camps not found in time" spawn dep_fnc_log;
		};
	};
	_aacamps = nil;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// MORTAR CAMPS
// *********************
if (dep_mortars > 0) then
{
	_starttime = time;
    if (dep_debug) then {
		"Finding mortar camps" spawn dep_fnc_log;
	};

	_mortarcamps = [];
	_fckit = false;
    _createdzones = 0;
	for "_c" from 1 to dep_mortars do {
		_valid = false;
		while {!_valid} do {
			if ((time - _starttime) > 30) exitWith {
				_fckit = true;
			};
			_pos = [] call dep_fnc_random_position;
			_safe = [_pos, dep_safe_rad + 50] call dep_fnc_outsidesafezone;
			if (_safe) then {
				_flatPos = _pos isFlatEmpty [15, 0, 0.2, 12, 0, false];
				// Check if position is flat and empty
				if (count _flatPos == 3) then {
					_distance = true;
                    {
                        // Ignore distance to patrols, towns, roadpop
                        if !((_x select 1) == "patrol" || (_x select 1) == "town" || (_x select 1) == "roadpop") then {
                            _loc_pos    = _x select 0;
                            _radius     = _x select 2;
                            _spacing    = 100;
                            if ((_x select 1) == "mortar") then { _spacing = 3000; };
                            if ((_pos distance _loc_pos) < (_spacing + _radius)) exitWith { _distance = false; };
                        };
                    } foreach dep_locations;
					if (_distance) then {
						_valid = true;
						_mortarcamps = _mortarcamps + [_pos];
						_location = [];
						_location set [0, _pos];            // position
						_location set [1, "mortar"];        // location type
						_location set [2, 50];              // radius
						_location set [3, false];           // location active
						_location set [4, []];              // enemy groups
						_location set [5, 0];               // time last active
						_location set [6, 0];               // enemy amount
						_location set [7, false];           // location cleared
						_location set [8, []];              // objects to cleanup
						_location set [9, 0];               // possible direction of objects
						_location set [10, []];             // civilians
						_location set [11, ""];             // marker
                        _location set [12, 0];              // time last cleared
						dep_locations = dep_locations + [_location];
						dep_loc_cache = dep_loc_cache + [[]];
                        _createdzones = _createdzones + 1;
					};
				};
			};
		};
		if (_fckit) exitWith {
			"Mortar camps not found in time" spawn dep_fnc_log;
		};
	};
	_mortarcamps = nil;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// PATROLS
// *********************
if (dep_patrols > 0) then 
{
	_starttime = time;
    if (dep_debug) then {
		"Finding patrols" spawn dep_fnc_log;
	};
	
    if (isNil "dep_roads") then { dep_roads = [dep_map_center, dep_map_radius] call dep_fnc_findroads; };
	_fckit = false;
    _createdzones = 0;
	for [{_x=1}, {_x<=dep_patrols}, {_x=_x+1}] do {
		_valid = false;
		while {!_valid} do {
			if ((time - _starttime) > 30) exitWith {
				_fckit = true;
			};
			_road = dep_roads call BIS_fnc_selectRandom;
			_pos = getPos _road;
			_safe = [_pos, (dep_safe_rad + dep_veh_pat_rad), (dep_veh_pat_rad + 350)] call dep_fnc_outsidesafezone;
			_locationroads = [_pos, dep_veh_pat_rad] call dep_fnc_findroads;
			if (_safe && (count _locationroads) > 30) then {
				_distance = true;
				{
					if (_x select 1 == "patrol") then {
						_loc_pos    = _x select 0;
						_radius     = _x select 2;
						if ((_pos distance _loc_pos) < (_radius + dep_veh_pat_rad)) exitWith { _distance = false; };
					};
				} foreach dep_locations;
				if (_distance) then {
					_location = [];
					_location set [0, _pos];            // position
					_location set [1, "patrol"];        // location type
					_location set [2, dep_veh_pat_rad]; // radius
					_location set [3, false];           // location active
					_location set [4, []];              // enemy groups
					_location set [5, 0];               // time last active
					_location set [6, 0];               // enemy amount
					_location set [7, false];           // location cleared
					_location set [8, []];              // objects to cleanup
					_location set [9, 0];               // possible direction of objects
					_location set [10, []];             // civilians
					_location set [11, ""];             // marker
                    _location set [12, 0];              // time last cleared
					dep_locations = dep_locations + [_location];
					dep_loc_cache = dep_loc_cache + [[]];
					_valid = true;
                    _createdzones = _createdzones + 1;
				};
			};
			//sleep 0.005;
		};
		if (_fckit) exitWith {
			"Patrols not found in time" spawn dep_fnc_log;
		};
	};

	dep_roads = nil;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// FOREST PATROLS
// *********************
if (dep_forest_patrols > 0) then 
{
	_starttime = time;
    if (dep_debug) then {
		"Finding forest patrols" spawn dep_fnc_log;
	};
	
    if (isNil "dep_paths") then { dep_paths = [dep_map_center, dep_map_radius] call dep_fnc_findpaths; };
	_fckit = false;
    _createdzones = 0;
    
	for [{_x=1}, {_x<=dep_forest_patrols}, {_x=_x+1}] do {
		_valid = false;
		while {!_valid} do {
			if ((time - _starttime) > 30) exitWith {
				_fckit = true;
			};
			_road = dep_paths call BIS_fnc_selectRandom;
			_pos = getPos _road;
			_safe = [_pos] call dep_fnc_outsidesafezone;
			_locationroads = [_pos, 200] call dep_fnc_findpaths;
			_forests = [_pos, 200] call dep_fnc_findforests;
			if (_safe && (count _locationroads) > 30 && (count _forests) > 0) then {
				_distance = true;
				{
					if (_x select 1 == "forpat") then {
						_loc_pos    = _x select 0;
						_radius     = _x select 2;
						if ((_pos distance _loc_pos) < (_radius + 250)) exitWith { _distance = false; };
					};
				} foreach dep_locations;
				if (_distance) then {
					_location = [];
					_location set [0, _pos];            // position
					_location set [1, "forpat"];        // location type
					_location set [2, 200];             // radius
					_location set [3, false];           // location active
					_location set [4, []];              // enemy groups
					_location set [5, 0];               // time last active
					_location set [6, 0];               // enemy amount
					_location set [7, false];           // location cleared
					_location set [8, []];              // objects to cleanup
					_location set [9, 0];               // possible direction of objects
					_location set [10, []];             // civilians
					_location set [11, ""];             // marker
                    _location set [12, 0];              // time last cleared
					dep_locations = dep_locations + [_location];
					dep_loc_cache = dep_loc_cache + [[]];
					_valid = true;
                    _createdzones = _createdzones + 1;
				};
			};
			//sleep 0.005;
		};
		if (_fckit) exitWith {
			"Forest patrols not found in time" spawn dep_fnc_log;
		};
	};

	dep_paths = nil;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// BUNKERS
// *********************
if (dep_bunkers > 0) then 
{
	_starttime = time;
    if (dep_debug) then {
		"Finding bunkers" spawn dep_fnc_log;
	};

	_fckit = false;
    _createdzones = 0;
	for [{_x = 0}, {_x < dep_bunkers}, {_x = _x + 1}] do {
		_valid = false;
		while {!_valid} do {
			if ((time - _starttime) > 30) exitWith {
				_fckit = true;
			};
			_pos = [] call dep_fnc_random_position;
			_safe = [_pos, dep_safe_rad + 50] call dep_fnc_outsidesafezone;
			if (_safe) then {
				_flatPos = _pos isFlatEmpty [9, 0, 0.2, 12, 0, false];
				if (count _flatPos == 3) then {
					_distance = true;
					{
						if ((_x select 1) in ["bunker", "antiair", "roadblock", "ambush", "military"]) then
						{
							_loc_pos    = _x select 0;
							_radius     = _x select 2;
							if ((_pos distance _loc_pos) < (600 + _radius)) then { _distance = false; };
						};
						if (!_distance) exitWith {};
					} foreach dep_locations;
					if (_distance) then {
						_location = [];
						_location set [0, _pos];            // position
						_location set [1, "bunker"];        // location type
						_location set [2, 50];              // radius
						_location set [3, false];           // location active
						_location set [4, []];              // enemy groups
						_location set [5, 0];               // time last active
						_location set [6, 0];               // enemy amount
						_location set [7, false];           // location cleared
						_location set [8, []];              // objects to cleanup
						_location set [9, 0];               // possible direction of objects
						_location set [10, []];             // civilians
						_location set [11, ""];             // marker
                        _location set [12, 0];              // time last cleared
						dep_locations = dep_locations + [_location];
						dep_loc_cache = dep_loc_cache + [[]];
						_valid = true;
                        _createdzones = _createdzones +1;
					};
				};
			};
		};
		if (_fckit) exitWith {
			["Bunkers not found in time. (%1 of %2)", _x, dep_bunkers] spawn dep_fnc_log;
		};
	};

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Created %1. Took %2 seconds.", _createdzones, _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

if (dep_debug) then {
    ["Total initialization took %1 seconds.", _totaltime] spawn dep_fnc_log;
};

dep_roads = nil;

// Place makers in debug mode
if (dep_debug) then 
{
    for [{_x=0}, {_x<(count dep_locations)}, {_x=_x+1}] do {
        _location = dep_locations select _x;
        _pos = _location select 0;
        _m = createMarker [format ["depdebug-%1",_x], _pos];
        _m setMarkerShape "ELLIPSE";
        _m setMarkerSize [_location select 2, _location select 2];
        switch (_location select 1) do {
            case "patrol":          { _m setMarkerColor "ColorRed";};
            case "forpat":          { _m setMarkerColor "ColorKhaki";};
            case "antiair":         { _m setMarkerColor "ColorBlue";};
            case "roadblock":       { _m setMarkerColor "ColorGreen";};
            case "roadpop":         { _m setMarkerColor "ColorYellow";};
            case "town":            { _m setMarkerColor "ColorOrange";};
            case "military":        { _m setMarkerColor "ColorPink";};
            case "bunker":          { _m setMarkerColor "ColorBrown";};
            case "ambush":          { _m setMarkerColor "ColorBlack";};
            case "mortar":          { _m setMarkerColor "ColorWhite";};
        };
        _m setMarkerBrush "Solid";
        _m setMarkerAlpha 0.7;  
    };
	
	_pos = dep_map_center;
	_m = createMarker ["dep_map_center", _pos];
	_m setMarkerShape "ELLIPSE";
	_m setMarkerBrush "Border";
	_m setMarkerSize [dep_map_radius, dep_map_radius];
	_m setMarkerColor "ColorRed";
	_m setMarkerAlpha 0.6;
    
    // Safezone marker
    if (count dep_safe_zone > 0) then 
    {
        if (typeName (dep_safe_zone select 0) == "ARRAY") then 
        {
            _zonenr = 0;
            {
                _m = createMarker [format["dep_safezone_%1", _zonenr], _x];
                _m setMarkerShape "ELLIPSE";
                _m setMarkerSize [dep_safe_rad, dep_safe_rad];
                _m setMarkerColor "ColorBlue";
                _m setMarkerBrush "FDiagonal";
                _m setMarkerAlpha 0.5;
                _zonenr = _zonenr + 1;
            } forEach dep_safe_zone;
        } else {
            _m = createMarker ["dep_safezone", dep_safe_zone];
            _m setMarkerShape "ELLIPSE";
            _m setMarkerSize [dep_safe_rad, dep_safe_rad];
            _m setMarkerColor "ColorBlue";
            _m setMarkerBrush "FDiagonal";
            _m setMarkerAlpha 0.5;
        };
    };
    
	_debuginfo_space = (((dep_map_center select 0) / 3) / 5);
	_debuginfo_x = _debuginfo_space;
	_debuginfo_y = _debuginfo_space;
	
	_m = createMarker["dep_mrk_fps", [_debuginfo_x,_debuginfo_y]];
    _m setMarkerType "mil_dot";
	_debuginfo_y = _debuginfo_y + _debuginfo_space;
	_m = createMarker["dep_mrk_civ_grps", [_debuginfo_x,_debuginfo_y]];
    _m setMarkerType "mil_dot";
	_debuginfo_y = _debuginfo_y + _debuginfo_space;
	_m = createMarker["dep_mrk_totalciv", [_debuginfo_x,_debuginfo_y]];
    _m setMarkerType "mil_dot";
	_debuginfo_y = _debuginfo_y + _debuginfo_space;
	_m = createMarker["dep_mrk_totalai", [_debuginfo_x, _debuginfo_y]];
    _m setMarkerType "mil_dot";
	_debuginfo_y = _debuginfo_y + _debuginfo_space;
	_m = createMarker["dep_mrk_enemy_grps", [_debuginfo_x,_debuginfo_y]];
    _m setMarkerType "mil_dot";
};
if ((count dep_zone_markers) > 0) then 
{
    if ("all" in dep_zone_markers) then 
    { 
        dep_zone_markers = ["patrol","forpat","antiair","roadblock","town","roadpop","military","bunker","ambush"]; 
    };
    ["Placing markers on the following locations: %1", dep_zone_markers] spawn dep_fnc_log;
    
    for [{_g=0}, {_g<(count dep_locations)}, {_g=_g+1}] do {
        _location = dep_locations select _g;
        if ((_location select 1) in dep_zone_markers) then {            
            _location set [11, format ["depmarker-%1",_g]];
            dep_locations set [_g, _location];
            [_location] spawn dep_fnc_update_marker;
        };
    };
};

dep_num_loc = (count dep_locations);

if (dep_precache) then
{
    for "_g" from 0 to (dep_num_loc - 1) do 
    {
        _handle = _g call dep_fnc_activate;
        _handle = _g call dep_fnc_deactivate;
    };
};

// Start searching for players
if (dep_debug) then {
    "Done creating..." spawn dep_fnc_log;
};

["DEP ready with %1 locations", dep_num_loc] spawn dep_fnc_log;
dep_ready = true;
publicVariable "dep_ready";

// Create air patrols
[] spawn dep_fnc_airpatrols;

// Create vehicle patrols
[] spawn dep_fnc_vehiclepatrols;

// Start mortar script
[] spawn dep_fnc_mortars;

while {true} do 
{            
    dep_players = [];
    if (isMultiplayer) then 
    {
        dep_players = playableUnits;
    } else {
        {
            if ((side _x) == dep_own_side) then { 
                dep_players = dep_players + [_x];
            };
        } forEach allUnits;
    };
    
    // Dynamic max amount of ai at locations
    dep_num_players = count dep_players;
    dep_max_ai_loc = round (((dep_num_players * dep_aim_player) + 1) * dep_base_ai_loc);
    
    // Also check connected UAV's
    _UAVs = [];
    {
        _uav = getConnectedUAV _x;
        if !(isNull _uav) then { _UAVs = _UAVs + [_uav]; };
    } forEach dep_players;
    dep_players = dep_players + _UAVs;
    
    // Get zones
    dep_zones = [];
    dep_hostile_zones = [];
    dep_clear_zones = [];
    if ((count dep_zone_markers) > 0) then {
        for "_g" from 0 to (dep_num_loc - 1) do {
            _location = dep_locations select _g;
            if ((_location select 1) in dep_zone_markers) then {
                dep_zones pushBack _g;
                if ((_location select 7)) then {
                    dep_clear_zones pushBack _g;
                } else {
                    dep_hostile_zones pushBack _g;
                };
            };
        };
    };
            
    for "_g" from 0 to (dep_num_loc - 1) do {
        _location       = dep_locations select _g;
        _pos            = _location select 0;
        _type           = _location select 1;
        _radius         = _location select 2;
        _active         = _location select 3;
        _groups         = _location select 4;
        _time           = _location select 5;
        _enemies        = _location select 6;
        _clear          = _location select 7;
        _close          = false;
        _tooclose       = false;
        _holding        = false;
        _blacklist      = false;
        _force_despawn  = false;
        
        // Check if active location is clear
        if (_active && !_clear) then {
            _alive = 0;
            {
                _grp = _x;
                {
                    if (alive _x) then { _alive = _alive + 1; };
                } foreach (units _grp);
            } foreach _groups;
            
            if (_enemies > 0) then {
                if ((_alive / _enemies) < 0.1) then {
                    // If number of enemies alive below 10% concider this location clear.
                    ["Cleared location %1", _g] spawn dep_fnc_log;
                    _clear = true;
                    _location set [7, _clear];
                    _location set [12, time];
                    dep_locations set [_g, _location];
                };
            } else {
                ["Cleared location %1", _g] spawn dep_fnc_log;
                _clear = true;
                _location set [7, _clear];
                _location set [12, time];
                dep_locations set [_g, _location];
            };
            if (_clear) then
            {
                _active = false;
                _location set [3, _active];
                [_location] spawn dep_fnc_update_marker;
                dep_loc_cache set [_g, []];
                ["Removed cleared location %1 from cache", _g] spawn dep_fnc_log;
            };
        };
        
        // Check if location is close to blacklisted positions
        {
            if ((_pos distance _x) < (_radius * 2)) exitWith {_blacklist = true; };
        } foreach dep_act_bl;
        
        if (dep_act_bl_force && _blacklist) then {
            _force_despawn = true;
        };
        
        // Check if at least 1 player is close
        if (!_blacklist) then {            
            _closest = 999999;
            {
                _speedok = true;
                _heightok = true;
                if (_type != "antiair") then {
                    // Check the speed and height of the player
                    if (((getPos _x) select 2) > dep_act_height) then { _heightok = false; };
                    if ((speed _x) > dep_act_speed) then { _speedok = false; };
                };
                
                if ((_speedok && _heightok)) then {
                    _distance = (getPos _x) distance _pos;
                    if (_distance < _closest) then { _closest = _distance; };
                };
            } forEach dep_players;
            
            switch (_type) do {
				case "antiair": {
					if (_closest < (_radius + (dep_act_dist * 3))) then { _close = true; };
				};
				case "mortar": {
					if (_closest < (_radius + (dep_act_dist * 5))) then { _close = true; };
				};
				default {
					if (_closest < (_radius + dep_act_dist)) then { _close = true; };
				};
			};

            // Don't activate when players are too close
            if (_closest < (2 * _radius) && _type != "patrol") then { _tooclose = true; };
            
            // Are players holding the location?
            if (_closest <= _radius) then { _holding = true; };
        };
        
        // Should the location be respawned?
        if (!_close && _clear) then {
            _respawn_timeout = 0;
            if (typeName dep_respawn_timeout == "ARRAY") then {
                _respawn_timeout = dep_respawn_timeout call BIS_fnc_randomNum;
                _respawn_timeout = ceil (_respawn_timeout * 60);
            };
            if (typeName dep_respawn_timeout == "SCALAR") then {
                _respawn_timeout = ceil (dep_respawn_timeout * 60);
            };
            if (_respawn_timeout > 0) then {
                _clear_zones = count dep_clear_zones;
                _all_zones = count dep_zones;
                if (_all_zones > 0) then {
                    _respawn_timeout_multiplier = ((_clear_zones / _all_zones) + 1) ^ 2;
                    //["timeout %1 multipl %2 result %3", _respawn_timeout, _respawn_timeout_multiplier, (_respawn_timeout * _respawn_timeout_multiplier)] spawn dep_fnc_log; 
                    _respawn_timeout = _respawn_timeout * _respawn_timeout_multiplier;
                };
                if ((time - (_location select 12)) > _respawn_timeout) then {
                    ["Respawning location %1 after %2 seconds", _g, _respawn_timeout] spawn dep_fnc_log;
                    _clear = false;
                    _location set [7, _clear];
                    _loccache = dep_loc_cache select _g;
                    _loccache set [0, _location select 13];
                    _loccache set [1, _location select 14];
                    if ((count _loccache) < 3) then { _loccache set [2, []]; };
                    dep_loc_cache set [_g , _loccache];
                    
                    // Remove all objects
                    {
                        if !(isNull _x) then {
                            deleteVehicle _x;
                        };
                    } forEach (_location select 8);
                    _location set [8, []];
                    
                    [_location] spawn dep_fnc_update_marker;
                    dep_locations set [_g, _location];
                };
            };
        };
        
        // Players are holding a location
        if (_holding && _clear) then {
            // Reset the respawn timer
            _location set [12, time];
            dep_locations set [_g, _location];
        };
        
        if (_close && !_clear && !_force_despawn) then {
            // Players are close and location not clear, should enemies be spawned?
            if (!dep_exceeded_group_limit && !dep_exceeded_ai_limit) then {
                if (!_active && !_tooclose) then {
                    // Location is not cleared and not active => spawn units
                    _handle = _g call dep_fnc_activate;
                };
            };
            _time = time;
            _location set [5, _time];
            dep_locations set [_g, _location];
        } else {
            // No players close to location, should it be deactivated?
            if (_active) then {
                // Despawn after time limit
                if ((_clear && (time - _time) > (60 * dep_despawn)) || (!_clear && (time - _time) > (60 * (dep_despawn / 2))) ) then {
                    // Deactivate the location
                    _handle = _g call dep_fnc_deactivate;
                };
            };
        };
        
        dep_allgroups = [];
        dep_civgroups = [];
        dep_total_ai = 0;
        dep_total_civ = 0;
        {
            if (side _x == dep_side) then {
                if !(isGroupDeletedWhenEmpty _x) then { _x deleteGroupWhenEmpty true; };
                dep_allgroups = dep_allgroups + [_x];
                _grp = _x;
                {
                    if (!isNull _x) then {
                        if (alive _x) then { dep_total_ai = dep_total_ai + 1; };
                    };
                } foreach (units _grp);
            };
            if (side _x == civilian) then {
                if !(isGroupDeletedWhenEmpty _x) then { _x deleteGroupWhenEmpty true; };
                dep_civgroups = dep_civgroups + [_x];
                _grp = _x;
                {
                    if (!isNull _x) then {
                        if (alive _x) then { dep_total_civ = dep_total_civ + 1; };
                    };
                } foreach (units _grp);
            };
        } forEach allGroups;
        //["Total AI: %1 Total groups %2", dep_total_ai, (count dep_allgroups)] spawn dep_fnc_log;
        
        if (dep_total_ai >= dep_max_ai_tot) then {
            dep_exceeded_ai_limit = true;
            ["AI limit of %1 reached!", dep_max_ai_tot, dep_total_ai] spawn dep_fnc_log;
        } else {
            dep_exceeded_ai_limit = false;
        };
        if ((count dep_allgroups) >= 134 || (count dep_civgroups) >= 134) then {
            dep_exceeded_group_limit = true;
            "Group limit of 134 reached!" spawn dep_fnc_log;
            [] spawn dep_fnc_groupcleanup;
        } else {
            dep_exceeded_group_limit = false;
        };
        sleep 0.02;
    };
    
    _fps = diag_fps;
    if (dep_debug) then {
        "dep_mrk_totalai" setMarkerText format["# %2 enemies: %1", dep_total_ai, dep_side];
        "dep_mrk_enemy_grps" setMarkerText format["# %2 enemy groups: %1",(count dep_allgroups), dep_side];
        "dep_mrk_totalciv" setMarkerText format["# civilians: %1", dep_total_civ];
        "dep_mrk_civ_grps" setMarkerText format["# civilian groups: %1",(count dep_civgroups)];
        "dep_mrk_fps" setMarkerText format["Server FPS: %1",_fps];
    };
    if (_fps > 45) then {
        sleep 1;
    } else {
        if (_fps > 40) then {
            sleep 4;
        } else {
            sleep 8;
        };
    };
};