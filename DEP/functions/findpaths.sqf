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
// This file finds near paths, not real roads.
params ['_pos','_radius'];
private ["_bridge","_list"];

_list = [];
{
    _bridge = ["bridge", (getModelInfo _x) select 0] call BIS_fnc_inString;
    if (!(isOnRoad getPos _x) && !_bridge) then {
        _list pushBack _x;
    };
} forEach (_pos nearRoads _radius);
_list;