/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

GLOBAL_LIST_INIT(supported_img_hosts, list(
	"https://files.catbox.moe",
	"https://i.gyazo.com",
))

SUBSYSTEM_DEF(chat)
	name = "Chat"
	flags = SS_TICKER
	wait = 1
	priority = FIRE_PRIORITY_CHAT
	init_order = INIT_ORDER_CHAT

	/* 
	** Base 
	 */
	var/base_say_distance = 7
	var/extended_say_distance = 16

	var/base_whisper_distance = 1
	var/extended_whisper_distance = 3
	
	var/base_sing_distance = 15
	var/extended_sing_distance = 150
	var/base_yell_distance = 15
	var/extended_yell_distance = 150
	var/far_distance = 6 // how far until they're considered offscreen

	var/chat_display_plane = LIGHTING_PLANE + 1 // FUKCUAING FUKCING LIGHTING EATING AS //CHAT_PLANE

	var/list/payload_by_client = list()
	/// All the lookups for translating emotes to say prefixes
	var/list/emoticon_cache = list()

	/// all the wacky ass flirt datums we have in existence
	var/list/flirts = list()
	var/list/flirtsByNumbers = list()
	/// A cached mass of jsonified flirt datums, for TGUI
	var/list/flirt_for_tgui = list() // flirt for me, flirt for me, flirt flirt
	var/list/flirts_all_categories = list() // flirt for me, flirt for me, flirt flirt

	var/flirt_debug = TRUE
	var/debug_block_radio_blurbles = FALSE

	var/list/horny_tguis = list()

	/// Format: list("quid" = /datum/character_inspection)
	var/list/inspectors = list()

	/// list of flirt ckey things so that we can store their target or something
	/// format: list("flirterckey" = "targetckey")
	var/list/active_flirters = list()
	/// format: list("targetckey" = "flirterckey")
	var/list/active_flirtees = list()
	/// list of flirters who flirted so we can prevent spum
	/// format: list("flirterckey" = 21049190587190581)
	var/list/flirt_cooldowns = list()
	/// how long between flirts can we flirt
	var/flirt_cooldown_time = 5 SECONDS
	var/debug_character_directory = 0

	var/list/stock_image_packs = list() // see: [code\__DEFINES\mommychat_image_packs.dm]
	var/list/mandatory_modes = list(MODE_SAY, MODE_WHISPER, MODE_SING, MODE_ASK, MODE_EXCLAIM, MODE_YELL)

	var/list/test_pics = list( // warning: boobs
		MODE_SAY = list(
			"Host" = "catbox.moe",
			"URL" = "4m71t6.jpg",
		),
		MODE_ASK = list(
			"Host" = "catbox.moe",
			"URL" = "jm3f2c.jpg",
		),
		MODE_SING = list(
			"Host" = "catbox.moe",
			"URL" = "em5bgb.jpg",
		),
		MODE_EXCLAIM = list(
			"Host" = "catbox.moe",
			"URL" = "3ggp5e.jpg",
		),
		MODE_YELL = list(
			"Host" = "catbox.moe",
			"URL" = "1dmlu5.jpg",
		),
		MODE_WHISPER = list(
			"Host" = "catbox.moe",
			"URL" = "t040sg.jpg",
		),
		MODE_CUSTOM_SAY = list(
			"Host" = "catbox.moe",
			"URL" = "fcm6yw.jpg",
		),
		":example:" = list(
			"Host" = "catbox.moe",
			"URL" = "fcm6yw.jpg",
		),
	)

	var/list/default_pfps = list(
		MALE = list(
			"Host" = "catbox.moe",
			"URL" = "1i1zom.png",
		),
		FEMALE = list(
			"Host" = "catbox.moe",
			"URL" = "jgxtpe.png",
		)
	)

	var/img_size = 75
	var/headspace = 4
	var/debug_chud = FALSE
	var/list/colorable_keys = list(
		"TopBoxGradient1",
		"TopBoxGradient2",
		"TopBoxBorderColor",
		"BottomBoxGradient1",
		"BottomBoxGradient2",
		"BottomBoxBorderColor",
		"ButtonGradient1",
		"ButtonGradient2",
		"ButtonBorderColor",
		"ImageBorderBorderColor",
		"OuterBoxBorderColor",
	)
	var/list/numberable_keys = list(
		"TopBoxGradientAngle",
		"TopBoxBorderWidth",
		"BottomBoxGradientAngle",
		"BottomBoxBorderWidth",
		"ButtonGradientAngle",
		"ButtonBorderWidth",
		"ImageBorderBorderWidth",
		"OuterBoxBorderWidth",
	)
	var/list/selectable_keys = list(
		"TopBoxBorderStyle",
		"BottomBoxBorderStyle",
		"ButtonBorderStyle",
		"ImageBorderBorderStyle",
		"OuterBoxBorderStyle",
	)
	var/list/borderstyles = list(
		"solid",
		"dotted",
		"dashed",
		"double",
		"groove",
		"ridge",
		"inset",
		"outset",
		"none",
		"hidden",
	)
	var/numbermal_min = 0
	var/numbermal_max = 5
	var/numbermal_default = 1

/datum/controller/subsystem/chat/Initialize(start_timeofday)
	setup_emoticon_cache()
	build_flirt_datums()
	// build_stock_image_packs()
	. = ..()
	spawn(5 SECONDS)
		to_chat(world, span_boldnotice("Initialized [LAZYLEN(emoticon_cache)] emoticons! ;D"))
		to_chat(world, span_boldnotice("Initialized [LAZYLEN(flirts)] flirty messages! <3"))
		// to_chat(world, span_boldnotice("Initialized [LAZYLEN(stock_image_packs)] stock image packs! 'w'"))

// /datum/controller/subsystem/chat/proc/build_stock_image_packs()
// 	stock_image_packs.Cut()
// 	for(var/paq in subtypesof(/datum/horny_image_pack))
// 		var/datum/horny_image_pack/P = new(paq)
// 		stock_image_packs += list(P.ListifyPack())

/datum/controller/subsystem/chat/proc/setup_emoticon_cache()
	emoticon_cache.Cut()
	var/json_emoticons = file2text("strings/sausage_rolls.json") // am hungy
	/// there was a comment here, but it was fukcing enormous and made it hard to read
	var/list/emoticons = safe_json_decode(json_emoticons)
	if(!LAZYLEN(emoticons))
		return // :(
	for(var/emo in emoticons)
		var/list/emotilist = emoticons[emo]
		var/list/emoties = list()
		emoties |= emo
		for(var/emotie in emotilist["ALIASES"])
			emoties |= emotie
		for(var/emotie in emoties)
			var/datum/emoticon_bank/E = new(emo, emotilist)
			emoticon_cache[html_decode(emotie)] = E

/datum/controller/subsystem/chat/proc/emoticonify(atom/movable/sayer, message, messagemode, list/spans, datum/rental_mommy/chat/momchat)
	if(!sayer)
		return
	if(istype(sayer, /mob))
		var/mob/they = sayer
		if(!they.client)
			return
	if(!(messagemode in list(MODE_SAY, MODE_WHISPER, MODE_SING, MODE_ASK, MODE_EXCLAIM, MODE_YELL)))
		return
	var/out
	var/datum/emoticon_bank/E
	for(var/key in emoticon_cache) // if this gets laggy, lol idk
		if(findtext(message, key))
			E = LAZYACCESS(emoticon_cache, key)
			if(!E)
				continue
			out = E.verbify(sayer, message, messagemode, spans)
			if(out)
				break
	if(!out)
		return
	for(var/key in emoticon_cache)
		out = replacetext(out, key, "") // remove the rest of the emoticons
	return out

/datum/controller/subsystem/chat/fire()
	for(var/key in payload_by_client)
		var/client/client = key
		var/list/payload = payload_by_client[key]
		payload_by_client -= key
		if(client)
			// for(var/pl_badwater in 1 to LAZYLEN(payload))
			// 	// Check if we should block this message
			// 	var/list/control_point = LAZYACCESS(payload, pl_badwater)
			// 	if(control_point["prefCheck"] && !CHECK_PREFS(client, control_point["prefCheck"]))
			// 		payload.Cut(pl_badwater, pl_badwater-1) // Failmate
			// 		continue // we dont want to see it
			// Send to tgchat
			client.tgui_panel?.window.send_message("chat/message", payload)
			// Send to old chat
			for(var/message in payload)
				SEND_TEXT(client, message_to_html(message))
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/chat/proc/queue(target, message)
	if(islist(target))
		for(var/_target in target)
			var/client/client = CLIENT_FROM_VAR(_target)
			if(client)
				if(message["prefCheck"] && !CHECK_PREFS(client, message["prefCheck"]))
					continue
				LAZYADD(payload_by_client[client], list(message))
		return
	var/client/client = CLIENT_FROM_VAR(target)
	if(client)
		if(message["prefCheck"] && !CHECK_PREFS(client, message["prefCheck"]))
			return
		LAZYADD(payload_by_client[client], list(message))

