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

dep_side        = independent;             // Enemy side (east, west, independent)
dep_despawn     = 1;//5;                // Despawn location after x minutes inactivity
dep_debug       = DEBUG;            // Enable debug
dep_max_ai_loc  = 10;               // Maximum AI per location
dep_max_ai_tot  = 300;              // Maximum AI in total
dep_act_dist    = 800;//PAR_ACT_DIST;     // Location activation distance
//dep_act_height  = 80;               // Player must be below this height to activate location
//dep_act_speed   = 160;              // Player must be below this speed to activate location
//dep_roadblocks  = 10;               // Number of roadblocks
//dep_aa_camps    = 10;               // Number of AA camps
//dep_housepop    = 100;//PAR_DENSITY;      // Number of road population
dep_safe_zone   = getMarkerPos "respawn_west";    // Safe zone position
dep_safe_rad    = 800;                            // Safe zone radius
dep_max_veh     = 6;                // Max number of vehicles
dep_ied_chance  = 0.9;              // Chance of IEDs
dep_veh_chance  = 0.3;              // Chance of vehicles
dep_cr_ied      = false;            // Restrict disarming IED to explosives class
//dep_unit_init   = "[_this] execVM ""unitinit.sqf""; ";
//dep_useheadless = false;
//dep_headlessclient = "";
dep_allow_mortars = false;
dep_civilians = true;

// Military forces
dep_u_soldier       = "CUP_I_GUE_Soldier_AKSU";        // Soldier
dep_u_gl            = "CUP_I_GUE_Soldier_GL";     // Grenade launcher
dep_u_ar            = "CUP_I_GUE_Soldier_MG";     // Assault rifle
dep_u_at            = "CUP_I_GUE_Soldier_AT";    // Anti tank
dep_u_medic         = "CUP_I_GUE_Medic";          // Medic
dep_u_aa            = "CUP_I_GUE_Soldier_AA";     // Anti air
dep_u_aaa           = "CUP_I_GUE_Soldier_AA";    // Assistant anti air
dep_u_sl            = "CUP_I_GUE_Officer";     // Squad leader
dep_u_marksman      = "CUP_I_GUE_Soldier_Scout";      // Marksman
dep_u_sniper        = "CUP_I_GUE_Sniper";         // Sniper
dep_u_veh_cmnd      = "CUP_I_GUE_Officer";      // Vehicle commander
dep_u_veh_crew      = "CUP_I_GUE_Crew";      // Vehicle crew

// Guerilla forces
 dep_u_g_soldier     = "CUP_I_TK_GUE_Soldier";      // Soldier
 dep_u_g_gl          = "CUP_I_TK_GUE_Soldier_GL";   // Grenade launcher
 dep_u_g_ar          = "CUP_I_TK_GUE_Soldier_AR";   // Assault rifle
 dep_u_g_at          = "CUP_I_TK_GUE_Soldier_AT";  // Anti tank
 dep_u_g_medic       = "CUP_I_TK_GUE_Guerilla_Medic";        // Medic
 dep_u_g_sl          = "CUP_I_TK_GUE_Soldier_TL";   // Squad leader
 dep_u_g_marksman    = "CUP_I_TK_GUE_Sniper";    // Marksman