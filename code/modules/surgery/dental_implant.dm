/datum/surgery/dental_implant
	name = "Dental implant"
	steps = list(/datum/surgery_step/drill, /datum/surgery_step/insert_pill)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	requires_bodypart_type = BODYPART_ORGANIC
	requires_trait = 1

/datum/surgery_step/insert_pill
	name = "insert pill"
	implements = list(/obj/item/reagent_containers/pill = 100)
	time = 16

/datum/surgery_step/insert_pill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to wedge \the [tool] in [target]'s [parse_zone(target_zone)].", span_notice("I begin to wedge [tool] in [target]'s [parse_zone(target_zone)]..."))

/datum/surgery_step/insert_pill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/reagent_containers/pill/tool, datum/surgery/surgery)
	if(!istype(tool))
		return 0

	user.transferItemToLoc(tool, target, TRUE)

	var/datum/action/item_action/hands_free/activate_pill/P = new(tool)
	P.button.name = "Activate [tool.name]"
	P.target = tool
	P.Grant(target)	//The pill never actually goes in an inventory slot, so the owner doesn't inherit actions from it

	user.visible_message("[user] wedges \the [tool] into [target]'s [parse_zone(target_zone)]!", span_notice("I wedge [tool] into [target]'s [parse_zone(target_zone)]."))
	return 1

/datum/action/item_action/hands_free/activate_pill
	name = "Activate Pill"

/datum/action/item_action/hands_free/activate_pill/Trigger()
	if(!..())
		return 0
	to_chat(owner, span_caution("I grit your teeth and burst the implanted [target.name]!"))
	log_combat(owner, null, "swallowed an implanted pill", target)
	if(target.reagents.total_volume)
		target.reagents.reaction(owner, INGEST)
		target.reagents.trans_to(owner, target.reagents.total_volume, log = TRUE)
	qdel(target)
	return 1
