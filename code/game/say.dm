/*
Miauw's big Say() rewrite.
This file has the basic atom/movable level speech procs.
And the base of the send_speech() proc, which is the core of saycode.
*/

/atom/movable/proc/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, just_chat)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	if(SSrentaldatum.chat_uses_mommy)
		var/datum/rental_mommy/mommychat = SSrentaldatums.CheckoutMommy(MOMMY_CHAT)
		mommychat.original_message = message
		mommychat.message = mommychat.original_message
		mommychat.spans = spans
		mommychat.language = language
		if(!mommychat.language)
			mommychat.language = get_selected_language()
		mommychat.message_mode = get_message_mode(message, mommychat)
		mommychat.source = src
		mommychat.just_chat = just_chat
		mommychat.forced = forced
		mommychat.ignore_spam = ignore_spam
		mommychat.sanitize = sanitize
		send_speech(range = SSchat.base_say_distance, mommychat = mommychat)
		RETURN_MOMMY(mommychat)
	spans |= speech_span
	if(!language)
		language = get_selected_language()
	send_speech(message, 7, src, , spans, message_language=language, just_chat = just_chat)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, atom/movable/source, just_chat, list/data, datum/rental_mommy/mommychat)
	var/sigret = SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)
	if(mommychat && !(sigret & KEEP_MOMMYCHAT))
		RETURN_MOMMY(mommychat)

/atom/movable/proc/can_speak()
	return 1

/// If MommyChat is enabled, this proc will take our mommychat datum, and make an edited copy for each of the listeners in view.
/// If MommyChat is disabled, this proc will just do what it says in the help file, which is to say I dont really know
/atom/movable/proc/send_speech(
	message,
	range = 7,
	atom/movable/source = src,
	bubble_type,
	list/spans,
	datum/language/message_language = null,
	message_mode,
	just_chat,
	datum/rental_mommy/mommychat
)
	if(SSrentaldatum.chat_uses_mommy && !mommychat)
		CRASH("send_speech() called without a mommychat datum")
	if(mommychat)
		for(var/_AM in get_hearers_in_view(range, source))
			var/datum/rental_mommy/mom2 = SSrentaldatums.CheckoutMommy(MOMMY_CHAT)
			mom2.copy_mommy(mommychat)
			compose_message(mommychat = mom2)
			var/atom/movable/AM = _AM
			mom2.hearer = AM
			AM.Hear(rendered, src, message_language, message, , spans, message_mode, source, just_chat, mommychat = mom2)
			return // Hear will return the mommychat if needed
	var/rendered = compose_message(src, message_language, message, , spans, message_mode, source, mommychat)
	for(var/_AM in get_hearers_in_view(range, source))
		var/atom/movable/AM = _AM
		AM.Hear(rendered, src, message_language, message, , spans, message_mode, source, just_chat, mommychat)

