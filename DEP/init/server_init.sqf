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

 if !(isClass(configFile>>"CfgPatches">>"cba_main_a3")) exitWith 
 {
    diag_log "DEP INIT FAILED: CBA NOT FOUND";
 };
  
// SETTINGS
//dep_directory = "scripts\DEP\";   // Script location
_handle = [] execVM dep_directory+"settings.sqf";
waitUntil{scriptDone _handle};

// PUBLIC VARIABLES
dep_total_ai    = 0;
dep_total_veh   = 0;
dep_spawning    = false;
dep_locations   = [];
dep_loc_cache   = [];
dep_num_loc     = 0;
dep_act_bl      = [];
dep_veh_pat_rad = 600;
dep_allgroups   = [];

if (isNil "dep_side")           then { dep_side         = independent; };   // Enemy side (east, west, independent)
if (isNil "dep_despawn")        then { dep_despawn      = 5; };             // Despawn location after x minutes inactivity
if (isNil "dep_debug")          then { dep_debug        = false; };         // Enable debug
if (isNil "dep_max_ai_loc")     then { dep_max_ai_loc   = 14; };            // Maximum AI per location
if (isNil "dep_max_ai_tot")     then { dep_max_ai_tot   = 400; };           // Maximum AI in total
if (isNil "dep_act_dist")       then { dep_act_dist     = 800; };           // Location activation distance
if (isNil "dep_act_height")     then { dep_act_height   = 80; };            // Player must be below this height to activate location
if (isNil "dep_act_speed")      then { dep_act_speed    = 160; };           // Player must be below this speed to activate location
if (isNil "dep_safe_zone")      then { dep_safe_zone    = [];  };           // Safe zone position
if (isNil "dep_safe_rad")       then { dep_safe_rad     = 800; };           // Safe zone radius
if (isNil "dep_max_veh")        then { dep_max_veh      = 10; };            // Max number of vehicles
if (isNil "dep_ied_chance")     then { dep_ied_chance   = 0.6; };           // Chance of IEDs
if (isNil "dep_veh_chance")     then { dep_veh_chance   = 0.3; };           // Chance of vehicles
if (isNil "dep_unit_init")      then { dep_unit_init    = ""; };            // Code executed on unit creation
if (isNil "dep_cr_ied")         then { dep_cr_ied       = false; };         // Restrict disarming IED to explosives class

if (isNil "dep_u_g_soldier")    then { dep_u_g_soldier  = "I_G_Soldier_F"; };
if (isNil "dep_u_g_gl")         then { dep_u_g_gl       = "I_G_Soldier_GL_F"; };
if (isNil "dep_u_g_ar")         then { dep_u_g_ar       = "I_G_Soldier_AR_F"; };
if (isNil "dep_u_g_at")         then { dep_u_g_at       = "I_G_Soldier_LAT_F"; };
if (isNil "dep_u_g_medic")      then { dep_u_g_medic    = "I_G_medic_F"; };
if (isNil "dep_u_g_sl")         then { dep_u_g_sl       = "I_G_Soldier_SL_F"; };
if (isNil "dep_u_g_marksman")   then { dep_u_g_marksman = "I_G_Soldier_M_F"; };

if (isNil "dep_u_soldier")      then { dep_u_soldier    = "I_soldier_F"; };
if (isNil "dep_u_gl")           then { dep_u_gl         = "I_Soldier_GL_F"; };
if (isNil "dep_u_ar")           then { dep_u_ar         = "I_Soldier_AR_F"; };
if (isNil "dep_u_at")           then { dep_u_at         = "I_Soldier_LAT_F"; };
if (isNil "dep_u_medic")        then { dep_u_medic      = "I_medic_F"; };
if (isNil "dep_u_aa")           then { dep_u_aa         = "I_Soldier_AA_F"; };
if (isNil "dep_u_aaa")          then { dep_u_aaa        = "I_Soldier_AAA_F"; };
if (isNil "dep_u_sl")           then { dep_u_sl         = "I_Soldier_SL_F"; };
if (isNil "dep_u_marksman")     then { dep_u_marksman   = "I_soldier_M_F"; };
if (isNil "dep_u_sniper")       then { dep_u_sniper     = "I_Sniper_F"; };

