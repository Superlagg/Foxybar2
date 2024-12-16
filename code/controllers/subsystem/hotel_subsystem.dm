SUBSYSTEM_DEF(hotel)
	name = "Hotel"
	init_order = INIT_ORDER_HOLODECK
	var/list/room_prefabs = list()
	var/list/existing_rooms = list()

/datum/controller/subsystem/hotel/Initialize(start_timeofday)
	. = ..()
	