/// The mommychat is the chat packet that we were given, copied from the original chat packet and modified to make sense to us
/// without mommychat, it returns the rendered message
/// otherwise, it just edits the mommychat and returns TRUE
/atom/movable/proc/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode, face_name = FALSE, atom/movable/source, datum/rental_mommy/mommychat)
	if(!source)
		source = speaker
	if(SSrentaldatum.chat_uses_mommy && !mommychat)
		CRASH("compose_message() called without a mommychat datum")
	if(mommychat)
		//This proc uses text() because it is faster than appending strings. Thanks BYOND. //i'll append my strings to your mom
		//Radio freq/name display
		if(mommychat.radio_freq)
			mommychat.outer_span_class = get_radio_span(radio_freq)
			mommychat.radio_rendered = "\[[get_radio_name(radio_freq)]\] "
		else
			mommychat.outer_span_class = "game say"
			mommychat.radio_rendered = ""
		mommychat.outer_span_class_rendered = "<span class='[mommychat.outer_span_class]'>"
		mommychat.name_span_class = "name"
		mommychat.name_span_class_rendered = "<span class='[mommychat.name_span_class]'>"
		mommychat.speaker_voice = speaker.GetVoice()
		mommychat.speaker_alt_name = speaker.get_alt_name()
		mommychat.speaker_rendered = "[mommychat.speaker_voice][mommychat.speaker_alt_name]"
		//Speaker name
		if(mommychat.face_name && ishuman(mommychat.speaker))
			var/mob/living/carbon/human/H = speaker
			mommychat.speaker_rendered = "[H.get_face_name()]" //So "fake" speaking like in hallucinations does not give the speaker away if disguised
		// language icon stuff
		mommychat.language_icon = ""
		var/datum/language/D = GLOB.language_datum_instances[message_language]
		if(istype(D) && D.display_icon(src))
			mommychat.language_icon = "[D.get_icon()] "
		// track href stuff
		mommychat.track_href = compose_track_href(mommychat.speaker, mommychat.speaker_rendered)
		// job stuff
		mommychat.job_rendered = compose_job(mommychat.speaker, mommychat.message_language, mommychat.original_message, mommychat.radio_freq)
		// the actual message
		/// scramble for non-understanders
		lang_treat(mommychat = mommychat)
		/// Set the message mode, and the default sayverb for the message.
		mommy_message_mode(mommychat)
		/// wrap the message in spans
		attach_spans(mommychat = mommychat)
		/// make a quotationed message
		say_quote(mommychat = mommychat)
		mommychat.message_rendered = "<span class='message'>[mommychat.message_rendered]</span></span>"
		mommychat.message_rendered_quoted = "<span class='message'>[mommychat.message_rendered_quoted]</span></span>"
		return TRUE

	//This proc uses text() because it is faster than appending strings. Thanks BYOND.
	//Basic span
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	//Start name span.
	var/spanpart2 = "<span class='name'>"
	//Radio freq/name display
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	//Speaker name
	if(face_name && ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		namepart = "[H.get_face_name()]" //So "fake" speaking like in hallucinations does not give the speaker away if disguised
	//End name span.
	var/endspanpart = "</span>"
	
	//Message
	var/messagepart = " <span class='message'>[lang_treat(speaker, message_language, raw_message, spans, message_mode)]</span></span>"

	var/languageicon = ""
	var/datum/language/D = GLOB.language_datum_instances[message_language]
	if(istype(D) && D.display_icon(src))
		languageicon = "[D.get_icon()] "

	return "[spanpart1][spanpart2][freqpart][languageicon][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_language, raw_message, radio_freq)][endspanpart][messagepart]"
	// the above, but with example values filled in:
	/*
	return "<span class='game say'><span class='name'>[freqpart][languageicon][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_language, raw_message, radio_freq)][endspanpart] <span class='message'>[lang_treat(speaker, message_language, raw_message, spans, message_mode)]</span></span>"
	<span class='game say'>
		<span class='name'>
			[freqpart][languageicon][trackref][namepart][jobpart]
		</span>
		<span class='message'>
			[lang_treat(speaker, message_language, raw_message, spans, message_mode)]
		</span>
	</span>
	*/

/atom/movable/proc/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/// Sets the message mode, and the default sayverb for the message.
/// naturally, only supports mommychat
/atom/movable/proc/mommy_message_mode(datum/rental_mommy/chat/momchat)
	if(!mommychat)
		CRASH("say_mod() called without a mommychat datum")
	if(!mommychat.original_message)
		mommychat.original_message = "..."
		mommychat.message = mommychat.original_message
	var/starts_with = copytext_char(mommychat.message, 1)
	var/ends_with = copytext_char(mommychat.message, -1)
	var/specialty
	if(starts_with == "!" && length_char(mommychat.original_message) > 1) // special mode
		mommychat.message_mode = MODE_CUSTOM_SAY
		specialty = "!"
	else if(findtext(mommychat.original_message, "*") && starts_with != "*" && length_char(mommychat.original_message) > 1) // custom sayverb
		mommychat.message_mode = MODE_CUSTOM_SAY
		specialty = "*"
	else if(starts_with == "#")
		mommychat.message_mode = MODE_WHISPER
	else if(starts_with == "%")
		mommychat.message_mode = MODE_SING
	else if(starts_with == ";")
		mommychat.message_mode = MODE_HEADSET
	else if(starts_with == "$")
		mommychat.message_mode = MODE_YELL
	else if(ends_with == "?")
		mommychat.message_mode = MODE_ASK
	else if(ends_with == "!")
		var/last_two = copytext_char(mommychat.original_message, -2)
		if(last_two == "!!")
			mommychat.message_mode = MODE_YELL
		else
			mommychat.message_mode = MODE_EXCLAIM
	else
		/// department radio stuff
		var/first_two = copytext_char(mommychat.original_message, 1, 3)
		if((length_char(mommychat.original_message) > (length_char(first_two) + 1)) && (first_two in GLOB.department_radio_prefixes))
			var/key_symbol = lowertext(first_two)
			var/saymode = GLOB.department_radio_keys[key_symbol]
			if(momchat)
				momchat.mode_key = key_symbol
				momchat.message_mode = saymode
		else
			mommychat.message_mode = MODE_SAY

	if(SSchat.emoticonify(mommychat))
		return // it handled it! yay!
		
	switch(mommychat.message_mode)
		if(MODE_CUSTOM_SAY)
			if(specialty == "!")
				mommychat.message_verb = lowertext_first_word(copytext_char(mommychat.message, 2))
				mommychat.message = ""
			if(specialty == "*")
				var/list/splut = splittext(mommychat.message, "*")
				if(length(splut) <= 1)
					mommychat.message_verb = verb_say
					mommychat.message_mode = MODE_SAY
					return
				var/prefyx = LAZYACCESS(splut, 1)
				mommychat.message_verb = lowertext_first_word(prefyx)
				splut -= prefyx
				mommychat.message = capitalize(splut.Join())
		if(MODE_WHISPER)
			mommychat.message_verb = verb_whisper
		if(MODE_SING)
			mommychat.message_verb = verb_sing
		if(MODE_HEADSET)
			mommychat.message_verb = verb_headset
		if(MODE_YELL)
			mommychat.message_verb = verb_yell
		if(MODE_ASK)
			mommychat.message_verb = verb_ask
		if(MODE_EXCLAIM)
			mommychat.message_verb = verb_exclaim
		if(MODE_YELL)
			mommychat.message_verb = verb_yell
		if(MODE_SAY)
			mommychat.message_verb = verb_say
	mommychat.message_verb_comma = "[mommychat.message_verb] ,"


/// only for non-mommychat
/atom/movable/proc/say_mod(input, message_mode)
	var/ending = copytext_char(input, -1)
	var/beginning = copytext_char(input, 1)
	if(message_mode == MODE_WHISPER || beginning == "#")
		. = verb_whisper
	else if(message_mode == MODE_SING)
		. = verb_sing
	else if(copytext_char(input, -2) == "!!")
		. = verb_yell
	else if(ending == "?")
		. = verb_ask
	else if(ending == "!")
		. = verb_exclaim
	else if(beginning == "$")
		. = verb_yell
	else
		. = verb_say
	return get_random_if_list(.)

/atom/movable/proc/say_quote(input, list/spans=list(speech_span), message_mode, datum/rental_mommy/mommychat)
	if(SSrentaldatum.chat_uses_mommy && !mommychat)
		CRASH("say_quote() called without a mommychat datum")
	if(mommychat)
		mommychat.message_quotes = "\"[spanned]\""
		return // hey bro, nice proc

	if(!input)
		input = "..."
	if(copytext_char(input, -2) == "!!")
		spans |= SPAN_YELL
	var/reformatted = SSchat.emoticonify(src, input, message_mode, spans)
	if(reformatted)
		return reformatted
	var/spanned = attach_spans(input, spans)
	return "[say_mod(input, message_mode)][spanned ? ", \"[spanned]\"" : ""]"
	// Citadel edit [spanned ? ", \"[spanned]\"" : ""]"

