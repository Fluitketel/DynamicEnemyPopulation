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
// This file creates all the server variables

dep_worldname   			= toLower(worldName);
dep_total_ai    			= 0;
dep_total_civ   			= 0;
dep_total_veh   			= 0;
dep_locations   			= [];
dep_loc_cache   			= [];
dep_num_loc     			= 0;
dep_num_players 			= 0;
dep_act_bl      			= [];
dep_allgroups   			= [];
dep_civgroups 				= [];
dep_exceeded_ai_limit       = false;
dep_exceeded_group_limit	= false;

if (isNil "dep_side")               then { dep_side             = east; };          // Enemy side (east, west, independent)
if (isNil "dep_own_side")           then { dep_own_side         = west; };          // Friendly side (east, west, independent)
if (isNil "dep_despawn")            then { dep_despawn          = 5; };             // Despawn location after x minutes inactivity
if (isNil "dep_debug")              then { dep_debug            = false; };         // Enable debug
if (isNil "dep_logging")     		then { dep_logging   		= true; };          // Write debug messages to log file
if (isNil "dep_chat_logging") 		then { dep_chat_logging 	= false; };         // Write debug messages in chat
if (isNil "dep_precache")           then { dep_precache         = false; };         // Pre cache locations
if (isNil "dep_max_ai_loc")         then { dep_max_ai_loc       = 8; };             // Maximum AI per location
if (isNil "dep_aim_player")         then { dep_aim_player       = 0; };             // AI multiplier for on the fly modifying the maximum amount of enemy per location
if (isNil "dep_max_ai_tot")         then { dep_max_ai_tot       = 200; };           // Maximum AI in total
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
if (isNil "dep_mines")          	then { dep_mines        	= true; };         	// Spawn mines
if (isNil "dep_ieds")          		then { dep_ieds        		= true; };         	// Spawn IEDs
if (isNil "dep_allow_mortars")      then { dep_allow_mortars    = true; };          // Allow players to use mortars
if (isNil "dep_fail_civilians")     then { dep_fail_civilians   = 0; };             // Number of civilian casualties before mission fail. Use 0 for infinite.
if (isNil "dep_zone_markers")       then { dep_zone_markers     = []; };            // Set which markers show up on the map.
if (isNil "dep_civ_fail_script")    then { dep_civ_fail_script 	= ""; };            // Code executed when too many civilians are killed
if (isNil "dep_veh_pat_rad")    	then { dep_veh_pat_rad 		= 800; };           // Radius of vehicle patrol zones
if (isNil "dep_map_margin")    		then { dep_map_margin 		= 400; };           // Distance in meters from the edges of the map where enemies can spawn
if (isNil "dep_air_patrols")    	then { dep_air_patrols 		= 1; };           	// Number of patroling air vehicles
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
        if (isNil "dep_u_g_soldier")    	then { dep_u_g_soldier  	= "O_G_Soldier_F"; };
        if (isNil "dep_u_g_gl")         	then { dep_u_g_gl       	= "O_G_Soldier_GL_F"; };
        if (isNil "dep_u_g_ar")         	then { dep_u_g_ar       	= "O_G_Soldier_AR_F"; };
        if (isNil "dep_u_g_at")         	then { dep_u_g_at       	= "O_G_Soldier_LAT_F"; };
        if (isNil "dep_u_g_medic")      	then { dep_u_g_medic    	= "O_G_medic_F"; };
        if (isNil "dep_u_g_sl")         	then { dep_u_g_sl       	= "O_G_Soldier_SL_F"; };
        if (isNil "dep_u_g_marksman")   	then { dep_u_g_marksman 	= "O_G_Soldier_M_F"; };

        if (isNil "dep_u_soldier")      	then { dep_u_soldier    	= "O_Soldier_F"; };
        if (isNil "dep_u_gl")           	then { dep_u_gl         	= "O_Soldier_GL_F"; };
        if (isNil "dep_u_ar")           	then { dep_u_ar         	= "O_Soldier_AR_F"; };
        if (isNil "dep_u_at")           	then { dep_u_at         	= "O_Soldier_LAT_F"; };
        if (isNil "dep_u_medic")        	then { dep_u_medic      	= "O_medic_F"; };
        if (isNil "dep_u_aa")           	then { dep_u_aa         	= "O_Soldier_AA_F"; };
        if (isNil "dep_u_aaa")          	then { dep_u_aaa        	= "O_Soldier_AAA_F"; };
        if (isNil "dep_u_sl")           	then { dep_u_sl         	= "O_Soldier_SL_F"; };
        if (isNil "dep_u_marksman")     	then { dep_u_marksman   	= "O_soldier_M_F"; };
        if (isNil "dep_u_sniper")       	then { dep_u_sniper     	= "O_Sniper_F"; };
        if (isNil "dep_u_veh_cmnd")     	then { dep_u_veh_cmnd   	= "O_officer_F"; };
        if (isNil "dep_u_veh_crew")     	then { dep_u_veh_crew   	= "O_crew_F"; };
		
		if (isNil "dep_static_aa") 			then { dep_static_aa		= "O_static_AA_F"; };
		if (isNil "dep_static_at") 			then { dep_static_at		= "O_static_AT_F"; };
		if (isNil "dep_static_hmg") 		then { dep_static_hmg		= "O_HMG_01_high_F"; };
		if (isNil "dep_static_gmg") 		then { dep_static_gmg		= "O_GMG_01_high_F"; };
		if (isNil "dep_static_hmg_tri") 	then { dep_static_hmg_tri 	= "O_HMG_01_F"; };
		
		if (isNil "dep_box_weapons") 		then { dep_box_weapons		= "Box_East_Wps_F"; };
		if (isNil "dep_box_special") 		then { dep_box_special		= "Box_East_WpsSpecial_F"; };
		if (isNil "dep_box_launchers") 		then { dep_box_launchers	= "Box_East_WpsLaunch_F"; };
		if (isNil "dep_box_ammo") 			then { dep_box_ammo			= "Box_East_Ammo_F"; };
		if (isNil "dep_box_ord") 			then { dep_box_ord			= "Box_East_AmmoOrd_F"; };
        
        if (isNil "dep_ground_vehicles") 	then { dep_ground_vehicles 	= ["O_MRAP_02_hmg_F","O_MRAP_02_gmg_F","O_APC_Tracked_02_cannon_F","O_G_Van_01_transport_F","O_APC_Wheeled_02_rcws_F","O_G_Offroad_01_armed_F"]; };
        if (isNil "dep_air_vehicles") 		then { dep_air_vehicles 	= ["O_Heli_Attack_02_F","O_Heli_Light_02_F","O_Plane_CAS_02_F"]; };
    };
    case west: {
        if (isNil "dep_u_g_soldier")    	then { dep_u_g_soldier  	= "B_G_Soldier_F"; };
        if (isNil "dep_u_g_gl")         	then { dep_u_g_gl       	= "B_G_Soldier_GL_F"; };
        if (isNil "dep_u_g_ar")         	then { dep_u_g_ar       	= "B_G_Soldier_AR_F"; };
        if (isNil "dep_u_g_at")         	then { dep_u_g_at       	= "B_G_Soldier_LAT_F"; };
        if (isNil "dep_u_g_medic")      	then { dep_u_g_medic    	= "B_G_medic_F"; };
        if (isNil "dep_u_g_sl")         	then { dep_u_g_sl       	= "B_G_Soldier_SL_F"; };
        if (isNil "dep_u_g_marksman")   	then { dep_u_g_marksman 	= "B_G_Soldier_M_F"; };

        if (isNil "dep_u_soldier")      	then { dep_u_soldier    	= "B_Soldier_F"; };
        if (isNil "dep_u_gl")           	then { dep_u_gl         	= "B_Soldier_GL_F"; };
        if (isNil "dep_u_ar")           	then { dep_u_ar         	= "B_Soldier_AR_F"; };
        if (isNil "dep_u_at")           	then { dep_u_at         	= "B_Soldier_LAT_F"; };
        if (isNil "dep_u_medic")        	then { dep_u_medic      	= "B_medic_F"; };
        if (isNil "dep_u_aa")           	then { dep_u_aa         	= "B_Soldier_AA_F"; };
        if (isNil "dep_u_aaa")          	then { dep_u_aaa        	= "B_Soldier_AAA_F"; };
        if (isNil "dep_u_sl")           	then { dep_u_sl         	= "B_Soldier_SL_F"; };
        if (isNil "dep_u_marksman")     	then { dep_u_marksman   	= "B_soldier_M_F"; };
        if (isNil "dep_u_sniper")       	then { dep_u_sniper     	= "B_Sniper_F"; };
        if (isNil "dep_u_veh_cmnd")     	then { dep_u_veh_cmnd   	= "B_officer_F"; };
        if (isNil "dep_u_veh_crew")     	then { dep_u_veh_crew   	= "B_crew_F"; };
		
		if (isNil "dep_static_aa") 			then { dep_static_aa		= "B_static_AA_F"; };
		if (isNil "dep_static_at") 			then { dep_static_at		= "B_static_AT_F"; };
		if (isNil "dep_static_hmg") 		then { dep_static_hmg		= "B_HMG_01_high_F"; };
		if (isNil "dep_static_gmg") 		then { dep_static_gmg		= "B_GMG_01_high_F"; };
		if (isNil "dep_static_hmg_tri") 	then { dep_static_hmg_tri 	= "B_HMG_01_F"; };
		
		if (isNil "dep_box_weapons") 		then { dep_box_weapons 		= "Box_NATO_Wps_F"; };
		if (isNil "dep_box_special") 		then { dep_box_special 		= "Box_NATO_WpsSpecial_F"; };
		if (isNil "dep_box_launchers") 		then { dep_box_launchers 	= "Box_NATO_WpsLaunch_F"; };
		if (isNil "dep_box_ammo") 			then { dep_box_ammo 		= "Box_NATO_Ammo_F"; };
		if (isNil "dep_box_ord") 			then { dep_box_ord 			= "Box_NATO_AmmoOrd_F"; };
        
        if (isNil "dep_ground_vehicles") 	then { dep_ground_vehicles 	= ["B_MRAP_01_hmg_F","B_MRAP_01_gmg_F","B_APC_Wheeled_01_cannon_F","B_G_Van_01_transport_F","B_APC_Tracked_01_AA_F","B_G_Offroad_01_armed_F"]; };
		if (isNil "dep_air_vehicles") 		then { dep_air_vehicles 	= ["B_Heli_Attack_01_F","B_Heli_Light_01_armed_F","B_Plane_CAS_01_F"]; };
    };
    default {
        if (isNil "dep_u_g_soldier")    	then { dep_u_g_soldier  	= "I_G_Soldier_F"; };
        if (isNil "dep_u_g_gl")         	then { dep_u_g_gl       	= "I_G_Soldier_GL_F"; };
        if (isNil "dep_u_g_ar")         	then { dep_u_g_ar       	= "I_G_Soldier_AR_F"; };
        if (isNil "dep_u_g_at")         	then { dep_u_g_at       	= "I_G_Soldier_LAT_F"; };
        if (isNil "dep_u_g_medic")      	then { dep_u_g_medic    	= "I_G_medic_F"; };
        if (isNil "dep_u_g_sl")         	then { dep_u_g_sl       	= "I_G_Soldier_SL_F"; };
        if (isNil "dep_u_g_marksman")   	then { dep_u_g_marksman 	= "I_G_Soldier_M_F"; };

        if (isNil "dep_u_soldier")      	then { dep_u_soldier    	= "I_soldier_F"; };
        if (isNil "dep_u_gl")           	then { dep_u_gl         	= "I_Soldier_GL_F"; };
        if (isNil "dep_u_ar")           	then { dep_u_ar         	= "I_Soldier_AR_F"; };
        if (isNil "dep_u_at")           	then { dep_u_at         	= "I_Soldier_LAT_F"; };
        if (isNil "dep_u_medic")        	then { dep_u_medic      	= "I_medic_F"; };
        if (isNil "dep_u_aa")           	then { dep_u_aa         	= "I_Soldier_AA_F"; };
        if (isNil "dep_u_aaa")          	then { dep_u_aaa        	= "I_Soldier_AAA_F"; };
        if (isNil "dep_u_sl")           	then { dep_u_sl         	= "I_Soldier_SL_F"; };
        if (isNil "dep_u_marksman")     	then { dep_u_marksman   	= "I_soldier_M_F"; };
        if (isNil "dep_u_sniper")       	then { dep_u_sniper     	= "I_Sniper_F"; };
        if (isNil "dep_u_veh_cmnd")     	then { dep_u_veh_cmnd   	= "I_officer_F"; };
        if (isNil "dep_u_veh_crew")     	then { dep_u_veh_crew   	= "I_crew_F"; };
		
		if (isNil "dep_static_aa") 			then { dep_static_aa		= "I_static_AA_F"; };
		if (isNil "dep_static_at") 			then { dep_static_at		= "I_static_AT_F"; };
		if (isNil "dep_static_hmg") 		then { dep_static_hmg		= "I_HMG_01_high_F"; };
		if (isNil "dep_static_gmg") 		then { dep_static_gmg		= "I_GMG_01_high_F"; };
		if (isNil "dep_static_hmg_tri") 	then { dep_static_hmg_tri 	= "I_HMG_01_F"; };
		
		if (isNil "dep_box_weapons") 		then { dep_box_weapons		= "Box_IND_Wps_F"; };
		if (isNil "dep_box_special") 		then { dep_box_special		= "Box_IND_WpsSpecial_F"; };
		if (isNil "dep_box_launchers") 		then { dep_box_launchers	= "Box_IND_WpsLaunch_F"; };
		if (isNil "dep_box_ammo") 			then { dep_box_ammo			= "Box_IND_Ammo_F"; };
		if (isNil "dep_box_ord") 			then { dep_box_ord			= "Box_IND_AmmoOrd_F"; };
        
        if (isNil "dep_ground_vehicles") 	then { dep_ground_vehicles 	= ["I_MRAP_03_hmg_F","I_MRAP_03_gmg_F","I_APC_tracked_03_cannon_F","I_G_Van_01_transport_F","I_APC_Wheeled_03_cannon_F","I_G_offroad_01_armed_F"]; };
		if (isNil "dep_air_vehicles") 		then { dep_air_vehicles 	= ["I_Heli_light_03_F","I_Plane_Fighter_03_CAS_F"]; };
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
		if (isNil "dep_ambushes")   then { dep_ambushes    = 10; };
    };
    case "stratis": {
        if (isNil "dep_map_center") then { dep_map_center  = [4096, 4096]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 15; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 5; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 3; };
        if (isNil "dep_patrols")    then { dep_patrols     = 5; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 5; };
        if (isNil "dep_military")   then { dep_military    = 3; };
		if (isNil "dep_ambushes")   then { dep_ambushes    = 3; };
    };
    case "takistan": {
        if (isNil "dep_map_center") then { dep_map_center  = [6400, 6400]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 60; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 8; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 5; };
        if (isNil "dep_patrols")    then { dep_patrols     = 14; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 15; };
        if (isNil "dep_military")   then { dep_military    = 4; };
		if (isNil "dep_ambushes")   then { dep_ambushes    = 2; };
    };
    case "chernarus": {
        if (isNil "dep_map_center") then { dep_map_center  = [7680, 7680]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 70; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 10; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 8; };
        if (isNil "dep_patrols")    then { dep_patrols     = 20; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 20; };
        if (isNil "dep_military")   then { dep_military    = 6; };
		if (isNil "dep_ambushes")   then { dep_ambushes    = 5; };
    };
    case "woodland_acr": {
        if (isNil "dep_map_center") then { dep_map_center  = [3840, 3840]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 20; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 4; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 4; };
        if (isNil "dep_patrols")    then { dep_patrols     = 5; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 10; };
        if (isNil "dep_military")   then { dep_military    = 3; };
		if (isNil "dep_ambushes")   then { dep_ambushes    = 2; };
    };
	case "kunduz": {
        if (isNil "dep_map_center") then { dep_map_center  = [2560, 2560]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 12; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 4; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 2; };
        if (isNil "dep_patrols")    then { dep_patrols     = 3; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 10; };
        if (isNil "dep_military")   then { dep_military    = 0; };
        if (isNil "dep_ambushes")   then { dep_ambushes    = 3; };
    };
	case "zargabad": {
        if (isNil "dep_map_center") then { dep_map_center  = [4096, 4096]; };
        if (isNil "dep_housepop")   then { dep_housepop    = 8; };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = 4; };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = 4; };
        if (isNil "dep_patrols")    then { dep_patrols     = 3; };
        if (isNil "dep_bunkers")    then { dep_bunkers     = 8; };
        if (isNil "dep_military")   then { dep_military    = 3; };
		if (isNil "dep_ambushes")   then { dep_ambushes    = 2; };
    };
    default {
        diag_log format ["DEP: Unknown map %1. Attempting to set default values...", worldName];
        
        // Attempt to get map center from config file
        if (isNil "dep_map_center") then { dep_map_center  = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition"); };
        if (typeName dep_map_center != "ARRAY") exitWith 
        { 
            diag_log "DEP INIT FAILED: Could not detect world center.";
            dep_ready = false;
            publicVariable "dep_ready";
        };
        
        if (isNil "dep_housepop")   then { dep_housepop    = round (0.0052 * (dep_map_center select 0)); };
        if (isNil "dep_roadblocks") then { dep_roadblocks  = round (0.0011 * (dep_map_center select 0)); };
        if (isNil "dep_aa_camps")   then { dep_aa_camps    = round (0.0011 * (dep_map_center select 0)); };
        if (isNil "dep_patrols")    then { dep_patrols     = round (0.0013 * (dep_map_center select 0)); };
        if (isNil "dep_bunkers")    then { dep_bunkers     = round (0.0026 * (dep_map_center select 0)); };
        if (isNil "dep_military")   then { dep_military    = round (0.0008 * (dep_map_center select 0)); };
        if (isNil "dep_ambushes")   then { dep_ambushes    = round (0.0004 * (dep_map_center select 0)); };
    };
};
dep_map_radius  = ceil (sqrt (((dep_map_center select 0) ^ 2) + ((dep_map_center select 1) ^ 2)));