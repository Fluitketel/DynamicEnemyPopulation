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
// This file spawns units at a given location.

_cache = dep_loc_cache select _this;
if ((count _cache) > 0) exitWith {
    _result = _this call dep_fnc_restore;
    true;
};

private ["_pos","_houses","_house","_maxbuildingpos","_validhouses","_size","_buildpos","_enemyamount","_groups","_location","_num_houses","_num_buildpos","_totalenemies","_depgroup"];

diag_log format ["Spawning location %1", _this];
dep_spawning = true;

_location = dep_locations select _this;
_pos        = _location select 0;
_size       = _location select 2;
_objects    = _location select 8;

_groups = [];
_totalenemies = 0;

_rubble_pool = ["Land_Tyres_F","Land_GarbageBags_F","Land_JunkPile_F","Land_GarbageContainer_closed_F","Land_GarbageContainer_open_F","Land_WoodenBox_F"];
_ied_pool = ["IEDLandBig_Remote_Ammo","IEDLandSmall_Remote_Ammo","IEDUrbanBig_Remote_Ammo","IEDUrbanSmall_Remote_Ammo"];
//_rubble_pool = ["IEDLandBig_Remote_Ammo","IEDLandSmall_Remote_Ammo","IEDUrbanBig_Remote_Ammo","IEDUrbanSmall_Remote_Ammo"];
//_rubble_pool = ["IEDLandBig_F","IEDLandSmall_F","IEDUrbanBig_F","IEDUrbanSmall_F"];

