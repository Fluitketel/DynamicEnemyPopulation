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

private ["_pos","_houses","_house","_maxbuildingpos","_validhouses","_size","_buildpos","_enemyamount","_groups", "_civilians", "_location","_num_houses","_num_buildpos","_totalenemies","_depgroup"];

_location = dep_locations select _this;
["Spawning location %1 (%2)", _this, (_location select 1)] spawn dep_fnc_log;

_pos        = _location select 0;
_size       = _location select 2;
_objects    = _location select 8;

_groups = [];
_civilians = [];
_totalenemies = 0;

_rubble_pool = ["Land_Tyres_F","Land_GarbageBags_F","Land_JunkPile_F","Land_GarbageContainer_closed_F","Land_GarbageContainer_open_F","Land_WoodenBox_F"];
_ied_pool = ["IEDLandBig_Remote_Ammo","IEDLandSmall_Remote_Ammo","IEDUrbanBig_Remote_Ammo","IEDUrbanSmall_Remote_Ammo"];

if ((_location select 1) == "roadblock") then {
    _result = [_pos, _location select 9] call dep_fnc_roadblock;
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
        case "mortar": {    _result = [_pos, random 360] call dep_fnc_mortarcamp; };
        case "ins_camp1": { _result = [_pos, random 360] call dep_fnc_insurgentcamp1; };
    };
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

if ((_location select 1) == "ambush") then {
    _result = [];
    _type = ["ambush1","ambush2"] call BIS_fnc_selectRandom;
    switch (_type) do
    {
        case "ambush1": { _result = [_pos, (_location select 9)] call dep_fnc_ambush1; };
        case "ambush2": { _result = [_pos, (_location select 9)] call dep_fnc_ambush2; };
    };
    _totalenemies = _totalenemies + (_result select 0);
    _groups = _groups + (_result select 1);
    _objects = _objects + (_result select 2);
};

