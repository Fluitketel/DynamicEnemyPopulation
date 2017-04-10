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
// This file spawns a forest patrol at the given location.
params ['_location'];
private ["_pos","_radius","_paths","_path","_temp","_wp1","_wp2","_minepos","_group","_wp","_soldier","_soldiername","_groups","_totalenemies","_objects","_houses","_formation"];
_pos = _location select 0;
_radius = _location select 2;

_groups = [];
_totalenemies = 0;
_objects = [];

_group = createGroup dep_side;
_groups = _groups + [_group];
_enemyamount = round((dep_max_ai_loc / 2) + (random (dep_max_ai_loc / 2)));

for "_c" from 1 to _enemyamount do {
    _soldiername = dep_guer_units call BIS_fnc_selectRandom;
    _soldier = [_group, _soldiername, _pos] call dep_fnc_createunit;
    _totalenemies = _totalenemies + 1;
};

_minepos = _pos;
if (dep_mines && (random 1) < 0.4) then {
    _temp = 0;
    _paths = [_pos, _radius] call dep_fnc_findpaths;
    {
        if ((_pos distance _x) > _temp) then {
            _temp = _pos distance _x;
            _minepos = getPos _x;
        }; 
    } forEach _paths;
    
    if (dep_debug) then {
        _m = createMarker[format["APmine%1", _minepos], _minepos];
        _m setMarkerType "Minefield";
        _m setMarkerText "AP";
    };
    _mine = createMine ["APERSTripMine", _minepos, [], 0];
    _temp = [_minepos] call dep_fnc_slopedir;
    _mine setDir _temp;
};

_formation = dep_formations call BIS_fnc_selectRandom;

_wp = _group addWaypoint [_pos, 0];
_wp setWaypointBehaviour "SAFE";
_wp setWaypointSpeed "LIMITED";
_wp setWaypointFormation _formation;
_wp setWaypointTimeOut [0,10,20];
_wp setWaypointType "MOVE";

_houses = [_pos, _radius] call dep_fnc_enterablehouses;
if ((count _houses) > 0) then {
    _temp = _houses call BIS_fnc_selectRandom;
    _wp = _group addWaypoint [(getPos _temp), 0];
    _wp setWaypointBehaviour "SAFE";
    _wp setWaypointSpeed "LIMITED";
    _wp setWaypointFormation _formation;
    _wp setWaypointTimeOut [10,20,40];
    _wp setWaypointType "MOVE";
};

_temp = 0;
_wp1 = _pos;
_paths = [_pos, _radius] call dep_fnc_findpaths;
{
    if ((_pos distance _x) > _temp && (_minepos distance _x) > 10) then {
        _temp = _pos distance _x;
        _wp1 = getPos _x;
    }; 
} forEach _paths;

_wp = _group addWaypoint [_wp1, 0];
_wp setWaypointBehaviour "SAFE";
_wp setWaypointSpeed "LIMITED";
_wp setWaypointFormation _formation;
_wp setWaypointTimeOut [10,20,40];
_wp setWaypointType "MOVE";

_temp = 0;
_wp2 = _pos;
{
    if ((_wp1 distance _x) > _temp  && (_minepos distance _x) > 10) then {
        _temp = _wp1 distance _x;
        _wp2 = getPos _x;
    }; 
} forEach _paths;

_wp = _group addWaypoint [_wp2, 0];
_wp setWaypointBehaviour "SAFE";
_wp setWaypointSpeed "LIMITED";
_wp setWaypointFormation _formation;
_wp setWaypointTimeOut [10,20,40];
_wp setWaypointType "CYCLE";

[_totalenemies, _groups, _objects];