/datum/controller/subsystem/chat/proc/SanitizeUserImages(someone)
	if(!someone)
		return
	var/datum/preferences/P = extract_prefs(someone)
	if(!P)
		return
	var/list/defaulturls = list(
		default_pfps[MALE]["URL"],
		default_pfps[FEMALE]["URL"],
	)
	var/list/PP = P.ProfilePics // this is my PP
	// testing stuff
	PP.Cut()
	for(var/emotimode in mandatory_modes)
		var/list/tentry = list()
		for(var/list/moud in test_pics)
			if(moud["Mode"] == emotimode)
				tentry = moud
				break
		if(tentry) // check if its a valid image thing, and if not, BALEET IT
			var/valid = FALSE
			// if the user's image is default, and it isnt appropriate to their gender, we'll update it (cus it defaults to male and not everyone is)
			if(tentry["URL"] in defaulturls)
				switch(P.gender)
					if(MALE)
						if(tentry["URL"] != default_pfps[MALE]["URL"])
							valid = FALSE
					if(FEMALE)
						if(tentry["URL"] != default_pfps[FEMALE]["URL"])
							valid = FALSE
			else
				for(var/validhost in GLOB.supported_img_hosts)
					if(tentry["Host"] == validhost)
						valid = TRUE
						break
			if(!valid)
				PP -= tentry
				tentry = null
		if(!LAZYLEN(tentry))
			// none there, so we'll add a default
			var/list/newPP = list(
				"Mode" = emotimode,
			)
			switch(P.gender)
				if(MALE)
					newPP["URL"] = default_pfps[MALE]["URL"]
					newPP["Host"] = default_pfps[MALE]["Host"]
				if(FEMALE)
					newPP["URL"] = default_pfps[FEMALE]["URL"]
					newPP["Host"] = default_pfps[FEMALE]["Host"]
				else
					if(prob(50))
						newPP["URL"] = default_pfps[MALE]["URL"]
						newPP["Host"] = default_pfps[MALE]["Host"]
					else
						newPP["URL"] = default_pfps[FEMALE]["URL"]
						newPP["Host"] = default_pfps[FEMALE]["Host"]
			PP += list(newPP)
	// and finally, sort them!
	var/list/PPsorted = list()
	for(var/emotimode in mandatory_modes)
		for(var/list/PPentry in PP) // AKA, your mom
			if(PPentry["Mode"] == emotimode)
				PPsorted += list(PPentry)
	// and add in the customs
	for(var/list/PPentry in PP)
		if(PPentry["Mode"] in mandatory_modes)
			continue
		PPsorted += list(PPentry)
	P.ProfilePics = PPsorted.Copy()
	// P.save_character()

/// makes sure that the user has a properly filled out set of preferences lists for their hornychat
/datum/controller/subsystem/chat/proc/SanitizeUserPreferences(someone)
	if(!someone) // You'll be able to set colors and such for each of the message modes!
		return // So you could, say, have your I AM YELLING block look more YELLY
	var/datum/preferences/P = extract_prefs(someone) // and, hm, maybe not today, probably tomorrow
	if(!P)
		return
	var/list/HP = P.mommychat_settings // this is my PP
	if(!islist(HP))
		HP = list()
	///  P.mommychat_settings[mmode]["ImageBorderBorderWidth"] = "2px" // the settings look like this
	for(var/mode in mandatory_modes)
		if(!islist(HP[mode]))
			HP[mode] = list()
		// check if the entries have a valid value
		for(var/key in colorable_keys)
			var/vale = HP[mode][key]
			if(!vale || (LAZYACCESS(vale, 1) != "#"))
				HP[mode][key] = "#222222"
		for(var/key in numberable_keys)
			var/vale = HP[mode][key]
			if(!isnum(vale) || (vale < numbermal_min) || (vale > numbermal_max))
				HP[mode][key] = numbermal_default
		for(var/key in selectable_keys)
			var/vale = HP[mode][key]
			if(!vale || !(vale in borderstyles))
				HP[mode][key] = borderstyles[1]
	P.mommychat_settings = HP
	// P.save_character()


/datum/controller/subsystem/chat/proc/HornyPreferences(someone)
	if(!someone)
		return
	var/client/C = extract_client(someone)
	if(!C)
		return
	var/datum/horny_tgui_holder/HTH = LAZYACCESS(horny_tguis, C.ckey)
	if(!HTH)
		HTH = new(C.ckey)
		horny_tguis[C.ckey] = HTH
	HTH.OpenPrefsMenu()

/datum/controller/subsystem/chat/proc/TestHorny()
	var/mob/user = usr
	to_chat(user, "Testing the horny")
	for(var/mmode in test_pics)
		PreviewHornyFurryDatingSimMessage(user, mmode)
	to_chat(user, "Test complete")

/datum/controller/subsystem/chat/proc/PreviewHornyFurryDatingSimMessage(mob/target, message_mode, message, print)
	if(!istype(target))
		CRASH("PreviewHornyFurryDatingSimMessage called with invalid arguments! [target]!")
	var/mob/living/carbon/human/dummy/D = SSdummy.get_a_dummy()
	var/datum/preferences/P = extract_prefs(target)
	if(!P)
		CRASH("PreviewHornyFurryDatingSimMessage called with invalid arguments! [P]!")
	P.copy_to(D)
	D.dummyckey = target.ckey
	D.forceMove(get_turf(target))
	var/msg = message ? message : "Hey there! How's it going? I was thinking we could go on a date sometime. I'm a vampire and"
	if(message_mode)
		switch(message_mode) // dan // I mean, it is, isnt it?
			if(MODE_SAY)
				msg = msg
			if(MODE_WHISPER)
				msg = "#[msg]"
			if(MODE_SING)
				msg = "%[msg]"
			if(MODE_ASK)
				msg = "[msg]?"
			if(MODE_EXCLAIM)
				msg = "[msg]!"
			if(MODE_YELL)
				msg = "$[msg]"
			else
				msg = "[msg][message_mode]" // to catch any custom modes

	var/datum/rental_mommy/chat/mommy = D.say(msg, direct_to_mob = target)
	mommy.prefs_override = P
	var/mommess = BuildHornyFurryDatingSimMessage(mommy, TRUE)
	mommy.checkin()
	SSdummy.return_dummy(D)
	if(print)
		to_chat(target, mommess)
	else
		return mommess

/datum/controller/subsystem/chat/proc/BuildHornyFurryDatingSimMessage(datum/rental_mommy/chat/mommy)
	if(!istype(mommy))
		CRASH("BuildHornyFurryDatingSimMessage called with invalid arguments! [mommy]!")
	var/mob/living/target = mommy.recipiant
	if(!istype(mommy.recipiant))
		CRASH("BuildHornyFurryDatingSimMessage called with invalid arguments! [target]!!")
	if(!mommy.source)
		CRASH("BuildHornyFurryDatingSimMessage called with invalid arguments! [mommy.source]!!!!")
	var/datum/preferences/P = mommy.prefs_override || extract_prefs(mommy.source)
	if(!P)
		CRASH("BuildHornyFurryDatingSimMessage called with invalid arguments! [P]!")
	/// SO. now we need a few things from the speaker (mommy)
	/// - Name
	/// - Spoken Verb
	/// - Rendered message, with quotes
	/// - The message mode, for reasons i'll get into later
	/// - A list of profile images
	/// - A link to their chardir profile
	/// - A link to DM them
	/// - A link to flirt with them
	/// - A link to "interact" with them
	/// - A color for the text background
	/// - A color for the header background
	/// and from this, we will make a furry dating sim style message that will be sent to the target *and* the speaker
	var/m_name       = mommy.speakername
	var/m_verb       = mommy.message_saymod_comma
	var/m_rawmessage = mommy.original_message
	var/m_message    = mommy.message
	var/m_mode       = mommy.message_mode || MODE_SAY

	/// look for something in m_rawmessage formatted as :exammple: and extract that to look up a custom image
	/// We'll extract this, store it as a var, and use it as an override for the profile image
	var/list/m_images = /* P ? P.ProfilePics.Copy() :  */test_pics
	var/m_pfp = get_horny_pfp(m_rawmessage, m_images, m_mode)
	
	
	/// now all the many many colors for everything!
	// first the background gradients (and their angles)
	var/tgc_1 =   "#[P.mommychat_settings["[m_mode]"]["TopGradientColor1"]]"
	var/tgc_2 =   "#[P.mommychat_settings["[m_mode]"]["TopGradientColor2"]]"
	var/tgangle =  "[P.mommychat_settings["[m_mode]"]["TopGradientAngle"]]"
	var/tbc =     "#[P.mommychat_settings["[m_mode]"]["TopBorderColor"]]"
	var/tbs =     "#[P.mommychat_settings["[m_mode]"]["TopBorderSize"]]"
	var/tbt =     "#[P.mommychat_settings["[m_mode]"]["TopBorderStyle"]]"

	var/bgc_1 =   "#[P.mommychat_settings["[m_mode]"]["BottomGradientColor1"]]"
	var/bgc_2 =   "#[P.mommychat_settings["[m_mode]"]["BottomGradientColor2"]]"
	var/bgangle =  "[P.mommychat_settings["[m_mode]"]["BottomGradientAngle"]]"
	var/bbc =     "#[P.mommychat_settings["[m_mode]"]["BottomBorderColor"]]"
	var/bbs =     "#[P.mommychat_settings["[m_mode]"]["BottomBorderSize"]]"
	var/bbt =     "#[P.mommychat_settings["[m_mode]"]["BottomBorderStyle"]]"

	var/bbc_1 =   "#[P.mommychat_settings["[m_mode]"]["ButtonBackgroundColor1"]]"
	var/bbc_2 =   "#[P.mommychat_settings["[m_mode]"]["ButtonBackgroundColor2"]]"
	var/bbangle =  "[P.mommychat_settings["[m_mode]"]["ButtonBackgroundAngle"]]"
	// now the borders
	var/obc =     "#[P.mommychat_settings["[m_mode]"]["OuterBorderColor"]]"
	var/obs =     "#[P.mommychat_settings["[m_mode]"]["OuterBorderSize"]]"
	var/obt =     "#[P.mommychat_settings["[m_mode]"]["OuterBorderStyle"]]"
	var/ibc =     "#[P.mommychat_settings["[m_mode]"]["ImageBorderColor"]]"
	var/ibs =      "[P.mommychat_settings["[m_mode]"]["ImageBorderSize"]]"
	var/ibt =      "[P.mommychat_settings["[m_mode]"]["ImageBorderStyle"]]"
	// now the text colors
	// most are defined by mommy, but some arent, so we'll need to get a color that contrasts with the average of the top and bottom gradient colors
	var/tgc_to_num = hex2num(replacetext(tgc_1,"#", "")) + hex2num(replacetext(tgc_2,"#", ""))
	var/bgc_to_num = hex2num(replacetext(bgc_1,"#", "")) + hex2num(replacetext(bgc_2,"#", ""))
	var/avg_color = (tgc_to_num + bgc_to_num) / 4
	/// now we need to get the contrast color
	var/contrast_color = num2hex(16777215 - avg_color)
	var/dtc = "#[contrast_color]"

	var/senderquid = mommy.source_quid
	var/senderckey = mommy.source_ckey

	/// Character Directory link
	var/m_charlink = "<button style='width: 100% background: linear-gradient([bbangle]deg, [bbc_1], [bbc_2]);\
		border: 2px solid [bbc];'><a href='?src=[REF(src)];CHARDIR=1;reciever_quid=[senderquid];sender_quid=[target.ckey]'>\
		Profile</a></button>"
	/// DM link
	var/m_dmlink = "<button style='width: 100%; background: linear-gradient([bbangle]deg, [bbc_1], [bbc_2]);\
		border: 2px solid [bbc];'><a href='?src=[REF(src)];DM=1;reciever_quid=[senderckey];sender_quid=[target.ckey]'>\
		DM</a></button>"
	/// Flirt link
	var/m_flirtlink = "<button style='width: 100%; background: linear-gradient([bbangle]deg, [bbc_1], [bbc_2]);\
		border: 2px solid [bbc];'><a href='?src=[REF(src)];FLIRT=1;reciever_quid=[senderquid];sender_quid=[target.ckey]'>\
		Flirt</a></button>"
	/// Interact link
	var/m_interactlink = "<button style='width: 100%; background: linear-gradient([bbangle]deg, [bbc_1], [bbc_2]);\
		border: 2px solid [bbc];'><a href='?src=[REF(src)];INTERACT=1;reciever_quid=[senderquid];sender_quid=[target.ckey]'>\
		Interact</a></button>"


