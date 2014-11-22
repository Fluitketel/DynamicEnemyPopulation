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
// This file finds enterable houses in a given area.
private ["_houses", "_pos", "_size", "_house", "_maxbuildingpos"];
_pos = _this select 0;
_size = _this select 1;

_pos set [2, 0];

_validhouses = [];
_houses = nearestObjects [_pos, ["House"], _size];
{	
    _enterable = [_x] call dep_fnc_isenterable;
    if (_enterable) then { 
        _validhouses = _validhouses + [_x]; 
    };    
} foreach _houses;
_validhouses;