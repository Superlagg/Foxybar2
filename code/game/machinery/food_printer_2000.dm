GLOBAL_DATUM_INIT(food_menu, /datum/food_menu, new())
GLOBAL_LIST_EMPTY(food_printer_outputs)

/obj/structure/food_printer
	name = "GekkerTec TurboKitchen 2000"
	desc = "A high-tech kitchen appliance that can produce a variety of food items. For free! Live! Over the internet!"
	icon_state = "autolathe"
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

/obj/structure/food_printer/Initialize()
	. = ..()
	menu = GLOB.food_menu
	new /obj/item/foodprinter_output_beacon(get_turf(src))
	sl_1 = new /datum/looping_sound/foodprinter_1(list(src), FALSE)
	sl_2 = new /datum/looping_sound/foodprinter_2(list(src), FALSE)
	START_PROCESSING(SSfastprocess, src)

/obj/structure/food_printer/Destroy()
	. = ..()
	for(var/datum/food_printer_workorder/work in worklist)
		work.Cancel()
		qdel(work)
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/food_printer/proc/AddPrintJob(FM_key, beacon_key)
	if(!menu)
		return
	var/datum/food_menu_entry/food = menu.foods[FM_key]
	if(!food)
		return
	var/obj/item/foodprinter_output_beacon/foutput = BeaconKey2Output(beacon_key)
	var/datum/food_printer_workorder/work = new /datum/food_printer_workorder(food, src, foutput)
	worklist += work

/obj/structure/food_printer/proc/BeaconKey2Output(beacon_key)
	for(var/obj/item/foodprinter_output_beacon/beac in GLOB.food_printer_outputs)
		if(beac.beacon_name == beacon_key)
			return beac

/obj/structure/food_printer/proc/StartWorking()
	working = TRUE
	sl_1.start()
	sl_2.start()

/obj/structure/food_printer/proc/StopWorking()
	working = FALSE
	sl_1.stop()
	sl_2.stop()

/obj/structure/food_printer/proc/WorkFinished(datum/food_printer_workorder/work, obj/item/food)
	worklist -= work
	qdel(work)
	if(!LAZYLEN(worklist))
		StopWorking()
		FinishedEverything()

/obj/structure/food_printer/proc/FinishedEverything()
	playsound(src, 'sound/machines/moxi/moxi_hi.ogg', 65, TRUE)
	say("All done!")

/// the loop that goes through all the work orders and works on them, one by one
/obj/structure/food_printer/process()
	var/datum/food_printer_workorder/work = LAZYACCESS(worklist, 1)
	if(!work) // no work to do
		if(working)
			StopWorking()
		return
	if(!working)
		StartWorking()
	if(!work.in_progress)
		work.Start()

/obj/structure/food_printer/proc/CancelOrder(FM_key)
	for(var/datum/food_printer_workorder/work in worklist)
		if(work.printing.food_key == FM_key)
			work.Cancel()
			WorkFinished(work, null)

/obj/structure/food_printer/proc/CancelAllOrders()
	for(var/datum/food_printer_workorder/work in worklist)
		work.Cancel()
		WorkFinished(work, null)

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
	// beacons["Right Here"] = "NONE"
	for(var/obj/item/foodprinter_output_beacon/beac in GLOB.food_printer_outputs)
		beacons += "[beac.beacon_name]QOSXZOVVVZZZZZZHHHHH&!&!&!&!&![beac.beacon_id]"
	beacons = sort_list(beacons)
	var/list/truebeacons = list()
	for(var/bacon in beacons)
		var/list/beac = bacon.splittext("QOSXZOVVVZZZZZZHHHHH&!&!&!&!&!") // im coder
		truebeacons["[beac[1]]"] = "[beac[2]]"
	data["Beacons"] = truebeacons
	return data

/// The menu!
/obj/structure/food_printer/ui_static_data(mob/user)
	var/list/data = list()
	data["FoodMenu"] = menu.TGUI_chunk
	return data

/obj/structure/food_printer/ui_act(action, params)
	. = ..()
	










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

/datum/food_printer_workorder/New(datum/food_menu_entry/food, obj/structure/food_printer/printer, obj/item/foodprinter_output_beacon/foutput, amt)
	. = ..()
	printing = food
	src.printer = WEAKREF(printer)
	if(foutput)
		src.foutput = WEAKREF(foutput)
		if(foutput.beacon_name)
			src.output_tag = foutput.beacon_name
	amt = max(amt, 1)
	timeleft = printing.print_time
	if(amt > 1)
		// logarythmic scaling of time based on amount
		var/amtscalar = log(amt, 2) / 2
		timeleft = round(timeleft * amtscalar)
	totaltime = max(timeleft, 1) // i fear division by zero
	mytag = "FUPA-[rand(1000,9999)]-[rand(1000,9999)]-BEPIS"

