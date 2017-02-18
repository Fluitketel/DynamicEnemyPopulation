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
// This file finds all (enterable) military buildings in a given area.

private ["_pos","_radius","_allbuildings","_buildings","_building","_checkenterable","_ok","_keywords","_classnames"];
_pos                = _this select 0;
_radius             = _this select 1;
_checkenterable     = if (count _this > 2) then { _this select 2 } else { true }; 

_allbuildings = [];
_buildings = [];
_classnames = 
[
    "Land_Radar_F",
    "Land_Hangar_F",
    "Cargo_HQ_base_F",
    "Cargo_House_base_F",
    "Cargo_Tower_base_F",
    "Land_Cargo_House_V4_F",
    "Land_Cargo_HQ_V4_F",
    "Land_Cargo_Patrol_V4_F",
    "Land_Cargo_Tower_V4_F",
    "Land_Barracks_01_camo_F",
    "Land_Barracks_01_grey_F",
    "Land_Barracks_01_dilapidated_F",
    "Land_PillboxBunker_01_hex_F",
    "Land_PillboxBunker_01_rectangle_F"
];

switch (dep_worldname) do {
    case "tanoa";
    case "stratis";
    case "altis": {
        _buildings = nearestObjects [_pos, _classnames, _radius];
    };
    default {
        _allbuildings = nearestObjects [_pos, ["House"], _radius];
        _keywords = ["mil_","_fort","hangar"];

        {
            _ok = false;
            _building = _x;
            
            // Check if it's a military building    
            {
                /*_result = [(toLower str _building), _x] call CBA_fnc_find;
                if (_result >= 0) exitWith { _ok = true;  };*/
                _result = [_x, (str _building)] call BIS_fnc_inString;
                if (_result) exitWith { _ok = true;  };
            }forEach _keywords;
            
            // Check if it's enterable
            if (_ok && _checkenterable) then {
                _ok = [_building] call dep_fnc_isenterable;
            };
            
            // Add it to the array
            if (_ok) then {
                _buildings = _buildings + [_building];
            };
        } forEach _allbuildings;
        _allbuildings = nil;
    };
};

_buildings;