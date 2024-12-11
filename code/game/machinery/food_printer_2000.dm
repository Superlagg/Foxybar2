/obj/structure/food_printer
	name = "GekkerTec FoodFox 2000"
	desc = "A high-tech kitchen appliance that can produce a variety of food items. For free! Live! Over the internet!"
	icon = 'icons/obj/food_printer.dmi'
	icon_state = "default"
	density = TRUE
	/// the food menu to use
	var/datum/food_menu/menu
	/// currently selected output
	var/datum/weakref/foutput
	/// list of food items to be printed
	var/list/worklist = list()
	var/working = FALSE
	var/paused = FALSE
	var/datum/looping_sound/foodprinter_1/sl_1
	var/datum/looping_sound/foodprinter_2/sl_2
	var/target_beacon
	var/last_new_beacon = 0
	var/list/usage_log = list()

	var/obj/item/pda/moviefone

/obj/structure/food_printer/Initialize()
	. = ..()
	menu = SSfood_printer.food_menu
	GeneratePDA()
	new /obj/item/foodprinter_output_beacon(GetNearestTable(src, 2, TRUE))
	sl_1 = new /datum/looping_sound/foodprinter_1(list(src), FALSE)
	sl_2 = new /datum/looping_sound/foodprinter_2(list(src), FALSE)
	START_PROCESSING(SSfood_printer, src)

/obj/structure/food_printer/Destroy()
	. = ..()
	CancelAllOrders()
	QDEL_NULL(moviefone)
	STOP_PROCESSING(SSfood_printer, src)

/obj/structure/food_printer/proc/GeneratePDA()
	if(moviefone)
		return
	moviefone = new /obj/item/pda(src)
	moviefone.owner = "GekkerTec FoodFox 2000 \[0x[random_color()]\]"
	moviefone.ttone = "Ack-Ack!"
	moviefone.forward_to = WEAKREF(src)

/obj/structure/food_printer/proc/AddPrintJob(FoodKey, amount, mob/user)
	if(!menu)
		return
	var/datum/food_menu_entry/food = menu.foods[FoodKey]
	if(!food)
		return
	var/datum/food_printer_workorder/work = new /datum/food_printer_workorder(src)
	work.SetMenuItem(food, amount)
	work.SetOutput(target_beacon)
	worklist += work
	say("Okay! [work.printing.name] is being printed! It will be ready in about [work.GetTimeLeftString()]!", just_chat = TRUE)
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	LogFoodPrint(work, user)
	if(LAZYLEN(worklist) == 1)
		update_static_data(user)

/obj/structure/food_printer/proc/BeaconKey2Output(beacon_key)
	var/obj/item/foodprinter_output_beacon/beac = LAZYACCESS(SSfood_printer.food_printer_outputs, beacon_key)
	if(!beac)
		return GetNearestTable(src, 2, TRUE)
	return beac.GetOutput(src, null)

/obj/structure/food_printer/proc/StartWorking()
	working = TRUE
	sl_1.start()
	sl_2.start()

/obj/structure/food_printer/proc/StopWorking()
	working = FALSE
	sl_1.stop()
	sl_2.stop()

/obj/structure/food_printer/proc/WorkFinished(datum/food_printer_workorder/work, success)
	worklist -= work
	qdel(work)
	if(LAZYLEN(worklist))
		return
	StopWorking()
	if(success)
		FinishedEverything()

/obj/structure/food_printer/proc/FinishedEverything()
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	say("All done!")

/// the loop that goes through all the work orders and works on them, one by one
/obj/structure/food_printer/process()
	if(paused)
		return
	var/datum/food_printer_workorder/work = LAZYACCESS(worklist, 1)
	if(work)
		if(!working)
			StartWorking()
		if(!work.in_progress)
			work.Start()
		work.TickTime()
		if(work.timeleft <= 0)
			work.Stop()
			FinalizeWork(work)
		return
	else
		if(working)
			StopWorking()

/obj/structure/food_printer/proc/CancelOrder(FoodKey)
	for(var/datum/food_printer_workorder/work in worklist)
		if(work.mytag == FoodKey)
			say("Okay! [work.printing.name] is no longer being printed!")
			playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
			work.Stop()
			WorkFinished(work, FALSE)

/obj/structure/food_printer/proc/CancelAllOrders()
	for(var/datum/food_printer_workorder/work in worklist)
		work.Stop()
		WorkFinished(work, null)
	say("Okay! All orders cancelled!")
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)