/datum/food_printer_workorder/Destroy()
	. = ..()
	Cancel()

/datum/food_printer_workorder/proc/Start()
	START_PROCESSING(SSfastprocess, src)

/datum/food_printer_workorder/process()
	TickTime()
	if(timeleft <= 0)
		Finish()
		return PROCESS_KILL

/datum/food_printer_workorder/proc/Finish()
	STOP_PROCESSING(SSfastprocess, src)
	var/obj/structure/food_printer/print = GET_WEAKREF(printer)
	if(!print)
		return
	var/atom/herefirst = GetNearestTable(get_turf(print), 5)
	var/list/foodz = list()
	for(var/i in 1 to amt)
		var/obj/item/food = new printing.itempath(get_turf(herefirst))
		foodz += food
	do_sparks(1, TRUE, herefirst, /datum/effect_system/spark_spread/quantum)
	/// food printed, now put it somewhere
	if(!foutput)
		return TRUE // all done!
	var/obj/item/foodprinter_output_beacon/beac = GET_WEAKREF(foutput)
	var/atom/put_herre
	if(beac)
		put_herre = beac.GetOutput(print, printing)
	else if(print)
		put_herre = GetNearestTable(get_turf(print), 5)
	else // fallback, stick it somewhere idk
		put_herre = get_turf(safepick(GLOB.player_list))
	do_sparks(1, TRUE, put_herre, /datum/effect_system/spark_spread/quantum)
	playsound(put_herre, 'sound/effects/claim_thing.ogg', 65, TRUE)
	playsound(herefirst, 'sound/effects/claim_thing.ogg', 65, TRUE)
	for(var/obj/item/food in foodz)
		food.forceMove(get_turf(put_herre))
	print.WorkFinished(src, foodz)
	return TRUE

/datum/food_printer_workorder/proc/Cancel()
	STOP_PROCESSING(SSfastprocess, src)
	return TRUE

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
	desc = "This thing is used by the GekkerTec TurboKitchen 2000 to deliver food items. \
		That's right, the GekkerTec TurboKitchen 2000 will teleport food to you, any time, \
		any place! For free! Live! Over the internet!\n\
		\n\
		To use, squeeze (click) it in hand, then select a helpful name that the GekkerTec TurboKitchen 2000 will use to identify it. \
		Then, have whoever's using the GekkerTec TurboKitchen 2000 select the beacon in the food printer's output menu. \
		Then, the GekkerTec TurboKitchen 2000 will teleport whatever it prints out to the beacon's location."
	var/beacon_name = "Bepis"
	var/beacon_id = "BEPIS"

/obj/item/foodprinter_output_beacon/Initialize()
	. = ..()
	RandomName()
	RandomID()
	GLOB.food_printer_outputs |= src

/obj/item/foodprinter_output_beacon/Destroy()
	. = ..()
	GLOB.food_printer_outputs -= src

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
		"Enter a name for the beacon. This is what will show up in the GekkerTec TurboKitchen 2000's output menu, so make it something helpful, like your name, or some kind of big shark! 64 characters max, please!",
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
	beacon_name = "[safepick(GLOB.megacarp_first_names)]-[safepick(GLOB.megacarp_last_names)]-[rand(1000,9999)]"
	UpdateName()

/obj/item/foodprinter_output_beacon/proc/UpdateName()
	name = "Food Beacon - [beacon_name]"

/obj/item/foodprinter_output_beacon/proc/GetOutput(mob/printer, obj/item/food)
	if(isturf(loc))
		return loc
	if(SEND_SIGNAL(loc, COMSIG_CONTAINS_STORAGE)) // try and stuff it in there
		if(SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_CAN_INSERT, food, printer, TRUE))
			return loc
	return GetNearestTable(get_turf(src), 5)

