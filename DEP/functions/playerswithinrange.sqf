/*  Copyright 2017 Fluit
    
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
// This file checks if a position is within range of any player

private ["_pos","_distance","_inrange"];
_pos        = _this select 0;
_distance   = _this select 1;
_inrange    = false;

{
    if ((_x distance _pos) <= _distance) exitWith {
        _inrange = true;
    };
} forEach dep_players;
_inrange;