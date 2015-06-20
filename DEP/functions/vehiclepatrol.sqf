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
// This file makes a vehicle patrol the given area.
private ["_pos","_wppos","_group","_list","_road","_wp"];
_pos = _this select 0;
_group = _this select 1;

_list = _pos nearRoads dep_veh_pat_rad;
if ((count _list) >= 5) then
{
    for "_y" from 0 to 5 do {
        _road = _list call BIS_fnc_selectRandom;
        _list = _list - [_road];
        _wp = _group addWaypoint [(getPos _road), _y];
        _wp setWaypointBehaviour "SAFE";
        _wp setWaypointSpeed "LIMITED";
        _wp setWaypointFormation "COLUMN";
        _wp setWaypointTimeOut [0,5,10];
        if (_y < 5) then {
            _wp setWaypointType "MOVE";
        } else {
            _wp setWaypointType "CYCLE";
        };
    };
} else {
    "Vehicle patrol couldn't find enough roads, finding random waypoints instead." spawn dep_fnc_log;
    for "_y" from 0 to 5 do {
        _wppos = [_pos, (random dep_veh_pat_rad), (random 360)] call BIS_fnc_relPos;
        _wp = _group addWaypoint [_wppos, _y];
        _wp setWaypointBehaviour "SAFE";
        _wp setWaypointSpeed "LIMITED";
        _wp setWaypointFormation "COLUMN";
        _wp setWaypointTimeOut [0,5,10];
        if (_y < 5) then {
            _wp setWaypointType "MOVE";
        } else {
            _wp setWaypointType "CYCLE";
        };
    };
};
true;