if ((_location select 1) == "roadblock") then {
    _result = [_pos, _location select 9] call dep_fnc_roadblock;
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

if ((_location select 1) == "bunker") then {
    _result = [];
    if (random 1 < 0.7) then {
        _result = [_pos, random 360] call dep_fnc_atcamp;
    } else {
        _result = [_pos, random 360] call dep_fnc_mortarcamp;
    };
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

// Spawn units
if !((_location select 1) in ["patrol","bunker","roadblock"]) then {
    _validhouses = [_pos, _size] call dep_fnc_enterablehouses;
    _num_houses = (count _validhouses);
    _groupsperlocation = (ceil (random _num_houses));
    if (_groupsperlocation < (_num_houses / 2)) then { _groupsperlocation = ceil(_num_houses / 2); };

    for "_c" from 1 to _groupsperlocation do {
        if (_totalenemies >= dep_max_ai_loc) exitWith { diag_log format ["Location %1 max enemies (%2) reached, stopping spawn.", _this, dep_max_ai_loc]; };
        
        _house = _validhouses call BIS_fnc_selectRandom;
        _validhouses = _validhouses - [_house];
        
        // Get positions in building
        _buildpos = _house call dep_fnc_buildingpositions;
        _num_buildpos = (count _buildpos);

        _enemyamount = ceil (random _num_buildpos);
        if (_enemyamount < (_num_buildpos / 2)) then { _enemyamount = ceil(_num_buildpos / 2); };
        if (_enemyamount > 8) then { _enemyamount = 8; };
        if (_enemyamount < 4) then { _enemyamount = 4; };
        
        _depgroup = createGroup dep_side;
        _groups = _groups + [_depgroup];
        _totalenemies = _totalenemies + _enemyamount;
        
        for "_e" from 1 to _enemyamount do {
            _newbuildpos = [];
            if ((count _buildpos) > 0) then {
                _newbuildpos = _buildpos call BIS_fnc_selectRandom;
                _buildpos = _buildpos - [_newbuildpos];
            } else {
                _newbuildpos = (getPos _house) findEmptyPosition [0,20];
                if ((count _newbuildpos) == 0) then { _newbuildpos = (getPos _house); };
            };
            _soldiername = "";
            if ((_location select 1) == "military") then {
                _soldiername = dep_mil_units call BIS_fnc_selectRandom;
            } else {
                _soldiername = dep_guer_units call BIS_fnc_selectRandom;
            };
            
            _spawnhandle = [_depgroup, _soldiername, _newbuildpos] spawn {
                _soldier = [(_this select 0), (_this select 1), (_this select 2)] call dep_fnc_createunit;
                waitUntil{alive _soldier};
                _soldier removeEventHandler ["killed", 0];
                _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1functions\cleanup.sqf", dep_directory]}];
                _soldier setDir (random 360);
            };
            waitUntil {scriptDone _spawnhandle};
        };
        if ((random 1) <= 0.3 && _enemyamount > 1) then {
            // Make units patrol
            for "_y" from 0 to 8 do {
                _newpos = [(getPos _house), 10, (45 * _y)] call BIS_fnc_relPos;
                _wp = _depgroup addWaypoint [_newpos, _y];
                _wp setWaypointBehaviour "SAFE";
                _wp setWaypointSpeed "LIMITED";
                _wp setWaypointFormation "COLUMN";
                _wp setWaypointTimeOut [0,5,10];
                if (_y < 8) then {
                    _wp setWaypointType "MOVE";
                } else {
                    _wp setWaypointType "CYCLE";
                };
            };
        } else {
            doStop (units _depgroup);
        };
        [_depgroup] spawn dep_fnc_enemyspawnprotect;
        sleep 0.02;
    };
    
    if (dep_civilians) then
    {
        civilian setFriend [west, 1];
        _civgroup = createGroup civilian;
        for "_e" from 1 to 3 do {
            _unit = _civgroup createUnit ["C_man_polo_1_F", _pos, [], 0, "NONE"];
        };
        _wp = _depgroup addWaypoint [(_pos findEmptyPosition [0, 20]), 0];
        _wp setWaypointBehaviour "SAFE";
        _wp setWaypointSpeed "LIMITED";
        _wp setWaypointFormation "COLUMN";
        _wp setWaypointTimeOut [10,20,30];
        _wp setWaypointType "LOITER";
        [_civgroup, 0] setWaypointLoiterType "CIRCLE";
        [_civgroup, 0] setWaypointLoiterRadius 100;
        _wp = _depgroup addWaypoint [(_pos findEmptyPosition [0, 20]), 1];
        _wp setWaypointBehaviour "SAFE";
        _wp setWaypointSpeed "LIMITED";
        _wp setWaypointFormation "COLUMN";
        _wp setWaypointType "CYCLE";
        
        for "_o" from 1 to 4 do {
            if ((count _validhouses) > 0) then 
            {
                _house = _validhouses call BIS_fnc_selectRandom;
                _validhouses = _validhouses - [_house];
                _buildpos = _house call dep_fnc_buildingpositions;
                _civgroup = createGroup civilian;
                for "_e" from 1 to 3 do {
                    _newbuildpos = [];
                    if ((count _buildpos) > 0) then 
                    {
                        _newbuildpos = _buildpos call BIS_fnc_selectRandom;
                        _buildpos = _buildpos - [_newbuildpos];
                        _unit = _civgroup createUnit ["C_man_polo_1_F", _newbuildpos, [], 0, "NONE"];
                    };
                };
                doStop (units _civgroup);
                [_civgroup] spawn dep_fnc_enemyspawnprotect;
            };
        };
    };
};

if (_location select 1 == "military") then {
    if ((random 1) < 0.7) then {
        _depgroup = createGroup dep_side;
        _groups = _groups + [_depgroup];
        _enemyamount = 6;
        _totalenemies = _totalenemies + _enemyamount;
        
        for "_e" from 1 to _enemyamount do {				
            _soldiername = dep_mil_units call BIS_fnc_selectRandom;
            _newpos = _pos findEmptyPosition [0,20];
            _spawnhandle = [_depgroup, _soldiername, _newpos] spawn {
                _soldier = [(_this select 0), (_this select 1), (_this select 2)] call dep_fnc_createunit;
                waitUntil{alive _soldier};
                _soldier removeEventHandler ["killed", 0];
                _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1functions\cleanup.sqf", dep_directory]}];
            };
            waitUntil {scriptDone _spawnhandle};
        };
        [_depgroup] spawn dep_fnc_enemyspawnprotect;
        [_depgroup, (_location select 2)] spawn dep_fnc_unitpatrol;
    };
    _rng = round random 2;
    _ammoboxes = ["IG_supplyCrate_F", "O_supplyCrate_F", "Box_East_Ammo_F"];
    for "_y" from 1 to _rng do {
        _newpos = _pos findEmptyPosition [0, _size];
        _ammo = (_ammoboxes call BIS_fnc_selectRandom) createVehicle _newpos;
    };
};

// Spawn APERS mines
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
            //_objects = _objects + [_mine];
            east revealMine _mine;
            independent revealMine _mine;
        };
    };
};