if (isNil "dep_mil_units")          then { dep_mil_units        = [dep_u_soldier, dep_u_gl, dep_u_ar, dep_u_at, dep_u_medic, dep_u_aa, dep_u_sl, dep_u_marksman, dep_u_sniper]; };
if (isNil "dep_guer_units")         then { dep_guer_units       = [dep_u_g_soldier, dep_u_g_gl, dep_u_g_ar, dep_u_g_at, dep_u_g_medic, dep_u_g_sl, dep_u_g_marksman]; };
if (isNil "dep_ground_vehicles")    then { dep_ground_vehicles  = ["I_MRAP_03_hmg_F","I_MRAP_03_gmg_F","I_APC_tracked_03_cannon_F","I_G_Van_01_transport_F","I_APC_Wheeled_03_cannon_F","I_G_offroad_01_armed_F"]; };

// World specific settings
switch (worldName) do {
    case "Altis": {
        if (isNil "dep_map_center") then { dep_map_center  = [15360, 15360]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 250; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 50; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 30; };
        if (isNil "dep_patrols")    then { dep_patrols     = 60; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 50; };
    };
    case "Stratis": {
        if (isNil "dep_map_center") then { dep_map_center  = [4096, 4096]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 50; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 7; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 5; };
        if (isNil "dep_patrols")    then { dep_patrols     = 7; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 10; };
    };
    case "Takistan": {
        if (isNil "dep_map_center") then { dep_map_center  = [6400, 6400]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 100; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 10; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 8; };
        if (isNil "dep_patrols")    then { dep_patrols     = 25; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 15; };
    };
    case "Chernarus": {
        if (isNil "dep_map_center") then { dep_map_center  = [7680, 7680]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 100; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 10; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 8; };
        if (isNil "dep_patrols")    then { dep_patrols     = 25; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 20; };
    };
    default {
        if (isNil "dep_map_center") then { dep_map_center  = [0, 0]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 0; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 0; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 0; };
        if (isNil "dep_patrols")    then { dep_patrols     = 0; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 0; };
    };
};
dep_map_radius  = ceil (sqrt (((dep_map_center select 0) ^ 2) + ((dep_map_center select 1) ^ 2)));

