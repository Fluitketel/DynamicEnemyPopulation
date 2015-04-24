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
 
// SETTINGS
_handle = [] execVM dep_directory+"settings.sqf";
waitUntil{scriptDone _handle};

// PUBLIC VARIABLES
dep_worldname   = toLower(worldName);
dep_total_ai    = 0;
dep_total_civ   = 0;
dep_total_veh   = 0;
dep_locations   = [];
dep_loc_cache   = [];
dep_num_loc     = 0;
dep_num_players = 0;
dep_act_bl      = [];
dep_veh_pat_rad = 600;
dep_allgroups   = [];
dep_civgroups = [];
dep_exceeded_ai_limit       = false;
dep_exceeded_group_limit    = false;

if (!(isClass(configFile>>"CfgPatches">>"cba_main_a3")) && !(dep_worldname in ['altis', 'stratis'])) exitWith 
{
    diag_log "DEP INIT FAILED: CBA NOT RUNNING ON SERVER";
    ["DEP INIT FAILED: CBA NOT RUNNING ON SERVER","systemChat",nil,true] call BIS_fnc_MP;
    dep_ready = false;
    publicVariable "dep_ready";
};

if (isNil "dep_side")               then { dep_side             = east; };          // Enemy side (east, west, independent)
if (isNil "dep_own_side")           then { dep_own_side         = west; };          // Friendly side (east, west, independent)
if (isNil "dep_despawn")            then { dep_despawn          = 5; };             // Despawn location after x minutes inactivity
if (isNil "dep_debug")              then { dep_debug            = false; };         // Enable debug
if (isNil "dep_max_ai_loc")         then { dep_max_ai_loc       = 8; };             // Maximum AI per location
if (isNil "dep_aim_player")         then { dep_aim_player       = 0; };             // AI multiplier for on the fly modifying the maximum amount of enemy per location
if (isNil "dep_max_ai_tot")         then { dep_max_ai_tot       = 400; };           // Maximum AI in total
if (isNil "dep_act_dist")           then { dep_act_dist         = 800; };           // Location activation distance
if (isNil "dep_act_height")         then { dep_act_height       = 80; };            // Player must be below this height to activate location
if (isNil "dep_act_speed")          then { dep_act_speed        = 160; };           // Player must be below this speed to activate location
if (isNil "dep_safe_rad")           then { dep_safe_rad         = 800; };           // Safe zone radius
if (isNil "dep_max_veh")            then { dep_max_veh          = 10; };            // Max number of vehicles
if (isNil "dep_ied_chance")         then { dep_ied_chance       = 0.7; };           // Chance of IEDs
if (isNil "dep_veh_chance")         then { dep_veh_chance       = 0.3; };           // Chance of vehicles
if (isNil "dep_unit_init")          then { dep_unit_init        = ""; };            // Code executed on unit creation
if (isNil "dep_cr_ied")             then { dep_cr_ied           = false; };         // Restrict disarming IED to explosives class
if (isNil "dep_useheadless")        then { dep_useheadless      = false; };         // Load DEP on a headless client
if (isNil "dep_headlessclient")     then { dep_headlessclient   = ""; };            // Specify the headless client if there are more than one
if (isNil "dep_civilians")          then { dep_civilians        = false; };         // Place civilians on the map
if (isNil "dep_allow_mortars")      then { dep_allow_mortars    = true; };          // Allow players to use mortars
if (isNil "dep_fail_civilians")     then { dep_fail_civilians   = 0; };             // Number of civilian casualties before mission fail. Use 0 for infinite.
if (isNil "dep_zone_markers")       then { dep_zone_markers     = []; };            // Set which markers show up on the map.
if (isNil "dep_civ_fail_script")    then { dep_civ_fail_script = ""; };             // Code executed when too many civilians are killed
if (isNil "dep_safe_zone") then 
{ 
    if (getMarkerColor "respawn_west" != "" && dep_own_side == west) then { dep_safe_zone = getMarkerPos "respawn_west"; };
    if (getMarkerColor "respawn_east" != "" && dep_own_side == east) then { dep_safe_zone = getMarkerPos "respawn_east"; };
    if (getMarkerColor "respawn_guerrila" != "" && dep_own_side == independent) then { dep_safe_zone = getMarkerPos "respawn_guerrila"; };
    if (isNil "dep_safe_zone") then { dep_safe_zone = []; }; 
};

dep_base_ai_loc = dep_max_ai_loc;
if (dep_aim_player > 1 || dep_aim_player < 0) then { dep_aim_player = 0; };

if (dep_unit_init != "")        then { dep_unit_init = compile dep_unit_init; };
if (dep_civ_fail_script != "")  then { dep_civ_fail_script = compile dep_civ_fail_script; };

dep_side setFriend [dep_own_side, 0];
dep_own_side setFriend [dep_side, 0];

if (dep_civilians) then
{
    civilian setFriend [dep_own_side, 1];
    civilian setFriend [dep_side, 1];
    dep_own_side setFriend [civilian, 1];
    dep_side setFriend [civilian, 1];
};

