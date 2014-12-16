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
    
    This file launches Dynamic Enemy Population on the server and on the client.
    To modify the Dynamic Enemy Population settings you can edit the settings.sqf file in the DEP root folder.
*/

if (count _this > 0) then {
    dep_directory = (_this select 0) + "\";
} else {
    dep_directory = "DEP\";
};

dep_ishostedserver = if (isServer && !isDedicated) then {true} else {false};
dep_isserver = if (isDedicated || dep_ishostedserver) then {true} else {false};
dep_isclient = if ((dep_ishostedserver || !isDedicated) && (hasInterface)) then {true} else {false};
dep_isheadless = if !(hasInterface || isDedicated) then {true} else {false};

if (dep_isserver || dep_ishostedserver || dep_isheadless) then 
{
    [] execVM dep_directory+"init\server_init.sqf"; 
};

if (dep_isclient) then 
{
    [] execVM dep_directory+"init\client_init.sqf"; 
};