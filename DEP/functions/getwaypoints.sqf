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
// This file returns the waypoints of a group.
private ["_group","_waypoints","_waypoint","_amount","_pos"];
_group  = _this select 0;

_wps = waypoints _group;
_amount = count _wps;

_waypoints = [];
for "_y" from 1 to _amount do {
    _i = _y - 1;
    _pos = waypointPosition [_group, _i];
    if ((_pos select 0) > 0 && (_pos select 1 > 0)) then {
        _waypoint = [];
        _waypoint set [0, waypointPosition  [_group, _i]];
        _waypoint set [1, waypointBehaviour [_group, _i]];
        _waypoint set [2, waypointSpeed     [_group, _i]];
        _waypoint set [3, waypointFormation [_group, _i]];
        _waypoint set [4, waypointTimeout   [_group, _i]];
        _waypoint set [5, waypointType      [_group, _i]];
        _waypoints = _waypoints + [_waypoint];
    };
};
_waypoints;