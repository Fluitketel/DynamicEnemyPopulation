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
// This file fills a vehicle's cargo slots

private ["_vehicle","_group","_unit","_units","_positions","_maxpositions"];
_vehicle = _this select 0;
_group = _this select 1;

_maxpositions = dep_max_ai_loc - (count crew _vehicle);
if (_maxpositions > 0) then {
    _units = [];
    if (_vehicle isKindOf "Tank" || _vehicle isKindOf "Wheeled_APC_F") then {
        _units = dep_mil_units;
    } else {
        _units = dep_guer_units;
    };
    _positions = (_vehicle emptyPositions "cargo");
    if (_positions > _maxpositions) then {
        _positions = _maxpositions;
    };
    for "_y" from 1 to _positions do {
        _unit = [_group, (_units call BIS_fnc_selectRandom), (getPos _vehicle) findEmptyPosition[0, 30]] call dep_fnc_createunit;
        _unit assignAsCargo _vehicle;
        _unit moveInCargo _vehicle;
    };
};