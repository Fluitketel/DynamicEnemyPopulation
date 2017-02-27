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
// This file fires mortars from mortar camps

private ["_mortar_loctations", "_player", "_mortars","_mortar","_fired","_firepos","_location","_seq","_spotter","_knowsabout","_continue"];

waitUntil {!isNil "dep_mortars"};
waitUntil {!isNil "dep_players"};
waitUntil {!isNil "dep_num_players"};

if (dep_mortars == 0) exitWith {
    "Exiting DEP mortar script" spawn dep_fnc_log;
};

_mortar_loctations = [];
for "_g" from 0 to (dep_num_loc - 1) do {
    _location = dep_locations select _g;
    if ((_location select 1) == "mortar") then {
        _mortar_loctations = _mortar_loctations + [_g];
    };
};

_seq = 0;
while {true} do {
    waitUntil {dep_mortars > 0};
    waitUntil {dep_num_players > 0};
    
    // Wait until a mortar camp is active
    _continue = false;
    while {!_continue} do {
        {
            _location = dep_locations select _x;
            _active = _location select 3;
            if (_active) exitWith {
                _continue = true;
            };
        } forEach _mortar_loctations;
        sleep 5;
    };
    
    _fired = false;
    _firepos = [];
    _mortars = [];
    _player = objNull;
    _spotter = objNull;
    _knowsabout = 0;
    
    // Select a player as a possible target
    {
        _spotter = leader _x;
        {
            _knowsabout = (_spotter knowsAbout _x);
            if (_knowsabout > 2) then {
                if ((random 1) <= 0.3) exitWith {
                    _player = _x;
                };
            };
        } forEach dep_players;
        if !(isNull _player) exitWith {};
        sleep 1;
    } forEach dep_allgroups;
    
    // Transmit fire mission
    if !(isNull _player) then {
        ["The enemy is calling a mortar strike on %1.", _player] spawn dep_fnc_log;
        sleep 40;
        
        _continue = false;
        _knowsabout = 0;
        if (alive _spotter && alive _player) then {
            _knowsabout = (_spotter knowsAbout _player);
            if ((_spotter knowsAbout _player) > 2) then {
                _continue = true;
                _firepos = getPos _player;
            };
        };
        
        // Cancel fire mission if the spotter no longer knows where the player is or if the spotter is dead
        if !(_continue) then {
            ["Cancelling mortar strike with knowsabout %1.", _knowsabout] spawn dep_fnc_log;
            _player = objNull;
        };
    };
    
    // Check if enemy units are near target position
    if !(isNull _player) then {
        _nearunits = _firepos nearObjects ["Man", 50];
        {
            if ((side _x) == dep_side) exitWith {
                _player = objNull;
                "Cancelling mortar strike. Enemies are too close." spawn dep_fnc_log;
            };
        } forEach _nearunits;
    };
    
    // Fire mission received...
    if !(isNull _player) then {
        // Select valid mortars for fire mission
        {
            _location = dep_locations select _x;
            _locpos = _location select 0;
            _active = _location select 3;
            if (_active && ((_player distance _locpos) < 3000)) then {
                {
                    _mortar = _x;
                    if !(isNull _mortar) then {
                        if ((typeOf _mortar) == dep_static_mortar && (alive gunner _mortar)) then {
                            _mortars = _mortars + [_mortar];
                        };
                    };
                } forEach (_location select 8);
            };
        } forEach _mortar_loctations;
        
        // Begin mortar strike
        if ((count _mortars) > 0) then {            
            ["Firing mortar at player %1 with knowsabout %2.", _player, _knowsabout] spawn dep_fnc_log;
            {
                if (alive _x) then {
                    sleep 15 + (random 25);
                    for "_g" from 0 to (ceil random 3) do {
                        _newpos = [_firepos, 10 + (random 70), random 360] call BIS_fnc_relPos;
                        _x setVehicleAmmo 1;
                        _x commandArtilleryFire [_newpos, "8Rnd_82mm_Mo_shells", 1];
                        _fired = true;
                        sleep 1;
                    };
                    _x addMagazine "8Rnd_82mm_Mo_shells";
                };
            } forEach _mortars; 
        } else {
            "Cancelling mortar strike. Mortar not available" spawn dep_fnc_log;
        };
    };
    
    // Handle timeouts
    if (_fired) then {
        _seq = _seq + 1;
        if (_seq >= 4) then {
            // Timeout after 4 continuous fire missions
            sleep 900;
            _seq = 0;
        } else {
            sleep 120;
        }
    } else {
        _seq = 0;
        sleep 30;
    };
};