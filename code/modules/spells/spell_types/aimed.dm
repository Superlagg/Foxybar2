
/obj/effect/proc_holder/spell/aimed
	name = "aimed projectile spell"
	var/projectile_type = /obj/item/projectile/magic/teleport
	var/deactive_msg = "I discharge your projectile..."
	var/active_msg = "I charge your projectile!"
	base_icon_state = "projectile"
	var/active_icon_state = "projectile"
	var/list/projectile_var_overrides = list()
	var/projectile_amount = 1	//Projectiles per cast.
	var/current_amount = 0	//How many projectiles left.
	var/projectiles_per_fire = 1		//Projectiles per fire. Probably not a good thing to use unless you override ready_projectile().

/obj/effect/proc_holder/spell/aimed/Trigger(mob/user, skip_can_cast = TRUE)
	if(!istype(user))
		return
	var/msg
	if(!skip_can_cast && !can_cast(user, FALSE, TRUE))
		msg = span_warning("I can no longer cast [name]!")
		remove_ranged_ability(msg)
		return
	if(active)
		msg = span_notice("[deactive_msg]")
		if(charge_type == "recharge")
			var/refund_percent = current_amount/projectile_amount
			charge_counter = charge_max * refund_percent
			start_recharge()
		remove_ranged_ability(msg)
		on_deactivation(user)
	else
		msg = span_notice("[active_msg] <B>Left-click to shoot it at a target!</B>")
		current_amount = projectile_amount
		add_ranged_ability(user, msg, TRUE)
		on_activation(user)

/obj/effect/proc_holder/spell/aimed/proc/on_activation(mob/user)
	return

/obj/effect/proc_holder/spell/aimed/proc/on_deactivation(mob/user)
	return

/obj/effect/proc_holder/spell/aimed/update_icon()
	if(!action)
		return
	action.button_icon_state = "[base_icon_state][active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/aimed/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE
	var/ran_out = (current_amount <= 0)
	if(!cast_check(!ran_out, ranged_ability_user))
		remove_ranged_ability()
		return FALSE
	var/list/targets = list(target)
	perform(targets, ran_out, user = ranged_ability_user)
	return TRUE

/obj/effect/proc_holder/spell/aimed/cast(list/targets, mob/living/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE
	fire_projectile(user, target)
	user.newtonian_move(get_dir(U, T))
	if(current_amount <= 0)
		remove_ranged_ability() //Auto-disable the ability once you run out of bullets.
		charge_counter = 0
		start_recharge()
		on_deactivation(user)
	return TRUE

/obj/effect/proc_holder/spell/aimed/proc/fire_projectile(mob/living/user, atom/target)
	current_amount--
	if(!projectile_type)
		return
	for(var/i in 1 to projectiles_per_fire)
		var/obj/item/projectile/P = new projectile_type(user.loc)
		P.firer = user
		P.preparePixelProjectile(target, user)
		for(var/V in projectile_var_overrides)
			if(P.vars[V])
				P.vv_edit_var(V, projectile_var_overrides[V])
		ready_projectile(P, target, user, i)
		P.fire()
	return TRUE

/obj/effect/proc_holder/spell/aimed/proc/ready_projectile(obj/item/projectile/P, atom/target, mob/user, iteration)
	return

/obj/effect/proc_holder/spell/aimed/lightningbolt
	name = "Lightning Bolt"
	desc = "Fire a high powered lightning bolt at your foes!"
	school = "evocation"
	charge_max = 150
	invocation = "ZAP MUTHA'FUCKA"
	invocation_type = "shout"
	cooldown_min = 30
	active_icon_state = "lightning"
	base_icon_state = "lightning"
	sound = 'sound/magic/lightningbolt.ogg'
	active = FALSE
	projectile_var_overrides = list("zap_range" = 15, "zap_power" = 20000, "zap_flags" = ZAP_MOB_DAMAGE)
	active_msg = "I energize your hand with arcane lightning!"
	deactive_msg = "I let the energy flow out of your hands back into yourself..."
	projectile_type = /obj/item/projectile/magic/aoe/lightning

/obj/effect/proc_holder/spell/aimed/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."
	school = "evocation"
	charge_max = 100
	clothes_req = NONE
	invocation = "ONI SOMA"
	invocation_type = "shout"
	range = 20
	cooldown_min = 20 //20 deciseconds reduction per rank
	projectile_type = /obj/item/projectile/magic/aoe/fireball
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/fireball.ogg'
	active_msg = "I prepare to cast your fireball spell!"
	deactive_msg = "I extinguish your fireball... for now."
	active = FALSE
