/datum/map_template/hilbertshotel/lore
	name = "Doctor Hilbert's Deathbed"
	mappath = '_maps/templates/hilbertshotellore.dmm'

/datum/map_template/hilbertshotelstorage
	name = "Hilbert's Hotel Storage"
	mappath = '_maps/templates/hilbertshotelstorage.dmm'

// Better SPLURT version of hilbert's
/datum/map_template/hilbertshotel
	var/room_title = "Hotel Room"
	var/room_short_desc = "A roomy room in a hotel."
	var/room_long_desc = "An all-purpose hotel room with coziness and comfort in mind. \
		Comes with a spacious living room, an even more spacious bedroom, a bathroom you could get lost in, \
		and a kitchen that's just the right size for a midnight snack."
	var/landingZoneRelativeX = 2
	var/landingZoneRelativeY = 8
	mappath = '_maps/templates/splurt_templates/hilbertshotel.dmm'

// Empty room - different due to the dimensions of the updated map
/datum/map_template/hilbertshotel/empty
	name = "Empty Room"
	room_title = "Vacant Room"
	room_short_desc = "An empty room in a hotel."
	room_long_desc = "Our basic hotel room, minus the furniture. \
		You can furnish it however you like, or just leave it empty. \
		We won't judge."
	mappath = '_maps/templates/splurt_templates/hilbertshotelempty.dmm'

// SELECTABLE APARTMENTS UPDATE
/datum/map_template/hilbertshotel/apartment/one
	name = "Apartment_1"
	room_title = "Couples Apartment"
	room_short_desc = "A cozy apartment for couples."
	room_long_desc = "A more subdivided apartment for those who want a little more intimacy. \
		One bedroom with a queen-sized bed and kilobaud-ready computer, one games room / living room \
		/ love nest, one bathroom with a shower and a bathtub, and a dining room with a kitchenette. \
		Perfect for couples who want to get away from it all."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/apartment_1.dmm'

/datum/map_template/hilbertshotel/apartment/two
	name = "Apartment_2"
	room_title = "Party Apartment"
	room_short_desc = "The perfect destination for parties!"
	room_long_desc = "A larger apartment for those who want to throw a party. \
		Comes with a spacious activity den with a multipurpose table, connected to a kitchen bar. \
		Also includes a bedroom with a king-sized bed and your very own FunSquare(TM). Bathroom \
		comes standard with Urbworld 7170 style showerpool. Perfect for those who want to throw a party."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/apartment_2.dmm'

/datum/map_template/hilbertshotel/apartment/three
	name = "Apartment_3"
	room_title = "Club Apartment"
	room_short_desc = "A club apartment for the party animals."
	room_long_desc = "A club apartment for those who want to party all night long. \
		Comes with a Vampire Queen descending entry hall (with complimentary decorative air alarm) \
		leading to a Standing Room Only dining room / bar combo, complete with wall-facing color TV. \
		Master bedroom includes a king-sized bed and secret dildo closet. Microbathroom is perfect for \
		microfolk. Perfect for those who aren't sure what they want, but know they want it now."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/apartment_3.dmm'

/datum/map_template/hilbertshotel/apartment/four
	name = "Apartment_4"
	room_title = "Urban Apartment"
	room_short_desc = "A keen apartment for the keen."
	room_long_desc = "A clever hide-a-way apartment for the more adventurous type. \
		An authentic sampling of the urban lifestyle, sourced from refurbished city buildings. \
		Fixer-upper cloakroom leads into the BreakfastWall, complete with fifth generation Ma's Grundle \
		planterrarium. Living room includes an extra-large sofa, fireplace, and a 17\" color TV. \
		Bedroom with secret sex dungeon, and bath sauna with a view. Includes decorative elevator and \
		dingy hallway. Pets welcome."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/apartment_4.dmm'

/datum/map_template/hilbertshotel/apartment/bar
	name = "Apartment_bar"
	room_title = "Brownstone Pub"
	room_short_desc = "Your very own pub, freshly renovated."
	room_long_desc = "A personal pub for those who want to drink in style. \
		Comes with a bar, a cards nook, booths, and a recently clearned unisex men's room. \
		Bar is fully stocked with a variety of drinks, including a few you've never heard of. \
		Perfect for large parties, or for those who want to drink alone in public."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/apartment_bar.dmm'