switch (dep_side) do 
{
    case east: {
        if (isNil "dep_u_g_soldier")    then { dep_u_g_soldier  = "O_G_Soldier_F"; };
        if (isNil "dep_u_g_gl")         then { dep_u_g_gl       = "O_G_Soldier_GL_F"; };
        if (isNil "dep_u_g_ar")         then { dep_u_g_ar       = "O_G_Soldier_AR_F"; };
        if (isNil "dep_u_g_at")         then { dep_u_g_at       = "O_G_Soldier_LAT_F"; };
        if (isNil "dep_u_g_medic")      then { dep_u_g_medic    = "O_G_medic_F"; };
        if (isNil "dep_u_g_sl")         then { dep_u_g_sl       = "O_G_Soldier_SL_F"; };
        if (isNil "dep_u_g_marksman")   then { dep_u_g_marksman = "O_G_Soldier_M_F"; };

        if (isNil "dep_u_soldier")      then { dep_u_soldier    = "O_Soldier_F"; };
        if (isNil "dep_u_gl")           then { dep_u_gl         = "O_Soldier_GL_F"; };
        if (isNil "dep_u_ar")           then { dep_u_ar         = "O_Soldier_AR_F"; };
        if (isNil "dep_u_at")           then { dep_u_at         = "O_Soldier_LAT_F"; };
        if (isNil "dep_u_medic")        then { dep_u_medic      = "O_medic_F"; };
        if (isNil "dep_u_aa")           then { dep_u_aa         = "O_Soldier_AA_F"; };
        if (isNil "dep_u_aaa")          then { dep_u_aaa        = "O_Soldier_AAA_F"; };
        if (isNil "dep_u_sl")           then { dep_u_sl         = "O_Soldier_SL_F"; };
        if (isNil "dep_u_marksman")     then { dep_u_marksman   = "O_soldier_M_F"; };
        if (isNil "dep_u_sniper")       then { dep_u_sniper     = "O_Sniper_F"; };
        if (isNil "dep_u_veh_cmnd")     then { dep_u_veh_cmnd   = "O_officer_F"; };
        if (isNil "dep_u_veh_crew")     then { dep_u_veh_crew   = "O_crew_F"; };
        
        if (isNil "dep_ground_vehicles") then { dep_ground_vehicles = ["O_MRAP_02_hmg_F","O_MRAP_02_gmg_F","O_APC_Tracked_02_cannon_F","O_G_Van_01_transport_F","O_APC_Wheeled_02_rcws_F","O_G_Offroad_01_armed_F"]; };
    };
    case west: {
        if (isNil "dep_u_g_soldier")    then { dep_u_g_soldier  = "B_G_Soldier_F"; };
        if (isNil "dep_u_g_gl")         then { dep_u_g_gl       = "B_G_Soldier_GL_F"; };
        if (isNil "dep_u_g_ar")         then { dep_u_g_ar       = "B_G_Soldier_AR_F"; };
        if (isNil "dep_u_g_at")         then { dep_u_g_at       = "B_G_Soldier_LAT_F"; };
        if (isNil "dep_u_g_medic")      then { dep_u_g_medic    = "B_G_medic_F"; };
        if (isNil "dep_u_g_sl")         then { dep_u_g_sl       = "B_G_Soldier_SL_F"; };
        if (isNil "dep_u_g_marksman")   then { dep_u_g_marksman = "B_G_Soldier_M_F"; };

        if (isNil "dep_u_soldier")      then { dep_u_soldier    = "B_Soldier_F"; };
        if (isNil "dep_u_gl")           then { dep_u_gl         = "B_Soldier_GL_F"; };
        if (isNil "dep_u_ar")           then { dep_u_ar         = "B_Soldier_AR_F"; };
        if (isNil "dep_u_at")           then { dep_u_at         = "B_Soldier_LAT_F"; };
        if (isNil "dep_u_medic")        then { dep_u_medic      = "B_medic_F"; };
        if (isNil "dep_u_aa")           then { dep_u_aa         = "B_Soldier_AA_F"; };
        if (isNil "dep_u_aaa")          then { dep_u_aaa        = "B_Soldier_AAA_F"; };
        if (isNil "dep_u_sl")           then { dep_u_sl         = "B_Soldier_SL_F"; };
        if (isNil "dep_u_marksman")     then { dep_u_marksman   = "B_soldier_M_F"; };
        if (isNil "dep_u_sniper")       then { dep_u_sniper     = "B_Sniper_F"; };
        if (isNil "dep_u_veh_cmnd")     then { dep_u_veh_cmnd   = "B_officer_F"; };
        if (isNil "dep_u_veh_crew")     then { dep_u_veh_crew   = "B_crew_F"; };
        
        if (isNil "dep_ground_vehicles") then { dep_ground_vehicles = ["B_MRAP_01_hmg_F","B_MRAP_01_gmg_F","B_APC_Wheeled_01_cannon_F","B_G_Van_01_transport_F","B_APC_Tracked_01_AA_F","B_G_Offroad_01_armed_F"]; };
    };
    default {
        if (isNil "dep_u_g_soldier")    then { dep_u_g_soldier  = "I_G_Soldier_F"; };
        if (isNil "dep_u_g_gl")         then { dep_u_g_gl       = "I_G_Soldier_GL_F"; };
        if (isNil "dep_u_g_ar")         then { dep_u_g_ar       = "I_G_Soldier_AR_F"; };
        if (isNil "dep_u_g_at")         then { dep_u_g_at       = "I_G_Soldier_LAT_F"; };
        if (isNil "dep_u_g_medic")      then { dep_u_g_medic    = "I_G_medic_F"; };
        if (isNil "dep_u_g_sl")         then { dep_u_g_sl       = "I_G_Soldier_SL_F"; };
        if (isNil "dep_u_g_marksman")   then { dep_u_g_marksman = "I_G_Soldier_M_F"; };

        if (isNil "dep_u_soldier")      then { dep_u_soldier    = "I_soldier_F"; };
        if (isNil "dep_u_gl")           then { dep_u_gl         = "I_Soldier_GL_F"; };
        if (isNil "dep_u_ar")           then { dep_u_ar         = "I_Soldier_AR_F"; };
        if (isNil "dep_u_at")           then { dep_u_at         = "I_Soldier_LAT_F"; };
        if (isNil "dep_u_medic")        then { dep_u_medic      = "I_medic_F"; };
        if (isNil "dep_u_aa")           then { dep_u_aa         = "I_Soldier_AA_F"; };
        if (isNil "dep_u_aaa")          then { dep_u_aaa        = "I_Soldier_AAA_F"; };
        if (isNil "dep_u_sl")           then { dep_u_sl         = "I_Soldier_SL_F"; };
        if (isNil "dep_u_marksman")     then { dep_u_marksman   = "I_soldier_M_F"; };
        if (isNil "dep_u_sniper")       then { dep_u_sniper     = "I_Sniper_F"; };
        if (isNil "dep_u_veh_cmnd")     then { dep_u_veh_cmnd   = "I_officer_F"; };
        if (isNil "dep_u_veh_crew")     then { dep_u_veh_crew   = "I_crew_F"; };
        
        if (isNil "dep_ground_vehicles") then { dep_ground_vehicles = ["I_MRAP_03_hmg_F","I_MRAP_03_gmg_F","I_APC_tracked_03_cannon_F","I_G_Van_01_transport_F","I_APC_Wheeled_03_cannon_F","I_G_offroad_01_armed_F"]; };
    };
};

