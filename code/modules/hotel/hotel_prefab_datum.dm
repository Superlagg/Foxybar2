/* 
 * File:   hotel_prefab_datum.dm
 * Author: Kelly
 * Date: 2021-07-07
 * License: WWW.PLAYAPOCALYPSE.COM
 * 
 * Description: A datum that holds all the interesting data about a hotel prefab.
 * 
 * Contains the following:
 * - Map template datum
 * - data from the datum
 * - Parsed map landmarks
 * 
 *  */

/datum/hotel_prefab
	var/datum/map_template/map_template
	var/list/spawn_offsets


/datum/hotel_prefab/proc/GetSpawnOffsets(datum/turf_reservation/trev)
	if(!trev)
		return list(3, 9) // Default spawn offsets?
	if(!islist(spawn_offsets))
		ParseReservation(trev)
	return spawn_offsets

/// takes in a turf reservation and looks for all the relevant stuff
/datum/hotel_prefab/proc/ParseReservation(datum/turf_reservation/trev)
	var/turf/BL = locate(trev.bottom_left_coords[1], trev.bottom_left_coords[2], trev.bottom_left_coords[3])
	var/turf/TR = locate(trev.top_right_coords[1], trev.top_right_coords[2], trev.top_right_coords[3])
	var/list/reserved = block(BL, TR)
	spunk:
	for(var/turf/T in reserved)
		var/relative_x = T.x - BL.x
		var/relative_y = T.y - BL.y
		for(var/obj/effect/landmark/hotel_landmark/L in T)
			if(L)
				spawn_offsets = list(relative_x, relative_y)
				break spunk // ew










	if(activeRooms.len)
		for(var/x in activeRooms)
			var/datum/turf_reservation/room = activeRooms[x]
			for(var/i=0, i<hotelRoomTemp.width, i++)
				for(var/j=0, j<hotelRoomTemp.height, j++)
					for(var/atom/movable/A in locate(room.bottom_left_coords[1] + i, room.bottom_left_coords[2] + j, room.bottom_left_coords[3]))
						if(ismob(A))
							var/mob/M = A
							if(M.mind)
								to_chat(M, "<span class='warning'>As the sphere breaks apart, you're suddenly ejected into the depths of space!</span>")
						var/max = world.maxx-TRANSITIONEDGE
						var/min = 1+TRANSITIONEDGE
						var/list/possible_transtitons = list()
						for(var/AZ in SSmapping.z_list)
							var/datum/space_level/D = AZ
							if (D.linkage == CROSSLINKED)
								possible_transtitons += D.z_value
						var/_z = pick(possible_transtitons)
						var/_x = rand(min,max)
						var/_y = rand(min,max)
						var/turf/T = locate(_x, _y, _z)
						A.forceMove(T)
			qdel(room)








