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
// This file creates a unit.

private ["_unit","_group","_pos","_type"];
_group  = _this select 0;
_type   = _this select 1;
_pos    = _this select 2;

_unit = _group createUnit [_type, _pos, [], 0, "NONE"];
waitUntil{alive _unit};

if (dep_unit_init != "") then {
    _unit spawn (compile dep_unit_init);
};

_unit;