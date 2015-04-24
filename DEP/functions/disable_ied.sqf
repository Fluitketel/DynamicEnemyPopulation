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
// This file disables an IED.

private ["_ied","_wire","_wrongwire","_unit","_params","_cut_wires","_disabled"];
_ied = _this select 0;
_unit = _this select 1;
_params = _this select 3;

_wire = _params select 0;
_wrongwire = _ied getVariable "wrong_wire";
_cut_wires = _ied getVariable "cut_wires";
_disabled = false;

_ied setVariable ["workingon",true,true];
//_unit playMove "AinvPknlMstpSlayWrflDnon_medic";
//sleep 6;
disableUserInput true;
_unit switchMove "AinvPknlMstpSnonWrflDr_medic4";
sleep 6;
disableUserInput false;

if (_wire == _wrongwire) then {
    for "_i" from 1 to 2 do {
        playsound3d ["A3\Sounds_f\sfx\Beep_Target.wss",_ied, true, getpos _ied, 1, 1, 0];
        sleep 1;
    };
    systemChat "Wrong wire!";
    for "_i" from 1 to 4 do {
        playsound3d ["A3\Sounds_f\sfx\Beep_Target.wss",_ied, true, getpos _ied, 1, 1, 0];
        sleep 0.5;
    };
    for "_i" from 1 to 4 do {
        playsound3d ["A3\Sounds_f\sfx\Beep_Target.wss",_ied, true, getpos _ied, 1, 1, 0];
        sleep 0.2;
    };
    for "_i" from 1 to 4 do {
        playsound3d ["A3\Sounds_f\sfx\Beep_Target.wss",_ied, true, getpos _ied, 1, 1, 0];
        sleep 0.1;
    };
    //sleep 5;
    _boomtype = ["Bomb_03_F", "Bomb_04_F", "Bo_GBU12_LGB"] select round random 2;
    _boomtype createVehicle (position _ied);
    deleteVehicle _ied;
} else {
    _cut_wires = _cut_wires + [_wire];
    _ied setVariable ["workingon",false,true];
    if ((count _cut_wires) > 1) then 
    {
        _disabled = true;
    } else {
        if ((random 1) < 0.5) then 
        {
            _ied setVariable ["cut_wires",_cut_wires,true];
            systemChat "Wire cut. Nothing happened.";
        } else {
            _disabled = true;
        };
    };
    
    if (_disabled) then 
    {
        _ied setVariable ["IED",false,true];
        systemChat "IED disabled.";
    };
};