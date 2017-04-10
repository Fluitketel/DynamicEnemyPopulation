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
// Cleans up empty groups
private ["_group","_empty"];

{
    _group = _x;
    if (side _group == dep_side || side _group == civilian) then {
        _empty = true;
        {
            if (!isNull _x) then {
                if (alive _x) exitWith { 
                    _empty = false; 
                };
            };
        } foreach (units _group);
        
        if (_empty) then {
            ["Deleting group %1", _group] spawn dep_fnc_log;
            deleteGroup _group;
        };
    };
} forEach allGroups;