/obj/structure/food_printer/proc/TogglePause()
	paused = !paused
	if(paused)
		say("Okay! Pausing all orders!")
		playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	else
		say("Okay! Resuming all orders!")
		playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
	
/obj/structure/food_printer/proc/SetTargetBeacon(beacon_key)
	if(SSfood_printer.food_printer_outputs[beacon_key])
		target_beacon = beacon_key
	else
		target_beacon = null
	
/obj/structure/food_printer/proc/MakeNewBeacon()
	if(world.time < last_new_beacon + (5 SECONDS))
		say("Hold your horses! I'm still looking for another beacon!")
		playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
		return
	last_new_beacon = world.time
	new /obj/item/foodprinter_output_beacon(GetNearestTable(src, 2, TRUE))
	say("A new beacon has been created! Be sure to name it!")
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)

/obj/structure/food_printer/proc/LogFoodPrint(datum/food_printer_workorder/work, mob/user)
	if(!user)
		return
	var/log = list()
	log["Time"] = world.time
	log["User"] = user.ckey
	log["FoodKey"] = work.printing.food_key
	log["Amount"] = work.amt
	log["Beacon"] = work.output_tag
	var/atom/dest = GET_WEAKREF(work.foutput)
	if(isbelly(dest)) // mainly for this, in case people send un-asked-for things to someone's voregan
		log["IsBelly"] = TRUE
	else
		log["IsBelly"] = FALSE
	usage_log += list(log)

/obj/structure/food_printer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "FoodPrinter")
		ui.open()

/// our stuff thats constantly changing!
/obj/structure/food_printer/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/workdata = list()
	for(var/datum/food_printer_workorder/work in worklist)
		workdata += list(work.data_for_tgui())
	data["WorkOrders"] = workdata
	var/list/beacons = list()
	for(var/beacid in SSfood_printer.food_printer_outputs)
		var/obj/item/foodprinter_output_beacon/beac = SSfood_printer.food_printer_outputs[beacid]
		beacons += "[beac.beacon_name]QOSXZOVVVZZZZZZHHHHH&!&!&!&!&![beac.beacon_id]"
	beacons = sort_list(beacons)
	var/list/truebeacons = list()
	for(var/bacon in beacons)
		var/list/beac = splittext(bacon, "QOSXZOVVVZZZZZZHHHHH&!&!&!&!&!") // im coder
		var/list/beacdat = list()
		beacdat["DisplayName"] = beac[1]
		beacdat["BeaconID"] = beac[2]
		truebeacons += list(beacdat)
	data["Beacons"] = truebeacons
	data["SelectedBeacon"] = target_beacon
	return data

/// The menu!
/obj/structure/food_printer/ui_static_data(mob/user)
	var/list/data = list()
	data["EntriesPerPage"] = SSfood_printer.entries_per_page
	data["FoodMenuList"] = menu.TGUI_chunk
	data["FullFoodMenu"] = menu.full_TGUI_chunk
	data["CoolTip"] = pick(SSfood_printer.tips)
	data["Tagline"] = pick(SSfood_printer.taglines)
	return data

/obj/structure/food_printer/ui_act(action, params)
	. = ..()
	var/mob/user = usr
	switch(action)
		if("PrintFood")
			var/datum/food_menu_entry/food = menu.foods[params["FoodKey"]]
			if(!food)
				say("Oh! I can't seem to find that recipe! Maybe it's expired?")
				playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 50, TRUE)
				return
			var/howmany = numberfy(params["Amount"])
			howmany = clamp(howmany, 1, SSfood_printer.max_food_print)
			AddPrintJob(food.food_key, howmany, user)
		if("CancelOrder")
			CancelOrder(params["FoodKey"])
		if("CancelAllOrders")
			CancelAllOrders()
		if("Pause")
			TogglePause()
		if("SetTargetBeacon")
			SetTargetBeacon(params["BeaconKey"])
		if("NewBeacon")
			MakeNewBeacon()

