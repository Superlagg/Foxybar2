

/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	inhand_icon_state = "s-ninja_mask"
	armor = ARMOR_VALUE_MEDIUM
	strip_delay = 12
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	blockTracking = 1//Roughly the only unique thing about this helmet.
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/helmet/space/space_ninja/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_NODROP, NINJA_SUIT_TRAIT)