/proc/GetNearestTable(atom/place, maxdist = 5)
	if(!place)
		return
	var/list/tables = list()
	for(var/turf/T in view(maxdist, get_turf(place)))
		if(istype(T, /obj/structure/table))
			tables += T
	if(!tables)
		return get_turf(place)
	var/closest_dist = 999999
	var/obj/structure/table/closest_table
	for(var/obj/structure/table/T in tables)
		var/dist = GET_DIST_EUCLIDEAN(place, T)
		if(dist < closest_dist)
			closest_dist = dist
			closest_table = T
	if(closest_table)
		return closest_table
	return get_turf(place)



//////////////////////////////////////////////////////////////////////
// Food Menu 2000 - The Menu of the Future ///////////////////////////
// Holds all the foods in existence, and categorizes them. ///////////
//////////////////////////////////////////////////////////////////////
/datum/food_menu
	var/list/foods = list()
	var/list/TGUI_chunk = list()


/datum/food_menu/New()
	. = ..()
	InitFoodList()

/// goes through every single item in the game and checks IS IT FOOD? HEY ARE YOU FOOD? WHY DO I KEEP EATING MY FRIENDS
/datum/food_menu/proc/InitFoodList()
	foods = list()
	for(var/thing in subtypesof(/obj/item))
		var/obj/item/I = thing
		if(!initial(I.is_food))
			continue
		var/datum/food_menu_entry/entry = new /datum/food_menu_entry(I)
		foods["[entry.food_key]"] = entry
	InitTGUIChunk()

/datum/food_menu/proc/InitTGUIChunk()
	TGUI_chunk = list()
	for(var/foodkey in foods)
		var/datum/food_menu_entry/entry = foods[foodkey]
		TGUI_chunk += list(entry.data_for_tgui())

//////////////////////////////////////////////////////////////////////
// Food Item - The Food of the Future ////////////////////////////////
// A single food item. ///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/datum/food_menu_entry
	var/name = "Food"
	var/desc = "It's a food"
	var/list/categories = list()
	var/list/nut_facts = list()
	var/print_time = 5 SECONDS
	var/food_key
	var/obj/item/itempath

/datum/food_menu_entry/New(obj/item/thing)
	. = ..()
	if(!thing)
		qdel(src)
		CRASH("Food menu entry created with no item. ERROR CODE: WAIFU SPHERE SOFA FILLER")
	Initify(thing)

/// Spawns then unspawns a food item to get its data
/datum/food_menu_entry/proc/Initify(obj/item/thing)
	var/obj/item/I = new(thing)
	food_key = "[I.type]"
	name = I.name
	desc = I.desc
	// categories = Catagorize(I)
	nut_facts = Nutrify(I)
	qdel(I) // YEAH EAT IT GARBAGE COLLECTOR

/// Categorizes a food item
/datum/food_menu_entry/proc/Catagorize(obj/item/thing)
	return // catabite me

/// Gets the nutritional facts of a food item
/datum/food_menu_entry/proc/Nutrify(obj/item/thing)
	nut_facts = list()
	var/calories = 0
	var/vitamins = 0
	var/sugars = 0
	var/list/everything_else = list()
	for(var/datum/reagent/R in thing.reagents?.reagent_list)
		if(istype(R, /datum/reagent/consumable))
			var/datum/reagent/consumable/C = R
			var/totnut = (C.volume * C.nutriment_factor) / C.metabolization_rate
			if(istype(C, /datum/reagent/consumable/vitamins))
				vitamins += totnut
			else if(istype(C, /datum/reagent/consumable/nutriment))
				calories += totnut
			else if(istype(C, /datum/reagent/consumable/sugar) || \
				istype(C, /datum/reagent/consumable/sprinkles) || \
				istype(C, /datum/reagent/consumable/corn_syrup) || \
				istype(C, /datum/reagent/consumable/honey))
				var/sugs = totnut
				if(istype(C, /datum/reagent/consumable/corn_syrup))
					sugs *= 3
				if(istype(C, /datum/reagent/consumable/honey))
					sugs *= 3
				sugars += sugs
		everything_else["[R.name]"] = R.volume
	nut_facts["Calories"] = calories
	nut_facts["Vitamins"] = vitamins
	nut_facts["Sugars"] = sugars
	nut_facts["EverythingElse"] = list(everything_else)
	return nut_facts

/datum/food_menu_entry/proc/data_for_tgui()
	var/list/data = list()
	data["Name"] = name || "Food"
	data["Description"] = desc || "No description available."
	data["Categories"] = categories || list()
	data["NutritionalFacts"] = nut_facts || list()
	data["PrintTime"] = (print_time / 10) || 5
	data["FoodKey"] = food_key || "/datum/food_menu_entry/awful_food"
	return data
























