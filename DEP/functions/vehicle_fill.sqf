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
// This file fills all of a vehicle's slots

private ["_vehicle","_group"];
_vehicle = _this select 0;
_group = createGroup dep_side;
nill = [_vehicle, _group] call dep_fnc_vehicle_fill_driver;
nill = [_vehicle, _group] call dep_fnc_vehicle_fill_guns;
nill = [_vehicle, _group] call dep_fnc_vehicle_fill_commander;
nill = [_vehicle, _group] call dep_fnc_vehicle_fill_cargo;
_group;