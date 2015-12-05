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

private ["_locations","_pos","_flatPos","_building","_countunits","_airports"];
"Initializing DEP . . ." call dep_fnc_log;

_totaltime = 0;
_starttime = 0;
_parttime = 0;

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
	_counter = 0;
	for [{_x=0}, {_x<=_numbuildings}, {_x=_x+1}] do {
		if (_counter >= dep_military) exitWith {};
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
					dep_locations = dep_locations + [_location];
					dep_loc_cache = dep_loc_cache + [[]];
					_counter = _counter + 1;
				};
			};
		};
		//sleep 0.005;
	};
	_buildings = nil;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// NORMAL BUILDINGS
// *********************
if (dep_housepop > 0) then
{
	if (dep_debug) then {
		_starttime = time;
		"Finding normal buildings" spawn dep_fnc_log;
	};
	_buildings = nearestObjects [dep_map_center, ["House"], dep_map_radius];
	_numbuildings = 0;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
		_starttime = time;
		"Creating normal areas" spawn dep_fnc_log;
	};

	while {_numbuildings < dep_housepop} do {
		_building = _buildings call BIS_fnc_selectRandom;
		if (count _buildings == 0) exitWith { 
			["Not enough buildings, found %1 of %2.", _numbuildings, dep_housepop] spawn dep_fnc_log; 
		};
		_buildings = _buildings - [_building];
		_pos = getPos _building;
		_ownradius = 100 + (round random 100);
		_safe = [_pos, dep_safe_rad + _ownradius] call dep_fnc_outsidesafezone;
		if (_safe) then {
			_distance = true;
			_spacing = 50;
			{
				_loc_pos    = _x select 0;
				_radius     = _x select 2;
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
					dep_locations = dep_locations + [_location];
					dep_loc_cache = dep_loc_cache + [[]];
					_numbuildings = _numbuildings + 1;
				};
			};
		};
		//sleep 0.005;
	};
	_buildings = nil;

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// ROADBLOCKS
// *********************
if (dep_roadblocks > 0) then
{
	if (dep_debug) then {
		_starttime = time;
		"Finding roadblocks" spawn dep_fnc_log;
	};

	if (isNil "dep_roads") then { dep_roads = dep_map_center nearRoads dep_map_radius; };
	_fckit = false;
	for [{_x=1}, {_x<=dep_roadblocks}, {_x=_x+1}] do {
		_valid = false;
		if ((count dep_roads) == 0) exitWith { "Not enough roads!" spawn dep_fnc_log; };
		while {!_valid} do {
			if ((time - _starttime) > 60) exitWith {
				_fckit = true;
			};
			_road = dep_roads call BIS_fnc_selectRandom;
			_pos = getPos _road;
			_safe = [_pos, dep_safe_rad + 100] call dep_fnc_outsidesafezone;
			if (_safe) then {
				_distance = true;
				{
					_loc_pos    = _x select 0;
					_radius     = _x select 2;
					_spacing    = 0;
					if ((_x select 1) == "roadblock") then { _spacing = 1000; };
					if ((_pos distance _loc_pos) < (_spacing + _radius + 100)) exitWith { _distance = false; };
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
						dep_locations = dep_locations + [_location];
						dep_loc_cache = dep_loc_cache + [[]];
						_valid = true;
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
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// AMBUSHES
// *********************
if (dep_ambushes > 0) then 
{
	if (dep_debug) then {
		_starttime = time;
		"Finding ambushes" spawn dep_fnc_log;
	};
	
	if (isNil "dep_roads") then { dep_roads = dep_map_center nearRoads dep_map_radius; };
	_fckit = false;
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
				dep_locations = dep_locations + [_location];
				dep_loc_cache = dep_loc_cache + [[]];
			};
		};
		if (_fckit) exitWith {
			"Ambushes not found in time" spawn dep_fnc_log;
		};
	};

	if (dep_debug) then {
		_parttime = time - _starttime;
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
	};
	sleep 0.5;
};

// *********************
// AA CAMPS
// *********************
if (dep_aa_camps > 0) then
{
	if (dep_debug) then {
		_starttime = time;
		"Finding aa camps" spawn dep_fnc_log;
	};

	_aacamps = [];
	_fckit = false;
	for "_c" from 1 to dep_aa_camps do {
		_valid = false;
		while {!_valid} do {
			if ((time - _starttime) > 60) exitWith {
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
						if ((_pos distance _x) < 1000) exitWith { _distance = false; };
					} foreach _aacamps;
					// Check distance between other AA camps
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
						dep_locations = dep_locations + [_location];
						dep_loc_cache = dep_loc_cache + [[]];
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
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// PATROLS
// *********************
if (dep_patrols > 0) then 
{
	if (dep_debug) then {
		_starttime = time;
		"Finding patrols" spawn dep_fnc_log;
	};
	
	if (isNil "dep_roads") then { dep_roads = dep_map_center nearRoads dep_map_radius; };
	_fckit = false;
	for [{_x=1}, {_x<=dep_patrols}, {_x=_x+1}] do {
		_valid = false;
		while {!_valid} do {
			if ((time - _starttime) > 60) exitWith {
				_fckit = true;
			};
			_road = dep_roads call BIS_fnc_selectRandom;
			_pos = getPos _road;
			_safe = [_pos, (dep_safe_rad + dep_veh_pat_rad), (dep_veh_pat_rad + 350)] call dep_fnc_outsidesafezone;
			_locationroads = _pos nearRoads dep_veh_pat_rad;
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
					dep_locations = dep_locations + [_location];
					dep_loc_cache = dep_loc_cache + [[]];
					_valid = true;
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
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
		_totaltime = _totaltime + _parttime;
	};
	sleep 0.5;
};

// *********************
// BUNKERS
// *********************
if (dep_bunkers > 0) then 
{
	if (dep_debug) then {
		_starttime = time;
		"Finding bunkers" spawn dep_fnc_log;
	};

	_fckit = false;
	for [{_x = 0}, {_x < dep_bunkers}, {_x = _x + 1}] do {
		_valid = false;
		while {!_valid} do {
			if ((time - _starttime) > 60) exitWith {
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
						dep_locations = dep_locations + [_location];
						dep_loc_cache = dep_loc_cache + [[]];
						_valid = true;
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
		["Took %1 seconds.", _parttime] spawn dep_fnc_log;
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
            case "antiair":         { _m setMarkerColor "ColorBlue";};
            case "roadblock":       { _m setMarkerColor "ColorGreen";};
            case "roadpop":         { _m setMarkerColor "ColorYellow";};
            case "military":        { _m setMarkerColor "ColorPink";};
            case "bunker":          { _m setMarkerColor "ColorBrown";};
            case "ambush":          { _m setMarkerColor "ColorBlack";};
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
        dep_zone_markers = ["patrol","antiair","roadblock","roadpop","military","bunker"]; 
    };
    ["Placing markers on the following locations: %1", dep_zone_markers] spawn dep_fnc_log;
    
    for [{_g=0}, {_g<(count dep_locations)}, {_g=_g+1}] do {
        _location = dep_locations select _g;
        if ((_location select 1) in dep_zone_markers) then {
            _pos = _location select 0;
            _markname = format ["depmarker-%1",_g];
            _m = createMarker [_markname, _pos];
            _m setMarkerType "mil_warning"; 
            _m setMarkerColor "ColorRed";
            if (dep_worldname == "altis") then 
            {
                _m setMarkerAlpha 0.5;
                _m setMarkerSize [0.4, 0.4];
            };
            
            _location set [11, _markname];
            dep_locations set [_g, _location];
        };
    };
};

dep_num_loc = (count dep_locations);

if (dep_precache) then
{
    for "_g" from 0 to (dep_num_loc - 1) do 
    {
        _location = dep_locations select _g;
        if ((_location select 1) == "antiair") then {
            _handle = _g call dep_fnc_activate_aacamp;
        } else {
            _handle = _g call dep_fnc_activate;
        };
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

_countunits = false;
while {true} do 
{    
    for "_g" from 0 to (dep_num_loc - 1) do {
        _location   = dep_locations select _g;
        _pos        = _location select 0;
        _type       = _location select 1;
        _radius     = _location select 2;
        _active     = _location select 3;
        _groups     = _location select 4;
        _time       = _location select 5;
        _enemies    = _location select 6;
        _clear      = _location select 7;
        _close      = false;
        _tooclose   = false;
        _blacklist  = false;
        
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
                    dep_locations set [_g, _location];
                };
            } else {
                ["Cleared location %1", _g] spawn dep_fnc_log;
                _clear = true;
                _location set [7, _clear];
                dep_locations set [_g, _location];
            };
            if (_clear) then
            {
                if ((_location select 11) != "") then {
                    // Change the marker
                    if ((_location select 1) in dep_zone_markers) then {
                        _markname = (_location select 11);
                        deleteMarker _markname;
                        _m = createMarker [_markname, _pos];
                        _m setMarkerType "mil_circle"; 
                        _m setMarkerColor "ColorGreen";
                        if (dep_worldname == "altis") then 
                        {
                            _m setMarkerAlpha 0.5;
                            _m setMarkerSize [0.4, 0.4];
                        };
                    };
                };
                dep_loc_cache set [_g, []];
                ["Removed cleared location %1 from cache", _g] spawn dep_fnc_log;
            };
        };
        
        // Check if location is close to blacklisted positions
        {
            if ((_pos distance _x) < (_radius * 2)) exitWith {_blacklist = true; };
        } foreach dep_act_bl;
        
        // Check if at least 1 player is close
        if (!_blacklist) then {
            _units = [];
            if (isMultiplayer) then 
            {
                _units = playableUnits;
            } else {
                {
                    if ((side _x) == dep_own_side) then { 
                        _units = _units + [_x];
                    };
                } forEach allUnits;
            };
            
            // Dynamic max amount of ai at locations
            dep_num_players = count _units;
            dep_max_ai_loc = round (((dep_num_players * dep_aim_player) + 1) * dep_base_ai_loc);
            
            // Also check connected UAV's
            _UAVs = [];
            {
                _uav = getConnectedUAV _x;
                if !(isNull _uav) then { _UAVs = _UAVs + [_uav]; };
            } forEach _units;
            _units = _units + _UAVs;
            
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
            } forEach _units;
            
            if (_type == "antiair") then {
                // Anti air locations have 3x greater activation distance
                if (_closest < (_radius + (dep_act_dist * 3))) then { _close = true; };
            } else {
                if (_closest < (_radius + dep_act_dist)) then { _close = true; };
            };

            // Don't activate when players are too close
            if (_closest < (2 * _radius) && _type != "patrol") then { _tooclose = true; };
        };
        
        if (_close && !_clear) then {
            // Players are close and location not clear, should enemies be spawned?
            if (!dep_exceeded_group_limit && !dep_exceeded_ai_limit) then {
                if (!_active && !_tooclose) then {
                    // Location is not cleared and not active => spawn units
                    if (_type == "antiair") then {
                        _handle = _g call dep_fnc_activate_aacamp;
                    } else {
                        _handle = _g call dep_fnc_activate;
                    };
                    _countunits = true;
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
                    _countunits = true;
                };
            };
        };
        
        if (_countunits) then
        {
            dep_allgroups = [];
            dep_civgroups = [];
            dep_total_ai = 0;
            dep_total_civ = 0;
            {
                if (side _x == dep_side) then { 
                    dep_allgroups = dep_allgroups + [_x];
                    _grp = _x;
                    {
                        if (!isNull _x) then {
                            if (alive _x) then { dep_total_ai = dep_total_ai + 1; };
                        };
                    } foreach (units _grp);
                };
                if (side _x == civilian) then {
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
            _countunits = false;
            
            if (dep_total_ai >= dep_max_ai_tot) then {
                dep_exceeded_ai_limit = true;
                ["AI limit of %1 reached!", dep_max_ai_tot, dep_total_ai] spawn dep_fnc_log;
            } else {
                dep_exceeded_ai_limit = false;
            };
            if ((count dep_allgroups) >= 134 || (count dep_civgroups) >= 134) then {
                dep_exceeded_group_limit = true;
                "Group limit of 134 reached!" spawn dep_fnc_log;
            } else {
                dep_exceeded_group_limit = false;
            };
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