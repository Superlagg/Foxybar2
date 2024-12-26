/* 
 * File:   hotel_room_data.dm
 * Author: Kelly
 * Date: 2021-07-07
 * Description: A datum assigned to a hotel room that holds all the cool data about it.
 * 
 * Contains the following:
 * - Room ID (internal)
 * - Room name
 * - Room description
 * - Room prefab path
 * - Owner name (if applicable)
 * - Owner key (if applicable)
 * - Whether or not it was spawned by the game or a player
 * - Its visibility on the list
 * - Who can access it
 * - How people can access it (key, password, etc)
 * - Who to contact for access
 * 
 *  */

// Room data
/datum/hotel_room_data
	var/owner_name = ""
	var/owner_key = ""
	var/room_id = ""
	var/room_name = ""
	var/room_description = ""
	var/room_prefab_key = ""
	var/area/my_area
	var/spawn_x = 0
	var/spawn_y = 0
	var/spawned_by_player = FALSE
	var/visible_on_list = TRUE
	var/access_style = HOTEL_UNLOCKED
	var/list/whitelist = list()
	var/list/blacklist = list()

