// FUNCTIONS
dep_fnc_random_position         = compile preprocessFileLineNumbers (dep_directory+"functions\randommappos.sqf");
dep_fnc_outsidesafezone         = compile preprocessFileLineNumbers (dep_directory+"functions\outsidesafezone.sqf");
dep_fnc_createunit              = compile preprocessFileLineNumbers (dep_directory+"functions\createunit.sqf");
dep_fnc_isenterable             = compile preprocessFileLineNumbers (dep_directory+"functions\isenterable.sqf");
dep_fnc_setwaypoints            = compile preprocessFileLineNumbers (dep_directory+"functions\setwaypoints.sqf");
dep_fnc_getwaypoints            = compile preprocessFileLineNumbers (dep_directory+"functions\getwaypoints.sqf");
dep_fnc_vehiclepatrol           = compile preprocessFileLineNumbers (dep_directory+"functions\vehiclepatrol.sqf");
dep_fnc_housepatrol             = compile preprocessFileLineNumbers (dep_directory+"functions\housepatrol.sqf");
dep_fnc_unitpatrol              = compile preprocessFileLineNumbers (dep_directory+"functions\unitpatrol.sqf");
dep_fnc_enterablehouses         = compile preprocessFileLineNumbers (dep_directory+"functions\enterablehouses.sqf");
dep_fnc_findmilitarybuildings   = compile preprocessFileLineNumbers (dep_directory+"functions\findmilitarybuildings.sqf");
dep_fnc_findnearhouses          = compile preprocessFileLineNumbers (dep_directory+"functions\findnearhouses.sqf");
dep_fnc_buildingpositions       = compile preprocessFileLineNumbers (dep_directory+"functions\buildingpositions.sqf");
dep_fnc_vehicledamage           = compile preprocessFileLineNumbers (dep_directory+"functions\vehicledamage.sqf");
dep_fnc_nearestroad             = compile preprocessFileLineNumbers (dep_directory+"functions\nearestroad.sqf");
dep_fnc_roaddir                 = compile preprocessFileLineNumbers (dep_directory+"functions\roaddir.sqf");
dep_fnc_roadblock               = compile preprocessFileLineNumbers (dep_directory+"structures\roadblock.sqf");
dep_fnc_atcamp                  = compile preprocessFileLineNumbers (dep_directory+"structures\atcamp.sqf");
dep_fnc_mortarcamp              = compile preprocessFileLineNumbers (dep_directory+"structures\mortarcamp.sqf");
dep_fnc_aacamp1                 = compile preprocessFileLineNumbers (dep_directory+"structures\aacamp1.sqf");
dep_fnc_aacamp2                 = compile preprocessFileLineNumbers (dep_directory+"structures\aacamp2.sqf");
dep_fnc_restore                 = compile preprocessFileLineNumbers (dep_directory+"functions\restore.sqf");
dep_fnc_activate                = compile preprocessFileLineNumbers (dep_directory+"functions\activate.sqf");
dep_fnc_activate_aacamp         = compile preprocessFileLineNumbers (dep_directory+"functions\activate_aacamp.sqf");
dep_fnc_deactivate              = compile preprocessFileLineNumbers (dep_directory+"functions\deactivate.sqf");
dep_fnc_garrison                = compile preprocessFileLineNumbers (dep_directory+"functions\garrison.sqf");
dep_fnc_enemyspawnprotect       = compile preprocessFileLineNumbers (dep_directory+"functions\enemyspawnprotect.sqf");
dep_fnc_disable_ied             = compile preprocessFileLineNumbers (dep_directory+"functions\disable_ied.sqf");
dep_fnc_disable_ied_action      = compile preprocessFileLineNumbers (dep_directory+"functions\disable_ied_action.sqf");

if (dep_debug) then {
    waitUntil {time > 0};
};

private ["_locations","_pos","_flatPos","_building"];
diag_log "Initializing DEP . . .";

if (dep_debug) then {
    _m = createMarker ["dep_map_radius", dep_map_center];
    _m setMarkerShape "ELLIPSE";
    _m setMarkerSize [dep_map_radius, dep_map_radius];
    _m setMarkerColor "ColorWhite";
    _m setMarkerAlpha 0.1;
    _m = createMarker ["dep_map_center", dep_map_center];
    _m setMarkerType "mil_dot";
    _m setMarkerText "center";
};

_totaltime = 0;
_starttime = 0;
_parttime = 0;
if (dep_debug) then {
    diag_log "Finding military buildings";
    _starttime = time;
};
_buildings = [dep_map_center, dep_map_radius] call dep_fnc_findmilitarybuildings;
_numbuildings = (count _buildings) / 2;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Creating military areas";
};

for [{_x=0}, {_x<=_numbuildings}, {_x=_x+1}] do {
    if (count _buildings == 0) exitWith {};
    _building = _buildings call BIS_fnc_selectRandom;
    _buildings = _buildings - [_building];
    _pos = getPos _building;
    _safe = [_pos] call dep_fnc_outsidesafezone;
    if (_safe) then {
        _ownradius = 75 + (round random 50);
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
                dep_locations = dep_locations + [_location];
                dep_loc_cache = dep_loc_cache + [[]];
            };
        };
    };
    //sleep 0.005;
};
_buildings = nil;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding normal buildings";
};
_buildings = nearestObjects [dep_map_center, ["House"], dep_map_radius];
_numbuildings = 0;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Creating normal areas";
};

