GLOBAL_DATUM_INIT(food_menu, /datum/food_menu)

/obj/structure/food_printer
	name = "GekkerTec TurboKitchen 2000"
	desc = "A high-tech kitchen appliance that can produce a variety of food items. For free! Live! Over the internet!"
	icon_state = "autolathe"
	density = TRUE
	var/datum/food_menu/menu
	var/datum/weakref/foutput

/obj/structure/food_printer/Initialize()
	. = ..()
	menu = GLOB.food_menu
	foutput = FindOutput()

/obj/structure/food_printer/proc/FindOutput()
	var/list/outputs = spiral_range_turfs(3, src, TRUE)
	for(var/turf/T in outputs)
		for(var/obj/structure/table/S in T)
			foutput = GET_WEAKREF(S)
			return
	foutput = GET_WEAKREF(get_turf(src)) // just throw it on the floor




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
		TGUI_chunk += list(entry/data_for_tgui())

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
	return // catagunt me

/// Gets the nutritional facts of a food item
/datum/food_menu_entry/proc/Nutrify(obj/item/thing)
	var/list/nut_facts = list()
	var/calories = 0
	var/vitamins = 0
	var/sugars = 0
	for(var/datum/reagent/R in thing.reagents)
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
	nut_facts += list("Calories", calories)







/datum/food_menu_entry/proc/data_for_tgui()
	var/list/data = list()
	data["Name"] = name || "Food"
	data["Description"] = desc || "No description available."
	data["Categories"] = categories || list()
	data["NutritionalFacts"] = nut_facts || list()
	data["PrintTime"] = (print_time / 10) || 5
	data["FoodKey"] = food_key || "/datum/food_menu_entry/awful_food"
	return data
























