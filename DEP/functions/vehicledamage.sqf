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

(_this select 0) addEventHandler ["HandleDamage", {
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
            };
        };
    };
}];