/obj/structure/food_printer/proc/FinalizeWork(datum/food_printer_workorder/work)
	if(!work || !work.printing)
		return
	var/turf/dest = get_turf(src)
	if(!dest)
		return
	var/turf/first_dest = GetNearestTable(dest, 2, TRUE)
	var/is_tele
	// worklist's output thing can be a beacon ID, an atom, or nothing at all!
	var/b_id = work.output_tag
	if(b_id)
		var/obj/item/foodprinter_output_beacon/beac = SSfood_printer.food_printer_outputs[b_id]
		if(beac)
			dest = beac.GetOutput(src, work.printing)
			is_tele = TRUE
	else if(isweakref(work.foutput))
		var/atom/thing = GET_WEAKREF(work.foutput)
		if(thing)
			dest = thing
			if(get_dist(dest, get_turf(src)) > 2)
				is_tele = TRUE
	else if(isatom(work.foutput))
		var/atom/thing = work.foutput
		dest = thing
		if(get_dist(dest, get_turf(src)) > 2)
			is_tele = TRUE
	else
		dest = GetNearestTable(dest, 5, TRUE)
		if(get_dist(dest, get_turf(src)) > 2)
			is_tele = TRUE

	var/isvore = isbelly(dest)
	if(!isvore)
		dest = get_turf(dest)
	var/quiet = FALSE
	for(var/i in 1 to work.amt)
		var/obj/item/food
		if(is_tele)
			food = new work.printing.itempath(first_dest)
			TeleportFood(food, dest, quiet)
			quiet = TRUE
		else
			food = new work.printing.itempath(first_dest)
			food.forceMove(dest)
	if(isvore)
		var/obj/vore_belly/belly = dest
		var/mob/owner = belly.owner
		to_chat(owner, span_notice("Oh! Something just appeared in your [belly.name]!"))
	LogFoodPrint(work)
	WorkFinished(work, TRUE)
	playsound(src, 'sound/weapons/energy_chargedone_ding.ogg', 95, TRUE)

/obj/structure/food_printer/proc/TeleportFood(atom/movable/food, atom/put_herre, silent)
	if(!food)
		return
	if(!silent)
		playsound(get_turf(food), 'sound/effects/claim_thing.ogg', 100)
		playsound(get_turf(put_herre), 'sound/effects/claim_thing.ogg', 100)
	var/obj/effect/afterimage = new(get_turf(food))
	food.forceMove(put_herre)

	/// image of the food item teleporting out
	afterimage.appearance = food.appearance
	var/matrix/M = food.transform.Scale(1, 3)
	animate(afterimage, transform = M, pixel_y = 32, time = 10, alpha = 50, easing = CIRCULAR_EASING, flags=ANIMATION_PARALLEL)
	M.Scale(0,4)
	animate(transform = M, time = 5, color = "#1111ff", alpha = 0, easing = CIRCULAR_EASING)
	QDEL_IN(afterimage, 2 SECONDS)



/datum/food_printer_workorder
	var/datum/food_menu_entry/printing
	var/datum/weakref/printer
	var/datum/weakref/foutput
	var/output_tag
	var/totaltime = 1
	var/timeleft = 0
	var/last_tick = 0
	var/in_progress = FALSE
	var/amt = 1
	var/mytag
	var/ckeywhodidit
	var/quidwhodidit

/datum/food_printer_workorder/New(obj/structure/food_printer)
	mytag = "FUPA-[rand(1000,9999)]-[rand(1000,9999)]-BEPIS"
	printer = WEAKREF(food_printer)
	. = ..()

/datum/food_printer_workorder/Destroy()
	. = ..()
	printing = null
	printer = null
	foutput = null
	Stop()

/datum/food_printer_workorder/proc/SetMenuItem(datum/food_menu_entry/food, amount)
	printing = food
	amt = clamp(amount, 1, SSfood_printer.max_food_print)
	timeleft = printing.print_time
	if(amt > 1)
		// extra items take longer to print, but not linearly
		timeleft = timeleft * sqrt(amt) // sure
	totaltime = max(timeleft, 1) // i fear division by zero

/datum/food_printer_workorder/proc/SetOutput(atom/dest)
	if(isatom(dest))
		foutput = GET_WEAKREF(dest)
		output_tag = null
	else
		var/obj/item/foodprinter_output_beacon/beac = SSfood_printer.food_printer_outputs[dest]
		if(beac)
			foutput = GET_WEAKREF(beac)
			output_tag = beac.beacon_id
		else
			foutput = null
			output_tag = null

/datum/food_printer_workorder/proc/Start()
	in_progress = TRUE

/datum/food_printer_workorder/proc/Stop()
	in_progress = FALSE

/datum/food_printer_workorder/proc/GetTimeLeft()
	return timeleft

/datum/food_printer_workorder/proc/GetTimeLeftString()
	var/timeleft = GetTimeLeft()
	return DisplayTimeText(timeleft, 0.1, TRUE, TRUE)

/datum/food_printer_workorder/proc/GetTimeLeftPercent()
	var/timeleft = GetTimeLeft()
	return 100 - ((timeleft / totaltime) * 100)

