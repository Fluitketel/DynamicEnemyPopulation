/*  Copyright 2015 Fluit
    
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
// Logs and or prints debug messages

private ["_msg"];

_msg = _this;
if ((typeName _this) == "ARRAY") then
{
	_msg = (format _this);
};

if ((typeName _msg) != "STRING") then 
{
	_msg = (str _msg);
};

if (dep_logging) then
{
	diag_log _msg;
};

if (dep_chat_logging) then
{
	[_msg, "systemChat", dep_own_side, false, false] call BIS_fnc_MP; 
};