// Spawn vehicles and patroling squad
if ((_location select 1) in ["patrol"]) then {
    _soldiername = "";
    _list = _pos nearRoads dep_veh_pat_rad;
    if (count _list > 10) then {
        _numvehicles = round random (dep_veh_chance * 10);
        if (_numvehicles < 1) then { _numvehicles = 1; };
        for "_z" from 1 to _numvehicles do {
            if (dep_total_veh < dep_max_veh) then {
                _road = _list call BIS_fnc_selectRandom;
                _vehname = dep_ground_vehicles call BIS_fnc_selectRandom;
                _veh = _vehname createVehicle (getPos _road);
                dep_total_veh = dep_total_veh + 1;
                _objects = _objects + [_veh];
                [_veh] spawn dep_fnc_vehicledamage;
                
                _depgroup = createGroup dep_side;
                _groups = _groups + [_depgroup];
                _units = [];
                _soldiername = "";
                if (_vehname in ["I_G_offroad_01_armed_F", "I_G_Van_01_transport_F"]) then {
                    _units = dep_guer_units;
                    _soldiername = _units call BIS_fnc_selectRandom;
                } else {
                    _units = dep_mil_units;
                    _soldiername = dep_u_veh_crew;
                };
                
                _soldier = [_depgroup, _soldiername, (getPos _road)] call dep_fnc_createunit;
                _soldier assignAsDriver _veh;
                _soldier moveInDriver _veh;
                _soldier removeEventHandler ["killed", 0];
                _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1functions\cleanup.sqf", dep_directory]}];
                _totalenemies = _totalenemies + 1;
                _positions = _veh emptyPositions "Gunner";
                if (_positions > 0) then {
                    if (_veh isKindOf "Tank") then {
                        _soldiername = dep_u_veh_crew;
                    } else {
                        _soldiername = _units call BIS_fnc_selectRandom;
                    };
                    _soldier = [_depgroup, _soldiername, (getPos _road)] call dep_fnc_createunit;
                    _soldier assignAsGunner _veh;
                    _soldier moveInGunner _veh;
                    _soldier removeEventHandler ["killed", 0];
                    _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1functions\cleanup.sqf", dep_directory]}];
                    _totalenemies = _totalenemies + 1;
                };
                if (_veh isKindOf "Tank") then {
                    _soldier = [_depgroup, dep_u_veh_cmnd, (getPos _road)] call dep_fnc_createunit;
                    _soldier assignAsCommander _veh;
                    _soldier moveInCommander _veh;
                    _soldier removeEventHandler ["killed", 0];
                    _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1functions\cleanup.sqf", dep_directory]}];
                    _totalenemies = _totalenemies + 1;
                };
                // Put soldiers in APC
                if (_vehname in ["I_APC_tracked_03_cannon_F","I_APC_Wheeled_03_cannon_F","I_G_Van_01_transport_F"]) then {
                    _freeCargoPositions = _veh emptyPositions "cargo";
                    _freeCargoPositions = round random _freeCargoPositions;
                    for "_y" from 1 to _freeCargoPositions do {
                        _soldiername = _units call BIS_fnc_selectRandom;
                        _soldier = [_depgroup, _soldiername, (getPos _road)] call dep_fnc_createunit;
                        _soldier assignAsCargo _veh;
                        _soldier moveInCargo _veh;
                        _soldier removeEventHandler ["killed", 0];
                        _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1functions\cleanup.sqf", dep_directory]}];
                    };
                };
                _return = [_pos, _depgroup] call dep_fnc_vehiclepatrol;
            };
        };
    };
    
    _depgroup = createGroup dep_side;
    _groups = _groups + [_depgroup];
    _enemyamount = [6,8,12] call BIS_fnc_selectRandom;
    _totalenemies = _totalenemies + _enemyamount;
    _newpos = [_pos, 30, (random 360)] call BIS_fnc_relPos;
    
    for "_e" from 1 to _enemyamount do {				
        _soldiername = dep_mil_units call BIS_fnc_selectRandom;
        _spawnhandle = [_depgroup, _soldiername, _newpos] spawn {
            _soldier = [(_this select 0), (_this select 1), (_this select 2)] call dep_fnc_createunit;
            waitUntil{alive _soldier};
            _soldier removeEventHandler ["killed", 0];
            _soldier addEventHandler ["killed", {(_this select 0) execVM format ["%1functions\cleanup.sqf", dep_directory]}];
        };
        waitUntil {scriptDone _spawnhandle};
    };
    [_depgroup] spawn dep_fnc_enemyspawnprotect;
    [_depgroup, (_location select 2)] spawn dep_fnc_unitpatrol;
};

