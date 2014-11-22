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
private ["_pos","_group","_list","_road","_wp"];
_pos = _this select 0;
_group = _this select 1;

_list = _pos nearRoads dep_act_dist;
for "_y" from 0 to 8 do {
    _road = _list call BIS_fnc_selectRandom;
    _list = _list - [_road];
    _wp = _group addWaypoint [(getPos _road), _y];
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
true;