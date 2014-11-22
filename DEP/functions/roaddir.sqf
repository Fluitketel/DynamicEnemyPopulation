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
// This file finds the direction of a road.
private ["_road","_roadsConnectedTo","_connectedRoad","_roaddir","_connected"];
_road = _this select 0;
_roadsConnectedTo = roadsConnectedTo _road;
_roaddir = 0;
_connected = count _roadsConnectedTo;
_connectedRoad = objNull;
if (_connected == 0) then {
    _roaddir = direction _road;
} else {
    if (_connected > 1) then {
        _connectedRoad = _roadsConnectedTo select (round(random (_connected - 1)));
    } else {
        _connectedRoad = _roadsConnectedTo select 0;
    };
    _roaddir = [_road, _connectedRoad] call BIS_fnc_DirTo;;
};
_roaddir;