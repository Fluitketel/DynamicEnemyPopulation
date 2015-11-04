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
// This file makes a vehicle patrol the given area.

private ["_pos","_wppos","_group","_list","_road","_wp","_waypoints","_numwp"];
_pos = _this select 0;
_group = _this select 1;

_numwp = 4;
_list = _pos nearRoads dep_veh_pat_rad;
_waypoints = [];

for "_y" from 0 to (_numwp - 1) do {
	_tooclose = true;
	_valid = false;
	while {!_valid && (count _list) > 0} do 
	{
		_road = _list call BIS_fnc_selectRandom;
		_list = _list - [_road];
		_wppos = getPos _road;
		_tooclose = false;
		_toocentered = false;
		
		// Check if too close to other waypoints
		{
			if ((_x distance _wppos) < (dep_veh_pat_rad * 0.2)) exitWith { _tooclose = true; };
		} forEach _waypoints;
		
		// Check if too close to location center
		if ((_wppos distance _pos) < (dep_veh_pat_rad / 3)) then { _toocentered = true; };
		
		if (!_toocentered && !_tooclose) then { _valid = true; };
	};
	if (_valid) then { _waypoints = _waypoints + [_wppos]; };    
};

if ((count _waypoints) < _numwp) then 
{
    "Vehicle patrol couldn't find enough roads, finding random waypoints instead." spawn dep_fnc_log;
    while {(count _waypoints) < _numwp} do 
	{
        _wppos = [_pos, (dep_veh_pat_rad / 3) + (random (dep_veh_pat_rad * (2/3))), (random 360)] call BIS_fnc_relPos;
		if !(surfaceIsWater _wppos) then 
		{
			_waypoints = _waypoints + [_wppos];
		};
    };
};

_y = 0;
{
	_wp = _group addWaypoint [_x, _y];
	_wp setWaypointBehaviour "SAFE";
	_wp setWaypointSpeed "LIMITED";
	_wp setWaypointFormation "COLUMN";
	_wp setWaypointTimeOut [10,20,40];
	if ((_y + 1) < (count _waypoints)) then {
		_wp setWaypointType "MOVE";
	} else {
		_wp setWaypointType "CYCLE";
	};
	
	//_m = createMarker[format["wptest%1%2", _y, time], _x];
	//_m setMarkerType "mil_dot";
	//_m setMarkerText format ["%1", _y];
	//_m setMarkerColor "ColorBlue";
	
	_y = _y + 1;
} forEach _waypoints;
true;