/* 
	<button style='width: 100%; background: linear-gradient(0deg, #FFFFFF, #FFFFFF);border: 2px solid #000000;'><a href='?src=[0x21000073];CHARDIR=1;reciever_quid=superlagg-numbering-crossly-5964-6337;sender_quid=superlagg'>Profile</a></button>
	<button style='width: 100%; background: linear-gradient(0deg, #FFFFFF, #FFFFFF);border: 2px solid #000000;'><a href='?src=[0x21000073];DM=1;reciever_quid=superlagg;sender_quid=superlagg'>DM</a></button>
	<button style='width: 100%; background: linear-gradient(0deg, #FFFFFF, #FFFFFF);border: 2px solid #000000;'><a href='?src=[0x21000073];FLIRT=1;reciever_quid=superlagg-numbering-crossly-5964-6337;sender_quid=superlagg'>Flirt</a></button>
	<button style='width: 100%; background: linear-gradient(0deg, #FFFFFF, #FFFFFF);border: 2px solid #000000;'><a href='?src=[0x21000073];INTERACT=1;reciever_quid=superlagg-numbering-crossly-5964-6337;sender_quid=superlagg'>Interact</a></button>
 */

	/// now we need to build the message
	var/list/cum = list()
	// First, the full body container
	cum += "<div style='width: 100%; border: [obs]px [obt] [obc];'>"
	// first the head
	cum += "<div style='width: 100%; background: linear-gradient([tgangle]deg, [tgc_1], [tgc_2]); border: [tbs]px [tbt] [tbc]; display: flex;'>"
	// now the profile picture
	cum += "<div style='height: [img_size]px; width: [img_size]px; background: [tgc_1]; border: [ibs]px [ibt] [ibc]; border-radius: 10px; margin: 2px;'>"
	cum += "<img src='[m_pfp]' style='height: [img_size]px; width: [img_size]px; border-radius: 10px;'>"
	cum += "</div>"
	// now the rest of the head
	cum += "<div style='text-align: center; width: calc(100% - [img_size + headspace]px); max-width: calc(100% - [img_size + headspace]px);'>"
	cum += "<span style='font-weight: bold;'>[m_name]</span>" // already formatted!
	// now the button panel
	cum += "<table style='margin: 0 auto;'>"
	cum += "<tr>"
	cum += "<td style='width: 50%;'>"
	cum += m_charlink
	cum += "</td>"
	cum += "<td style='width: 50%;'>"
	cum += m_dmlink
	cum += "</td>"
	cum += "</tr>"
	cum += "<tr>"
	cum += "<td style='width: 50%;'>"
	cum += m_flirtlink
	cum += "</td>"
	cum += "<td style='width: 50%;'>"
	cum += m_interactlink
	cum += "</td>"
	cum += "</tr>"
	cum += "</table>"
	cum += "</div>"
	cum += "</div>"
	// now the body
	cum += "<div style='width: 100%; background: linear-gradient([bgangle]deg, [bgc_1], [bgc_2]); border: [bbs]px [bbt] [bbc]; padding: 2px;'>"
	cum += "<p style='font-weight: bold; margin: 0;'>[m_name] <span style='font-style: italic; color: [dtc];'>[m_verb]</span></p>"
	cum += "<p style='margin: 0; color: [dtc];'>[m_message]</p>"
	cum += "</div>"
	cum += "</div>"
	// now we need to send it to the target
	return cum.Join()






	// <!-- FurryHead -->
	// <div style="width: 100%; background: linear-gradient(0deg, #FFC0CB, #FF1493); border: 2px solid #FF69B4; display: flex;">
	// 	<!-- Profile Picture -->
	// 	<div style="height: 75px; width: 75px; background: #FFC0CB; border: 2px solid #FF1493; border-radius: 10px; margin: 2px;">
	// 		<img src="https://via.placeholder.com/75" style="height: 75px; width: 75px; border-radius: 10px;">
	// 	</div>
	// 	<!-- Rest of the Furryhead -->
	// 	<div style="flex-grow: 1; display: flex; flex-direction: column; justify-content: center; align-items: center;">
	// 	<!-- Button Panel -->
	// 		<span style="font-weight: bold; color:darkmagenta;">Foxxxy Vixen</span>
	// 		<div style="display: grid; grid-template-areas: 'profile dm' 'flirt yiff'; grid-gap: 2px;">
	// 			<button style="grid-area: profile; background: #FFC0CB; border: 2px solid #FF1493;">Profile</button>
	// 			<button style="grid-area: dm; background: #FFC0CB; border: 2px solid #FF1493;">DM</button>
	// 			<button style="grid-area: flirt; background: #FFC0CB; border: 2px solid #FF1493;">Flirt</button>
	// 			<button style="grid-area: yiff; background: #FFC0CB; border: 2px solid #FF1493;">Yiff</button>
	// 		</div>
	// 	</div>
	// </div>
	// <!-- FurryBody -->
	// <div style="width: 100%; background: linear-gradient(0deg, #FFC0CB, #FF1493); border: 2px solid #FF69B4; padding: 2px;">
	// 	<p style="font-weight: bold; margin: 0; color:darkmagenta;">Foxxxy Vixen <span style="font-style: italic;">asks,</span></p>
	// 	<p style="margin: 0; color: darkmagenta;">Hey there! How's it going? I was thinking we could go on a date sometime. What do you say?</p>


/datum/controller/subsystem/chat/proc/get_horny_pfp(m_rawmessage, list/m_images, m_mode)
	var/image2use = ""
	var/first_colon = findtext(m_rawmessage, ":")
	if(first_colon)
		var/list/splittify = splittext(m_rawmessage, ":")
		for(var/splut in splittify)
			var/testpart = ":[splut]:"
			if(findtext(m_rawmessage, testpart))
				if(m_images[testpart])
					var/list/imgz = m_images[testpart]
					if(imgz["URL"] != "" && imgz["Host"] != "")
						image2use = PfpHostLink(imgz["URL"], imgz["Host"])
	/// then extract the message mode and see if they have a corresponting image
	if(!image2use)
		var/list/testimages = m_images[m_mode]
		if(testimages["URL"] != "" && testimages["Host"] != "")
			image2use = PfpHostLink(testimages["URL"], testimages["Host"])
	// just grab their default one
	if(!image2use)
		var/list/testimages = m_images[MODE_SAY]
		if(testimages["URL"] != "" && testimages["Host"] != "")
			image2use = PfpHostLink(testimages["URL"], testimages["Host"])
	// if we still dont have one, just use a placeholder
	if(!image2use)
		image2use = "https://www.placehold.it/100x100.png"
	return image2use


/datum/controller/subsystem/chat/proc/build_flirt_datums()
	if(LAZYLEN(flirts))
		QDEL_LIST_ASSOC_VAL(flirts)
	flirts = list()
	flirts_all_categories = list()
	for(var/flt in subtypesof(/datum/flirt))
		new flt() // it knows what its do
	flirts_all_categories.Insert(1, "All Flirts")

/datum/controller/subsystem/chat/proc/run_directed_flirt(mob/living/flirter, mob/living/target, flirtkey)
	if(!istype(flirter) ||!istype(target) || !flirtkey)
		return
	var/datum/flirt/flirt = LAZYACCESS(flirts, flirtkey)
	if(!flirt)
		return
	return flirt.flirt_directed(flirter, target)

/datum/controller/subsystem/chat/proc/run_aoe_flirt(mob/living/flirter, flirtkey)
	if(!istype(flirter) ||!flirtkey)
		return
	var/datum/flirt/flirt = LAZYACCESS(flirts, flirtkey)
	if(!flirt)
		return
	return flirt.flirt_aoe(flirter)

/datum/controller/subsystem/chat/proc/flirt_occurred(mob/living/flirter, mob/living/target)
	add_flirt_target(flirter, target) // flirter FLIRTED with target
	add_flirt_recipient(flirter, target) // target WAS FLIRTED BY flirter
	ui_interact(flirter)
	// ui_interact(target)

/datum/controller/subsystem/chat/proc/add_flirt_target(mob/living/flirter, mob/living/target)
	if(!istype(flirter) ||!istype(target))
		return
	if(!flirter.ckey ||!target.ckey)
		return
	if(!flirter.client ||!target.client)
		return
	active_flirters[flirter.ckey] = target.ckey
	return TRUE

/datum/controller/subsystem/chat/proc/remove_flirt_target(mob/living/flirter)
	if(!istype(flirter))
		return
	if(!flirter.ckey)
		return
	if(!flirter.client)
		return
	active_flirters -= flirter.ckey
	return TRUE

