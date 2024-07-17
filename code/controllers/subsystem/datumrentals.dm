/* 
 * File:   datumrentals.dm
 * Date:   13/13/2013
 * License: rent to own
 * 
 * Purpose: A handy library system to hold all the wierd temporary data packets that would
 *          otherwise be sent as a dozen or so args and misc data lists
 *          As we all know, anything a frickhuge list or mass of args can do, a datum can do better.
 *          A proc can check out a datum, fill it with data, pass it around like the town bicycle, and then
 *          check it back in when it's done.
 *          They're generally intended to only be used for at most a second or two, otherwise you're not renting, you're buying.
 *          Which, fine, you can keep it, but really at that point you should just give it its own home.
 *          If we need a datum, but none are available, we can create a new one, but we should always check it back in.
 *          The checkin process is so that the datum can be recycled and reused, cus we're all about recycling here.
 *          Save the datums, nuke the whales.
 * */

SUBSYSTEM_DEF(rentaldatums)
	name = "RentalDatums"
	flags = SS_TICKER
	wait = 1 MINUTE
	init_order = INIT_ORDER_RENTALS

	var/list/mommies = list()

	/// now for the rental mommies
	var/list/chat_datums = list()
	var/chat_uses_mommy = TRUE


/datum/controller/subsystem/rentaldatums/Initialize(start_timeofday)
	init_datums()
	. = ..()

/datum/controller/subsystem/rentaldatums/proc/init_datums()
	// 

/datum/controller/subsystem/rentaldatums/proc/CheckoutMommy(mom)
	var/list/mymom = LAZYACCESS(vars, mom)
	if(!mymom)
		return null
	for(var/datum/rental_mommy/mommy in mommies)
		if(mommy.available)
			mommy.checkout()
			return mommy
	var/datum/rental_mommy/mommy = LAZYACCESS(mymom, 1) // there will always be at least one mommy
	var/datum/rental_mommy/mommy2 = new mommy.path()
	mymom += mommy2
	mommy2.checkout()
	return mommy2

/datum/rental_mommy // hey isnt that your mom?
	/// Is your mom available?
	var/available = TRUE
	/// The number of tally marks sharpied on your mom's butt that denotes how many times she's been "rented"
	var/uses = 0

/datum/rental_mommy/proc/checkout()
	available = FALSE
	uses += 1

/datum/rental_mommy/proc/checkin()
	wipe()
	available = TRUE

/datum/rental_mommy/proc/wipe()
	return

/datum/rental_mommy/proc/copy_mommy(datum/rental_mommy/mommy)
	if(mommy.type != type)
		return
	for(var/V in vars)
		if(V == "vars")
			continue
		vars[V] = mommy.vars[V]

/// Charlotte, chat's rental mommy
/// Holds a dynamic glob of chat data that can be easily manipulated and passed around
/// She loves it
/datum/rental_mommy/chat
	var/original_message = ""
	var/message = ""
	var/original_speakername = ""
	var/speakername = ""
	var/atom/source
	var/message_mode
	var/message_key
	var/list/spans = list()
	var/sanitize
	var/bubble_type = null
	var/datum/language/language
	var/language_key
	var/datum/saymode/saymode
	var/ignore_spam
	var/forced
	var/only_overhead
	var/is_radio
	var/radio_freq
	var/close_message_range = 7
	var/far_message_range = 15
	/// Stuff to put to the left of the inner body of the message
	var/list/msg_decor_left = list()
	/// Stuff to put to the right of the inner body of the message
	var/list/msg_decor_right = list()
	/// for ventriloquist dolls to prevent the player from saying whatever it is they're saying, 
	/// and for the doll to say it instead
	var/no_pass
	/// SHOULD THE MESSAGE BE RENDERED IN ALL CAPS???????????????
	var/ALL_CAPS

