/*
 * Name: Hyperspace Hotel
 * Author: Kelly
 * Date: 2021-07-07
 * Description: A system to load any sort of room prefab into the middle of nowhere.
 * 
 * Kinda like hilbert's hotel, but better, because I made it.
 *
 *  */

/obj/effect/hotel_access_point
	name = "hotel access point"
	desc = "A handy link between here and there. Where is there? And how do you get there? That's for you to decide!"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "hilbertshotel"

/obj/effect/hotel_access_point/attack_hand(mob/user, act_intent, attackchain_flags)
	SShotel.ClickedThing(user, src)