/datum/food_printer_workorder/proc/TickTime()
	if(!last_tick)
		last_tick = world.time
		return
	var/now = world.time
	var/delta = now - last_tick
	last_tick = now
	timeleft -= delta
	if(timeleft <= 0)
		timeleft = 0

/datum/food_printer_workorder/proc/data_for_tgui()
	var/list/data = list()
	data["Name"] = printing.name || "Food"
	data["Description"] = printing.desc || "No description available."
	data["OutputTag"] = output_tag || "Right here!"
	data["TimeLeft"] = GetTimeLeftString()
	data["TimeLeftPercent"] = GetTimeLeftPercent()
	data["Amount"] = amt
	data["MyTag"] = mytag
	return data

//////////////////////////////////////////////////////////////////////
// Food Beacon - The Beacon of the Future ////////////////////////////
/obj/item/foodprinter_output_beacon
	name = "Food Beacon"
	desc = "This thing is used by the GekkerTec FoodFox 2000 to deliver food items. \
		That's right, the GekkerTec FoodFox 2000 will teleport food to you, any time, \
		any place! For free! Live! Over the internet!\n\
		\n\
		To use, squeeze (click) it in hand, then select a helpful name that the GekkerTec FoodFox 2000 will use to identify it. \
		Then, have whoever's using the GekkerTec FoodFox 2000 select the beacon in the food printer's output menu. \
		Then, the GekkerTec FoodFox 2000 will teleport whatever it prints out to the beacon's location."
	icon = 'icons/obj/food_printer.dmi'
	icon_state = "beacon"
	var/beacon_name = "Bepis"
	var/beacon_id = "BEPIS"

/obj/item/foodprinter_output_beacon/Initialize()
	. = ..()
	RandomName()
	RandomID()
	SSfood_printer.food_printer_outputs[beacon_id] = src

/obj/item/foodprinter_output_beacon/Destroy()
	. = ..()
	SSfood_printer.food_printer_outputs -= beacon_id

/obj/item/foodprinter_output_beacon/attack_self(mob/user)
	. = ..()
	SetName(user)

/obj/item/foodprinter_output_beacon/proc/RandomID()
	beacon_id = "CHIARA-[rand(1000,9999)]-IS-[rand(1000,9999)]-FAT-[rand(1000,9999)]"

/obj/item/foodprinter_output_beacon/proc/SetName(mob/setter)
	if(!setter || !setter.client)
		return RandomName()
	var/newname = input(
		setter,
		"Enter a name for the beacon. This is what will show up in the GekkerTec FoodFox 2000's output menu, so make it something helpful, like your name, or some kind of big shark! 64 characters max, please!",
		"Name 4 Me",
		"[beacon_name]") as text|null
	if(isnull(newname))
		return
	if(!newname)
		RandomName()
	else
		beacon_name = copytext(newname, 1, 64)
	UpdateName()
	to_chat(setter, span_notice("The beacon's name has been set to [beacon_name]."))

/obj/item/foodprinter_output_beacon/proc/RandomName()
	beacon_name = "[safepick(GLOB.megacarp_first_names)] [safepick(GLOB.megacarp_last_names)]"
	UpdateName()

/obj/item/foodprinter_output_beacon/proc/UpdateName()
	name = "[initial(name)] - '[beacon_name]'"

/obj/item/foodprinter_output_beacon/proc/GetOutput(mob/printer, obj/item/food)
	if(isturf(loc))
		return loc
	if(isbelly(loc))
		return loc // =3
	if(SEND_SIGNAL(loc, COMSIG_CONTAINS_STORAGE)) // try and stuff it in there
		if(SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_CAN_INSERT, food, printer, TRUE))
			return loc
	return GetNearestTable(get_turf(src), 5)

/proc/GetNearestTable(atom/place, maxdist = 5, torf)
	if(!place)
		return
	var/list/tables = list()
	for(var/obj/structure/table/T in view(maxdist, get_turf(place)))
		tables += T
	if(!tables)
		return torf ? get_turf(place) : place
	var/closest_dist = 999999
	var/obj/structure/table/closest_table
	for(var/obj/structure/table/T in tables)
		var/dist = GET_DIST_EUCLIDEAN(place, T)
		if(dist < closest_dist)
			closest_dist = dist
			closest_table = T
	if(closest_table)
		if(torf)
			return get_turf(closest_table)
		return closest_table
	return torf ? get_turf(place) : place






















