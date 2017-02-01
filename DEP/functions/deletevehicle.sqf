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
// This deletes a vehicle once players are no longer close to it

private ["_pos", "_inrange"];
_vehicle = _this select 0;

_inrange = true;
while {_inrange} do {
    _inrange = [getPos _vehicle, (dep_act_dist / 2)] call dep_fnc_players_within_range;
    if (isNull _vehicle) then {
        _inrange = false;
    };
    if (_inrange) then {
        sleep 30;
    };
};

if (!isNull _vehicle) then {
    {
        deleteVehicle _x;
    } forEach (crew _vehicle) + [_vehicle];
};