dep_unit_rare = 1;
dep_unit_low = 3;
dep_unit_med = 6;
dep_unit_high = 10;
if (isNil "dep_mil_units") then 
{ 
    dep_mil_units = [];
    for [{_x=1}, {_x<=dep_unit_high}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_soldier]; };
    for [{_x=1}, {_x<=dep_unit_med}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_gl]; };
    for [{_x=1}, {_x<=dep_unit_med}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_ar]; };
    for [{_x=1}, {_x<=dep_unit_med}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_at]; };
    for [{_x=1}, {_x<=dep_unit_low}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_medic]; };
    for [{_x=1}, {_x<=dep_unit_med}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_aa]; };
    for [{_x=1}, {_x<=dep_unit_low}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_sl]; };
    for [{_x=1}, {_x<=dep_unit_low}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_marksman]; };
    for [{_x=1}, {_x<=dep_unit_rare}, {_x=_x+1}] do { dep_mil_units = dep_mil_units + [dep_u_sniper]; };
};

if (isNil "dep_guer_units") then 
{ 
    dep_guer_units = [];
    for [{_x=1}, {_x<=dep_unit_high}, {_x=_x+1}] do { dep_guer_units = dep_guer_units + [dep_u_g_soldier]; };
    for [{_x=1}, {_x<=dep_unit_low}, {_x=_x+1}] do { dep_guer_units = dep_guer_units + [dep_u_g_gl]; };
    for [{_x=1}, {_x<=dep_unit_med}, {_x=_x+1}] do { dep_guer_units = dep_guer_units + [dep_u_g_ar]; };
    for [{_x=1}, {_x<=dep_unit_med}, {_x=_x+1}] do { dep_guer_units = dep_guer_units + [dep_u_g_at]; };
    for [{_x=1}, {_x<=dep_unit_low}, {_x=_x+1}] do { dep_guer_units = dep_guer_units + [dep_u_g_medic]; };
    for [{_x=1}, {_x<=dep_unit_low}, {_x=_x+1}] do { dep_guer_units = dep_guer_units + [dep_u_g_sl]; };
    for [{_x=1}, {_x<=dep_unit_rare}, {_x=_x+1}] do { dep_guer_units = dep_guer_units + [dep_u_g_marksman]; };
};

if (isNil "dep_civ_units") then { dep_civ_units = ["C_man_1","C_man_1","C_man_polo_1_F","C_man_polo_2_F","C_man_polo_3_F","C_man_polo_4_F","C_man_polo_5_F","C_man_shorts_1_F","C_man_1_1_F","C_man_1_2_F","C_man_1_3_F","C_man_w_worker_F"]; };
if (isNil "dep_civ_veh") then { dep_civ_veh = ["C_Offroad_01_F","C_Van_01_box_F","C_Van_01_transport_F"]; };

if (dep_isheadless && !dep_useheadless) exitWith
{
    diag_log "DEP is not using the headless client!";
};
if ((dep_ishostedserver || dep_isserver) && dep_useheadless) exitWith
{
    diag_log "DEP is not being ran by the server because it's ran by the headless client!";
};
if ((typeName dep_headlessclient) == "OBJECT" && dep_useheadless && dep_isheadless) then
{
    if (player != dep_headlessclient) exitWith
    {
        diag_log format ["DEP is not running on HC '%1' because it's set to run on HC '%2'.", player, dep_headlessclient];
    };
};

[] execVM dep_directory+"functions\common.sqf";

