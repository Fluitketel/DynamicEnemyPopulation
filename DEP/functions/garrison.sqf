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
// This file tells a group to garrison in the nearest building.
private ["_house","_group","_pos","_buildpos","_newbuildpos"];
_group  = _this select 0;
_pos    = getPos (leader _group);

_validhouses = [_pos] call dep_fnc_findnearhouses;
if ((count _validhouses) > 0) then {
    _house = _validhouses call BIS_fnc_selectRandom;
    _buildpos = _house call dep_fnc_buildingpositions;
    {
        if (alive _x) then {
            _newbuildpos = [];
            if ((count _buildpos) > 0) then {
                _newbuildpos = _buildpos call BIS_fnc_selectRandom;
                _buildpos = _buildpos - [_newbuildpos];
            } else {
                _newbuildpos = (getPos _house) findEmptyPosition [0, 15];
            };
            if ((count _newbuildpos) < 2) then { _newbuildpos = _pos; };
            _x setPos _newbuildpos;
        };
    } foreach (units _group);
};