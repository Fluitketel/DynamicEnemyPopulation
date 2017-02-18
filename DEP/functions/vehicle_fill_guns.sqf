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
// This file fills a vehicle's gun slots

private ["_vehicle","_group","_unit","_unitname"];
_vehicle = _this select 0;
_group = _this select 1;
_unitname = "";
if (_vehicle isKindOf "Tank" || _vehicle isKindOf "Wheeled_APC_F") then {
    _unitname = dep_u_veh_crew;
} else {
    _unitname = dep_guer_units call BIS_fnc_selectRandom;
};
for "_y" from 1 to (_vehicle emptyPositions "Gunner") do {
    _unit = [_group, _unitname, (getPos _vehicle) findEmptyPosition[0, 30]] call dep_fnc_createunit;
    _unit assignAsGunner _vehicle;
    _unit moveInGunner _vehicle;
};
