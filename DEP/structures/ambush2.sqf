/*  Copyright 2015 Fluit
    
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
// This file spawns an ambush at the given location.
private ["_pos", "_dir", "_newpos", "_campgroup", "_prop", "_soldier", "_gate", "_groups", "_totalenemies", "_objects", "_wrecks", "_wreck"];
_pos    = _this select 0;
_dir    = _this select 1;

_groups = [];
_totalenemies = 0;
_objects = [];

_wrecks = ["Land_Wreck_HMMWV_F","Land_Wreck_Offroad_F","Land_Wreck_Offroad2_F","Land_Wreck_Truck_dropside_F","Land_Wreck_Truck_F","Land_Wreck_UAZ_F","Land_Wreck_Van_F"];

_newpos = [_pos, 2, (_dir + 90)] call BIS_fnc_relPos;
_wreck = (_wrecks call BIS_fnc_selectRandom) createVehicle _newpos;
_wreck setDir _dir;

if (((random 1) <= dep_ied_chance) && dep_ieds) then 
{
	_wreck setVariable ["workingon",false,true];
	_wreck setVariable ["IED",true,true];
	_wreck setVariable ["wrong_wire", round random 2, true];
	_wreck setVariable ["cut_wires", [], true];
	_wreck execFSM (dep_directory + "functions\ied_veh.fsm");

	[[[_wreck],format["%1functions\disable_ied_addactions.sqf", dep_directory]],"BIS_fnc_execVM",nil,true] spawn BIS_fnc_MP;
	
	if (dep_debug) then {
		_m = createMarker[format["ied%1", (str _newpos)], _newpos];
		_m setMarkerType "mil_dot";
		_m setMarkerText "ied";
		_m setMarkerColor "ColorRed";
	};
			
	_wreck addEventHandler 
	["Explosion", 
		{                       
			_object = (_this select 0);
			if (_object getVariable "IED") then {
				_boomtype = ["Bomb_03_F", "Bomb_04_F", "Bo_GBU12_LGB"] select round random 2;
				_boomtype createVehicle (position _object);
				deleteVehicle _object;
			};
			_this select 1;
		}
	];
};

if (dep_mines) then
{
	_numberofmines = 6;
	_newdir = 0;
	for "_c" from 1 to _numberofmines do
	{
		_newpos = [_pos, 9, _newdir] call BIS_fnc_relPos;
		_newpos set [2, 0.01];
		_mine = createMine [["APERSMine","APERSBoundingMine","SLAMDirectionalMine", "ATMine"] call BIS_fnc_selectRandom, _newpos, [], 0];
		_mine setDir _newdir;
		if (dep_debug) then {
			_m = createMarker[format["ambush%1", (str _newpos)], _newpos];
			_m setMarkerType "Minefield";
		};
		_newdir = _newdir + (360 / _numberofmines);
	};
};

[_totalenemies, _groups, _objects];