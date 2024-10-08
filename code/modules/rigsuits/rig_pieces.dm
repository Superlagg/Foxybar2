/*
 * Defines the helmets, gloves and shoes for rigs.
 */

/obj/item/clothing/head/helmet/space/new_rig
	name = "helmet"
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	//flags =  BLOCKHAIR | THICKMATERIAL | NODROP
	//flags_inv = 		 HIDEEARS|HIDEEYES|HIDEFACE|HIDEMASK
	body_parts_covered = HEAD
	heat_protection =    HEAD
	cold_protection =    HEAD
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_on = FALSE
	var/on = 0
	/*
	sprite_sheets = list(
		"Tajaran" = 'icons/mob/species/tajaran/helmet.dmi',
		"Skrell" = 'icons/mob/species/skrell/helmet.dmi',
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi'
		)
	species_restricted = null
	*/
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

	flash_protect = 2

/obj/item/clothing/head/helmet/space/new_rig/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, span_warning("I cannot turn the light on while in this [user.loc]."))//To prevent some lighting anomalities.

		return
	toggle_light(user)

/obj/item/clothing/head/helmet/space/new_rig/proc/toggle_light(mob/user)
	if(airtight)
		on = !on
		icon_state = "[item_color][on]"
		set_light_on(on)
	else
		to_chat(user, span_warning("I cannot turn the light on while the suit isn't sealed."))

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

/obj/item/clothing/gloves/rig
	name = "gauntlets"
	//flags = THICKMATERIAL | NODROP
	item_flags = NODROP
	clothing_flags = THICKMATERIAL
	body_parts_covered = HANDS
	heat_protection =    HANDS
	cold_protection =    HANDS
	//species_restricted = null
	gender = PLURAL

/obj/item/clothing/shoes/magboots/rig
	name = "boots"
	//flags = NODROP
	item_flags = NODROP
	body_parts_covered = FEET
	cold_protection = FEET
	heat_protection = FEET
	//species_restricted = null
	gender = PLURAL

/obj/item/clothing/shoes/magboots/rig/attack_self(mob/user)
	return //TGClaw; no magboots
	/*
	if(flags & AIRTIGHT) //Could also check for STOPSPRESSUREDMAGE, but one is enough, both get toggled when the seal gets toggled.
		..(user)
	else
		to_chat(user, span_warning("I cannot activate mag-pulse traction system while the suit is not sealed."))
	*/
/obj/item/clothing/suit/space/new_rig
	name = "chestpiece"
	allowed = list(/obj/item/flashlight,/obj/item/tank)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	//body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	//heat_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	//cold_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	//flags_inv =          HIDEJUMPSUIT|HIDETAIL
	//flags =              STOPSPRESSUREDMAGE | THICKMATERIAL | AIRTIGHT | NODROP
	slowdown = 0
	//breach_threshold = 20
	//resilience = 0.2
	//can_breach = 1
	var/obj/item/rig/holder
	//sprite_sheets = list(
	//	"Tajaran" = 'icons/mob/species/tajaran/suit.dmi',
	//	"Unathi" = 'icons/mob/species/unathi/suit.dmi'
	//	)

//TODO: move this to modules
/obj/item/clothing/head/helmet/space/new_rig/proc/prevent_track()
	return 0

/obj/item/clothing/gloves/rig/Touch(atom/A, proximity)

	if(!A || !proximity)
		return 0

	var/mob/living/carbon/human/H = loc
	if(!istype(H) || !H.back)
		return 0

	var/obj/item/rig/suit = H.back
	if(!suit || !istype(suit) || !suit.installed_modules.len)
		return 0

	for(var/obj/item/rig_module/module in suit.installed_modules)
		if(module.active && module.activates_on_touch)
			if(module.engage(A))
				return 1

	return 0

//Rig pieces for non-spacesuit based rigs

/obj/item/clothing/head/lightrig
	name = "mask"
	body_parts_covered = HEAD
	heat_protection =    HEAD
	cold_protection =    HEAD
	clothing_flags =     THICKMATERIAL

/obj/item/clothing/suit/lightrig
	name = "suit"
	allowed = list(/obj/item/flashlight)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	heat_protection =    CHEST|GROIN|LEGS|ARMS
	cold_protection =    CHEST|GROIN|LEGS|ARMS
	//flags_inv =          HIDEJUMPSUIT
	//flags =              THICKMATERIAL
	flags_inv = HIDEJUMPSUIT
	clothing_flags = THICKMATERIAL

/obj/item/clothing/shoes/lightrig
	name = "boots"
	body_parts_covered = FEET
	cold_protection = FEET
	heat_protection = FEET
	//species_restricted = null
	gender = PLURAL

/obj/item/clothing/gloves/lightrig
	name = "gloves"
	//flags = THICKMATERIAL
	clothing_flags = THICKMATERIAL
	body_parts_covered = HANDS
	heat_protection =    HANDS
	cold_protection =    HANDS
	//species_restricted = null
	gender = PLURAL
