/**********************Lazarus Injector**********************/
/obj/item/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead, making them become friendly to the user. Unfortunately, the process is useless on higher forms of life and incredibly costly, so these were hidden in storage until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1
	var/malfunctioning = 0
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it

/obj/item/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!loaded)
		return
	if(isliving(target) && proximity_flag)
		if(isanimal(target))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				to_chat(user, span_info("[src] does not work on this sort of creature."))
				return
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.revive(full_heal = 1, admin_revive = 1)
				M.make_ghostable(user)
				if(ishostile(target))
					var/mob/living/simple_animal/hostile/H = M
					if(malfunctioning)
						H.faction |= list("lazarus", "[REF(user)]")
						H.robust_searching = 1
						H.friends[user]++
						H.attack_same = 1
						log_game("[key_name(user)] has revived hostile mob [key_name(target)] with a malfunctioning lazarus injector")
					else
						H.attack_same = 0
				loaded = 0
				user.visible_message(span_notice("[user] injects [M] with [src], reviving it."))
				SSblackbox.record_feedback("tally", "lazarus_injector", 1, M.type)
				playsound(src,'sound/effects/refill.ogg',50,1)
				icon_state = "lazarus_empty"
				return
			else
				to_chat(user, span_info("[src] is only effective on the dead."))
				return
		else
			to_chat(user, span_info("[src] is only effective on lesser beings."))
			return

/obj/item/lazarus_injector/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!malfunctioning)
		malfunctioning = 1

/obj/item/lazarus_injector/examine(mob/user)
	. = ..()
	if(!loaded)
		. += span_info("[src] is empty.")
	if(malfunctioning)
		. += span_info("The display on [src] seems to be flickering.")

//
// Holoparasites
// + in the loadout
// + infinite uses
// // - reduced mob health
// - slightly larger
//

#define GHOSTLY_BLUE "#69afff"
#define DEMON_RED "#ff6969"

/obj/item/holoparasite_injector
	name = "BioSynth Reanimator Injector" // RIP, single most generic name to beat out "Etherleech".
	desc = "An injector filled with a cocktail of nanomachines that copy an entity's form, using the body to fuel another charge and animate it."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 5
	var/revive_type = SENTIENCE_ORGANIC // So you can't revive boss monsters with it.

/obj/item/holoparasite_injector/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(isliving(target) && proximity_flag)
		if(isanimal(target))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				to_chat(user, span_info("[src] needs a good biofuel source to reanimate."))
				return
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.maxHealth = 45
				M.revive(full_heal = 1, admin_revive = 1)
				M.loot = list()
				M.alpha = 180
				M.color = GHOSTLY_BLUE
				user.visible_message(span_notice("[M] suddenly contorts in pain before rising a ghostly blue!"))
				playsound(src,'modular_coyote/sound/items/holopara2.ogg',50,1)
				return
			else
				to_chat(user, span_info("Due to the gruesome process, the [src] has safeties to prevent it being used on the living."))
				return
		else
			to_chat(user, span_info("This monster is an exceptionally powerful soul and resists the nanomachines!"))
			return

/obj/item/jaegerholopara
	name = "LLX22 Crimson Holoparasite Auto-Injector"
	desc = "A specially branded Holoparasite nanite strain. What years of the LLX11 Jet Auto-Injector program has led up to- a modern philosopher's stone. You can't bring back the dead, not in the way LapinLattice tried at least."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/revive_type = SENTIENCE_ORGANIC // So you can't revive boss monsters with it.

/obj/item/jaegerholopara/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(isliving(target) && proximity_flag)
		if(isanimal(target))
			var/mob/living/simple_animal/M = target
			if(M.sentience_type != revive_type)
				to_chat(user, span_info("[src] needs a good biofuel source to reanimate."))
				return
			if(M.stat == DEAD)
				M.faction = list("neutral")
				M.color = DEMON_RED
				M.maxHealth = 20
				M.revive(full_heal = 1, admin_revive = 1)
				M.loot = list()
				M.alpha = 180
				user.visible_message(span_notice("[M] suddenly contorts in pain before rising a crimson red!"))
				playsound(src,'modular_coyote/sound/items/holopara2.ogg',50,1)
				return
			else
				to_chat(user, span_info("Due to the gruesome process, the [src] has safeties to prevent it being used on the living."))
				return
		else
			to_chat(user, span_info("This monster is an exceptionally powerful soul and resists the nanomachines!"))
			return
