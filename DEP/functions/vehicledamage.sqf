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
// This file prevents ai from destroying their own vehicles.

_veh = _this select 0;

if (isNil { _veh getVariable "selections" } ) then { _veh setVariable ["selections", []]; };
if (isNil { _veh getVariable "gethit" } ) then { _veh setVariable ["gethit", []]; };

_veh addEventHandler ["HandleDamage", {
    _crew = crew (_this select 0);
    if ((count _crew) > 0) then 
    {
        _friendlycrew = false;
        {
            if (isPlayer _x) exitWith
            {
                _friendlycrew = true; 
            };
        } forEach (_crew);
        
        if !(_friendlycrew) then 
        {
            if (!isPlayer(_this select 3)) then 
            {
                damage (_this select 0);
            } else {
                _unit = _this select 0;
                _selections = _unit getVariable ["selections", []];
                _gethit = _unit getVariable ["gethit", []];
                _selection = _this select 1;
                if !(_selection in _selections) then
                {
                    _selections set [count _selections, _selection];
                    _gethit set [count _gethit, 0];
                };
                _i = _selections find _selection;
                _olddamage = _gethit select _i;
                //_damage = _olddamage + ((_this select 2) - _olddamage);
                _damage = _olddamage + (_this select 2);
                _gethit set [_i, _damage];
                _unit setVariable ["selections", _selections];
                _unit setVariable ["gethit", _gethit];
                _damage;
            };
        };
    };
}];