// World specific settings
switch (dep_worldname) do {
    case "altis": {
        if (isNil "dep_map_center") then { dep_map_center  = [15360, 15360]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 140; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 30; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 20; };
        if (isNil "dep_patrols")    then { dep_patrols     = 30; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 30; };
        if (isNil "dep_military")   then { dep_military    = 8; };
    };
    case "stratis": {
        if (isNil "dep_map_center") then { dep_map_center  = [4096, 4096]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 15; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 5; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 3; };
        if (isNil "dep_patrols")    then { dep_patrols     = 5; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 5; };
        if (isNil "dep_military")   then { dep_military    = 3; };
    };
    case "takistan": {
        if (isNil "dep_map_center") then { dep_map_center  = [6400, 6400]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 60; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 8; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 5; };
        if (isNil "dep_patrols")    then { dep_patrols     = 14; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 15; };
        if (isNil "dep_military")   then { dep_military    = 4; };
    };
    case "chernarus": {
        if (isNil "dep_map_center") then { dep_map_center  = [7680, 7680]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 70; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 10; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 8; };
        if (isNil "dep_patrols")    then { dep_patrols     = 20; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 20; };
        if (isNil "dep_military")   then { dep_military    = 6; };
    };
    default {
        if (isNil "dep_map_center") then { dep_map_center  = [0, 0]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 0; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 0; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 0; };
        if (isNil "dep_patrols")    then { dep_patrols     = 0; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 0; };
        if (isNil "dep_military")   then { dep_military    = 0; };
    };
};
dep_map_radius  = ceil (sqrt (((dep_map_center select 0) ^ 2) + ((dep_map_center select 1) ^ 2)));

// FUNCTIONS
dep_fnc_random_position         = compile preprocessFileLineNumbers (dep_directory+"functions\randommappos.sqf");
dep_fnc_outsidesafezone         = compile preprocessFileLineNumbers (dep_directory+"functions\outsidesafezone.sqf");
dep_fnc_createunit              = compile preprocessFileLineNumbers (dep_directory+"functions\createunit.sqf");
dep_fnc_createcivilian          = compile preprocessFileLineNumbers (dep_directory+"functions\createcivilian.sqf");
dep_fnc_isenterable             = compile preprocessFileLineNumbers (dep_directory+"functions\isenterable.sqf");
dep_fnc_setwaypoints            = compile preprocessFileLineNumbers (dep_directory+"functions\setwaypoints.sqf");
dep_fnc_getwaypoints            = compile preprocessFileLineNumbers (dep_directory+"functions\getwaypoints.sqf");
dep_fnc_vehiclepatrol           = compile preprocessFileLineNumbers (dep_directory+"functions\vehiclepatrol.sqf");
dep_fnc_housepatrol             = compile preprocessFileLineNumbers (dep_directory+"functions\housepatrol.sqf");
dep_fnc_unitpatrol              = compile preprocessFileLineNumbers (dep_directory+"functions\unitpatrol.sqf");
dep_fnc_enterablehouses         = compile preprocessFileLineNumbers (dep_directory+"functions\enterablehouses.sqf");
dep_fnc_findmilitarybuildings   = compile preprocessFileLineNumbers (dep_directory+"functions\findmilitarybuildings.sqf");
dep_fnc_findnearhouses          = compile preprocessFileLineNumbers (dep_directory+"functions\findnearhouses.sqf");
dep_fnc_buildingpositions       = compile preprocessFileLineNumbers (dep_directory+"functions\buildingpositions.sqf");
dep_fnc_vehicledamage           = compile preprocessFileLineNumbers (dep_directory+"functions\vehicledamage.sqf");
dep_fnc_nearestroad             = compile preprocessFileLineNumbers (dep_directory+"functions\nearestroad.sqf");
dep_fnc_roaddir                 = compile preprocessFileLineNumbers (dep_directory+"functions\roaddir.sqf");
dep_fnc_roadblock               = compile preprocessFileLineNumbers (dep_directory+"structures\roadblock.sqf");
dep_fnc_atcamp                  = compile preprocessFileLineNumbers (dep_directory+"structures\atcamp.sqf");
dep_fnc_mortarcamp              = compile preprocessFileLineNumbers (dep_directory+"structures\mortarcamp.sqf");
dep_fnc_barracks1               = compile preprocessFileLineNumbers (dep_directory+"structures\barracks1.sqf");
dep_fnc_barracks2               = compile preprocessFileLineNumbers (dep_directory+"structures\barracks2.sqf");
dep_fnc_aacamp1                 = compile preprocessFileLineNumbers (dep_directory+"structures\aacamp1.sqf");
dep_fnc_aacamp2                 = compile preprocessFileLineNumbers (dep_directory+"structures\aacamp2.sqf");
dep_fnc_restore                 = compile preprocessFileLineNumbers (dep_directory+"functions\restore.sqf");
dep_fnc_activate                = compile preprocessFileLineNumbers (dep_directory+"functions\activate.sqf");
dep_fnc_activate_aacamp         = compile preprocessFileLineNumbers (dep_directory+"functions\activate_aacamp.sqf");
dep_fnc_deactivate              = compile preprocessFileLineNumbers (dep_directory+"functions\deactivate.sqf");
dep_fnc_garrison                = compile preprocessFileLineNumbers (dep_directory+"functions\garrison.sqf");
dep_fnc_enemyspawnprotect       = compile preprocessFileLineNumbers (dep_directory+"functions\enemyspawnprotect.sqf");
dep_fnc_disable_ied             = compile preprocessFileLineNumbers (dep_directory+"functions\disable_ied.sqf");
dep_fnc_disable_ied_action      = compile preprocessFileLineNumbers (dep_directory+"functions\disable_ied_action.sqf");

if (dep_debug) then {
    waitUntil {time > 0};
};

private ["_locations","_pos","_flatPos","_building","_countunits"];
diag_log "Initializing DEP . . .";

