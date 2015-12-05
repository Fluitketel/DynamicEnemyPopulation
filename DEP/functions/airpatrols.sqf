/*  Copyright 2015 Fluit
    
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
// This file creates patroling air vehicles

dep_fnc_spawn_air = 
{
	private ["_start","_end","_startpos","_endpos","_waypoints","_vehicle","_group"];
	_waypoints = _this select 0;
	
	_start = floor random (count _waypoints);
	_end = _start;
	_startpos = _waypoints select _start;
	_endpos = _waypoints select _end;
	while {(_startpos distance _endpos) < (dep_map_radius * 1.75)} do
	{
		_end = floor random (count _waypoints);
		_endpos = _waypoints select _end;
	};
	
	["Begin air patrol from %1 to %2", _start, _end] spawn dep_fnc_log;
	
	_return = [_startpos, 0, (dep_air_vehicles call BIS_fnc_selectRandom), dep_side] call BIS_fnc_spawnVehicle;
	_vehicle = _return select 0;
	_group = _return select 2;
	_vehicle flyInHeight 50;
	
	_wp = _group addWaypoint [_endpos, 0];
	_wp setWaypointBehaviour "SAFE";
	if ((random 1) < 0.5) then
	{
		_wp setWaypointSpeed "NORMAL";
	} else {
		_wp setWaypointSpeed "LIMITED";
	};
	_wp setWaypointFormation "COLUMN";
	_wp setWaypointType "MOVE";
	_wp setWaypointCompletionRadius 300;
	_wp setWaypointStatements ["true", "cleanUpveh = vehicle leader this; {deleteVehicle _x} forEach crew cleanUpveh + [cleanUpveh];"];
	
	_vehicle;
};

if (dep_air_patrols > 0) then 
{
	private ["_vehicles", "_waypoints", "_waypoints_available"];
	_waypoints = [];
	_vehicles = [];
	
	// Find waypoints
	_newdir = 0;
	for "_c" from 0 to 15 do 
	{
		_pos = [dep_map_center, dep_map_radius + 1000, _newdir] call BIS_fnc_relPos;
		_newdir = _newdir + (360 / 16);
		if (dep_debug) then
		{
			_m = createMarker[format["dep_air_wp_%1", _c], _pos];
			_m setMarkerType "o_plane";
			_m setMarkerText (str _c);
			_m setMarkerColor "ColorRed";
		};
		_waypoints = _waypoints + [_pos];
	};
	
	while {true} do
	{
		{
			_vehicle = _x;
			if (!isNull _vehicle) then
			{
				if (!alive _vehicle || !canMove _vehicle) then
				{
					{deleteVehicle _x} forEach crew _vehicle;
					deleteVehicle _vehicle;
					_vehicles = _vehicles - [_vehicle];
					sleep 600;
				};
			} else {
				_vehicles = _vehicles - [_vehicle];
			};
		} forEach _vehicles;
		while {(count _vehicles) < dep_air_patrols} do
		{
			_vehicle = [_waypoints] call dep_fnc_spawn_air;
			_vehicles = _vehicles + [_vehicle];
			sleep (random 60);
		};
		sleep 600;
	};
};