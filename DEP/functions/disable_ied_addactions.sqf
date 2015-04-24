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
// This add the addActions for disabling an IED.
_object = _this select 0;
_object addAction ["<t color='#FF0000'>Cut red wire</t>", "call dep_fnc_disable_ied",[0], 6, false, true, "", "[0] call dep_fnc_disable_ied_action"];
_object addAction ["<t color='#00990A'>Cut green wire</t>", "call dep_fnc_disable_ied",[1], 6, false, true, "", "[1] call dep_fnc_disable_ied_action"];
_object addAction ["<t color='#0006AD'>Cut blue wire</t>", "call dep_fnc_disable_ied",[2], 6, false, true, "", "[2] call dep_fnc_disable_ied_action"];