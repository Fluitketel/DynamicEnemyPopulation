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
// This file tells a group to patrol an area.
private ["_pos","_newpos","_group","_radius","_wp", "_formation", "_water", "_houses"];
_group  = _this select 0;
_radius = _this select 1;
_pos    = getPos (leader _group);
if ((count _this) > 2) then {
    _pos = _this select 2;
};

_formation = dep_formations call BIS_fnc_selectRandom;

_houses = [_pos, _radius] call dep_fnc_enterablehouses;

for "_y" from 0 to 8 do {
    _newpos = [];
    if ((count _houses) > 0) then {
        if (random 1 < 0.4) then {
            _newpos = _houses call BIS_fnc_selectRandom;
            _houses = _houses - [_newpos];
            _newpos = _newpos call dep_fnc_buildingpositions;
            if ((count _newpos) > 0) then {
                _newpos = _newpos call BIS_fnc_selectRandom;
            };
        };
    };
    if ((count _newpos) == 0) then {
        _water = true;
        while {_water} do {
            _newpos = [_pos, (_radius * 0.3) + (random (_radius * 0.7)), (random 360)] call BIS_fnc_relPos;
            _water = surfaceIsWater _newpos;
        };
    };
    /*_m = createMarker[format["r%1", _newpos], _newpos];
    _m setMarkerType "mil_dot";
    _m setMarkerText (str _y);*/
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