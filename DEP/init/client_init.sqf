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
// This is the init file that should run on every client.

if (isNil "dep_directory") then
{ 
    dep_directory = "DEP\"; 
};

dep_fnc_disable_ied         = compile preprocessFileLineNumbers (dep_directory+"functions\disable_ied.sqf");
dep_fnc_disable_ied_action  = compile preprocessFileLineNumbers (dep_directory+"functions\disable_ied_action.sqf");

[] execVM dep_directory+"functions\common.sqf";

if (isNil "dep_ready") then 
{
    waitUntil {!isNil "dep_ready"};
    if (dep_ready) then
    {
        //systemChat "Dynamic Enemy Population initialized.";
        systemChat format["Dynamic Enemy Population version %1 initialized.", dep_version];
    };
};

if !(dep_ready) then
{
	systemChat "Error while initilazing Dynamic Enemy Population!";
};