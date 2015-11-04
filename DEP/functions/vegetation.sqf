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
// This file finds vegetation in a given area.

private ["_objects", "_validobjects", "_pos", "_size", "_keywords"];
_pos = _this select 0;
_size = _this select 1;

_pos set [2, 0];
_keywords = ["b_", "t_"];
_objects = nearestObjects [_pos, [], _size];
_validobjects = [];
{
	_ok = false;
	_object = _x;   
	{
		_result = [_x, (str _object)] call BIS_fnc_inString;
		if (_result) exitWith { _validobjects = _validobjects + [_object];  };
	} forEach _keywords;
} forEach _objects;		
_validobjects;