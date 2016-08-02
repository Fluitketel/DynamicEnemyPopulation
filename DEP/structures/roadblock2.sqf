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
// This file spawns a roadblock at the given location.
private ["_pos", "_dir", "_newpos", "_campgroup", "_soldier", "_groups", "_totalenemies", "_objects","_spawnpos"];
_pos    = _this select 0; // roadblock position
_dir    = _this select 1; // roadblock direction

_groups = [];
_totalenemies = 0;
_objects = [];

_campgroup = createGroup dep_side;
_groups = _groups + [_campgroup];
_campgroup setFormDir _dir;

_objs = [
	["Land_CncBarrier_F",[-2.61865,0.663086,0],89.5492,1,0,[],"","",true,false], 
	["Land_CncBarrier_F",[2.76392,0.528809,0],89.5492,1,0,[],"","",true,false], 
	["Land_LampShabby_F",[-2.97241,-1.04785,-2],90,1,0,[],"","",true,false], 
	["RoadCone_L_F",[-2.51904,2.30127,0.00213099],359.989,1,0,[],"","",true,false], 
	["RoadCone_L_F",[2.60083,2.23975,0.00213099],359.989,1,0,[],"","",true,false], 
	["Land_CncBarrier_stripes_F",[-4.08081,2.06104,0],0,1,0,[],"","",true,false], 
	["Land_CncBarrier_stripes_F",[4.20508,1.99414,0],0,1,0,[],"","",true,false], 
	["Land_CncBarrier_F",[-2.6228,-4.53857,0],89.5492,1,0,[],"","",true,false], 
	["Land_CncBarrier_F",[2.75977,-4.67285,0],89.5492,1,0,[],"","",true,false], 
	["B_HMG_01_high_F",[-5.49072,-0.922363,-0.0871177],359.996,1,0,[],"gun2","",true,false], 
	["Land_BagBunker_Small_F",[-5.71265,-0.349121,0],180,1,0,[],"","",true,false], 
	["B_HMG_01_high_F",[6.0144,0.405762,-0.0871191],359.999,1,0,[],"gun1","",true,false], 
	["RoadCone_L_F",[-2.51221,-6.21924,0.00213099],359.989,1,0,[],"","",true,false], 
	["B_HMG_01_high_F",[5.94287,-3.20215,-0.0871177],179.996,1,0,[],"gun3","",true,false], 
	["RoadCone_L_F",[2.60767,-6.28076,0.00213099],359.989,1,0,[],"","",true,false], 
	["Land_BagBunker_Small_F",[6.08569,-3.72266,0],0,1,0,[],"","",true,false], 
	["B_HMG_01_high_F",[-5.14966,-4.58838,-0.0871177],179.996,1,0,[],"gun4","",true,false], 
	["Land_CncBarrier_stripes_F",[-6.68408,2.06299,0],0,1,0,[],"","",true,false], 
	["Land_CncBarrier_stripes_F",[6.80811,1.98145,0],0,1,0,[],"","",true,false], 
	["Land_CncBarrier_stripes_F",[-4.08081,-6.05615,0],0,1,0,[],"","",true,false], 
	["Land_CncBarrier_stripes_F",[4.20508,-6.14404,0],0,1,0,[],"","",true,false], 
	["Sign_Arrow_Blue_F",[8.11377,0.0620117,0],0,1,0,[],"","",true,false], 
	["Sign_Arrow_Blue_F",[-7.21802,-4.29053,0],0,1,0,[],"","",true,false], 
	["Land_CncBarrier_stripes_F",[-6.68384,-6.06494,0],0,1,0,[],"","",true,false], 
	["Land_CncBarrier_stripes_F",[6.80811,-6.146,0],0,1,0,[],"","",true,false]
];
_return = [_pos, _dir, _objs] call BIS_fnc_ObjectsMapper;

_gun1 = [gun1, gun2, gun3, gun4] call BIS_fnc_selectRandom;

_newpos = getPos _gun1;
_newdir = getDir _gun1;
deleteVehicle gun1;
deleteVehicle gun2;
deleteVehicle gun3;
deleteVehicle gun4;
if (random 1 < 0.3) then {
    _gun1 = dep_static_gmg createVehicle _newpos;
} else {
    _gun1 = dep_static_hmg createVehicle _newpos;
};
_objects = _objects + [_gun1];
_gun1 setDir _newdir;
_gun1 setPos _newpos;

_newpos = [_gun1, 1, (_newdir + 180)] call BIS_fnc_relPos;
_gunner1 = [_campgroup, dep_u_g_soldier, _newpos] call dep_fnc_createunit;
_gunner1 assignAsGunner _gun1;
_gunner1 moveInGunner _gun1;
_gunner1 setDir _newdir;

_spawnpos = [_pos, 30, true] call dep_fnc_scriptedspawnpos;

_newpos = (_spawnpos call BIS_fnc_selectRandom) findEmptyPosition[0, 50, dep_u_g_sl];
_soldier = [_campgroup, dep_u_g_sl, _newpos] call dep_fnc_createunit;
_totalenemies = _totalenemies + 1;
doStop _soldier;
for "_c" from 1 to (1 + round (random 1)) do
{
    _newpos = (_spawnpos call BIS_fnc_selectRandom) findEmptyPosition[0, 50, dep_u_g_at];
    _soldier = [_campgroup, dep_u_g_at, _newpos] call dep_fnc_createunit;
    _soldier setDir _dir;
    _totalenemies = _totalenemies + 1;
    doStop _soldier;
    
    _newpos = (_spawnpos call BIS_fnc_selectRandom) findEmptyPosition[0, 50, dep_u_g_at];
    _soldier = [_campgroup, dep_u_g_gl, _newpos] call dep_fnc_createunit;
    _soldier setDir (_dir + 180);
    _totalenemies = _totalenemies + 1;
    doStop _soldier;
};

_totalenemies = _totalenemies + 1;
[_totalenemies, _groups, _objects];