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
// This file spawns units at a given location.

_cache = dep_loc_cache select _this;
if ((count _cache) > 0) exitWith {
    _result = _this call dep_fnc_restore;
    true;
};

private ["_pos","_houses","_house","_maxbuildingpos","_validhouses","_size","_buildpos","_enemyamount","_groups", "_civilians", "_location","_num_houses","_num_buildpos","_totalenemies","_depgroup"];

_location = dep_locations select _this;
["Spawning location %1 (%2)", _this, (_location select 1)] spawn dep_fnc_log;

_pos        = _location select 0;
_size       = _location select 2;
_objects    = _location select 8;

_groups = [];
_civilians = [];
_totalenemies = 0;

if ((_location select 1) == "antiair") then {
    _result = [];
    if ((random 1) <= 0.5) then {
        _result = [_pos, random 360] call dep_fnc_aacamp1;
    } else {
        _result = [_pos, random 360] call dep_fnc_aacamp2;
    };
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

if ((_location select 1) == "roadblock") then {
    _result = [];
    _type = ["roadblock1","roadblock2"] call BIS_fnc_selectRandom;
    switch (_type) do {
        case "roadblock1": { _result = [_pos, _location select 9] call dep_fnc_roadblock1; };
        case "roadblock2": { _result = [_pos, _location select 9] call dep_fnc_roadblock2; };
    };
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

if ((_location select 1) == "forpat") then {
    _result = [_location] call dep_fnc_forest_patrol1;
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

if ((_location select 1) == "mortar") then {
    _result = [_pos, random 360] call dep_fnc_mortarcamp;
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

if ((_location select 1) == "bunker") then {
    _result = [];
    _type = ["at","barracks1","barracks2","ins_camp1"] call BIS_fnc_selectRandom;
    switch (_type) do
    {
        case "at": {        _result = [_pos, random 360] call dep_fnc_atcamp; };
        case "barracks1": { _result = [_pos, random 360] call dep_fnc_barracks1; };
        case "barracks2": { _result = [_pos, random 360] call dep_fnc_barracks2; };
        case "ins_camp1": { _result = [_pos, random 360] call dep_fnc_insurgentcamp1; };
    };
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

if ((_location select 1) == "ambush") then {
    _result = [];
    _type = ["ambush1","ambush2"] call BIS_fnc_selectRandom;
    switch (_type) do {
        case "ambush1": { _result = [_pos, (_location select 9)] call dep_fnc_ambush1; };
        case "ambush2": { _result = [_pos, (_location select 9)] call dep_fnc_ambush2; };
    };
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

// Spawn units 
if ((_location select 1) in ["roadpop","town"]) then {
    _validhouses = [_pos, _size] call dep_fnc_enterablehouses;
    _enemyamount = 2;
    if ((_location select 1) == "town") then {
        _enemyamount = dep_max_ai_loc; // Max amount of enemies in towns
    } else {
        _enemyamount = round((dep_max_ai_loc / 2) + (random (dep_max_ai_loc / 2)));
    };
    _spawnpositions = [];
    {
        _temp = _x call dep_fnc_buildingpositions;
        _spawnpositions = _spawnpositions + _temp;
    } forEach _validhouses;
    _spawnpositions = _spawnpositions call dep_fnc_shuffle;
    
    _depgroup = createGroup dep_side;
    _groups = _groups + [_depgroup];
    
    for "_e" from 1 to _enemyamount do {
        _spawnpos = [];
        if ((count _spawnpositions) > 0) then {
            _spawnpos = _spawnpositions call BIS_fnc_selectRandom;
            _spawnpositions = _spawnpositions - [_spawnpos];
        } else {
            _spawnpos = _pos findEmptyPosition [0,_size];
            if ((count _spawnpos) == 0) then { _spawnpos = _pos; };
        };
        _soldiername = dep_guer_units call BIS_fnc_selectRandom;
        _soldier = [_depgroup, _soldiername, _spawnpos] call dep_fnc_createunit;
        _totalenemies = _totalenemies + 1;
        _soldier setDir (random 360); 
    };
    [_depgroup] spawn dep_fnc_enemyspawnprotect;
    
    if ((random 1) < 0.3 && _enemyamount > 1) then {
        // Make units patrol
        [_depgroup, _size, _pos] spawn dep_fnc_unitpatrol;
    } else {
        doStop (units _depgroup);
    };
    sleep 0.5;
    
    // Civilians
    if (dep_civilians) then {
        if ((count _validhouses) > 10) then {
            _civgroup = createGroup civilian;
            _civilians = _civilians + [_civgroup];
            for "_e" from 1 to (4 + (round random 4)) do {
                _newpos = _pos findEmptyPosition [0, 50];
                if ((count _newpos) == 3) then {
                    _unit = [_civgroup, (dep_civ_units call bis_fnc_selectRandom), _newpos] call dep_fnc_createcivilian;
                };
            };
            _newpos = _validhouses call BIS_fnc_selectRandom;
            _newpos = getPos _newpos;
            _wp = _civgroup addWaypoint [_newpos, 1];
            _wp setWaypointBehaviour "CARELESS";
            _wp setWaypointCombatMode "BLUE";
            _wp setWaypointSpeed "LIMITED";
            _wp setWaypointFormation "LINE";
            _wp setWaypointTimeOut [20,30,40];
            _wp setWaypointType "DISMISS";
        };
    };
};

if ((_location select 1) == "town") then {
    // Vehicles in towns
    _patrolradius = _size * 1.25;
    _list = [_pos, _patrolradius] call dep_fnc_findroads;
    if ((count _list) > 10) then {
        _numvehicles = round random (dep_veh_chance * 5);
        for "_z" from 1 to _numvehicles do {
            _road = _list call BIS_fnc_selectRandom;
            _dir = [_road] call dep_fnc_roaddir;
            _vehname = dep_ground_vehicles call BIS_fnc_selectRandom;
            _veh = _vehname createVehicle (getPos _road);
            _veh setDir _dir;
            _objects = _objects + [_veh];
            [_veh] spawn dep_fnc_vehicledamage;
            _depgroup = [_veh] call dep_fnc_vehicle_fill;
            _groups = _groups + [_depgroup];
            nill = [_pos, _depgroup, _patrolradius] call dep_fnc_vehiclepatrol;
        };
    };
};

if ((_location select 1) == "military") then {
    _depgroup = createGroup dep_side;
    _groups = _groups + [_depgroup];
    _enemyamount = (dep_max_ai_loc / 2) + (round random (dep_max_ai_loc / 2));
    _totalenemies = _totalenemies + _enemyamount;
    
    for "_e" from 1 to _enemyamount do {				
        _soldiername = dep_mil_units call BIS_fnc_selectRandom;
        _newpos = _pos findEmptyPosition [0, 50, _soldiername];
        _soldier = [_depgroup, _soldiername, _newpos] call dep_fnc_createunit;
        _soldier setDir (random 360);
    };
    [_depgroup] spawn dep_fnc_enemyspawnprotect;
    [_depgroup, _size, _pos] spawn dep_fnc_unitpatrol;

    _validhouses = [_pos, _size] call dep_fnc_findmilitarybuildings;
    _spawnpositions = [];
    {
        _temp = _x call dep_fnc_buildingpositions;
        _spawnpositions = _spawnpositions + _temp;
    } forEach _validhouses;
    _spawnpositions = _spawnpositions call dep_fnc_shuffle;
    for "_y" from 0 to (round random 2) do {
        _newpos = [];
        if ((count _spawnpositions) > 0) then {
            _newpos = _spawnpositions call BIS_fnc_selectRandom;
            _spawnpositions = _spawnpositions - [_newpos];
        } else {
            _newpos = _pos findEmptyPosition [0, _size, dep_box_ord];
            if ((count _newpos) == 0) then { _newpos = _pos; };
        };
        _ammo = createVehicle [([dep_box_weapons,dep_box_special,dep_box_launchers,dep_box_ammo,dep_box_ord] call BIS_fnc_selectRandom), _newpos, [], 0, "CAN_COLLIDE"];
        _ammo setDir (random 360);
    };
};

// Spawn APERS mines
if (dep_mines) then {
	if ((_location select 1) in ["roadpop"]) then {
		for "_y" from 0 to 2 do {
			if ((count _validhouses) > 0 && (random 1) <= 0.2) then {
				_house = _validhouses call BIS_fnc_selectRandom;
				_validhouses = _validhouses - [_house];
				_minepos = _house buildingExit 0;
				if (dep_debug) then {
					_m = createMarker[format["APmine%1%2", _this, _y], _minepos];
					_m setMarkerType "Minefield";
					_m setMarkerText "AP";
				};
				
				_minepos set [2, 0.01];
				_mine = createMine [["APERSMine","APERSBoundingMine","APERSTripMine"] call BIS_fnc_selectRandom, _minepos, [], 0];
				_mine setDir (getDir _house);
				dep_side revealMine _mine;
			};
		};
	};
};

// Spawn vehicles and patroling squad
if ((_location select 1) in ["patrol"]) then {   
    _depgroup = createGroup dep_side;
    _groups = _groups + [_depgroup];
    _enemyamount = round((dep_max_ai_loc / 2) + random (dep_max_ai_loc / 2));
    _totalenemies = _totalenemies + _enemyamount;
    _newpos = [_pos, 200, (random 360)] call BIS_fnc_relPos;
    
    for "_e" from 1 to _enemyamount do {				
        _soldiername = dep_mil_units call BIS_fnc_selectRandom;
        _spawnhandle = [_depgroup, _soldiername, _newpos] spawn {
            _soldier = [(_this select 0), (_this select 1), (_this select 2)] call dep_fnc_createunit;
        };
        waitUntil {scriptDone _spawnhandle};
    };
    [_depgroup] spawn dep_fnc_enemyspawnprotect;
    [_depgroup, (_location select 2)] spawn dep_fnc_unitpatrol;
};

// Spawn IED and AT mine
if ((_location select 1) in ["roadpop", "patrol"]) then {
    _list = _pos nearRoads 75;
    if (count _list > 4) then {
        if ((random 1) <= 0.6) then {
            _road = _list call BIS_fnc_selectRandom;
            _list = _list - [_road];
			_dir = [_road] call dep_fnc_roaddir;
			_iedpos = getPos _road;
			_ied = objNull;
			
			_type = "car";
			if (dep_ieds) then {
				_type = ["car","rubble","mine"] call BIS_fnc_selectRandom;
			};
			switch (_type) do {
				case "car": {
					_iedpos = [_iedpos, 4, _dir + 90] call BIS_fnc_relPos;
					_ied = (dep_civ_veh call BIS_fnc_selectRandom) createVehicle _iedpos;
					_ied setDir (_dir);
					_ied setFuel (1 - (random 1));
				};
				case "rubble": {
					_iedpos = [_iedpos, (5 + (round random 2)), _dir + 90] call BIS_fnc_relPos;
					_ied = (dep_clutter call BIS_fnc_selectRandom) createVehicle _iedpos;
					_ied setDir (_dir + 90);
				};
				default {
					_iedpos = [_iedpos, 3, (random 360)] call BIS_fnc_relPos;
					_ied = createMine [["IEDUrbanBig_F","IEDLandBig_F","IEDUrbanSmall_F","IEDLandSmall_F"] call BIS_fnc_selectRandom, _iedpos, [], 0];
				};
			};
            
			// Enable IED
            if (((random 1) <= dep_ied_chance || _type == "mine") && dep_ieds) then 
			{
				_ied setVariable ["workingon",false,true];
                _ied setVariable ["IED",true,true];
                _ied setVariable ["wrong_wire", round random 2, true];
                _ied setVariable ["cut_wires", [], true];
                // type of IED
                if ((random 1) <= 0.2) then {
                    _ied execFSM (dep_directory + "functions\ied_dp.fsm"); // explodes on vehicles and infantry
                } else {
                    _ied execFSM (dep_directory + "functions\ied_veh.fsm"); // only explodes on vehicles
                };
                
                // Add the actions
				if (_type != "mine") then {
					[[[_ied],format["%1functions\disable_ied_addactions.sqf", dep_directory]],"BIS_fnc_execVM",nil,true] spawn BIS_fnc_MP;
				};
                
                if (dep_debug) then {
                    _m = createMarker[format["ied%1", _this], _iedpos];
                    _m setMarkerType "mil_dot";
                    _m setMarkerText "ied";
					_m setMarkerColor "ColorRed";
                };
                        
				_ied addEventHandler 
				["Explosion", 
					{                       
						_object = (_this select 0);
						if (_object getVariable "IED") then {
							_boomtype = ["Bomb_03_F", "Bomb_04_F", "Bo_GBU12_LGB"] select round random 2;
							_boomtype createVehicle (position _object);
							deleteVehicle _object;
						};
						_this select 1;
					}
				];
			};
        };
        
        // Create AT mine
		if (dep_mines) then {
			if ((_location select 1) in ["roadpop"]) then {
				if ((random 1) <= 0.15) then {
					_road = _list call BIS_fnc_selectRandom;
					_list = _list - [_road];
					_dir = [_road] call dep_fnc_roaddir;
					_minepos = [_road, 1, _dir + 270] call BIS_fnc_relPos;
					_mine = createMine ["ATMine", _minepos, [], 0];
					dep_side revealMine _mine;
					civilian revealMine _mine;
					if (dep_debug) then {
						_m = createMarker[format["ATmine%1", _this], _minepos];
						_m setMarkerType "Minefield";
						_m setMarkerText "AT";
					};
				};
			};
		};
    };
};

["%2 enemies created at location %1", _this, _totalenemies] spawn dep_fnc_log;

_location set [3, true];
_location set [4, _groups];
_location set [6, _totalenemies];
_location set [8, _objects];
_location set [10, _civilians];

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
            if (!_hasplayers) then {
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