#define ENCODE_HTML_EPHASIS(input, char, html, varname) \
	var/static/regex/##varname = regex("[char]{2}(.+?)[char]{2}", "g");\
	input = varname.Replace_char(input, "<[html]>$1</[html]>")

/// Converts specific characters, like +, |, and _ to formatted output.
/atom/movable/proc/say_emphasis(input)
	var/static/regex/italics = regex(@"\|((?=\S)[\w\W]*?(?<=\S))\|", "g")
	input = italics.Replace_char(input, "<i>$1</i>")
	var/static/regex/bold = regex(@"\+((?=\S)[\w\W]*?(?<=\S))\+", "g")
	input = bold.Replace_char(input, "<b>$1</b>")
	var/static/regex/underline = regex(@"_((?=\S)[\w\W]*?(?<=\S))_", "g")
	input = underline.Replace_char(input, "<u>$1</u>")
	return input

/atom/movable/proc/say_narrate_replace(input, atom/thing)
	if(!istype(thing))
		return
	if(findtext(input, "@"))
		. = replacetext(input, "@", "<b>[thing.name]</b>")
	return

/// Quirky citadel proc for our custom sayverbs to strip the verb out. Snowflakey as hell, say rewrite 3.0 when? // now, apparently
/atom/movable/proc/quoteless_say_quote(input, list/spans = list(speech_span), message_mode, datum/rental_mommy/mommychat)
	if(SSrentaldatum.chat_uses_mommy && !mommychat)
		CRASH("quoteless_say_quote() called without a mommychat datum")
	if(mommychat)
		if((mommychat.message[1] == "!") && (length_char(mommychat.message) > 1))
			mommychat.message_verb = ""
			mommychat.message_verb_rendered = ""
			return

	if((input[1] == "!") && (length_char(input) > 1))
		return ""
	var/pos = findtext(input, "*")
	return pos? copytext(input, pos + 1) : input

