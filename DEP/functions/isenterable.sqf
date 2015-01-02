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
// This file checks if a house is enterable.

private ["_house", "_maxbuildingpos", "_blacklist", "_blacklisted"];

_house = _this select 0;
_blacklist = ["Piers_base_F"];

_blacklisted = false;
{
    if (_house isKindOf _x) exitWith { _blacklisted = true; };
} forEach _blacklist;
if (_blacklisted) exitWith { false; };

_maxbuildingpos = 0;
while {count ((_house buildingPos _maxbuildingpos)-[0]) > 0} do {
    _maxbuildingpos = _maxbuildingpos + 1;
};

if (_maxbuildingpos > 0) then { 
    true; 
} else {
    false;
};