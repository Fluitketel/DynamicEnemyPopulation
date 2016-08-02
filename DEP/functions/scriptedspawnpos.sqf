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
// This file fetches scripted spawn positions.
private ["_pos","_range","_spawnpos","_arrows","_delete"];
_pos  = _this select 0;
_range  = _this select 1;
_delete = if ((count _this) > 2) then { _this select 2 } else { false };

_arrows = nearestObjects [_pos, ["Sign_Arrow_Blue_F"], _range];
_spawnpos = [];
{
	_spawnpos = _spawnpos + [(getPosATL _x)];
    if (_delete) then
    {
        deleteVehicle _x;
    };
} forEach _arrows;

_spawnpos;