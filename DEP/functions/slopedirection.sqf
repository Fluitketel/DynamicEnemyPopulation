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
// This file finds the direction of a slope.

params ['_pos'];
private ["_s","_p","_dir"];
_s = surfaceNormal _pos;
_p = [(_pos select 0) + ((_s select 0) * 10),(_pos select 1) + ((_s select 1) * 10), 0];
_dir = ([_pos,_p] call BIS_fnc_dirTo);
_dir;