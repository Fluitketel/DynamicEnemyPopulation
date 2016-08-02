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
// This file updates the marker at a location
params ['_location'];
private ["_m"];

if ((_location select 11) == "") exitWith { };
if !((_location select 1) in dep_zone_markers) exitWith { };

deleteMarker (_location select 11);
_m = createMarker [(_location select 11), (_location select 0)];

if (_location select 7) then {
    // the location is clear
    _m setMarkerType dep_mrk_location_clear;
    switch (dep_own_side) do {
        case east: {
            _m setMarkerColor "colorOPFOR";
        };
        case west: {
            _m setMarkerColor "colorBLUFOR";
        };
        default {
            _m setMarkerColor "colorIndependent";
        };
    };
} else {
    // the location is hostile
    _m setMarkerType dep_mrk_location_hostile;
    switch (dep_side) do {
        case east: {
            _m setMarkerColor "colorOPFOR";
        };
        case west: {
            _m setMarkerColor "colorBLUFOR";
        };
        default {
            _m setMarkerColor "colorIndependent";
        };
    };
};

switch (dep_worldname) do {
    case "altis": {
        _m setMarkerAlpha 0.5;
        _m setMarkerSize [0.4, 0.4];
    };
    case "tanoa": {
        _m setMarkerSize [0.7, 0.7];
    };
};