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
// This file tells a group to patrol an area.
private ["_pos","_group","_radius","_wp", "_formation"];
_group  = _this select 0;
_radius  = _this select 1;
_pos    = getPos (leader _group);

_formation = "COLUMN";
if (random 1 > 0.5) then {
    _formation = "STAG COLUMN";
};

for "_y" from 0 to 8 do {
    _newpos = [_pos, _radius, (random 360)] call BIS_fnc_relPos;
    _wp = _group addWaypoint [_newpos, _y];
    _wp setWaypointBehaviour "SAFE";
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointFormation _formation;
    _wp setWaypointTimeOut [0,10,20];
    if (_y < 8) then {
        _wp setWaypointType "MOVE";
    } else {
        _wp setWaypointType "CYCLE";
    };
};