_totaltime = 0;
_starttime = 0;
_parttime = 0;
if (dep_debug) then {
    diag_log "Finding military buildings";
    _starttime = time;
};
_buildings = [dep_map_center, dep_map_radius] call dep_fnc_findmilitarybuildings;
_numbuildings = (count _buildings);

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Creating military areas";
};
_counter = 0;
for [{_x=0}, {_x<=_numbuildings}, {_x=_x+1}] do {
    if (_counter >= dep_military) exitWith {};
    if (count _buildings == 0) exitWith {};
    _building = _buildings call BIS_fnc_selectRandom;
    _buildings = _buildings - [_building];
    _pos = getPos _building;
    _safe = [_pos] call dep_fnc_outsidesafezone;
    if (_safe) then {
        _ownradius = 75 + (round random 50);
        _distance = true;
        {
            _loc_pos    = _x select 0;
            _radius     = _x select 2;
            if ((_pos distance _loc_pos) < (_radius + _ownradius)) exitWith { _distance = false; };
        } foreach dep_locations;
        if (_distance) then {
            _milbuild = [_pos, _ownradius] call dep_fnc_findmilitarybuildings;
            if (count _milbuild > 2) then {
                _location = [];
                _location set [0, _pos];            // position
                _location set [1, "military"];      // location type
                _location set [2, _ownradius];      // radius
                _location set [3, false];           // location active
                _location set [4, []];              // enemy groups
                _location set [5, 0];               // time last active
                _location set [6, 0];               // enemy amount
                _location set [7, false];           // location cleared
                _location set [8, []];              // objects to cleanup
                _location set [9, 0];               // possible direction of objects
                _location set [10, []];             // civilians
                _location set [11, ""];             // marker
                dep_locations = dep_locations + [_location];
                dep_loc_cache = dep_loc_cache + [[]];
                _counter = _counter + 1;
            };
        };
    };
    //sleep 0.005;
};
_buildings = nil;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding normal buildings";
};
_buildings = nearestObjects [dep_map_center, ["House"], dep_map_radius];
_numbuildings = 0;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Creating normal areas";
};

while {_numbuildings < dep_housepop} do {
    _building = _buildings call BIS_fnc_selectRandom;
    if (count _buildings == 0) exitWith { 
        diag_log format ["Not enough buildings, found %1 of %2.", _numbuildings, dep_housepop]; 
    };
    _buildings = _buildings - [_building];
    _pos = getPos _building;
    _safe = [_pos] call dep_fnc_outsidesafezone;
    if (_safe) then {
        _ownradius = 100 + (round random 100);
        _distance = true;
        _spacing = 50;
        {
            _loc_pos    = _x select 0;
            _radius     = _x select 2;
            if ((_pos distance _loc_pos) < (_radius + _spacing + _ownradius)) exitWith { _distance = false; };
        } foreach dep_locations;
        if (_distance) then {
            _houses = [_pos, _ownradius] call dep_fnc_enterablehouses;
            if ((count _houses) > 1) then {
                _location = [];
                _location set [0, _pos];            // position
                _location set [1, "roadpop"];       // location type
                _location set [2, _ownradius];      // radius
                _location set [3, false];           // location active
                _location set [4, []];              // enemy groups
                _location set [5, 0];               // time last active
                _location set [6, 0];               // enemy amount
                _location set [7, false];           // location cleared
                _location set [8, []];              // objects to cleanup
                _location set [9, 0];               // possible direction of objects
                _location set [10, []];             // civilians
                _location set [11, ""];             // marker
                dep_locations = dep_locations + [_location];
                dep_loc_cache = dep_loc_cache + [[]];
                _numbuildings = _numbuildings + 1;
            };
        };
    };
    //sleep 0.005;
};
_buildings = nil;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding roadblocks";
};