// Spawn units
if !((_location select 1) in ["patrol","bunker","roadblock", "ambush"]) then {
    _validhouses = [_pos, _size] call dep_fnc_enterablehouses;
    _num_houses = (count _validhouses);
    _groupsperlocation = (ceil (random _num_houses));
    if (_groupsperlocation < (_num_houses / 2)) then { _groupsperlocation = ceil(_num_houses / 2); };

    for "_c" from 1 to _groupsperlocation do 
	{
		// Amount of enemies to spawn
		_enemyamount = 4 + (round random 4);
		if ((_totalenemies +_enemyamount) > dep_max_ai_loc) exitWith 
		{ 
			["Location %1: spawning of %4 enemies not allowed, already spawned %2 of max %3.", _this, _totalenemies, dep_max_ai_loc, _enemyamount] spawn dep_fnc_log; 
		};
		
		_house = _validhouses call BIS_fnc_selectRandom;
        _validhouses = _validhouses - [_house];
        
        // Get positions in building
        _buildpos = _house call dep_fnc_buildingpositions;
        
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
            
            _soldier = [_depgroup, _soldiername, _newbuildpos] call dep_fnc_createunit;
            _soldier setDir (random 360); 
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
    
    // Civilians
    if (dep_civilians && (_location select 1) in ["roadpop"]) then
    {
        if ((count _validhouses) > 10) then
        {
            _numciv = 4 + (round random 4);
            
            _civgroup = createGroup civilian;
            _civilians = _civilians + [_civgroup];
            for "_e" from 1 to _numciv do {
                _newpos = _pos findEmptyPosition [0, 50];
                if ((count _newpos) >= 2) then 
                {
                    _unit = [_civgroup, (dep_civ_units call bis_fnc_selectRandom), _newpos] call dep_fnc_createcivilian;
                };
            };
            _newpos = [_pos, 10, (random 360)] call BIS_fnc_relPos;
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

if (_location select 1 == "military") then {
    if ((random 1) < 0.7) then {
        _depgroup = createGroup dep_side;
        _groups = _groups + [_depgroup];
        _enemyamount = 6;
        _totalenemies = _totalenemies + _enemyamount;
        
        for "_e" from 1 to _enemyamount do {				
            _soldiername = dep_mil_units call BIS_fnc_selectRandom;
            _newpos = _pos findEmptyPosition [0,20];
            _soldier = [_depgroup, _soldiername, _newpos] call dep_fnc_createunit;
            _soldier setDir (random 360);
        };
        [_depgroup] spawn dep_fnc_enemyspawnprotect;
        [_depgroup, (_location select 2)] spawn dep_fnc_unitpatrol;
    };
    _rng = round random 2;
    _ammoboxes = [];
    switch (dep_side) do 
    {
        case east: {
            _ammoboxes = ["O_supplyCrate_F", "Box_East_Ammo_F", "Box_East_Support_F"];
        };
        case west: {
            _ammoboxes = ["B_supplyCrate_F", "Box_NATO_Ammo_F", "Box_NATO_Support_F"];
        };
        default {
            _ammoboxes = ["IG_supplyCrate_F", "Box_IND_Ammo_F", "Box_IND_Support_F"];
        };
    };
    for "_y" from 1 to _rng do {
        _newpos = _pos findEmptyPosition [0, _size];
        _ammo = (_ammoboxes call BIS_fnc_selectRandom) createVehicle _newpos;
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
				//_objects = _objects + [_mine];
				east revealMine _mine;
				independent revealMine _mine;
			};
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
            if !(_veh isKindOf "Tank" || _veh isKindOf "Wheeled_APC_F") then {
                _units = dep_guer_units;
                _soldiername = _units call BIS_fnc_selectRandom;
            } else {
                _units = dep_mil_units;
                _soldiername = dep_u_veh_crew;
            };
            
            _soldier = [_depgroup, _soldiername, (getPos _road)] call dep_fnc_createunit;
            _soldier assignAsDriver _veh;
            _soldier moveInDriver _veh;
            _totalenemies = _totalenemies + 1;
            _positions = _veh emptyPositions "Gunner";
            if (_positions > 0) then {
                if (_veh isKindOf "Tank" || _veh isKindOf "Wheeled_APC_F") then {
                    _soldiername = dep_u_veh_crew;
                } else {
                    _soldiername = _units call BIS_fnc_selectRandom;
                };
                _soldier = [_depgroup, _soldiername, (getPos _road)] call dep_fnc_createunit;
                _soldier assignAsGunner _veh;
                _soldier moveInGunner _veh;
                _totalenemies = _totalenemies + 1;
            };
            if (_veh isKindOf "Tank" || _veh isKindOf "Wheeled_APC_F") then {
                _soldier = [_depgroup, dep_u_veh_cmnd, (getPos _road)] call dep_fnc_createunit;
                _soldier assignAsCommander _veh;
                _soldier moveInCommander _veh;
                _totalenemies = _totalenemies + 1;
            };
            // Put soldiers in APC
			_freeCargoPositions = _veh emptyPositions "cargo";
            if (_freeCargoPositions >= 1) then {
                _freeCargoPositions = round random _freeCargoPositions;
                for "_y" from 1 to _freeCargoPositions do {
                    _soldiername = _units call BIS_fnc_selectRandom;
                    _soldier = [_depgroup, _soldiername, (getPos _road)] call dep_fnc_createunit;
                    _soldier assignAsCargo _veh;
                    _soldier moveInCargo _veh;
                };
            };
            _return = [_pos, _depgroup] call dep_fnc_vehiclepatrol;
        };
        
        if (dep_civilians) then
        {
            if ((round random 1) <= 1) then
            {
                _road = _list call BIS_fnc_selectRandom;
                _vehname = dep_civ_veh call BIS_fnc_selectRandom;
                _veh = _vehname createVehicle (getPos _road);
                [_veh] spawn dep_fnc_vehicledamage;
            
                _civgroup = createGroup civilian;
                _unit = [_civgroup, (dep_civ_units call bis_fnc_selectRandom), (getPos _road)] call dep_fnc_createcivilian;
                [_civgroup] spawn dep_fnc_enemyspawnprotect;
                _civilians = _civilians + [_civgroup];
                
                _unit assignAsDriver _veh;
                _unit moveInDriver _veh;
                
                _return = [_pos, _civgroup] call dep_fnc_vehiclepatrol;
            };
        };
    };
    
    _depgroup = createGroup dep_side;
    _groups = _groups + [_depgroup];
    _enemyamount = [6,8,12] call BIS_fnc_selectRandom;
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
					_ied = (_rubble_pool call BIS_fnc_selectRandom) createVehicle _iedpos;
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
		if (dep_mines) then 
		{
			if ((_location select 1) in ["roadpop"]) then 
			{
				if ((random 1) <= 0.15) then 
				{
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
dep_locations set [_this, _location];
true;