/datum/controller/subsystem/chat/proc/get_flirt_target(mob/living/flirter)
	if(!istype(flirter))
		return
	if(!flirter.ckey)
		return
	if(!flirter.client)
		return
	var/TargetCkey = LAZYACCESS(active_flirters, flirter.ckey)
	if(!TargetCkey)
		return
	return ckey2mob(TargetCkey)

/datum/controller/subsystem/chat/proc/add_flirt_recipient(mob/living/flirter, mob/living/recipient)
	if(!istype(flirter) ||!istype(recipient))
		return
	if(!flirter.ckey ||!recipient.ckey)
		return
	if(!flirter.client ||!recipient.client)
		return
	active_flirtees[recipient.ckey] = flirter.ckey
	return TRUE

/datum/controller/subsystem/chat/proc/remove_flirt_recipient(mob/living/flirter)
	if(!istype(flirter))
		return
	if(!flirter.ckey)
		return
	if(!flirter.client)
		return
	active_flirtees -= flirter.ckey
	return TRUE

/datum/controller/subsystem/chat/proc/get_flirt_recipient(mob/living/flirter)
	if(!istype(flirter))
		return
	if(!flirter.ckey)
		return
	if(!flirter.client)
		return
	var/TargetCkey = LAZYACCESS(active_flirtees, flirter.ckey)
	if(!TargetCkey)
		return
	return ckey2mob(TargetCkey)

/// YES IM BLOWING CHAT'S TGUI LOAD ON FLIRTING, FIGHT ME
/datum/controller/subsystem/chat/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FlirtyFlirty")
		ui.open()
		ui.set_autoupdate(FALSE)

/// just holds the reader's target, if any
/datum/controller/subsystem/chat/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/heart = get_flirt_target(user)
	var/mob/living/hearted = get_flirt_recipient(user)
	data["DP"] = SSquirks.dp
	data["FlirterCkey"] = user ? user.ckey : "AAAGOOD" // nulls are falsy
	data["FlirterName"] = user ? user.name : "Some Dope"
	/// who WE last flirted with
	data["TargetCkey"] = heart ? heart.ckey : "AAAGOOD" // balls are nullsy
	data["TargetName"] = heart ? heart.name : "AAABAD"
	/// who last flirted with US
	data["LastFlirtedByCkey"] = hearted ? hearted.ckey : "AAAGOOD" // balls are nullsy
	data["LastFlirtedByName"] = hearted ? hearted.name : "AAABAD"
	return data

/// holds the whole enchilada
/datum/controller/subsystem/chat/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["AllFlirts"] = flirt_for_tgui
	static_data["AllCategories"] = flirts_all_categories
	return static_data

/datum/controller/subsystem/chat/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/living/flirter = ckey2mob(params["ReturnFlirterCkey"])
	if(!flirter)
		return // nobody flirted
	var/datum/flirt/F = LAZYACCESS(flirts, params["ReturnFlirtKey"])
	flirt_cooldowns[flirter.ckey] = world.time + flirt_cooldown_time
	var/mob/living/target = ckey2mob(params["ReturnTargetCkey"] || get_flirt_target(flirter))
	switch(action)
		if("ClearFlirtTarget")
			return remove_flirt_target(flirter)
		if("GiveFlirtTargetItem")
			return give_flirt_targetter_item(flirter)
		if("PreviewFlirt")
			if(!F)
				return
			return F.preview_flirt(flirter, target)
		if("PreviewSound")
			if(!F)
				return
			return F.preview_sound(flirter, target)
		if("ClickedFlirtButton")
			if(!F)
				return
			if(LAZYACCESS(flirt_cooldowns, flirter.ckey) < world.time)
				to_chat(flirter, span_warning("Hold your horses! You're still working on that last flirt!"))
				return
			return F.give_flirter(flirter)

/datum/controller/subsystem/chat/ui_state(mob/user)
	return GLOB.always_state

/datum/controller/subsystem/chat/proc/start_page(mob/sender, mob/reciever)
	if(!sender || !reciever)
		return
	sender = extract_mob(sender)
	if(!sender || !sender.client)
		return
	reciever = extract_mob(reciever)
	if(!reciever || !reciever.client)
		to_chat(sender, span_alert("Unable to contact user, please try again later!"))
		return
	if(is_blocked(sender, reciever))
		to_chat(sender, span_warning("Module failed to load."))
		return
	var/theirname = name_or_shark(reciever) || "some jerk" // stop. naming. your. ckeys. after. your characcteres!!!!!!!!!!!!!!!!!!
	var/sender_should_see_ckey = check_rights_for(extract_client(sender), R_ADMIN)
	if(sender_should_see_ckey)
		theirname = "[theirname] - [extract_ckey(reciever)]"  // we're an admin, we can see their name
	var/mesage = input(
		sender,
		"Enter your message to [theirname]. This will send a direct message to them, which they can reply to! Be sure to respect their OOC preferences, don't be a creep (unless they like it), and <i>have fun!</i>",
		"Direct OOC Message",
		""
	) as message|null
	if(!mesage)
		return
	var/myname = name_or_shark(sender) || "Anonymouse"
	var/recipient_should_see_ckey = check_rights_for(extract_client(reciever), R_ADMIN)
	if(recipient_should_see_ckey)
		myname = "[myname] - [extract_ckey(sender)]"  // we're an admin, we can see their name

	var/payload2them = "<u><b>From [dm_linkify(reciever, sender, myname)]</u></b>: [mesage]<br>"
	payload2them = span_private(payload2them)
	to_chat(reciever, span_private("<br><U>You have a new message from [name_or_shark(sender) || "Some jerk"]!</U><br>"))
	to_chat(reciever, payload2them)
	reciever.playsound_local(reciever, 'sound/effects/direct_message_recieved.ogg', 75, FALSE)

	var/payload2me = "<u><b>To [dm_linkify(sender, reciever, theirname)]</u></b>: [mesage]<br>"
	payload2me = span_private_sent(payload2me)
	to_chat(sender, span_private_sent("<br><U>Your message to [theirname] has been sent!</U><br>"))
	to_chat(sender, payload2me)
	sender.playsound_local(sender, 'sound/effects/direct_message_setn.ogg', 75, FALSE)

	log_ooc("[sender.real_name] ([sender.ckey]) -> [reciever.real_name] ([reciever.ckey]): [mesage]")
	message_admins("[ADMIN_TPMONTY(sender)] -DM-> [ADMIN_TPMONTY(reciever)]: [mesage]", ADMIN_CHAT_FILTER_DMS, list(sender, reciever))

/// takes in a sencer, a reciever, and an optional name, and turns it into a clickable link to send a DM
/datum/controller/subsystem/chat/proc/dm_linkify(mob/sender, mob/reciever, optional_name)
	if(!sender || !reciever)
		return
	sender = extract_mob(sender)
	if(!sender || !sender.client)
		return
	reciever = extract_mob(reciever)
	if(!reciever || !reciever.client)
		return
	var/theirname = optional_name || name_or_shark(reciever) || "Anonymouse" // stop. naming. your. ckeys. after. your characcteres!!!!!!!!!!!!!!!!!!
	
	return "<a href='?src=[REF(src)];DM=1;sender_quid=[REF(sender)];reciever_quid=[REF(reciever)]'>[theirname]</a>"

/datum/controller/subsystem/chat/Topic(href, list/href_list)
	. = ..()
	if(href_list["DM"])
		start_page(href_list["sender_quid"], href_list["reciever_quid"])

/datum/controller/subsystem/chat/proc/is_blocked(mob/sender, mob/reciever)
	return FALSE // todo: this

/datum/controller/subsystem/chat/proc/name_or_shark(mob/they)
	if(!istype(they))
		return "Nobody"
	if(check_rights(R_ADMIN, FALSE))
		return they.name || they.real_name
	if(ckey(they.real_name) == ckey(they.ckey) || ckey(they.name) == ckey(they.ckey))
		if(they.client)
			var/test_name = they.client.prefs.real_name
			if(ckey(test_name) == ckey(they.ckey))
				if(strings("data/super_special_ultra_instinct.json", "[ckey(test_name)]", TRUE, TRUE))
					return test_name
				if(strings("data/super_special_ultra_instinct.json", "[ckey(they.name)]", TRUE, TRUE))
					return test_name
				if(strings("data/super_special_ultra_instinct.json", "[ckey(they.real_name)]", TRUE, TRUE))
					return test_name
				if(they.ckey == "aldrictavalin") // tired of this not working
					return test_name
				return they.client.prefs.my_shark
			return test_name
		return safepick(GLOB.cow_names + GLOB.megacarp_first_names + GLOB.megacarp_last_names)
	return they.real_name

/datum/controller/subsystem/chat/proc/inspect_character(mob/viewer, list/payload)
	if(!viewer)
		return
	viewer = extract_mob(viewer)
	if(!viewer || !viewer.client)
		return
	var/datum/character_inspection/chai = LAZYACCESS(inspectors, viewer.client.prefs.quester_uid)
	if(!chai)
		chai = new()
		inspectors[viewer.client.prefs.quester_uid] = chai
	chai.update(viewer, payload)
	chai.show_to(viewer)
	return TRUE

/datum/controller/subsystem/chat/proc/flirt_debug_toggle()
	TOGGLE_VAR(flirt_debug)
	build_flirt_datums()
	message_admins("Flirt debug [flirt_debug?"on":"off"]")

/datum/controller/subsystem/chat/proc/give_flirt_targetter_item(mob/living/flirter)
	if(!isliving(flirter))
		return
	if(flirter.get_active_held_item() && flirter.get_inactive_held_item())
		to_chat(flirter, span_warning("My hands are too full to flirt! Yes, you need your hands to flirt."))
		return

	var/obj/item/hand_item/flirt_targetter/hiya = new(flirter)

	if(flirter.put_in_hands(hiya)) // NOTE: put_in_hand is MUCH different from put_in_hands - NOTE THE S
		to_chat(flirter, span_notice("Pick someone you want to flirt with! Just click on them while holding this, and it'll target them."))
		return TRUE
	else
		to_chat(flirter, span_warning("Something went wrong! Try a different approach~"))
		qdel(hiya)

