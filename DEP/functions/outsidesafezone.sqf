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
// This file returns true is a position is outside the safe zone.

private ["_pos","_dist","_outside", "_margin"];
_pos  = _this select 0;
_dist = if (count _this > 1) then { _this select 1; } else { dep_safe_rad; };
_margin = if (count _this > 2) then { _this select 2; } else { dep_map_margin; };

_outside = true;

// Check if location in a safe zone
if (count dep_safe_zone > 0) then 
{
    if (typeName (dep_safe_zone select 0) == "ARRAY") then 
    {
        {
            if ((_pos distance _x) <= _dist) exitWith 
            {
                _outside = false;
            };
        } forEach dep_safe_zone;
    } else {
        if ((_pos distance dep_safe_zone) <= _dist) then 
        {
            _outside = false;
        };
    };
};

// Check if location in map margin
if (_outside) then
{
	if ((_pos distance dep_map_center) > (dep_map_radius - _margin)) then
	{
		_outside = false;
	};
};
_outside;