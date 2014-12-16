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

        This is the settings file for DEP. Edit to your own liking.
        If a setting is commented out, default values will be used.
*/

// dep_side        = independent;                  // Enemy side (east, west, independent)
// dep_despawn     = 10;                           // Despawn location after x minutes inactivity
// dep_debug       = true;                         // Enable debug
// dep_max_ai_loc  = 10;                           // Maximum AI per location
// dep_max_ai_tot  = 200;                          // Maximum AI in total
// dep_act_dist    = 800;                          // Location activation distance
// dep_act_height  = 80;                           // Player must be below this height to activate location
// dep_act_speed   = 160;                          // Player must be below this speed to activate location
// dep_roadblocks  = 10;                           // Number of roadblocks
// dep_aa_camps    = 10;                           // Number of AA camps
// dep_housepop    = 100;                          // Number of road population
// dep_safe_zone   = getMarkerPos "respawn_west";  // Safe zone position
// dep_safe_rad    = 800;                          // Safe zone radius
// dep_max_veh     = 6;                            // Max number of vehicles
// dep_ied_chance  = 0.7;                          // Chance of IEDs
// dep_veh_chance  = 0.3;                          // Chance of vehicles
// dep_cr_ied      = true;                         // Restrict disarming IED to explosives class
// dep_unit_init   = "";                           // Code to execute on every spawned unit's init
// dep_useheadless = false;                        // When true DEP is ran on the Headless Client instead of the server
// dep_allow_mortars = true;                       // When false stops players from using mortars spawned by DEP

// Military forces
// dep_u_soldier       = "I_soldier_F";        // Soldier
// dep_u_gl            = "I_Soldier_GL_F";     // Grenade launcher
// dep_u_ar            = "I_Soldier_AR_F";     // Assault rifle
// dep_u_at            = "I_Soldier_LAT_F";    // Anti tank
// dep_u_medic         = "I_medic_F";          // Medic
// dep_u_aa            = "I_Soldier_AA_F";     // Anti air
// dep_u_aaa           = "I_Soldier_AAA_F";    // Assistant anti air
// dep_u_sl            = "I_Soldier_SL_F";     // Squad leader
// dep_u_marksman      = "I_soldier_M_F";      // Marksman
// dep_u_sniper        = "I_Sniper_F";         // Sniper

// Guerilla forces
// dep_u_g_soldier     = "I_G_Soldier_F";      // Soldier
// dep_u_g_gl          = "I_G_Soldier_GL_F";   // Grenade launcher
// dep_u_g_ar          = "I_G_Soldier_AR_F";   // Assault rifle
// dep_u_g_at          = "I_G_Soldier_LAT_F";  // Anti tank
// dep_u_g_medic       = "I_G_medic_F";        // Medic
// dep_u_g_sl          = "I_G_Soldier_SL_F";   // Squad leader
// dep_u_g_marksman    = "I_G_Soldier_M_F";    // Marksman