/datum/controller/subsystem/chat/proc/can_usr_flirt_with_this(mob/A)
	if(!isliving(usr)) // fight me
		to_chat(usr, span_hypnophrase("Touch grass, you ghostly fucker. Spawn in to swap spit with them."))
		return
	if(isanimal(A) && !A.client)
		if(prob(1))
			to_chat(usr, span_hypnophrase("You're having a white woman moment."))
		else if(prob(10))
			to_chat(usr, span_hypnophrase("They probably wouldn't pass the Harkness test."))
		else
			to_chat(usr, span_hypnophrase("They're not in the right mood for flirting."))
		return
	// if(A == usr)
	// 	to_chat(usr, span_hypnophrase("I take a deep breath and psyche yourself up to flirt with someone other than yourself for a change. You got this, tiger!"))
	// 	return
	return TRUE

/mob/verb/check_out(mob/A as mob in view())
	set name = "Flirt with"
	set category = "IC"

	if(!SSchat.can_usr_flirt_with_this(A))
		return
	to_chat(src, span_notice("I get ready to flirt with [A]. What will you do?"))
	to_chat(src, span_notice("HOW TO USE: Click on the emote you want to use, and it'll direct a flirtatious message toward them! That's it! \
		Be sure to respect their OOC preferences, don't be a creep (unless they like it), and <i>have fun!</i>"))
	SSchat.add_flirt_target(src, A)
	SSchat.ui_interact(src)

/datum/emote/living/flirtlord
	key = "flirt"
	no_message = TRUE // we'll handle it from here =3

/datum/emote/living/flirtlord/run_emote(mob/user, params) //Player triggers the emote
	if(isdead(user))
		to_chat(user, span_warning("Nobody is interested in your cold dead heart, try rising from the grave with a fistful of flowers, should impress someone."))
		return
	if(user.stat == DEAD)
		to_chat(user, span_warning("You've got better things to do than flirt, such as being dead."))
		return
	if(LAZYLEN(params))
		var/whichm = text2num(params)
		if(isnum(whichm) && whichm > 0 && whichm <= LAZYLEN(SSchat.flirtsByNumbers))
			var/datum/flirt/F = LAZYACCESS(SSchat.flirtsByNumbers, whichm)
			if(F)
				return F.give_flirter(user)
	to_chat(user, span_notice("I get ready to flirt. What will you do? And who with?"))
	to_chat(user, span_notice("HOW TO USE: Click on the emote you want to use, and it'll give you a thing in your hand! Just click on whoever you want to send a flirtatious message to, or just use it in hand to send a message to everyone nearby. That's it! \
		Be sure to respect their OOC preferences, don't be a creep (unless they like it), and <i>have fun!</i>"))
	SSchat.ui_interact(user)


/datum/emoticon_bank
	var/key = ""
	var/list/say_messages = list()
	var/list/say_emotes = list()
	var/list/whisper_messages = list()
	var/list/whisper_emotes = list()
	var/list/sing_messages = list()
	var/list/sing_emotes = list()
	var/list/ask_messages = list()
	var/list/ask_emotes = list()
	var/list/exclaim_messages = list()
	var/list/exclaim_emotes = list()
	var/list/yell_messages = list()
	var/list/yell_emotes = list()

/datum/emoticon_bank/New(smiley, list/emot)
	. = ..()
	if(!islist(emot))
		return
	key = smiley
	var/list/saychunk = LAZYACCESS(emot, "SAY")
	say_messages = LAZYACCESS(saychunk, "MESSAGE")
	say_emotes = LAZYACCESS(saychunk, "EMOTE")
	var/list/whisperchunk = LAZYACCESS(emot, "WHISPER")
	whisper_messages = LAZYACCESS(whisperchunk, "MESSAGE")
	whisper_emotes = LAZYACCESS(whisperchunk, "EMOTE")
	var/list/singchunk = LAZYACCESS(emot, "SING")
	sing_messages = LAZYACCESS(singchunk, "MESSAGE")
	sing_emotes = LAZYACCESS(singchunk, "EMOTE")
	var/list/askchunk = LAZYACCESS(emot, "ASK")
	ask_messages = LAZYACCESS(askchunk, "MESSAGE")
	ask_emotes = LAZYACCESS(askchunk, "EMOTE")
	var/list/exclaimchunk = LAZYACCESS(emot, "EXCLAIM")
	exclaim_messages = LAZYACCESS(exclaimchunk, "MESSAGE")
	exclaim_emotes = LAZYACCESS(exclaimchunk, "EMOTE")
	var/list/yellchunk = LAZYACCESS(emot, "YELL")
	yell_messages = LAZYACCESS(yellchunk, "MESSAGE")
	yell_emotes = LAZYACCESS(yellchunk, "EMOTE")

	var/list/newsay_messages = list()
	for(var/msg in say_messages)
		newsay_messages += html_decode(msg)
	say_messages = newsay_messages
	var/list/newsay_emotes = list()
	for(var/msg in say_emotes)
		newsay_emotes += html_decode(msg)
	say_emotes = newsay_messages
	var/list/newwhisper_messages = list()
	for(var/msg in whisper_messages)
		newwhisper_messages += html_decode(msg)
	whisper_messages = newsay_messages
	var/list/newwhisper_emotes = list()
	for(var/msg in whisper_emotes)
		newwhisper_emotes += html_decode(msg)
	whisper_emotes = newsay_messages
	var/list/newsing_messages = list()
	for(var/msg in sing_messages)
		newsing_messages += html_decode(msg)
	sing_messages = newsay_messages
	var/list/newsing_emotes = list()
	for(var/msg in sing_emotes)
		newsing_emotes += html_decode(msg)
	sing_emotes = newsay_messages
	var/list/newask_messages = list()
	for(var/msg in ask_messages)
		newask_messages += html_decode(msg)
	ask_messages = newsay_messages
	var/list/newask_emotes = list()
	for(var/msg in ask_emotes)
		newask_emotes += html_decode(msg)
	ask_emotes = newsay_messages
	var/list/newexclaim_messages = list()
	for(var/msg in exclaim_messages)
		newexclaim_messages += html_decode(msg)
	exclaim_messages = newsay_messages
	var/list/newexclaim_emotes = list()
	for(var/msg in exclaim_emotes)
		newexclaim_emotes += html_decode(msg)
	exclaim_emotes = newsay_messages
	var/list/newyell_messages = list()
	for(var/msg in yell_messages)
		newyell_messages += html_decode(msg)
	yell_messages = newsay_messages
	var/list/newyell_emotes = list()
	for(var/msg in yell_emotes)
		newyell_emotes += html_decode(msg)
	yell_emotes = newsay_messages

/// takes in a message, extracts what the intent of the message is (say, ask, etc)
/// removes the emoticon, and returns a prefix to be used in the message
/// Also checks if its just the emoticon, and if so, return the emote message
/datum/emoticon_bank/proc/verbify(atom/movable/emoter, message, messagemode, list/spans = list())
	if(messagemode == MODE_CUSTOM_SAY)
		return // they'll handle it
	if(!emoter)
		return
	if(!findtext(message, key))
		return
	/// first lets check if its just the emoticon
	var/msg_sample = ckey(replacetext(message, key, ""))
	var/is_msg = msg_sample != ""
	var/is_emote = !is_msg
	var/foreverb = "smiles and nods"
	var/msgs = say_messages
	var/emts = say_emotes
	/// find the message mode / intent, if it isnt given (often isnt)
	if(!messagemode)
		/// okay now lets scan this message for intent
		var/list/characters = splittext(replacetext(message, key, ""), "") // minus the emoticon
		messagemode = MODE_SAY
		for(var/i in 1 to LAZYLEN(characters))
			var/char = characters[i]
			switch(char)
				if("?")
					messagemode = MODE_ASK
					if(LAZYACCESS(characters, i+1) == "!") // ?!
						break
				if("!")
					messagemode = MODE_EXCLAIM
					if(LAZYACCESS(characters, i+1) == "!") // !!
						messagemode = MODE_YELL
						break
					if(LAZYACCESS(characters, i+1) == "?" && LAZYACCESS(characters, i-1) != "!") // !?
						messagemode = MODE_ASK
						break

	switch(messagemode)
		if(MODE_SAY)
			msgs = say_messages
			emts = say_emotes
		if(MODE_WHISPER)
			msgs = whisper_messages
			emts = whisper_emotes
		if(MODE_SING)
			msgs = sing_messages
			emts = sing_emotes
		if(MODE_ASK)
			msgs = ask_messages
			emts = ask_emotes
		if(MODE_EXCLAIM)
			msgs = exclaim_messages
			emts = exclaim_emotes
		if(MODE_YELL)
			msgs = yell_messages
			emts = yell_emotes
			spans |= SPAN_YELL
	if(is_msg)
		if(LAZYLEN(msgs))
			foreverb = pick(msgs)
		else
			switch(messagemode)
				if(MODE_SAY)
					foreverb = emoter.verb_say
				if(MODE_WHISPER)
					foreverb = emoter.verb_whisper
				if(MODE_SING)
					foreverb = emoter.verb_sing
				if(MODE_ASK)
					foreverb = emoter.verb_ask
				if(MODE_EXCLAIM)
					foreverb = emoter.verb_exclaim
				if(MODE_YELL)
					foreverb = emoter.verb_yell
		foreverb = "[foreverb]," // the comma is important
	if(is_emote)
		if(LAZYLEN(emts))
			foreverb = pick(emts)
		else
			switch(messagemode)
				if(MODE_SAY)
					foreverb = emoter.verb_say
				if(MODE_WHISPER)
					foreverb = emoter.verb_whisper
				if(MODE_SING)
					foreverb = emoter.verb_sing
				if(MODE_ASK)
					foreverb = emoter.verb_ask
				if(MODE_EXCLAIM)
					foreverb = emoter.verb_exclaim
				if(MODE_YELL)
					foreverb = emoter.verb_yell
		foreverb = "[foreverb]" // the dot is important
	foreverb = replacify(emoter, foreverb, messagemode)
	/// foreverv is built! now lets tidy up the message block.
	if(is_emote)
		return emoter.attach_spans(foreverb, spans) // sike

	/// so we need to surgically extract our emoticon from the message. Easy? sorta, but we need to clean ourself up
	/// lets say the message is "hi :) how are you?" and the emoticon is ":)"
	/// we need to remove the emoticon, but that would leave us with "hi  how are you?", with two spaces
	/// so we need to remove the emoticon, and then remove any extra spaces, but not too many spaces!
	/// also this case: "hi how are you? :)" would leave us with "hi how are you? ", with a space at the end
	var/list/frontback = splittext(message, key) // split the message into two parts, before and after the emoticon
	if(LAZYLEN(frontback) != 2)
		return /// RRRRGH
	if(LAZYLEN(ckey(frontback[1])) < 1) // if the emoticon is at the start of the message, we need to remove the space at the start
		frontback[1] = ckey(frontback[1]) // remove the space
	if(LAZYLEN(ckey(frontback[2])) < 1) // if the emoticon is at the end of the message, we need to remove the space and punctuation at the end
		frontback[2] = ckey(frontback[2]) // remove the space and punctuation
	var/middlepart = "[frontback[1]][frontback[2]]"
	// clean up any extra spaces
	middlepart = replacetext(middlepart, "  ", " ") // remove double spaces
	// clean up any extra spaces at the end
	middlepart = trim(middlepart)
	if(isliving(emoter))
		var/mob/living/emo = emoter
		middlepart = emo.treat_message(middlepart)
	/// if the message now has a space and a period at the end, remove the space
	/// Now assemble the message! We have our prefix, and our middlepart, and we need to put them together
	/// add spans, add quotes, and that's it!
	middlepart = emoter.attach_spans("\"[middlepart]\"", spans)
	return "[foreverb] [middlepart]"