/atom/movable/proc/lang_treat(atom/movable/speaker, datum/language/language, raw_message, list/spans, message_mode, no_quote = FALSE, datum/rental_mommy/mommychat)
	if(SSrentaldatum.chat_uses_mommy && !mommychat)
		CRASH("lang_treat() called without a mommychat datum")
	if(mommychat) // here goes nothin
		if(!language) // speaker is not speaking a language
			mommychat.message = "makes a strange sound."
			return // :(
		var/atom/movable/virtualboy = speaker.GetSource()
		if(!has_language(language)) // speaker is speaking a language, but we don't understand it
			var/datum/language/D = GLOB.language_datum_instances[language]
			mommychat.message = D.scramble(mommychat.message)
		else
			mommychat.message = say_emphasis(mommychat.message)
		if(virtualboy) //Basically means "if the speaker is virtual"
			mommychat.source = virtualboy
		if(no_quote)
			return mommychat.source.quoteless_say_quote( mommychat.message, spans, message_mode, mommychat )
		else
			return mommychat.source.say_quote(           mommychat.message, spans, message_mode, mommychat )
	else
		if(has_language(language)) // speaker is speaking a language, and we understand it
			var/atom/movable/AM = speaker.GetSource()
			raw_message = say_emphasis(raw_message)
			if(AM) //Basically means "if the speaker is virtual"
				return no_quote ? AM.quoteless_say_quote(raw_message, spans, message_mode) : AM.say_quote(raw_message, spans, message_mode)
			else
				return no_quote ? speaker.quoteless_say_quote(raw_message, spans, message_mode) : speaker.say_quote(raw_message, spans, message_mode)
		else if(language) // speaker is speaking a language, but we don't understand it
			var/atom/movable/AM = speaker.GetSource()
			var/datum/language/D = GLOB.language_datum_instances[language]
			raw_message = D.scramble(raw_message)
			if(AM)
				return no_quote ? AM.quoteless_say_quote(raw_message, spans, message_mode) : AM.say_quote(raw_message, spans, message_mode)
			else
				return no_quote ? speaker.quoteless_say_quote(raw_message, spans, message_mode) : speaker.say_quote(raw_message, spans, message_mode)
		else
			return "makes a strange sound."

