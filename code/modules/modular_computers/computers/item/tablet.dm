/obj/item/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet-red"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "menu"
	// worn_icon_state = "tablet"
	hardware_flag = PROGRAM_TABLET
	max_hardware_size = 1
	w_class = WEIGHT_CLASS_SMALL
	max_bays = 3
	steel_sheet_cost = 1
	slot_flags = INV_SLOTBIT_ID | INV_SLOTBIT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3 //Same as the PDA
	var/has_variants = TRUE
	var/finish_color = null

/obj/item/modular_computer/tablet/update_icon_state()
	if(has_variants)
		if(!finish_color)
			finish_color = pick("red","blue","brown","green","black")
		icon_state = icon_state_powered = icon_state_unpowered = "tablet-[finish_color]"

/obj/item/modular_computer/tablet/syndicate_contract_uplink
	name = "contractor tablet"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "assign"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = INV_SLOTBIT_ID | INV_SLOTBIT_BELT
	comp_light_luminosity = 6.3
	has_variants = FALSE

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	icon_state = "tablet-syndicate"
	comp_light_luminosity = 6.3
	has_variants = FALSE
	device_theme = "syndicate"

/obj/item/modular_computer/tablet/nukeops/emag_act(mob/user)
	if(!enabled)
		to_chat(user, span_warning("You'd need to turn the [src] on first."))
		return FALSE
	to_chat(user, span_notice("I swipe \the [src]. It's screen briefly shows a message reading \"MEMORY CODE INJECTION DETECTED AND SUCCESSFULLY QUARANTINED\"."))
	return FALSE
