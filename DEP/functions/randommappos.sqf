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
// This file returns a random position on the map.
private ["_height", "_width", "_position"];
_position = [];

_width = (dep_map_center select 0) * 2;
_height = (dep_map_center select 1) * 2;

_width = _width - (dep_map_margin * 2);
_height = _height - (dep_map_margin * 2);

_position set [0, dep_map_margin + (random _width)];
_position set [1, dep_map_margin + (random _height)];

_position;