/datum/emoticon_bank/proc/replacify(atom/movable/emoter, message, messagemode)
	if(!emoter)
		return
	switch(messagemode)
		if(MODE_SAY)
			message = replacetext(message, "SAYVERBS", emoter.verb_say)
		if(MODE_WHISPER)
			message = replacetext(message, "WHISPERVERBS", emoter.verb_whisper)
		if(MODE_SING)
			message = replacetext(message, "SINGVERBS", emoter.verb_sing)
		if(MODE_ASK)
			message = replacetext(message, "ASKVERBS", emoter.verb_ask)
		if(MODE_EXCLAIM)
			message = replacetext(message, "EXCLAIMVERBS", emoter.verb_exclaim)
		if(MODE_YELL)
			message = replacetext(message, "YELLVERBS", emoter.verb_yell)
	message = replacetext(message, "THEIR", emoter.p_their())
	return message

////////////// so those datums were awful, maybe this one will be better
/datum/character_inspection // DROP YOUR PANTS, ITS CHARACTER INSPECTION DAY
	var/gender
	var/species
	var/vorepref
	var/erppref
	var/kisspref
	var/flink
	var/ad
	var/notes
	var/flavor
	var/their_quid
	var/looking_for_friends
	var/dms_r_open
	var/name
	var/profile_pic

	/// update the character inspection with new data
/datum/character_inspection/proc/update(mob/viewer, list/payload)
	if(!payload)
		return
	gender = payload["gender"]
	species = payload["species"]
	vorepref = payload["tag"]
	erppref = payload["erptag"]
	kisspref = payload["whokisser"]
	flink = payload["flist"]
	ad = payload["character_ad"]
	notes = payload["ooc_notes"]
	flavor = payload["flavor_text"]
	their_quid = payload["quid"]
	looking_for_friends = payload["looking_for_friends"]
	dms_r_open = TRUE
	name = payload["name"]
	profile_pic = payload["profile_pic"]
	if(viewer && viewer.client)
		show_to(viewer)

	/// show the character inspection to the viewer
/datum/character_inspection/proc/show_to(mob/viewer)
	ui_interact(viewer)

/datum/character_inspection/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterInspection")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/character_inspection/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["gender"] = gender
	static_data["species"] = species
	static_data["vorepref"] = vorepref
	static_data["erppref"] = erppref
	static_data["kisspref"] = kisspref
	static_data["flink"] = flink
	static_data["ad"] = html_decode(ad)
	static_data["notes"] = html_decode(notes)
	static_data["flavor"] = html_decode(flavor)
	static_data["their_quid"] = their_quid
	static_data["name"] = name
	static_data["looking_for_friends"] = looking_for_friends
	static_data["dms_r_open"] = TRUE
	static_data["profile_pic"] = profile_pic
	if(user && user.client) // dont know why they wouldnt, but whatever
		static_data["viewer_quid"] = user.client.prefs.quester_uid
	return static_data

