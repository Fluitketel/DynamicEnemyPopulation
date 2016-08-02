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
// This file finds the closest enterable houses.
private ["_pos", "_validhouses","_maxrange","_range","_c"];
_pos = _this select 0;
_maxrange = 90;
if ((count _this) > 1) then { _maxrange = _this select 1; };

_validhouses = [];
_c = 1;
_range = 4;
while {(count _validhouses) == 0 && _range <= _maxrange} do
{
	_validhouses = [_pos, _range] call dep_fnc_enterablehouses;
	_c = _c + 1;
	_range = _range * _c;
};

_validhouses;