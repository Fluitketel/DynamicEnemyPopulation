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
// This file spawns a mortar camp.

private ["_pos", "_dir", "_gun", "_campgroup", "_gunner", "_groups", "_totalenemies", "_objects","_spawnpos"];
_pos    = _this select 0; // position
_dir    = _this select 1; // direction

_groups = [];
_totalenemies = 0;
_objects = [];

_campgroup = createGroup dep_side;
_groups = _groups + [_campgroup];
_campgroup setFormDir _dir;

_objs = 
[
	["Land_BagFence_01_long_green_F",[1.23926,-0.155762,-0.000999928],270,1,0,[],"","",true,false], 
	["Land_BagFence_01_long_green_F",[-1.26685,0.0556641,-0.000999928],90,1,0,[],"","",true,false], 
	["Land_BagFence_01_corner_green_F",[1.52417,1.80615,-0.000999928],270,1,0,[],"","",true,false], 
	["Land_BagFence_01_corner_green_F",[-1.56714,-1.9458,-0.000999928],90,1,0,[],"","",true,false], 
	["Land_BagFence_01_corner_green_F",[-1.65942,1.896,-0.000999928],0,1,0,[],"","",true,false], 
	["Land_BagFence_01_corner_green_F",[1.69653,-2.07227,-0.000999928],180,1,0,[],"","",true,false], 
	["B_Mortar_01_F",[-3.48462,-0.183105,-0.0384116],359.999,1,0,[],"mortar1","",true,false], 
	["B_Mortar_01_F",[3.52515,-0.1875,-0.0383983],179.999,1,0,[],"mortar2","",true,false], 
	["Land_BagFence_01_long_green_F",[-3.26611,-2.30811,-0.000999928],0,1,0,[],"","",true,false], 
	["Land_BagFence_01_long_green_F",[3.37817,2.19336,-0.000999928],0,1,0,[],"","",true,false], 
	["Land_BagFence_01_long_green_F",[-3.6311,2.19824,-0.000999928],0,1,0,[],"","",true,false], 
	["Land_WoodenCrate_01_stack_x3_F",[2.20288,3.69238,0],24.843,1,0,[],"","",true,false], 
	["Land_BagFence_01_long_green_F",[3.74316,-2.31299,-0.000999928],0,1,0,[],"","",true,false], 
	["Sign_Arrow_Blue_F",[-2.54346,4.75488,0],0,1,0,[],"","",true,false], 
	["Land_WoodenCrate_01_F",[4.11328,3.6499,4.76837e-007],75.6395,1,0.0116541,[],"","",true,false], 
	["Land_BagFence_01_corner_green_F",[5.34985,1.89111,-0.000999928],0,1,0,[],"","",true,false], 
	["Land_BagFence_01_corner_green_F",[-5.31274,-2.06738,-0.000999928],180,1,0,[],"","",true,false], 
	["Land_BagFence_01_long_green_F",[5.74243,0.0507813,-0.000999928],90,1,0,[],"","",true,false], 
	["Land_BagFence_01_long_green_F",[-5.77002,-0.150879,-0.000999928],270,1,0,[],"","",true,false], 
	["Land_BagFence_01_corner_green_F",[-5.48511,1.81104,-0.000999928],270,1,0,[],"","",true,false], 
	["Land_BagFence_01_corner_green_F",[5.44189,-1.95068,-0.000999928],90,1,0,[],"","",true,false], 
	["Land_WoodenCrate_01_stack_x5_F",[-4.31763,-4.03076,0],337.302,1,0,[],"","",true,false]
];
_return = [_pos, _dir, _objs] call BIS_fnc_ObjectsMapper;

_spawnpos = [_pos, 30, true] call dep_fnc_scriptedspawnpos;
_spawnpos = _spawnpos select 0;

_gunpos = getPos mortar1;
_gundir = getDir mortar1;
deleteVehicle mortar1;
_gun = dep_static_mortar createVehicle _gunpos;
_objects = _objects + [_gun];
_gun setPos _gunpos;
_gun setDir _gundir;
_gun addEventHandler["Fired",{if (!isPlayer (gunner _gun)) then { _gun setVehicleAmmo 1; };}];

_gunner = [_campgroup, dep_u_soldier, _spawnpos] call dep_fnc_createunit;
_gunner assignAsGunner _gun;
_gunner moveInGunner _gun;
_totalenemies = _totalenemies + 1;

_gunpos = getPos mortar2;
_gundir = getDir mortar2;
deleteVehicle mortar2;
_gun = dep_static_mortar createVehicle _gunpos;
_objects = _objects + [_gun];
_gun setPos _gunpos;
_gun setDir _gundir;
_gun addEventHandler["Fired",{if (!isPlayer (gunner _gun)) then { _gun setVehicleAmmo 1; };}];

_gunner = [_campgroup, dep_u_soldier, _spawnpos] call dep_fnc_createunit;
_gunner assignAsGunner _gun;
_gunner moveInGunner _gun;
_totalenemies = _totalenemies + 1;

[_totalenemies, _groups, _objects];