/datum/character_inspection/ui_act(action, list/params)
	. = ..()
	if(!params["viewer_quid"])
		return
	var/mob/viower = extract_mob(params["viewer_quid"])
	if(!viower) // warning: sum of dis chapta is extremely scray
		return // viower excretion advisd
	var/mob/viowed = extract_mob(params["their_quid"])
	if(!viowed)
		return
	if(action == "pager")
		SSchat.start_page(viower, viowed)
		return TRUE
	if(action == "show_pic")
		var/dat = {"
			<img src='[profile_pic]' width='100%' height='100%' 'object-fit: scale-down;'>
			<br>
			[profile_pic] <- Copy this link to your browser to view the full sized image.
		"}
		var/datum/browser/popup = new(viower, "enlargeImage", "Full Sized Picture!",1024,768)
		popup.set_content(dat)
		popup.open()
		return TRUE
	if(action == "view_flist")
		if(viowed)
			to_chat(viower, span_notice("Opening F-list..."))
			SEND_SIGNAL(viowed, COMSIG_FLIST, viower)
			return TRUE
		else
			to_chat(viower, span_alert("Couldn't find that character's F-list!"))
			return TRUE
	return TRUE

/datum/character_inspection/ui_state(mob/user)
	return GLOB.always_state

/mob/verb/direct_message(mob/A as mob in view(10, src))
	set name = "Direct Message"
	set category = "OOC"
	set desc = "Send a direct message to this character."
	set popup_menu = TRUE

	SSchat.start_page(src, A)

/// Hi! I'm the thing that holds the stuff for the horny mommychat setup thing
/datum/horny_tgui_holder
	var/ownerkey
	/// HornyChat supports copypasting! Rejoice!
	var/list/clipboard = list()
	// var/datum/horny_stock_image_tgui_holder/hsith // dewit


/datum/horny_tgui_holder/New(okey)
	. = ..()
	ownerkey = okey
	// hsith = new(ownerkey)

/datum/horny_tgui_holder/proc/OpenPrefsMenu()
	var/mob/M = ckey2mob(ownerkey)
	if(!M)
		return
	ui_interact(M)

/datum/horny_tgui_holder/ui_state(mob/user)
	return GLOB.always_state

/datum/horny_tgui_holder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HornyChat") // yes Im calling it that
		ui.open()


/datum/horny_tgui_holder/ui_static_data(mob/user)
	var/list/data = list()
	var/datum/preferences/P = extract_prefs(user)
	/// first, the stock images
	/// not using em lol
	/// then, the user's images
	SSchat.SanitizeUserImages(P)
	SSchat.SanitizeUserPreferences(P)
	data["UserImages"] = P.ProfilePics
	/// Also all the previews
	var/list/previewmsgs = list()
	/// Anatomy of a msgmode entry in ProfilePics:
	/// list(
	///      "NameOfTheMode" = list(
	///           "Host" = "www.catbox.moe", // or something
	///           "URL" = "image.png",
	///      ),
	/// etc
	/// )
	/// Anatomy of a preview message:
	/// list(
	///      list(
	///           "[msgmode]" = "long html thing"
	///      ),
	/// etc
	for(var/list/modus in P.ProfilePics)
		var/msgmode = modus["Mode"]
		var/message2say = "Hi."
		switch(msgmode)
			if(MODE_SAY)
				message2say = "Hello! You are hearing me talk. I am saying words. I am saying words to you. \
				I am saying words to you in a friendly manner. I am not yelling, I am not whispering, I am not singing, \
				I am not asking, I am not exclaiming. I am saying words to you, and you are hearing them. And now I am done. Hi."
			if(MODE_WHISPER)
				message2say = "#Psst, hey! Wanna know a secret? I'm whispering to you. This is what its like for you to \
				whisper, and what other people will see when you whisper to them. Does it look like I'm whispering? \
				You can tell by my profile picture that whispering is taking place. And now I'm done. Hi."
			if(MODE_SING)
				message2say = "%Allow me to sing the song of my people: ACK ACAKCHA AKGH CKCKHHGN YIP YIP YAKCGH EE EI EEI \
				GEKKER GEKKER ACK GACK AKCH TCHOFF AHC IA IA TEKALI-LI RLYEA CTHULHU FTAGHN YIPYIP! And now I'm done. Hi."
			if(MODE_ASK)
				message2say = "Hello? Is this thing on? So tell me, how many licks does it take to get to the center of a vixen? \
				Can you help me find out? Wanna go on a date and help em find out how many licks it takes to get to the center of a vixen? \
				What if it's more than one? What if it's less than one? What if it's exactly one? And now I'm done? Hi?"
			if(MODE_EXCLAIM)
				message2say = "Wow! I'm so excited! I'm so excited to be here! I'm so excited to be talking to you! \
				This is so exciting! I'm so excited! I'm so excited! I'm so excited! I'm so excited! I'm so excited! \
				I'm so excited! I'm so excited! I'm so excited! I'm so excited! I'm so excited! I'm so excited! \
				And now I'm done! Hi!"
			if(MODE_YELL)
				message2say = "$AAAAAAAAAAAAAAAAAAAAAAAA AAAAAA AAAAAAAAAA A AAAAAAAAAA AAAAAAAAAAAAAAAAAAAA AAAAAAAAA \
				AAAAAAAAA A AAA AAAAAAAAAAA AAAAAAAAAA AAAAAAAAAA AAA AAAAAAA AAAAAA AAAA A A AA AAAAAAAA AAA AAAA AAAA \
				AA A A AA A AAA A A AAAAAAAAAAAAAA AAA A A AAA  AAAAAAAAAAAA A AAAA A A A AA AAAAAAAAAAAAAAAAA AAAAAA \
				AND NOW IM DONE!! HI!!"
			else
				message2say = "Hi, this is a test of a custom message mode that has been set by you to be used to display \
				a custom message mode. The mode is set to [replacetext(msgmode, ":","")]. If the previous sentence was \
				cut off, please make a note of it. Cool huh? And now I'm done. Hi. [msgmode]"
		var/msgmess = SSchat.PreviewHornyFurryDatingSimMessage(user, null, message2say, FALSE)
		previewmsgs += list(list("Mode" = msgmode, "Message" = msgmess))
	data["NumbermalMin"] = SSchat.numbermal_min
	data["NumbermalMax"] = SSchat.numbermal_max
	data["PreviewHTMLs"] = previewmsgs
	/// Then, the message appearance settings, its a mmouthful (just like your mom)
	/// arranged by tab of course of course
	data["TopBox"] = list()
	data["BottomBox"] = list()
	data["Buttons"] = list()
	data["OuterBox"] = list()
	data["ImageBox"] = list()
	for(var/mmode in P.mommychat_settings)
		// First, the top box settings
		var/list/topfox = list()
		topfox["Mode"] = mmode
		topfox["Name"] = "Top Box"
		topfox["Settings"] = list()
		topfox["Settings"] += list(
			list(
				"Name" = "Gradient 1",
				"Val" = P.mommychat_settings[mmode]["TopBoxGradient1"],
				"Type" = "COLOR",
				"Loc" = "L",
				"PKey" = "TopBoxGradient1",
				"Desc" = "The first color of the gradient for the top box.",
				"Default" = "000000"
			),
			list(
				"Name" = "Gradient 2",
				"Val" = P.mommychat_settings[mmode]["TopBoxGradient2"],
				"Type" = "COLOR",
				"Loc" = "L",
				"PKey" = "TopBoxGradient2",
				"Desc" = "The second color of the gradient for the top box.",
				"Default" = "000000"
			),
			list(
				"Name" = "Gradient Angle",
				"Val" = P.mommychat_settings[mmode]["TopBoxGradientAngle"],
				"Type" = "NUMBER",
				"Loc" = "L",
				"PKey" = "TopBoxGradientAngle",
				"Desc" = "The angle of the gradient for the top box.",
				"Default" = "0"
			),
			list(
				"Name" = "Border Color",
				"Val" = P.mommychat_settings[mmode]["TopBoxBorderColor"],
				"Type" = "COLOR",
				"Loc" = "R",
				"PKey" = "TopBoxBorderColor",
				"Desc" = "The color of the border for the top box.",
				"Default" = "000000"
			),
			list(
				"Name" = "Border Width",
				"Val" = P.mommychat_settings[mmode]["TopBoxBorderWidth"],
				"Type" = "NUMBER",
				"Loc" = "R",
				"PKey" = "TopBoxBorderWidth",
				"Desc" = "The width of the border for the top box.",
				"Default" = "1"
			),
			list(
				"Name" = "Border Style",
				"Val" = P.mommychat_settings[mmode]["TopBoxBorderStyle"],
				"Type" = "SELECT",
				"Loc" = "R",
				"PKey" = "TopBoxBorderStyle",
				"Desc" = "The style of the border for the top box.",
				"Default" = "solid",
				"Options" = SSchat.borderstyles
			),
		)
		data["TopBox"] += list(topfox)
		// Then, the bottom box settings
		var/list/bottomfox = list()
		bottomfox["Mode"] = mmode
		bottomfox["Name"] = "Message Box"
		bottomfox["Settings"] = list()
		bottomfox["Settings"] += list(
			list(
				"Name" = "Gradient 1",
				"Val" = P.mommychat_settings[mmode]["BottomBoxGradient1"],
				"Type" = "COLOR",
				"Loc" = "L",
				"PKey" = "BottomBoxGradient1",
				"Desc" = "The first color of the gradient for the bottom box.",
				"Default" = "000000"
			),
			list(
				"Name" = "Gradient 2",
				"Val" = P.mommychat_settings[mmode]["BottomBoxGradient2"],
				"Type" = "COLOR",
				"Loc" = "L",
				"PKey" = "BottomBoxGradient2",
				"Desc" = "The second color of the gradient for the bottom box.",
				"Default" = "000000"
			),
			list(
				"Name" = "Gradient Angle",
				"Val" = P.mommychat_settings[mmode]["BottomBoxGradientAngle"],
				"Type" = "NUMBER",
				"Loc" = "L",
				"PKey" = "BottomBoxGradientAngle",
				"Desc" = "The angle of the gradient for the bottom box.",
				"Default" = "0"
			),
			list(
				"Name" = "Border Color",
				"Val" = P.mommychat_settings[mmode]["BottomBoxBorderColor"],
				"Type" = "COLOR",
				"Loc" = "R",
				"PKey" = "BottomBoxBorderColor",
				"Desc" = "The color of the border for the bottom box.",
				"Default" = "000000"
			),
			list(
				"Name" = "Border Width",
				"Val" = P.mommychat_settings[mmode]["BottomBoxBorderWidth"],
				"Type" = "NUMBER",
				"Loc" = "R",
				"PKey" = "BottomBoxBorderWidth",
				"Desc" = "The width of the border for the bottom box.",
				"Default" = "1"
			),
			list(
				"Name" = "Border Style",
				"Val" = P.mommychat_settings[mmode]["BottomBoxBorderStyle"],
				"Type" = "SELECT",
				"Loc" = "R",
				"PKey" = "BottomBoxBorderStyle",
				"Desc" = "The style of the border for the bottom box.",
				"Default" = "solid",
				"Options" = SSchat.borderstyles
			),
		)
		data["BottomBox"] += list(bottomfox)
		// Then, the button settings
		var/list/buttonfox = list()
		buttonfox["Mode"] = mmode
		buttonfox["Name"] = "Buttons"
		buttonfox["Settings"] = list()
		buttonfox["Settings"] += list(
			list(
				"Name" = "Gradient 1",
				"Val" = P.mommychat_settings[mmode]["ButtonGradient1"],
				"Type" = "COLOR",
				"Loc" = "L",
				"PKey" = "ButtonGradient1",
				"Desc" = "The first color of the gradient for the buttons.",
				"Default" = "000000"
			),
			list(
				"Name" = "Gradient 2",
				"Val" = P.mommychat_settings[mmode]["ButtonGradient2"],
				"Type" = "COLOR",
				"Loc" = "L",
				"PKey" = "ButtonGradient2",
				"Desc" = "The second color of the gradient for the buttons.",
				"Default" = "000000"
			),
			list(
				"Name" = "Gradient Angle",
				"Val" = P.mommychat_settings[mmode]["ButtonGradientAngle"],
				"Type" = "NUMBER",
				"Loc" = "L",
				"PKey" = "ButtonGradientAngle",
				"Desc" = "The angle of the gradient for the buttons.",
				"Default" = "0"
			),
			list(
				"Name" = "Border Color",
				"Val" = P.mommychat_settings[mmode]["ButtonBorderColor"],
				"Type" = "COLOR",
				"Loc" = "R",
				"PKey" = "ButtonBorderColor",
				"Desc" = "The color of the border for the buttons.",
				"Default" = "000000"
			),
			list(
				"Name" = "Border Width",
				"Val" = P.mommychat_settings[mmode]["ButtonBorderWidth"],
				"Type" = "NUMBER",
				"Loc" = "R",
				"PKey" = "ButtonBorderWidth",
				"Desc" = "The width of the border for the buttons.",
				"Default" = "1"
			),
			list(
				"Name" = "Border Style",
				"Val" = P.mommychat_settings[mmode]["ButtonBorderStyle"],
				"Type" = "SELECT",
				"Loc" = "R",
				"PKey" = "ButtonBorderStyle",
				"Desc" = "The style of the border for the buttons.",
				"Default" = "solid",
				"Options" = SSchat.borderstyles
			),
		)
		data["Buttons"] += list(buttonfox)
		/// Then, the Image Border settings
		var/list/imagefox = list()
		imagefox["Mode"] = mmode
		imagefox["Name"] = "Image Border"
		imagefox["Settings"] = list()
		imagefox["Settings"] += list(
			list(
				"Name" = "Border Color",
				"Val" = P.mommychat_settings[mmode]["ImageBorderBorderColor"],
				"Type" = "COLOR",
				"Loc" = "L",
				"PKey" = "ImageBorderBorderColor",
				"Desc" = "The color of the border for the images.",
				"Default" = "000000"
			),
			list(
				"Name" = "Border Width",
				"Val" = P.mommychat_settings[mmode]["ImageBorderBorderWidth"],
				"Type" = "NUMBER",
				"Loc" = "L",
				"PKey" = "ImageBorderBorderWidth",
				"Desc" = "The width of the border for the images.",
				"Default" = "1"
			),
			list(
				"Name" = "Border Style",
				"Val" = P.mommychat_settings[mmode]["ImageBorderBorderStyle"],
				"Type" = "SELECT",
				"Loc" = "L",
				"PKey" = "ImageBorderBorderStyle",
				"Desc" = "The style of the border for the images.",
				"Default" = "solid",
				"Options" = SSchat.borderstyles
			),
		)
		data["ImageBox"] += list(imagefox)
		/// And finally the Outer Box settings
		var/list/outerfox = list()
		outerfox["Mode"] = mmode
		outerfox["Name"] = "Outer Box"
		outerfox["Settings"] = list()
		outerfox["Settings"] += list(
			list(
				"Name" = "Border Color",
				"Val" = P.mommychat_settings[mmode]["OuterBoxBorderColor"],
				"Type" = "COLOR",
				"Loc" = "L",
				"PKey" = "OuterBoxBorderColor",
				"Desc" = "The color of the border for the outer box.",
				"Default" = "000000"
			),
			list(
				"Name" = "Border Width",
				"Val" = P.mommychat_settings[mmode]["OuterBoxBorderWidth"],
				"Type" = "NUMBER",
				"Loc" = "L",
				"PKey" = "OuterBoxBorderWidth",
				"Desc" = "The width of the border for the outer box.",
				"Default" = "1"
			),
			list(
				"Name" = "Border Style",
				"Val" = P.mommychat_settings[mmode]["OuterBoxBorderStyle"],
				"Type" = "SELECT",
				"Loc" = "L",
				"PKey" = "OuterBoxBorderStyle",
				"Desc" = "The style of the border for the outer box.",
				"Default" = "solid",
				"Options" = SSchat.borderstyles
			),
		)
		data["OuterBox"] += list(outerfox)
	return data

/* 
 * IMPORTANT NAMING CONVENTIONS
 * Strings sent TO TGUI are in the format "ModeName" (e.g. "TopBoxGradient1")
 * Strings sent FROM TGUI are in the format "ModeName" (e.g. "TopBoxGradient1")
 * Clipboard VALUES STORED in the format "lowercase_name" (e.g. "profilepic")
 * Clipboard are SENT TO TGUI in the format "ModeName" (e.g. "ProfilePic")
 * Horny Images are stored as BYOND sees them in the code (e.g. "say" or "%")
 * screw it, everything is in ModeName format
 * 
 *  */

/datum/horny_tgui_holder/ui_act(action, list/params)
	. = ..()
	if(!params["UserCkey"])
		return
	var/mob/M = ckey2mob(params["UserCkey"])
	if(!M)
		return
	var/datum/preferences/P = extract_prefs(M)
	if(!P)
		return
	switch(action)
		if("ModifyProfileEntry")
			var/mode = params["Mode"]
			var/newmode = params["NewMode"]
			var/host = params["Host"]
			var/url = params["URL"]
			var/list/ProfilePics = P.ProfilePics // operates directly on the referenced list, hopefully
			var/list/fount
			for(var/list/entry in ProfilePics)
				if(entry["Mode"] == mode)
					fount = entry
			if(fount)
				if(newmode)
					fount["Mode"] = newmode
				else
					fount["Mode"] = mode
				fount["Host"] = host
				fount["URL"] = url
			else
				to_chat(M, span_alert("Unable to modify profile entry for [mode2string(mode)], entry not found! :c"))
				return FALSE
			to_chat(M, span_notice("Profile entry for [mode2string(mode)] has been updated!"))
			. = TRUE
		/// hey github copilot, what is your favorite color of fox?
		/// "I like
		/// the color of
		/// the fox
		/// that is
		/// the color
		/// of the
		/// fox that
		/// is the
		/// color of
		/// the fox // good talking to you, copilot
		if("CopyImage")
			var/mode = params["Mode"]
			var/list/ProfilePics = P.ProfilePics
			var/list/fount
			for(var/list/entry in ProfilePics)
				if(entry["Mode"] == mode)
					fount = entry
			if(fount) //
				var/list/clip = list(
					"Mode" = fount["Mode"],
					"Host" = fount["Host"],
					"URL" = fount["URL"],
				)
				clipboard["ProfilePic"] = clip
				to_chat(M, span_notice("Profile entry for [mode2string(mode)] has been copied to the clipboard!"))
				. = TRUE
			else
				to_chat(M, span_alert("Unable to copy profile entry for [mode2string(mode)], entry not found! :c"))
				return FALSE
		if("PasteImage")
			var/mode = params["Mode"]
			var/list/ProfilePics = P.ProfilePics
			var/list/clip = clipboard["ProfilePic"]
			if(clip)
				var/list/fount
				for(var/list/entry in ProfilePics)
					if(entry["Mode"] == mode)
						fount = entry
				if(fount)
					fount["Mode"] = clip["Mode"]
					fount["Host"] = clip["Host"]
					fount["URL"] = clip["URL"]
					to_chat(M, span_notice("Profile entry for [mode2string(mode)] has been pasted from the clipboard!"))
					. = TRUE
				else
					to_chat(M, span_alert("Unable to paste profile entry for [mode2string(mode)], entry not found! :c"))
					return FALSE
			else
				to_chat(M, span_alert("Unable to paste profile entry for [mode2string(mode)], clipboard is empty! :c"))
				return FALSE
		if("ClearProfileEntry")
			var/mode = params["Mode"]
			var/list/ProfilePics = P.ProfilePics
			var/list/fount
			for(var/list/entry in ProfilePics)
				if(entry["Mode"] == mode)
					fount = entry
			if(fount)
				if(mode in SSchat.mandatory_modes)
					// just reset it
					fount["Host"] = "www.catbox.moe"
					switch(mode)
						if(MODE_SAY)
							fount["URL"] = "say.png" // replace these
						if(MODE_WHISPER)
							fount["URL"] = "whisper.png" // with the actual
						if(MODE_SING)
							fount["URL"] = "sing.png" // images
						if(MODE_ASK)
							fount["URL"] = "ask.png" // for the
						if(MODE_EXCLAIM)
							fount["URL"] = "exclaim.png" // modes
						if(MODE_YELL)
							fount["URL"] = "yell.png" // you yiff
						else
							fount["URL"] = "say.png" // you lose
					to_chat(M, span_notice("Profile entry for [mode2string(mode)] has been reset!"))
				else
					ProfilePics -= fount
					to_chat(M, span_notice("Profile entry for [mode2string(mode)] has been removed!"))
				. = TRUE
			else
				to_chat(M, span_alert("Unable to clear profile entry for [mode2string(mode)], entry not found! :c"))
				return FALSE
		if("EditColor") // we'll handle this one
			var/pisskey = params["PKey"]
			var/mode = params["Mode"]
			var/current = params["Current"]
			if(!(pisskey in SSchat.colorable_keys))
				to_chat(M, span_alert("Unable to edit color for [mode2string(mode)], mode is not colorable! This is probably a bug :c"))
				return FALSE
			var/val = input(
				M,
				"Enter a new color for the [pisskey] of the [mode2string(mode)]!",
				"Tripod like a real AngelFire",
				current
			) as color|null
			if(!istext(val))
				to_chat(M, span_alert("Nevermind!!"))
			P.mommychat_settings[mode][pisskey] = val
			to_chat(M, span_notice("Color for [mode2string(mode)] [pisskey] has been updated to #[val]!"))
			. = TRUE
		if("EditNumber") // TGUI handled this one
			var/pisskey = params["PKey"]
			var/mode = params["Mode"]
			var/newval = params["Val"]
			if(!(pisskey in SSchat.numberable_keys))
				to_chat(M, span_alert("Unable to edit number for [mode2string(mode)], mode is not numberable! This is probably a bug :c"))
				return FALSE
			P.mommychat_settings[mode][pisskey] = newval
			to_chat(M, span_notice("Number for [mode2string(mode)] [pisskey] has been updated to [newval]!"))
			. = TRUE
		if("EditSelect") // TGUI handled this one
			var/pisskey = params["PKey"]
			var/mode = params["Mode"]
			var/newval = params["Val"]
			if(!(pisskey in SSchat.selectable_keys))
				to_chat(M, span_alert("Unable to edit select for [mode2string(mode)], mode is not selectable! This is probably a bug :c"))
				return FALSE
			P.mommychat_settings[mode][pisskey] = newval
			to_chat(M, span_notice("Select for [mode2string(mode)] [pisskey] has been updated to [newval]!"))
			. = TRUE
		if("CopySetting")
			var/pisskey = params["PKey"]
			var/mode = params["Mode"]
			var/list/horny_settings = P.mommychat_settings
			var/list/fount
			for(var/list/entry in horny_settings[mode])
				if(entry["PKey"] == pisskey)
					fount = entry
			if(fount)
				var/list/clip = list(
					"Mode" = fount["Mode"],
					"PKey" = pisskey,
					"Val" = fount[pisskey],
				)
				clipboard["MsgSetting"] = clip
				to_chat(M, span_notice("Setting for [mode2string(mode)] [pisskey] has been copied to the clipboard!"))
				. = TRUE
			else
				to_chat(M, span_alert("Unable to copy setting for [mode2string(mode)] [pisskey], setting not found! :c"))
				return FALSE
		if("PasteSetting")
			var/pisskey = params["PKey"]
			var/mode = params["Mode"]
			var/list/horny_settings = P.mommychat_settings
			var/list/clip = clipboard["MsgSetting"]
			if(clip)
				// first check if this setting can accept the value
				if((clip["PKey"] in SSchat.colorable_keys) && (pisskey in SSchat.colorable_keys)\
				|| (clip["PKey"] in SSchat.numberable_keys) && (pisskey in SSchat.numberable_keys)\
				|| (clip["PKey"] in SSchat.selectable_keys) && (pisskey in SSchat.selectable_keys))
					horny_settings[mode][pisskey] = clip["Val"]
					to_chat(M, span_notice("Setting for [mode2string(mode)] [pisskey] has been pasted from the clipboard!"))
					. = TRUE
				else
					to_chat(M, span_alert("Unable to paste setting for [mode2string(mode)] [pisskey], setting type mismatch! :c"))
					return FALSE
			else
				to_chat(M, span_alert("Unable to paste setting for [mode2string(mode)] [pisskey], clipboard is empty! :c"))
				return FALSE

/datum/horny_tgui_holder/proc/mode2string(mode)
	switch(mode)
		if(MODE_SAY)
			return "Say"
		if(MODE_WHISPER)
			return "Whisper"
		if(MODE_SING)
			return "Sing"
		if(MODE_ASK)
			return "Ask"
		if(MODE_EXCLAIM)
			return "Exclaim"
		if(MODE_YELL)
			return "Yell"
	return "[mode]"