// Roadblocks
_list = dep_map_center nearRoads dep_map_radius;
_fckit = false;
for [{_x=1}, {_x<=dep_roadblocks}, {_x=_x+1}] do {
    _valid = false;
    while {!_valid} do {
        if ((time - _starttime) > 60) exitWith {
            _fckit = true;
        };
        _road = _list call BIS_fnc_selectRandom;
        _pos = getPos _road;
        _safe = [_pos] call dep_fnc_outsidesafezone;
        if (_safe) then {
            _distance = true;
            {
                _loc_pos    = _x select 0;
                _radius     = _x select 2;
                _spacing    = 0;
                if ((_x select 1) == "roadblock") then { _spacing = 1000; };
                if ((_pos distance _loc_pos) < (_spacing + _radius + 100)) exitWith { _distance = false; };
            } foreach dep_locations;
            if (_distance) then {
                _flatPos = _pos isFlatEmpty [12, 0, 0.3, 12, 0, false];
                if (count _flatPos == 3) then {
                    _dir = [_road] call dep_fnc_roaddir;
                    _location = [];
                    _location set [0, _pos];            // position
                    _location set [1, "roadblock"];     // location type
                    _location set [2, 100];             // radius
                    _location set [3, false];           // location active
                    _location set [4, []];              // enemy groups
                    _location set [5, 0];               // time last active
                    _location set [6, 0];               // enemy amount
                    _location set [7, false];           // location cleared
                    _location set [8, []];              // objects to cleanup
                    _location set [9, _dir];            // possible direction of objects
                    _location set [10, []];             // civilians
                    _location set [11, ""];             // marker
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                    _valid = true;
                };
            };
        };
        //sleep 0.01;
    };
    if (_fckit) exitWith {
        diag_log "Roadblocks not found in time";
    };
};

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding aa camps";
};
// AA Camps
_aacamps = [];
_fckit = false;
for "_c" from 1 to dep_aa_camps do {
    _valid = false;
    while {!_valid} do {
        if ((time - _starttime) > 60) exitWith {
            _fckit = true;
        };
        _pos = [] call dep_fnc_random_position;
        _safe = [_pos] call dep_fnc_outsidesafezone;
        if (_safe) then {
            _flatPos = _pos isFlatEmpty [15, 0, 0.2, 12, 0, false];
            // Check if position is flat and empty
            if (count _flatPos == 3) then {
                _distance = true;
                {
                    if ((_pos distance _x) < 1000) exitWith { _distance = false; };
                } foreach _aacamps;
                // Check distance between other AA camps
                if (_distance) then {
                    _valid = true;
                    _aacamps = _aacamps + [_pos];
                    _location = [];
                    _location set [0, _pos];            // position
                    _location set [1, "antiair"];       // location type
                    _location set [2, 50];              // radius
                    _location set [3, false];           // location active
                    _location set [4, []];              // enemy groups
                    _location set [5, 0];               // time last active
                    _location set [6, 0];               // enemy amount
                    _location set [7, false];           // location cleared
                    _location set [8, []];              // objects to cleanup
                    _location set [9, 0];               // possible direction of objects
                    _location set [10, []];             // civilians
                    _location set [11, ""];             // marker
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                };
            };
        };
    };
    if (_fckit) exitWith {
        diag_log "AA camps not found in time";
    };
};
_aacamps = nil;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding patrols";
};
// Vehicle patrols
_fckit = false;
for [{_x=1}, {_x<=dep_patrols}, {_x=_x+1}] do {
    _valid = false;
    while {!_valid} do {
        if ((time - _starttime) > 60) exitWith {
            _fckit = true;
        };
        _road = _list call BIS_fnc_selectRandom;
        _pos = getPos _road;
        _safe = [_pos, (dep_safe_rad + dep_veh_pat_rad)] call dep_fnc_outsidesafezone;
        if (_safe) then {
            _distance = true;
            {
                if (_x select 1 == "patrol") then {
                    _loc_pos    = _x select 0;
                    _radius     = _x select 2;
                    if ((_pos distance _loc_pos) < (_radius + dep_veh_pat_rad)) exitWith { _distance = false; };
                };
            } foreach dep_locations;
            if (_distance) then {
                _location = [];
                _location set [0, _pos];            // position
                _location set [1, "patrol"];        // location type
                _location set [2, dep_veh_pat_rad]; // radius
                _location set [3, false];           // location active
                _location set [4, []];              // enemy groups
                _location set [5, 0];               // time last active
                _location set [6, 0];               // enemy amount
                _location set [7, false];           // location cleared
                _location set [8, []];              // objects to cleanup
                _location set [9, 0];               // possible direction of objects
                _location set [10, []];             // civilians
                _location set [11, ""];             // marker
                dep_locations = dep_locations + [_location];
                dep_loc_cache = dep_loc_cache + [[]];
                _valid = true;
            };
        };
        //sleep 0.005;
    };
    if (_fckit) exitWith {
        diag_log "Patrols not found in time";
    };
};
_list = nil;

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    _starttime = time;
    diag_log "Finding bunkers";
};

// Bunkers
_fckit = false;
for [{_x = 0}, {_x < dep_bunkers}, {_x = _x + 1}] do {
    _valid = false;
    while {!_valid} do {
        if ((time - _starttime) > 60) exitWith {
            _fckit = true;
        };
        _pos = [] call dep_fnc_random_position;
        _safe = [_pos] call dep_fnc_outsidesafezone;
        if (_safe) then {
            _flatPos = _pos isFlatEmpty [9, 0, 0.2, 12, 0, false];
            if (count _flatPos == 3) then {
                _distance = true;
                {
                    if ((_x select 1) in ["bunker","antiair","roadblock"]) then
                    {
                        _loc_pos    = _x select 0;
                        _radius     = _x select 2;
                        if ((_pos distance _loc_pos) < (800 + _radius)) then { _distance = false; };
                    };
                    if (!_distance) exitWith {};
                } foreach dep_locations;
                if (_distance) then {
                    _location = [];
                    _location set [0, _pos];            // position
                    _location set [1, "bunker"];        // location type
                    _location set [2, 50];              // radius
                    _location set [3, false];           // location active
                    _location set [4, []];              // enemy groups
                    _location set [5, 0];               // time last active
                    _location set [6, 0];               // enemy amount
                    _location set [7, false];           // location cleared
                    _location set [8, []];              // objects to cleanup
                    _location set [9, 0];               // possible direction of objects
                    _location set [10, []];             // civilians
                    _location set [11, ""];             // marker
                    dep_locations = dep_locations + [_location];
                    dep_loc_cache = dep_loc_cache + [[]];
                    _valid = true;
                };
            };
        };
    };
    if (_fckit) exitWith {
        diag_log format ["Bunkers not found in time. (%1 of %2)", _x, dep_bunkers];
    };
};

if (dep_debug) then {
    _parttime = time - _starttime;
    diag_log format ["Took %1 seconds.", _parttime];
    _totaltime = _totaltime + _parttime;
    diag_log format ["Total initialization took %1 seconds.", _totaltime];
};

