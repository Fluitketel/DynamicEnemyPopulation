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
// This file contains scripts for both server and client.

dep_killed_civ = 0;

dep_public_eh =
{
	_EH     = _this select 0;
	_value  = _this select 1;
    
    switch (_EH) do
    {
        case "dep_killed_civ":
        {
            systemChat format ["Civilians killed: %1", _value];
        };
    };
};

"dep_killed_civ" addPublicVariableEventHandler dep_public_eh;