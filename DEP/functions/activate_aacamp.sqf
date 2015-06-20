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
// This file activates an anti-air camp.

private ["_location","_pos","_return"];

_cache = dep_loc_cache select _this;
if ((count _cache) > 0) exitWith {
    _result = _this call dep_fnc_restore;
    true;
};

_location = dep_locations select _this;
_pos = _location select 0;

["Spawning location %1 (%2)", _this, (_location select 1)] spawn dep_fnc_log;

_return = [];
if ((random 1) <= 0.5) then {
    _return = [_pos, random 360] call dep_fnc_aacamp1;
} else {
    _return = [_pos, random 360] call dep_fnc_aacamp2;
};

["%2 enemies created at location %1", _this, (_return select 0)] spawn dep_fnc_log;

_location set [3, true];
_location set [4, (_return select 1)];
_location set [6, (_return select 0)];
_location set [8, (_return select 2)];
dep_locations set [_this, _location];
true;