// Place makers in debug mode
if (dep_debug) then 
{
    for [{_x=0}, {_x<(count dep_locations)}, {_x=_x+1}] do {
        _location = dep_locations select _x;
        _pos = _location select 0;
        _m = createMarker [format ["depdebug-%1",_x], _pos];
        _m setMarkerShape "ELLIPSE";
        _m setMarkerSize [_location select 2, _location select 2];
        switch (_location select 1) do {
            case "patrol":          { _m setMarkerColor "ColorRed";};
            case "antiair":         { _m setMarkerColor "ColorBlue";};
            case "roadblock":       { _m setMarkerColor "ColorGreen";};
            case "roadpop":         { _m setMarkerColor "ColorYellow";};
            case "military":        { _m setMarkerColor "ColorPink";};
            case "bunker":          { _m setMarkerColor "ColorBrown";};
        };
        _m setMarkerBrush "Solid";
        _m setMarkerAlpha 0.7;
    };
    
    // Safezone marker
    if (count dep_safe_zone > 0) then 
    {
        if (typeName (dep_safe_zone select 0) == "ARRAY") then 
        {
            _zonenr = 0;
            {
                _m = createMarker [format["dep_safezone_%1", _zonenr], _x];
                _m setMarkerShape "ELLIPSE";
                _m setMarkerSize [dep_safe_rad, dep_safe_rad];
                _m setMarkerColor "ColorBlue";
                _m setMarkerBrush "FDiagonal";
                _m setMarkerAlpha 0.5;
                _zonenr = _zonenr + 1;
            } forEach dep_safe_zone;
        } else {
            _m = createMarker ["dep_safezone", dep_safe_zone];
            _m setMarkerShape "ELLIPSE";
            _m setMarkerSize [dep_safe_rad, dep_safe_rad];
            _m setMarkerColor "ColorBlue";
            _m setMarkerBrush "FDiagonal";
            _m setMarkerAlpha 0.5;
        };
    };
    
    _m = createMarker["dep_mrk_totalai", [01000,03000]];
    _m setMarkerType "mil_dot";
    _m setMarkerText format["Total enemies present: %1",0];
    
    _m = createMarker["dep_mrk_enemy_grps", [01000,02500]];
    _m setMarkerType "mil_dot";
    _m setMarkerText format["Total enemy groups: %1",0];
    
    _m = createMarker["dep_mrk_totalciv", [01000,02000]];
    _m setMarkerType "mil_dot";
    _m setMarkerText format["Total civilians present: %1",0];
    
    _m = createMarker["dep_mrk_civ_grps", [01000,01500]];
    _m setMarkerType "mil_dot";
    _m setMarkerText format["Total civilian groups: %1",0];
    
    _m = createMarker["dep_mrk_fps", [01000,01000]];
    _m setMarkerType "mil_dot";
    _m setMarkerText format["Server FPS: %1",0];
};
if ((count dep_zone_markers) > 0) then 
{
    if ("all" in dep_zone_markers) then 
    { 
        dep_zone_markers = ["patrol","antiair","roadblock","roadpop","military","bunker"]; 
    };
    diag_log format ["Placing markers on the following locations: %1", dep_zone_markers];
    
    for [{_g=0}, {_g<(count dep_locations)}, {_g=_g+1}] do {
        _location = dep_locations select _g;
        if ((_location select 1) in dep_zone_markers) then {
            _pos = _location select 0;
            _markname = format ["depmarker-%1",_g];
            _m = createMarker [_markname, _pos];
            _m setMarkerType "mil_warning"; 
            _m setMarkerColor "ColorRed";
            if (dep_worldname == "altis") then 
            {
                _m setMarkerAlpha 0.5;
                _m setMarkerSize [0.4, 0.4];
            };
            
            _location set [11, _markname];
            dep_locations set [_g, _location];
        };
    };
};

// Start searching for players
if (dep_debug) then {
    diag_log "Done creating...";
};
dep_num_loc = (count dep_locations);
diag_log format ["DEP ready with %1 locations", dep_num_loc];
dep_ready = true;
publicVariable "dep_ready";