while {_numbuildings < dep_housepop} do {
    _building = _buildings call BIS_fnc_selectRandom;
    if (count _buildings == 0) exitWith { 
        diag_log format ["Not enough buildings, found %1 of %2.", _numbuildings, dep_housepop]; 
    };
    _buildings = _buildings - [_building];
    _pos = getPos _building;
    _safe = [_pos] call dep_fnc_outsidesafezone;
    if (_safe) then {
        _ownradius = 100 + (round random 100);
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
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding roadblocks";
};

// Roadblocks
_list = dep_map_center nearRoads dep_map_radius;
_fckit = false;
for [{_x=1}, {_x<=dep_roadblocks}, {_x=_x+1}] do {
    _valid = false;
    while {!_valid} do {
        if ((time - _starttime) > 60) exitWith {
            _fckit = true;
        };
        _road = _list call BIS_fnc_selectRandom;
        _pos = getPos _road;
        _safe = [_pos] call dep_fnc_outsidesafezone;
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
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                    _valid = true;
                };
            };
        };
        //sleep 0.01;
    };
    if (_fckit) exitWith {
        diag_log "Roadblocks not found in time";
    };
};

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding aa camps";
};
// AA Camps
_aacamps = [];
_fckit = false;
for "_c" from 1 to dep_aa_camps do {
    _valid = false;
    while {!_valid} do {
        if ((time - _starttime) > 60) exitWith {
            _fckit = true;
        };
        _pos = [] call dep_fnc_random_position;
        _safe = [_pos] call dep_fnc_outsidesafezone;
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
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                };
            };
        };
    };
    if (_fckit) exitWith {
        diag_log "AA camps not found in time";
    };
};
_aacamps = nil;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding patrols";
};
// Vehicle patrols
_fckit = false;
for [{_x=1}, {_x<=dep_patrols}, {_x=_x+1}] do {
    _valid = false;
    while {!_valid} do {
        if ((time - _starttime) > 60) exitWith {
            _fckit = true;
        };
        _road = _list call BIS_fnc_selectRandom;
        _pos = getPos _road;
        _safe = [_pos, (dep_safe_rad + dep_veh_pat_rad)] call dep_fnc_outsidesafezone;
        if (_safe) then {
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
                dep_locations = dep_locations + [_location];
                dep_loc_cache = dep_loc_cache + [[]];
                _valid = true;
            };
        };
        //sleep 0.005;
    };
    if (_fckit) exitWith {
        diag_log "Patrols not found in time";
    };
};
_list = nil;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding bunkers";
};

// Bunkers

/*_exp = "(1 + meadow) * (1 - forest) * (1 - trees) * (1 - hills) * (1 - houses) * (1 - sea)";
_bunkers = selectBestPlaces [ dep_map_center, dep_map_radius,_exp, 75, dep_bunkers];
for [{_x=0}, {_x<(count _bunkers)}, {_x=_x+1}] do {
    _place = _bunkers select _x;
    _pos = _place select 0;
    _safe = [_pos] call dep_fnc_outsidesafezone;
    if (_safe) then {
        _flatPos = _pos isFlatEmpty [12, 0, 0.2, 10, 0, false];
        if (count _flatPos == 3) then {
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
            dep_locations = dep_locations + [_location];
            dep_loc_cache = dep_loc_cache + [[]];
        };
    };
};*/

_fckit = false;
for [{_x = 0}, {_x < dep_bunkers}, {_x = _x + 1}] do {
    _valid = false;
    while {!_valid} do {
        if ((time - _starttime) > 60) exitWith {
            _fckit = true;
        };
        _pos = [] call dep_fnc_random_position;
        _safe = [_pos] call dep_fnc_outsidesafezone;
        if (_safe) then {
            _flatPos = _pos isFlatEmpty [9, 0, 0.2, 12, 0, false];
            if (count _flatPos == 3) then {
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
                dep_locations = dep_locations + [_location];
                dep_loc_cache = dep_loc_cache + [[]];
                _valid = true;
            };
        };
    };
    if (_fckit) exitWith {
        diag_log format ["Bunkers not found in time. (%1 of %2)", _x, dep_bunkers];
    };
};

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    diag_log format ["Total initialization took %1 seconds.", _totaltime];
};

