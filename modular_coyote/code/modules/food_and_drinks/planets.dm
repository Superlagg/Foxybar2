/obj/item/reagent_containers/food/snacks/earthcandy
	name = "Earth candy"
	desc = "A little, fist sized jawbreaker candy resembling Earth"
	icon = 'modular_coyote/icons/objects/food/planets.dmi'
	icon_state = "EarthCandy" //stolen from https://gold356.itch.io/earh-rotating-32-x-32. Thank you!
	bitesize = 10
	list_reagents = list(
		/datum/reagent/consumable/sugar = 20
	)
	is_sweet = TRUE
	is_celestial = TRUE

/obj/item/reagent_containers/food/snacks/earthplanet
	name = "Compressed Earth"
	desc = "A planet pulled from an alternative dimension, and compressed down to basketball size. This one is Earth!"
	icon = 'modular_coyote/icons/objects/food/planets.dmi'
	icon_state = "EarthPlanet" //stolen from https://gold356.itch.io/earh-rotating-32-x-32. Thank you!
	bitesize = 10
	list_reagents = list(
		/datum/reagent/consumable/planet = 200000000,
		/datum/reagent/consumable/sugar = 200000,
		/datum/reagent/consumable/nutriment/vitamin = 200000,
		/datum/reagent/consumable/gluttony = 200000,
	)
	volume = INFINITY
	is_celestial = TRUE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/earthcandy/suncandy
	name = "Sun candy"
	desc = "A little, fist sized jawbreaker candy resembling the sun of the Sol system"
	icon_state = "SunCandy"

/obj/item/reagent_containers/food/snacks/earthplanet/sunstar
	name = "Compressed Sun"
	desc = "A star pulled from an alternative dimension, and compressed down to a basketball size. This one is the sun of the Sol system! Or just plainly sun for those less nerdy."
	icon_state = "SunStar"
	list_reagents = list(
		/datum/reagent/consumable/star = 2500000000000000,
		/datum/reagent/consumable/gluttony = 200000,
	)

/datum/reagent/consumable/planet
	name = "Planet"
	description = "All the various non edible components of a planet... well, non edible is subjective..."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	taste_description = "planet"

/datum/reagent/consumable/star
	name = "Star"
	description = "It's a hot ball of gas, mostly hydrogen and helium. But once again, non edible is quite subjective"
	reagent_state = SOLID
	nutriment_factor = 2000 * REAGENTS_METABOLISM //If it's enough to sustain a "fire" that warms and lights up an entire solar system, it m i g h t be enough to satiate a dragon
	color = "#e42602"
	taste_description = "Spicy, hot star"

/datum/reagent/consumable/gluttony
	name = "Pure gluttony"
	description = "Can't belive you did that, think of all the things you ate!"
	nutriment_factor = 1000 * REAGENTS_METABOLISM
	color = "#FF0000"
	taste_description = "pure gluttony, that could rival that of deities"
	taste_mult = 50


