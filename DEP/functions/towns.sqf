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
// This file finds near towns.
params ['_pos','_radius','_types'];
private ["_list","_positions"];

if (isNil "_types") then {
    _types = ["NameVillage","NameCity","NameCityCapital"];
};

_positions = [];
_list = nearestLocations [_pos, _types, _radius];
{
    _positions pushBack (getPos _x);
} forEach _list;
_positions;