// Spawn IED and AT mine
if ((_location select 1) in ["roadpop"]) then {
    _list = _pos nearRoads 75;
    if (count _list > 4) then {
        
        if ((random 1) <= 0.6) then {
            // Create rubble
            _road = _list call BIS_fnc_selectRandom;
            _list = _list - [_road];
            _dir = [_road] call dep_fnc_roaddir;
            _rubblepos = [_road, (5 + (round random 2)), _dir + 90] call BIS_fnc_relPos;
            _rubble = (_rubble_pool call BIS_fnc_selectRandom) createVehicle _rubblepos;
            _rubble setDir (_dir + 90);
           _rubble setVariable ["workingon",false,true]; 
            if ((random 1) <= dep_ied_chance) then {
                // Hide IED in rubble
                _rubble setVariable ["IED",true,true];
                // type of IED
                if ((random 1) <= 0.2) then {
                    _rubble execFSM (dep_directory + "functions\ied_dp.fsm"); // explodes on vehicles and infantry
                } else {
                    _rubble execFSM (dep_directory + "functions\ied_veh.fsm"); // only explodes on vehicles
                };
                
                // Add the actions
                [[[_rubble],format["%1functions\disable_ied_addactions.sqf", dep_directory]],"BIS_fnc_execVM",nil,true] spawn BIS_fnc_MP;
                
                if (dep_debug) then {
                    _m = createMarker[format["ied%1", _this], _rubblepos];
                    _m setMarkerType "mil_dot";
                    _m setMarkerText "ied";
                };
            } else {
                _rubble setVariable ["IED",false,true];
                if (dep_debug) then {
                    _m = createMarker[format["ied%1", _this], _rubblepos];
                    _m setMarkerType "mil_dot";
                    _m setMarkerText "fake ied";
                };
            };            
            _rubble addEventHandler 
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
        
        if ((random 1) <= 0.15) then {
            // Create mine
            _road = _list call BIS_fnc_selectRandom;
            _list = _list - [_road];
            _dir = [_road] call dep_fnc_roaddir;
            _minepos = [_road, 1, _dir + 270] call BIS_fnc_relPos;
            _mine = createMine ["ATMine", _minepos, [], 0];
            east revealMine _mine;
            independent revealMine _mine;
            if (dep_debug) then {
                _m = createMarker[format["ATmine%1", _this], _minepos];
                _m setMarkerType "Minefield";
                _m setMarkerText "AT";
            };
        };
    };
};
diag_log format ["%2 enemies created at location %1", _this, _totalenemies];

_location set [3, true];
_location set [4, _groups];
_location set [6, _totalenemies];
_location set [8, _objects];
dep_locations set [_this, _location];
dep_spawning = false;
true;