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
// This file handles the action for disabling an IED.
private ["_target", "_explosivesclass","_wire"];
_target = cursorTarget;
_wire = _this select 0;

if (vehicle player != player)                   exitWith { false; };
if (_target distance player > 3)                exitWith { false; };
if (!("ToolKit" in backpackItems player) && !("ACE_DefusalKit" in items player)) exitWith { false; };
if !(_target getVariable "IED")                 exitWith { false; };
if (_wire in (_target getVariable "cut_wires")) exitWith { false; };
if (_target getVariable "workingon")            exitWith { false; };
if (dep_cr_ied) then {
    _explosivesclass = getNumber (configfile >> "CfgVehicles" >> typeOf player >> "canDeactivateMines");
    if (_explosivesclass == 0) exitWith { false; };
};

true;