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
// This file finds spawn positions in a building.
private ["_building", "_positions", "_i"];
_building = _this;
_positions = [];
_i = 1;
while {_i > 0} do {
   _next = _building buildingPos _i;
   if (((_next select 0) == 0) && ((_next select 1) == 0) && ((_next select 2) == 0)) then {
      _i = 0;
   } else {
      _positions set [(count _positions), _next];
      _i = _i + 1;
   };
};
_positions;