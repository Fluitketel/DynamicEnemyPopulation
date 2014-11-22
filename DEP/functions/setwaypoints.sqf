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
// This file sets the waypoints for a group.
private ["_group","_waypoints","_wp"];
_group  = _this select 0;
_waypoints  = _this select 1;

_y = 0;
{
    _wp = _group addWaypoint [(_x select 0), _y];
    _wp setWaypointBehaviour    (_x select 1);
    _wp setWaypointSpeed        (_x select 2);
    _wp setWaypointFormation    (_x select 3);
    _wp setWaypointTimeOut      (_x select 4);
    _wp setWaypointType         (_x select 5);

    _y = _y + 1;
} forEach _waypoints;