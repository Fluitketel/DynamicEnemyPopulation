/*  Copyright 2015 Fluit
    
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
// This file finds bridges in a given area.
private ["_bridges", "_pos", "_size", "_classnames"];
_pos = _this select 0;
_size = _this select 1;

_pos set [2, 0];
_classnames = ["Land_Bridge_HighWay_PathLod_F", "Land_Bridge_Concrete_PathLod_F", "Land_Bridge_Asphalt_PathLod_F", "Land_Bridge_01_PathLod_F"];
_bridges = nearestObjects [_pos, _classnames, _size];
_bridges;