/datum/map_template/hilbertshotel/apartment/big
	name = "Apartment_big"
	room_title = "Big Apartment"
	room_short_desc = "A macro-sized apartment for the macro-minded."
	room_long_desc = "The perfect destination for the plus sized in any dimension! \
		Rustic Hangar (TM) living room guaranteed to provide ample headroom for up to Kaiju-EX MacroScale \
		guests. Comes with Olympic-sized hot tub. Includes Dragon King sized bed (bedside elevators available \
		on request). Doorways guaranteed at least 16.5 Nowaks wide. Perfect for those who want to live large."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/apartment_big.dmm'

/datum/map_template/hilbertshotel/apartment/garden
	name = "Apartment_garden"
	room_title = "Garden Park"
	room_short_desc = "A moonlit grove for the nature lover."
	room_long_desc = "Your very own piece of the great outdoors! \
		Authentic nature retreat with a Keystone Tree, benches, wildflowers, and fresh-cut grass. \
		Sourced from the finest nature reserves in the galaxy. Allergy information available upon request. \
		Perfect for those who looking for terrafirma."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/apartment_garden.dmm'

/datum/map_template/hilbertshotel/apartment/sauna
	name = "Apartment_sauna"
	room_title = "Bath House Sauna"
	room_short_desc = "A resort for the wet and wild."
	room_long_desc = "An authentic bath house sauna for those who want to get steamy. \
		Comes with a steam room, a relaxation parlor, a sex den, and the deadliest pool \
		I've ever seen, my goodness. Secret dildo cave included. Perfect for those who want to \
		relax and unwind, or break their necks."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/apartment_sauna.dmm'

//FB maps
// /datum/map_template/hilbertshotel/apartment/movietheater
// 	name = "Movie_Theater"
// 	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/movie_theater.dmm'

// /datum/map_template/hilbertshotel/apartment/dungeon_one
// 	name = "Dungeon-One"
// 	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/dungeon_1.dmm'

/datum/map_template/hilbertshotel/apartment/oasis_one
	name = "oasis-One"
	room_title = "Midnight Oasis"
	room_short_desc = "A desert oasis for the weary traveler."
	room_long_desc = "A desert oasis for the warm sands enthusiast. \
		Quartz sand, palm trees, and a cool pool to relax in. Harem tent included."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/oasis_1.dmm'

/datum/map_template/hilbertshotel/apartment/snowcabin_one
	name = "snowcabin-One"
	room_title = "Alpine Cabin"
	room_short_desc = "A snowy cabin for the winter lover."
	room_long_desc = "A snowy cabin for the winter lover. \
		Bring a coat, because winter is here in this hoarfrost hideaway! \
		Rustic hunting cabin with a roaring fire (just add wood). \
		Ice fishing hole included."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/snowcabin_1.dmm'

// /datum/map_template/hilbertshotel/apartment/hospital_one
// 	name = "Hospital"
// 	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/hospital.dmm'

/datum/map_template/hilbertshotel/apartment/chessboard
	name = "Chess"
	room_title = "Chessboard"
	room_short_desc = "A chessboard for the strategic thinker."
	room_long_desc = "A chessboard for the strategic thinker. \
		Comes with a chessboard, a chessboard, and a chessboard. \
		Perfect for those who want to play chess."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/chess.dmm'

/datum/map_template/hilbertshotel/apartment/glade_one
	name = "Glade-One"
	room_title = "Sylvan Glade"
	room_short_desc = "A sylvan glade for the nature lover."
	room_long_desc = "A forest clearing for the nature lover. \
		Comes with a forest, a clearing, and a forest clearing. \
		Perfect for those who want to be in a forest clearing."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/glade_1.dmm'

/datum/map_template/hilbertshotel/apartment/wildsauna_one
	name = "Wildsauna-One"
	room_title = "Cave Hot Spring"
	room_short_desc = "A natural hot spring for the weary traveler."
	room_long_desc = "A natural hot spring for the weary traveler. \
		Comes with a hot spring, a cave, and a hot spring cave. \
		Perfect for those who want to relax in a hot spring cave."
	mappath = '_maps/templates/splurt_templates/hilbertshotel_templates/wildsauna_1.dmm'



