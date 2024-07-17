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
	spans |= speech_span
	if(!language)
		language = get_selected_language()
	send_speech(message, 7, src, , spans, message_language=language, just_chat = just_chat)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, atom/movable/source, just_chat, list/data)
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)

/atom/movable/proc/can_speak()
	return 1

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
	var/rendered = compose_message(src, message_language, message, , spans, message_mode, source, mommychat)
	for(var/_AM in get_hearers_in_view(range, source))
		var/atom/movable/AM = _AM
		AM.Hear(rendered, src, message_language, message, , spans, message_mode, source, just_chat, mommychat)

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

/atom/movable/proc/say_quote(input, list/spans=list(speech_span), message_mode)
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

/// Quirky citadel proc for our custom sayverbs to strip the verb out. Snowflakey as hell, say rewrite 3.0 when?
/atom/movable/proc/quoteless_say_quote(input, list/spans = list(speech_span), message_mode)
	if((input[1] == "!") && (length_char(input) > 1))
		return ""
	var/emoticontext = SSchat.emoticonify(src, input, message_mode, spans)
	if(emoticontext)
		return emoticontext
	var/pos = findtext(input, "*")
	return pos? copytext(input, pos + 1) : input

/atom/movable/proc/lang_treat(atom/movable/speaker, datum/language/language, raw_message, list/spans, message_mode, no_quote = FALSE, datum/rental_mommy/mommychat)
	if(SSrentaldatum.chat_uses_mommy && !mommychat)
		CRASH("lang_treat() called without a mommychat datum")
	if(mommychat) // here goes nothin

	else
		if(has_language(language))
			var/atom/movable/AM = speaker.GetSource()
			raw_message = say_emphasis(raw_message)
			if(AM) //Basically means "if the speaker is virtual"
				return no_quote ? AM.quoteless_say_quote(raw_message, spans, message_mode) : AM.say_quote(raw_message, spans, message_mode)
			else
				return no_quote ? speaker.quoteless_say_quote(raw_message, spans, message_mode) : speaker.say_quote(raw_message, spans, message_mode)
		else if(language)
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
	

/atom/movable/proc/attach_spans(input, list/spans)
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
