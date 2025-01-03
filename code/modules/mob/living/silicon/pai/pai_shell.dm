
/mob/living/silicon/pai/proc/fold_out(force = FALSE)
	if(emitterhealth < 0)
		to_chat(src, span_warning("My holochassis emitters are still too unstable! Please wait for automatic repair."))
		return FALSE

	if(!canholo && !force)
		to_chat(src, span_warning("My master or another force has disabled your holochassis emitters!"))
		return FALSE

	if(holoform)
		. = fold_in(force)
		return

	if(world.time < emitter_next_use)
		to_chat(src, span_warning("Error: Holochassis emitters recycling. Please try again later."))
		return FALSE

	emitter_next_use = world.time + emittercd
	density = TRUE
	if(istype(card.loc, /obj/item/pda))
		var/obj/item/pda/P = card.loc
		P.pai = null
		P.visible_message(span_notice("[src] ejects itself from [P]!"))
	if(isliving(card.loc))
		var/mob/living/L = card.loc
		if(!L.temporarilyRemoveItemFromInventory(card))
			to_chat(src, span_warning("Error: Unable to expand to mobile form. Chassis is restrained by some device or person."))
			return FALSE
	if(istype(card.loc, /obj/item/integrated_circuit/input/pAI_connector))
		var/obj/item/integrated_circuit/input/pAI_connector/C = card.loc
		C.RemovepAI()
		C.visible_message(span_notice("[src] ejects itself from [C]!"))
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		C.installed_pai = null
		C.push_data()
	forceMove(get_turf(card))
	card.forceMove(src)
	update_mobility()
	if(client)
		client.perspective = EYE_PERSPECTIVE
		client.eye = src
	set_light_on(FALSE)
	icon_state = "[chassis]"
	visible_message(span_boldnotice("[src] folds out its holochassis emitter and forms a holoshell around itself!"))
	holoform = TRUE

/mob/living/silicon/pai/proc/fold_in(force = FALSE)
	emitter_next_use = world.time + (force? emitteroverloadcd : emittercd)
	icon_state = "[chassis]"
	if(!holoform)
		. = fold_out(force)
		return
	if(force)
		short_radio()
		visible_message(span_warning("[src] shorts out, collapsing back into their storage card, sparks emitted from their radio antenna!"))
	else
		visible_message(span_notice("[src] deactivates its holochassis emitter and folds back into a compact card!"))
	stop_pulling()
	if(client)
		client.perspective = EYE_PERSPECTIVE
		client.eye = card
	var/turf/T = drop_location()
	card.forceMove(T)
	forceMove(card)
	density = FALSE
	set_light_on(FALSE)
	holoform = FALSE
	set_resting(FALSE, TRUE, FALSE)
	update_mobility()

/mob/living/silicon/pai/proc/choose_chassis()
	if(!isturf(loc) && loc != card)
		to_chat(src, span_boldwarning("I can not change your holochassis composite while not on the ground or in your card!"))
		return FALSE
	var/list/choices = list("Preset - Basic", "Preset - Dynamic")
	if(CONFIG_GET(flag/pai_custom_holoforms))
		choices += "Custom"
	var/old_chassis = chassis
	var/choicetype = input(src, "What type of chassis do you want to use?") as null|anything in choices
	if(!choicetype)
		return FALSE
	switch(choicetype)
		if("Custom")
			chassis = "custom"
		if("Preset - Basic")
			var/choice = input(src, "What would you like to use for your holochassis composite?") as null|anything in possible_chassis
			if(!choice)
				return FALSE
			chassis = choice
	resist_a_rest(FALSE, TRUE)
	update_icon()
	if(possible_chassis[old_chassis])
		RemoveElement(/datum/element/mob_holder, old_chassis, 'icons/mob/pai_item_head.dmi', 'icons/mob/pai_item_rh.dmi', 'icons/mob/pai_item_lh.dmi', INV_SLOTBIT_HEAD)
	if(possible_chassis[chassis])
		AddElement(/datum/element/mob_holder, chassis, 'icons/mob/pai_item_head.dmi', 'icons/mob/pai_item_rh.dmi', 'icons/mob/pai_item_lh.dmi', INV_SLOTBIT_HEAD)
	to_chat(src, span_boldnotice("I switch your holochassis projection composite to [chassis]"))

/mob/living/silicon/pai/lay_down()
	. = ..()
	if(loc != card)
		visible_message(span_notice("[src] [resting? "lays down for a moment..." : "perks up from the ground"]"))
	update_icon()

/mob/living/silicon/pai/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	if(ispAI(AM))
		return ..()
	return FALSE

/mob/living/silicon/pai/proc/toggle_integrated_light()
	if(!light_range)
		set_light_on(TRUE)
		to_chat(src, span_notice("I enable your integrated light."))
	else
		set_light_on(FALSE)
		to_chat(src, span_notice("I disable your integrated light."))

/mob/living/silicon/pai/can_buckle_others(mob/living/target, atom/buckle_to)
	return ispAI(target) && ..()