_countunits = false;
while {true} do {    
    for "_g" from 0 to (dep_num_loc - 1) do {
        _location   = dep_locations select _g;
        _pos        = _location select 0;
        _type       = _location select 1;
        _radius     = _location select 2;
        _active     = _location select 3;
        _groups     = _location select 4;
        _time       = _location select 5;
        _enemies    = _location select 6;
        _clear      = _location select 7;
        _close      = false;
        _tooclose   = false;
        _blacklist  = false;
        
        // Check if active location is clear
        if (_active && !_clear) then {
            _alive = 0;
            {
                _grp = _x;
                {
                    if (alive _x) then { _alive = _alive + 1; };
                } foreach (units _grp);
            } foreach _groups;
            
            if (_enemies > 0) then {
                if ((_alive / _enemies) < 0.1) then {
                    // If number of enemies alive below 10% concider this location clear.
                    diag_log format ["Cleared location %1", _g];
                    _clear = true;
                    _location set [7, _clear];
                    dep_locations set [_g, _location];
                };
            } else {
                diag_log format ["Cleared location %1", _g];
                _clear = true;
                _location set [7, _clear];
                dep_locations set [_g, _location];
            };
            if (_clear) then
            {
                if ((_location select 11) != "") then {
                    // Change the marker
                    if ((_location select 1) in dep_zone_markers) then {
                        _markname = (_location select 11);
                        deleteMarker _markname;
                        _m = createMarker [_markname, _pos];
                        _m setMarkerType "mil_circle"; 
                        _m setMarkerColor "ColorGreen";
                        if (dep_worldname == "altis") then 
                        {
                            _m setMarkerAlpha 0.5;
                            _m setMarkerSize [0.4, 0.4];
                        };
                    };
                };
                dep_loc_cache set [_g, []];
                diag_log format ["Removed cleared location %1 from cache", _g];
            };
        };
        
        // Check if location is close to blacklisted positions
        {
            if ((_pos distance _x) < (_radius * 2)) exitWith {_blacklist = true; };
        } foreach dep_act_bl;
        
        // Check if at least 1 player is close
        if (!_blacklist) then {
            _units = [];
            if (isMultiplayer) then 
            {
                _units = playableUnits;
            } else {
                {
                    if ((side _x) == dep_own_side) then { 
                        _units = _units + [_x];
                    };
                } forEach allUnits;
            };
            
            // Dynamic max amount of ai at locations
            dep_num_players = count _units;
            dep_max_ai_loc = round (((dep_num_players * dep_aim_player) + 1) * dep_base_ai_loc);
            
            // Also check connected UAV's
            _UAVs = [];
            {
                _uav = getConnectedUAV _x;
                if !(isNull _uav) then { _UAVs = _UAVs + [_uav]; };
            } forEach _units;
            _units = _units + _UAVs;
            
            _closest = 999999;
            {
                _speedok = true;
                _heightok = true;
                if (_type != "antiair") then {
                    // Check the speed and height of the player
                    if (((getPos _x) select 2) > dep_act_height) then { _heightok = false; };
                    if ((speed _x) > dep_act_speed) then { _speedok = false; };
                };
                
                if ((_speedok && _heightok)) then {
                    _distance = (getPos _x) distance _pos;
                    if (_distance < _closest) then { _closest = _distance; };
                };
            } forEach _units;
            
            if (_type == "antiair") then {
                // Anti air locations have 3x greater activation distance
                if (_closest < (_radius + (dep_act_dist * 3))) then { _close = true; };
            } else {
                if (_closest < (_radius + dep_act_dist)) then { _close = true; };
            };

            // Don't activate when players are too close
            if (_closest < (2 * _radius) && _type != "patrol") then { _tooclose = true; };
        };
        
        if (_close && !_clear) then {
            // Players are close and location not clear, should enemies be spawned?
            if (!dep_exceeded_group_limit && !dep_exceeded_ai_limit) then {
                if (!_active && !_tooclose) then {
                    // Location is not cleared and not active => spawn units
                    if (_type == "antiair") then {
                        _handle = _g call dep_fnc_activate_aacamp;
                    } else {
                        _handle = _g call dep_fnc_activate;
                    };
                    _countunits = true;
                };
            };
            _time = time;
            _location set [5, _time];
            dep_locations set [_g, _location];
        } else {
            // No players close to location, should it be deactivated?
            if (_active) then {
                // Despawn after time limit
                if ((_clear && (time - _time) > (60 * dep_despawn)) || (!_clear && (time - _time) > (60 * (dep_despawn / 2))) ) then {
                    // Deactivate the location
                    _handle = _g call dep_fnc_deactivate;
                    _countunits = true;
                };
            };
        };
        
        if (_countunits) then
        {
            dep_allgroups = [];
            dep_civgroups = [];
            dep_total_ai = 0;
            dep_total_civ = 0;
            {
                if (side _x == dep_side) then { 
                    dep_allgroups = dep_allgroups + [_x];
                    _grp = _x;
                    {
                        if (!isNull _x) then {
                            if (alive _x) then { dep_total_ai = dep_total_ai + 1; };
                        };
                    } foreach (units _grp);
                };
                if (side _x == civilian) then {
                    dep_civgroups = dep_civgroups + [_x];
                    _grp = _x;
                    {
                        if (!isNull _x) then {
                            if (alive _x) then { dep_total_civ = dep_total_civ + 1; };
                        };
                    } foreach (units _grp);
                };
            } forEach allGroups;
            //diag_log format ["Total AI: %1 Total groups %2", dep_total_ai, (count dep_allgroups)];
            _countunits = false;
            
            if (dep_total_ai >= dep_max_ai_tot) then {
                dep_exceeded_ai_limit = true;
                diag_log format ["AI limit of %1 reached!", dep_max_ai_tot, dep_total_ai];
            } else {
                dep_exceeded_ai_limit = false;
            };
            if ((count dep_allgroups) >= 134 || (count dep_civgroups) >= 134) then {
                dep_exceeded_group_limit = true;
                diag_log "Group limit of 134 reached!";
            } else {
                dep_exceeded_group_limit = false;
            };
        };
        sleep 0.02;
    };
    
    _fps = diag_fps;
    if (dep_debug) then {
        "dep_mrk_totalai" setMarkerText format["# %2 enemies: %1", dep_total_ai, dep_side];
        "dep_mrk_enemy_grps" setMarkerText format["# %2 enemy groups: %1",(count dep_allgroups), dep_side];
        "dep_mrk_totalciv" setMarkerText format["# civilians: %1", dep_total_civ];
        "dep_mrk_civ_grps" setMarkerText format["# civilian groups: %1",(count dep_civgroups)];
        "dep_mrk_fps" setMarkerText format["Server FPS: %1",_fps];
    };
    if (_fps > 45) then {
        sleep 1;
    } else {
        if (_fps > 40) then {
            sleep 4;
        } else {
            sleep 8;
        };
    };
};