// Place makers in debug mode
if (dep_debug) then {
    diag_log "Placing markers";
};
if (dep_debug) then {
    for [{_x=0}, {_x<(count dep_locations)}, {_x=_x+1}] do {
        _location = dep_locations select _x;
        _pos = _location select 0;
        _m = createMarker [format ["depmarker-%1",_x], _pos];
        _m setMarkerShape "ELLIPSE";
        _m setMarkerSize [_location select 2, _location select 2];
        switch (_location select 1) do {
            case "patrol":          { _m setMarkerColor "ColorRed";};
            case "antiair":         { _m setMarkerColor "ColorBlue";};
            case "roadblock":       { _m setMarkerColor "ColorGreen";};
            case "roadpop":         { _m setMarkerColor "ColorYellow";};
            case "military":        { _m setMarkerColor "ColorPink";};
            case "bunker":          { _m setMarkerColor "ColorBrown";};
        };
        _m setMarkerBrush "Solid";
        //_m setMarkerAlpha 0.7;
    };
};

// Start searching for players
if (dep_debug) then {
    diag_log "Done creating...";
};
dep_num_loc = (count dep_locations);
diag_log format ["DEP ready with %1 locations", dep_num_loc];
dep_ready = true;
publicVariable "dep_ready";
while {true} do {
    waitUntil{!dep_spawning};
    
    dep_allgroups = [];
    {
        if (side _x == dep_side) then { dep_allgroups = dep_allgroups + [_x]; };
    } forEach allGroups;
    
    dep_total_ai = 0;
    for "_g" from 0 to (dep_num_loc - 1) do {
        _location = dep_locations select _g;
        _groups = _location select 4;
        _alive = 0;
        {
            _grp = _x;
            {
                if (!isNull _x) then {
                    if (alive _x) then { _alive = _alive + 1; };
                };
            } foreach (units _grp);
        } foreach _groups;
        dep_total_ai = dep_total_ai + _alive;
    };
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
                    diag_log format ["Cleared location %1", _g];
                    _clear = true;
                    _location set [7, _clear];
                    dep_locations set [_g, _location];
                };
            } else {
                diag_log format ["Cleared location %1", _g];
                _clear = true;
                _location set [7, _clear];
                dep_locations set [_g, _location];
            };
        };
        
        // Check if location is close to blacklisted positions
        {
            if ((_pos distance _x) < (_radius * 2)) exitWith {_blacklist = true; };
        } foreach dep_act_bl;
        
        // Check if at least 1 player is close
        if (!_blacklist) then {
            _units = playableUnits;
            if ((count _units) == 0) then { 
                _units = allUnits;
            };
            _closest = 999999;
            {
               if ((side _x) == West && isPlayer _x) then
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
            if (count dep_allgroups <= 134) then {
                // Group limit not reached
                if (!_active && dep_total_ai < dep_max_ai_tot && !_tooclose) then {
                    // Location is not cleared and not active => spawn units
                    if (_type == "antiair") then {
                        _handle = _g call dep_fnc_activate_aacamp;
                    } else {
                        _handle = _g call dep_fnc_activate;
                    };
                };
                _time = time;
                _location set [5, _time];
                dep_locations set [_g, _location];
            } else {
                diag_log format ["Group limit of 134 reached: %1. Location %2 skipped.", count dep_allgroups, _g];
            };
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
        sleep 0.02;
    };
    
    _fps = diag_fps;
    if (dep_debug) then {
        _west = 0;
        _east = 0;
        _resi = 0;
        {
            if (side _x == east) then { _east = _east + 1; };
            if (side _x == west) then { _west = _west + 1; };
            if (side _x == resistance) then { _resi = _resi + 1; };
        } forEach allUnits;
        
        //systemChat format ["west: %1 east: %2 resistance: %3 FPS: %4", _west, _east, _resi, _fps];
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