/proc/get_radio_span(freq)
	var/returntext = GLOB.freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_name(freq)
	var/returntext = GLOB.reverseradiochannels["[freq]"]
	if(returntext)
		return returntext
	return make_radio_name(freq)
	//return "[copytext_char("[freq]", 1, 4)].[copytext_char("[freq]", 4, 5)]"

/proc/make_radio_name(freq)
	if(freq in GLOB.reverseradiochannels)
		return GLOB.reverseradiochannels["[freq]"]
	var/channel_number = rand(1,9999)
	GLOB.reverseradiochannels["[freq]"] = "CH-[channel_number]"
	return GLOB.reverseradiochannels["[freq]"]
	

/atom/movable/proc/attach_spans(input, list/spans, datum/rental_mommy/mommychat)
	if(SSrentaldatum.chat_uses_mommy && !mommychat)
		CRASH("attach_spans() called without a mommychat datum")
	if(mommychat)
		if(!LAZYLEN(mommychat.spans))
			return
		if(mommychat.message_mode == MODE_YELL)
			mommychat.spans |= SPAN_YELL
		if(mommychat.message_mode == MODE_CUSTOM_SAY)
			if(isnull(mommychat.spans[1]))
				return
			mommychat.message = "[message_spans_start(mommychat.spans)][mommychat.message]</span>"
		return
	var/customsayverb = findtext(input, "*")
	if(customsayverb)
		input = capitalize(copytext(input, customsayverb + length(input[customsayverb])))

	if((input[1] == "!") && (length(input) > 2))
		return
	if(!length(spans) || isnull(spans[1]) && !customsayverb)
		return input
	if(input)
		return "[message_spans_start(spans)][input]</span>"
	else
		return

/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output

/proc/say_test(text)
	var/ending = copytext_char(text, -1)
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

/atom/movable/proc/GetVoice()
	return "[src]"	//Returns the atom's name, prepended with 'The' if it's not a proper noun

/atom/movable/proc/IsVocal()
	return 1

/atom/movable/proc/get_alt_name()

//HACKY VIRTUALSPEAKER STUFF BEYOND THIS POINT
//these exist mostly to deal with the AIs hrefs and job stuff.

/atom/movable/proc/GetJob() //Get a job, you lazy butte

/atom/movable/proc/GetSource()

/atom/movable/proc/GetRadio()

//VIRTUALSPEAKERS
/atom/movable/virtualspeaker
	var/job
	var/atom/movable/source
	var/obj/item/radio/radio
	var/chatcolor

INITIALIZE_IMMEDIATE(/atom/movable/virtualspeaker)
/atom/movable/virtualspeaker/Initialize(mapload, atom/movable/M, radio)
	. = ..()
	radio = radio
	source = M
	if (istype(M))
		name = M.GetVoice()
		verb_say = M.verb_say
		verb_ask = M.verb_ask
		verb_exclaim = M.verb_exclaim
		verb_yell = M.verb_yell
		chatcolor = M.get_chat_color()

	// The mob's job identity
	if(ishuman(M))
		// Humans use their job as seen on the crew manifest. This is so the AI
		// can know their job even if they don't carry an ID.
		var/datum/data/record/findjob = find_record("name", name, GLOB.data_core.general)
		if(findjob)
			job = findjob.fields["rank"]
		else
			job = "Unknown"
	else if(iscarbon(M))  // Carbon nonhuman
		job = "No ID"
	else if(isAI(M))  // AI
		job = "AI"
	else if(iscyborg(M))  // Cyborg
		var/mob/living/silicon/robot/B = M
		job = "[B.designation] Cyborg"
	else if(istype(M, /mob/living/silicon/pai))  // Personal AI (pAI)
		job = "Personal AI"
	else if(isobj(M))  // Cold, emotionless machines
		job = "Machine"
	else  // Unidentifiable mob
		job = "Unknown"

/atom/movable/virtualspeaker/GetJob()
	return job

/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetRadio()
	return radio

//To get robot span classes, stuff like that.
/atom/movable/proc/get_spans()
	return list()

/atom/movable/virtualspeaker/get_chat_color()
	return chatcolor
