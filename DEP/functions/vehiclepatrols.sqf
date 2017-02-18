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
// This file creates patroling vehicles

dep_fnc_spawn_vehiclepatrol = 
{
	private ["_start","_end","_target","_try","_wp","_vehicle","_group","_player","_players","_roads"];
    
    // Find a player
    if ((count dep_players) == 0) exitWith { objNull; };
    _players = dep_players call dep_fnc_shuffle;
    _player = objNull;
    {
        if ([_x] call dep_fnc_outsidesafezone) exitWith {
            _player = _x;
        }
    } forEach _players;
    if (isNull _player) exitWith { objNull; };
    
    // Find a target road position
    _roads = [getPos _player, dep_act_dist] call dep_fnc_findroads;
    if ((count _roads) == 0) then {
        _roads = [getPos _player, dep_act_dist * 2] call dep_fnc_findroads;
    };
    if ((count _roads) == 0) exitWith { objNull; };
    
    _try = true;
    _y = 1;
    _target = objNull;
    while {_try} do {
        _target = _roads call BIS_fnc_selectRandom;
        if ([getPos _target] call dep_fnc_outsidesafezone) then {
            _try = false;
        };
        
        _y = _y + 1;
        if ((_y > 20) && _try) then {
            _target = objNull;
            _try = false;
        };
    };
    if (isNull _target) exitWith { objNull; };
    
    // Find the start road position
    _try = true;
    _y = 1;
    _start = objNull;
    _roads = [getPos _target, dep_act_dist * 3] call dep_fnc_findroads;
    while {_try} do {
        _start = _roads call BIS_fnc_selectRandom;
        if !([getPos _start, dep_act_dist] call dep_fnc_players_within_range) then {
            if ([getPos _start] call dep_fnc_outsidesafezone) then {
                _try = false;
            };
        };
        
        _y = _y + 1;
        if ((_y > 20) && _try) then {
            _start = objNull;
            _try = false;
        };
    };
    if (isNull _start) exitWith { objNull; };
    
    // Find the end road position
    _try = true;
    _y = 1;
    _end = objNull;
    while {_try} do {
        _end = _roads call BIS_fnc_selectRandom;
        if !([getPos _end, dep_act_dist] call dep_fnc_players_within_range) then {
            if ([getPos _end] call dep_fnc_outsidesafezone) then {
                _try = false;
            };
        };
        
        _y = _y + 1;
        if ((_y > 20) && _try) then {
            _end = objNull;
            _try = false;
        };
    };
    if (isNull _end) exitWith { objNull; };
    
    // Create the vehicle
    _vehicle = objNull;
    _group = grpNull;
    if (dep_civilians && (random 1) < 0.5) then {
        // Civilian vehicle
        _vehicle = (dep_civ_veh call BIS_fnc_selectRandom) createVehicle (getPos _start);
        _vehicle setDir ([_start] call dep_fnc_roaddir);
        [_vehicle] spawn dep_fnc_vehicledamage;
    
        _group = createGroup civilian;
        _spawnpos = (getPos _start) findEmptyPosition [0, 10];
        _soldier = [_group, (dep_civ_units call bis_fnc_selectRandom), _spawnpos] call dep_fnc_createcivilian;    
        _soldier assignAsDriver _vehicle;
        _soldier moveInDriver _vehicle;
    } else {
        // Enemy vehicle
        _vehicle = (dep_ground_vehicles call BIS_fnc_selectRandom) createVehicle (getPos _start);
        _vehicle setDir ([_start] call dep_fnc_roaddir);
        [_vehicle] spawn dep_fnc_vehicledamage;
        _group = [_vehicle] call dep_fnc_vehicle_fill;
    };
    
    _wp = _group addWaypoint [getPos _target, 0];
	_wp setWaypointBehaviour "SAFE";
	_wp setWaypointSpeed "LIMITED";
	_wp setWaypointFormation "COLUMN";
	_wp setWaypointTimeOut [0,15,30];
	_wp setWaypointType "MOVE";
    
    _wp = _group addWaypoint [getPos _end, 0];
	_wp setWaypointBehaviour "SAFE";
	_wp setWaypointSpeed "LIMITED";
	_wp setWaypointFormation "COLUMN";
	_wp setWaypointTimeOut [0,15,30];
	_wp setWaypointType "MOVE";
    _wp setWaypointCompletionRadius 20;
	_wp setWaypointStatements ["true", "[(vehicle leader this)] spawn dep_fnc_delete_vehicle;"];
    
    /*_m = createMarker[format["patrol%1", getPos _start], getPos _start];
    _m setMarkerType "mil_dot";
    _m setMarkerText format["Start %1", time];
    _m = createMarker[format["patrol%1", getPos _target], getPos _target];
    _m setMarkerType "mil_dot";
    _m setMarkerText format["Target %1", time];
    _m = createMarker[format["patrol%1", getPos _end], getPos _end];
    _m setMarkerType "mil_dot";
    _m setMarkerText format["End %1", time];*/
    
    ["Vehicle created and moving to %1.", getPos _end] spawn dep_fnc_log;
    _vehicle;
};

private ["_vehicles", "_waypoints_available", "_interval","_created"];

waitUntil {!isNil "dep_veh_chance"};
waitUntil {!isNil "dep_num_players"};
waitUntil {dep_veh_chance > 0};
waitUntil {dep_num_players > 0};

_vehicles = [];
_interval = 600;

while {true} do {
    {
        _vehicle = _x;
        if (!isNull _vehicle) then {
            if (!alive _vehicle || !canMove _vehicle || !(alive driver _vehicle)) then {
                //{deleteVehicle _x} forEach crew _vehicle;
                //deleteVehicle _vehicle;
                _vehicles = _vehicles - [_vehicle];
                sleep _interval;
            };
        } else {
            _vehicles = _vehicles - [_vehicle];
            sleep _interval;
        };
    } forEach _vehicles;
    dep_total_veh = count _vehicles;
    
    _maxvehicles = round random (dep_veh_chance * 4);
    _created = false;
    while {(count _vehicles) < _maxvehicles && dep_num_players > 0 && dep_veh_chance > 0} do {
        _vehicle = [] call dep_fnc_spawn_vehiclepatrol;
        if !(isNull _vehicle) then {
            _vehicles = _vehicles + [_vehicle];
            dep_total_veh = count _vehicles;
            dep_countunits = true;
            _created = true;
            sleep (random _interval);
        };
    };
    if (_created) then {
        sleep _interval;
    } else {
        sleep 10;
    };    
};