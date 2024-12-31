/* 
 * File:   preferences_tabs.dm
 * Author: Kelly
 * Date: 2021-07-07
 * License: WWW.PLAYAPOCALYPSE.COM
 * 
 * TGUI preferences is a pipe dream.
 * 
 * This file holds more accessible preferences for the player.
 * Part of the Great Preferences Cleanup of 2021. (its actually 2024)
 * 
 *  */
#define PREFLINK_AUTONAME null // COOL DEFINE, DAN
#define PREFCMD_COPYCOLOR "copycolor"
#define PREFCMD_PASTECOLOR "pastecolor"
#define PREFCMD_DELCOLOR "clearcolor"
#define PREFDAT "generic_data_slug"
/// have the handler thing interpret the color index as a marking UID
#define PREFDAT_INDEX_IS_MARKING_UID "index_is_marking_uid"
#define PREFCOLOR "is_color"
#define GO_PREV "prev"
#define GO_NEXT "next"
#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='17%'>"
#define ERP_CATEGORY_ROW "<tr valign='top' width='17%'>"
#define MAX_MUTANT_ROWS 5

/* 
 * This proc takes in its args and outputs a link that'll be printed in the preferences window.
 * cus ew, href spam
 * @param showtext The text that will be displayed in the link
 * @param pref The preference action (basically always TRUE)
 * @param list/data A list of key-value pairs that will be added to the URL
 * @param kind Used to tell the game what kind of sound to play when the link is clicked
 * @param span Extra spans used for styling on your foes
 */
/datum/preferences/proc/PrefLink(showtext, pref, list/data = list(), kind, span, style)
	var/argos = "?_src_=prefs;preference=[pref];"
	if(kind)
		argos += "p_kind=[kind];"
	for(var/key in data)
		argos += "[key]=[data[key]];"
	var/stylepro = ""
	if(style)
		stylepro = "style='[style]'"
	if(span)
		return "<a href='[argos]' class='[span]' [stylepro]>[showtext]</a>"
	else
		return "<a href='[argos]' [stylepro]>[showtext]</a>"

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return

	if(CONFIG_GET(flag/use_role_whitelist))
		user.client.set_job_whitelist_from_db()

	update_preview_icon(current_tab)
	var/list/dat = list()
	dat += CharacterList()
	dat += CoolDivider()
	dat += HeaderTabs()
	dat += CoolDivider()
	dat += SubTabs()

	switch(current_tab)
		if(PPT_CHARCTER_PROPERTIES)
			switch(current_subtab)
				if(PPT_CHARCTER_PROPERTIES_INFO)
					dat += CharacterProperties()
				if(PPT_CHARCTER_PROPERTIES_VOICE)
					dat += VoiceProperties()
				if(PPT_CHARCTER_PROPERTIES_MISC)
					dat += MiscProperties()

		//Character Appearance
		if(PPT_CHARCTER_APPEARANCE)
			if(current_subtab != PPT_CHARCTER_APPEARANCE_UNDERLYING)
				dat += ColorToolbar()
			switch(current_subtab)
				if(PPT_CHARCTER_APPEARANCE_MISC)
					dat += AppearanceMisc()
				if(PPT_CHARCTER_APPEARANCE_HAIR_EYES)
					dat += AppearanceHairEyes()
				if(PPT_CHARCTER_APPEARANCE_PARTS)
					dat += AppearanceParts()
				if(PPT_CHARCTER_APPEARANCE_MARKINGS)
					dat += AppearanceMarkings()
				if(PPT_CHARCTER_APPEARANCE_UNDERLYING)
					dat += SubSubTabs()
					dat += ColorToolbar()
					var/static/list/allnads = list()
					if(!LAZYLEN(allnads))
						for(var/datum/genital_data/nad in GLOB.genitals)
							if(nad.genital_flags & GENITAL_CAN_HAVE)
								allnads += nad.has_key
					switch(current_sub_subtab)
						if(PPT_CHARCTER_APPEARANCE_UNDERLYING_UNDIES)
							dat += AppearanceUnderlyingUndies()
						if(PPT_CHARCTER_APPEARANCE_UNDERLYING_LAYERING)
							dat += AppearanceUnderlyingLayering()
						else
							if(current_subtab in allnads)
								dat += AppearanceUnderlyingGenitals()
							else
								dat += "OH NO! This is a bug! Please report it to the staff! Error code SNACKY SWEET SUNFISH"
		
		//Loadout heck
		if(PPT_LOADOUT)
			dat += Loadout()
		
		//Game Preferences
		if(PPT_GAME_PREFERENCES)
			switch(current_subtab)
				if(PPT_GAME_PREFERENCES_GENERAL)
					dat += GamePreferencesGeneral()
				if(PPT_GAME_PREFERENCES_UI)
					dat += GamePreferencesUI()
				if(PPT_GAME_PREFERENCES_CHAT)
					dat += GamePreferencesChat()
				if(PPT_GAME_PREFERENCES_RUNECHAT)
					dat += GamePreferencesRunechat()
				if(PPT_GAME_PREFERENCES_GHOST)
					dat += GamePreferencesGhost()
				if(PPT_GAME_PREFERENCES_AUDIO)
					dat += GamePreferencesAudio()
				if(PPT_GAME_PREFERENCES_ADMIN)
					dat += GamePreferencesAdmin()
				if(PPT_GAME_PREFERENCES_CONTENT)
					dat += GamePreferencesContent()


		if(PPT_KEYBINDINGS) // Custom keybindings
			dat += "<b>Keybindings:</b> <a href='?_src_=prefs;preference=hotkeys'>[(hotkeys) ? "Hotkeys" : "Input"]</a><br>"
			dat += "Keybindings mode controls how the game behaves with tab and map/input focus.<br>If it is on <b>Hotkeys</b>, the game will always attempt to force you to map focus, meaning keypresses are sent \
			directly to the map instead of the input. You will still be able to use the command bar, but you need to tab to do it every time you click on the game map.<br>\
			If it is on <b>Input</b>, the game will not force focus away from the input bar, and you can switch focus using TAB between these two modes: If the input bar is pink, that means that you are in non-hotkey mode, sending all keypresses of the normal \
			alphanumeric characters, punctuation, spacebar, backspace, enter, etc, typing keys into the input bar. If the input bar is white, you are in hotkey mode, meaning all keypresses go into the game's keybind handling system unless you \
			manually click on the input bar to shift focus there.<br>\
			Input mode is the closest thing to the old input system.<br>\
			<b>IMPORTANT:</b> While in input mode's non hotkey setting (tab toggled), Ctrl + KEY will send KEY to the keybind system as the key itself, not as Ctrl + KEY. This means Ctrl + T/W/A/S/D/all your familiar stuff still works, but you \
			won't be able to access any regular Ctrl binds.<br>"
			dat += "<br><b>Modifier-Independent binding</b> - This is a singular bind that works regardless of if Ctrl/Shift/Alt are held down. For example, if combat mode is bound to C in modifier-independent binds, it'll trigger regardless of if you are \
			holding down shift for sprint. <b>Each keybind can only have one independent binding, and each key can only have one keybind independently bound to it.</b>"
			// Create an inverted list of keybindings -> key
			var/list/user_binds = list()
			var/list/user_modless_binds = list()
			for (var/key in key_bindings)
				for(var/kb_name in key_bindings[key])
					user_binds[kb_name] += list(key)
			for (var/key in modless_key_bindings)
				user_modless_binds[modless_key_bindings[key]] = key

			var/list/kb_categories = list()
			// Group keybinds by category
			for (var/name in GLOB.keybindings_by_name)
				var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
				kb_categories[kb.category] += list(kb)

			dat += {"
			<style>
			span.bindname { display: inline-block; position: absolute; width: 20% ; left: 5px; padding: 5px; } \
			span.bindings { display: inline-block; position: relative; width: auto; left: 20%; width: auto; right: 20%; padding: 5px; } \
			span.independent { display: inline-block; position: absolute; width: 20%; right: 5px; padding: 5px; } \
			</style><body>
			"}

			for (var/category in kb_categories)
				dat += "<h3>[category]</h3>"
				for (var/i in kb_categories[category])
					var/datum/keybinding/kb = i
					var/current_independent_binding = user_modless_binds[kb.name] || "Unbound"
					if(!length(user_binds[kb.name]))
						dat += "<span class='bindname'>[kb.full_name]</span><span class='bindings'><a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=["Unbound"]'>Unbound</a>"
						var/list/default_keys = hotkeys ? kb.hotkey_keys : kb.classic_keys
						if(LAZYLEN(default_keys))
							dat += "| Default: [default_keys.Join(", ")]"
						dat += "</span>"
						if(!kb.special && !kb.clientside)
							dat += "<span class='independent'>Independent Binding: <a href='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[current_independent_binding];independent=1'>[current_independent_binding]</a></span>"
						dat += "<br>"
					else
						var/bound_key = user_binds[kb.name][1]
						dat += "<span class='bindname'l>[kb.full_name]</span><span class='bindings'><a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
						for(var/bound_key_index in 2 to length(user_binds[kb.name]))
							bound_key = user_binds[kb.name][bound_key_index]
							dat += " | <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
						if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
							dat += "| <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name]'>Add Secondary</a>"
						var/list/default_keys = hotkeys ? kb.classic_keys : kb.hotkey_keys
						if(LAZYLEN(default_keys))
							dat += "| Default: [default_keys.Join(", ")]"
						dat += "</span>"
						if(!kb.special && !kb.clientside)
							dat += "<span class='independent'>Independent Binding: <a href='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[current_independent_binding];independent=1'>[current_independent_binding]</a></span>"
						dat += "<br>"

			dat += "<br><br>"
			dat += "<a href ='?_src_=prefs;preference=keybindings_reset'>\[Reset to default\]</a>"
			dat += "</body>"


	dat += CoolDivider()
	dat += FooterBar()

	winset(user, "preferences_window", "is-visible=1;focus=0;")
	var/datum/browser/popup = new(user, "preferences_browser", "<div align='center'>Character Setup - [real_name]</div>", 640, 770)
	popup.set_content(dat.Join())
	popup.open(FALSE)
	onclose(user, "preferences_window", src)

#undef APPEARANCE_CATEGORY_COLUMN
#undef MAX_MUTANT_ROWS

/datum/preferences/proc/HeaderTabs()
	var/static/list/tablist = list(
		"[PPT_CHARCTER_PROPERTIES]" = "Properties",
		"[PPT_CHARCTER_APPEARANCE]" = "Appearance",
		"[PPT_LOADOUT]" = "Loadout",
		"new_row",
		"[PPT_GAME_PREFERENCES]" = "Game Settings",
		"[PPT_KEYBINDINGS]" = "Keybindings",
	)
	var/list/dat = list()
	dat += "<center>"
	dat += "<table class='TabHeader'>"
	dat += "<tr>"
	for(var/supertab in tablist)
		if(supertab == "new_row")
			dat += "</tr><tr>"
		else
			dat += "<td>"
			var/cspan = current_tab == supertab ? "TabCellselected" : ""
			dat += PrefLink("[tablist["[supertab]"]]", "tab", list("tab" = supertab), "BUTTON", cspan)
			dat += "</td>"
	dat += "</tr>"
	dat += "</table>"
	if(!path)
		dat += "<div class='notice'>Hi Guest! You need to have a BYOND account to save anything.</div>"
	dat += "</center>"
	return dat.Join()

/datum/preferences/proc/SubTabs()
	var/static/list/subtablist = list(
		"[PPT_CHARCTER_PROPERTIES]" = list(
			"[PPT_CHARCTER_PROPERTIES_INFO]" = "Background",
			"[PPT_CHARCTER_PROPERTIES_VOICE]" = "Voice",
			"[PPT_CHARCTER_PROPERTIES_MISC]" = "Miscellaneous",
		),
		"[PPT_CHARCTER_APPEARANCE]" = list(
			"[PPT_CHARCTER_APPEARANCE_MISC]" = "General",
			"[PPT_CHARCTER_APPEARANCE_HAIR_EYES]" = "Hair & Eyes",
			"[PPT_CHARCTER_APPEARANCE_PARTS]" = "Body Parts",
			"[PPT_CHARCTER_APPEARANCE_MARKINGS]" = "Markings",
			"[PPT_CHARCTER_APPEARANCE_UNDERLYING]" = "Unmentionables",
		),
		"[PPT_GAME_PREFERENCES]" = list(
			"[PPT_GAME_PREFERENCES_GENERAL]" = "General",
			"[PPT_GAME_PREFERENCES_UI]" = "UI",
			"[PPT_GAME_PREFERENCES_CHAT]" = "Chat",
			"[PPT_GAME_PREFERENCES_RUNECHAT]" = "Runechat",
			"[PPT_GAME_PREFERENCES_GHOST]" = "Ghost",
			"[PPT_GAME_PREFERENCES_AUDIO]" = "Audio",
			"[PPT_GAME_PREFERENCES_ADMIN]" = "Admin",
			"[PPT_GAME_PREFERENCES_CONTENT]" = "Content",
		),
	)
	var/static/list/subtablist_nonadmin = list(
		"[PPT_CHARCTER_PROPERTIES]" = list(
			"[PPT_CHARCTER_PROPERTIES_INFO]" = "Background",
			"[PPT_CHARCTER_PROPERTIES_VOICE]" = "Voice",
			"[PPT_CHARCTER_PROPERTIES_MISC]" = "Miscellaneous",
		),
		"[PPT_CHARCTER_APPEARANCE]" = list(
			"[PPT_CHARCTER_APPEARANCE_MISC]" = "General",
			"[PPT_CHARCTER_APPEARANCE_HAIR_EYES]" = "Hair & Eyes",
			"[PPT_CHARCTER_APPEARANCE_PARTS]" = "Body Parts",
			"[PPT_CHARCTER_APPEARANCE_MARKINGS]" = "Markings",
			"[PPT_CHARCTER_APPEARANCE_UNDERLYING]" = "Unmentionables",
		),
		"[PPT_GAME_PREFERENCES]" = list(
			"[PPT_GAME_PREFERENCES_GENERAL]" = "General",
			"[PPT_GAME_PREFERENCES_UI]" = "UI",
			"[PPT_GAME_PREFERENCES_CHAT]" = "Chat",
			"[PPT_GAME_PREFERENCES_RUNECHAT]" = "Runechat",
			"[PPT_GAME_PREFERENCES_AUDIO]" = "Audio",
			"[PPT_GAME_PREFERENCES_CONTENT]" = "Content",
		),
	)
	var/list/touse
	if(check_rights(R_ADMIN, FALSE))
		touse = subtablist
	else
		touse = subtablist_nonadmin
	if(!LAZYLEN(touse["[current_tab]"]))
		return ""
	var/list/dat = list()
	dat += "<center>"
	dat += "<table class='TabHeader'>"
	dat += "<tr>"
	for(var/subtab in touse)
		dat += "<td>"
		var/cspan = current_subtab == subtab ? "TabCellselected" : ""
		var/textsay = "[touse["[subtab]"]]"
		dat += PrefLink(textsay, PREFCMD_SET_SUBTAB, list(PREFDAT_SUBTAB = subtab), span = cspan)
		dat += "</td>"
	dat += "</tr>"
	dat += "</table>"
	dat += "</center>"
	return dat.Join()

/// sub tabs, for undies, genitals, and layering
/datum/preferences/proc/SubSubTabs()
	var/list/dat = list()
	dat += "<center>"
	dat += "<div class='SettingArray'>"
	dat += "<div class='FlexTable'>"
	var/coolstyle = "flex-basis: 48%;"
	var/undiespan = current_subsubtab == PPT_CHARCTER_APPEARANCE_UNDERLYING_UNDERWEAR ? "TabCellselected" : ""
	dat += PrefLink("Underwear", PREFCMD_SET_SUBSUBTAB, list("subsubtab" = PPT_CHARCTER_APPEARANCE_UNDERLYING_UNDERWEAR), span = undiespan, style = coolstyle)
	var/layeringspan = current_subsubtab == PPT_CHARCTER_APPEARANCE_UNDERLYING_LAYERING ? "TabCellselected" : ""
	dat += PrefLink("Layering", PREFCMD_SET_SUBSUBTAB, list("subsubtab" = PPT_CHARCTER_APPEARANCE_UNDERLYING_LAYERING), span = layeringspan, style = coolstyle)
	/// and now, the rest of the tabs
	for(var/datum/genital_data/GD in GLOB.genital_data_system)
		var/genispan = current_subsubtab == GD.has_key ? "TabCellselected" : ""
		dat += PrefLink(GD.name, PREFCMD_SET_SUBSUBTAB, list("subsubtab" = GD.has_key), span = genispan)
	dat += "</div>"
	dat += "</div>"
	dat += "</center>"
	return dat.Join()

/datum/preferences/proc/CharacterList()
	if(!path)
		return "You're a guest! You can't save characters, you dorito!"
	var/savefile/S = new /savefile(path)
	if(!S)
		return "Error loading savefile! Please contact an admin."
	var/list/dat = list()
	dat += "<center>"
	dat += "<div class='FlexTable WellPadded'>"
	if(charlist_hidden)
		dat += PrefLink("Show Character List", "charlist_hidden", "TOGGLE")
		dat += "</center>"
	else
		var/name
		for(var/i=1, i<=min(max_save_slots, show_this_many), i++)
			S.cd = "/character[i]"
			S["real_name"] >> name
			if(!name)
				name = "Character[i]"
			var/coolspan = i == default_slot ? "TabCellselected" : ""
			dat += PrefLink("[name]", "changeslot", list("num" = i), "INPUT", coolspan)
		dat += "</div>"
		dat += "<div class='WideBarDark'>"
		dat += "Showing [PrefLink("[show_this_many]", "show_this_many", "INPUT")] characters"
		dat += "<br>"
		dat += PrefLink("Copy", "copyslot", "BUTTON")
		dat += PrefLink("Paste", "paste", "BUTTON")
		if(copyslot)
			dat += "<br>Copying FROM: [copyslot] ([copyname])"
		dat += "<br>"
		dat += PrefLink("Hide Character List", "charlist_hidden", "TOGGLE")
		dat += "</div>"
		dat += "</center>"
	return dat.Join()


/datum/preferences/proc/FooterBar()
	var/list/dat = list()
	dat += "<center>"
	dat += PrefLink("Visual Chat Options", "setup_hornychat", kind = "LINK", span = "WideBarDark")
	dat += PrefLink("Save", "save", kind = "BUTTON", span = "WideBarDark")
	dat += "<table class='TabHeader'>"
	dat += "<tr>"
	dat += "<td width='50%'>"
	dat += PrefLink("Undo", "load", kind = "BUTTON")
	dat += "</td>"
	dat += "<td width='50%'>"
	dat += PrefLink("Delete", "delete_character", kind = "BUTTON")
	dat += "</td>"
	dat += "</center>"
	return dat.Join()

/datum/preferences/proc/CharacterProperties()
	var/list/dat = list()
	dat += "<div class='BGsplitContainer'>" // DIV A
	dat += "<div class='BGsplit'>" // DIV A A
	dat += "<div class='SettingArray'>" // DIV A A A
	dat += "<div class='SettingFlex' style='flex-basis: 100%;'>" // DIV A A A A
	var/pfplink = SSchat.GetPicForMode(user, MODE_PROFILE_PIC)
	if(pfplink)
		pfplink = "<img src='[pfplink]' style='width: 125px; height: auto;'>"
	else
		pfplink = "<img src='https://via.placeholder.com/150' style='width: 125px; height: auto;'>"
	dat += "<center>"
	dat += PrefLink(pfplink, "setup_hornychat", kind = "LINK")
	dat += "</center>"
	dat += "</div>" // End of DIV A A A A
	dat += "<div class='SettingFlex' style='flex-basis: 100%;'>" // DIV A A A B
	dat += "<div class='SettingName'>" // DIV A A A B A
	dat += "Name:"
	dat += "</div>" // End of DIV A A A B A
	dat += PrefLink("[real_name]", "name")
	dat += "</div>" // End of DIV A A A B
	dat += "<div class='SettingFlex'>" // DIV A A A C
	dat += "<div class='SettingName'>" // DIV A A A C A
	dat += "Age:"
	dat += "</div>" // End of DIV A A A C A
	dat += PrefLink("[age]", "age")
	dat += "</div>" // End of DIV A A A C
	dat += "<div class='SettingFlex'>" // DIV A A A D
	dat += "<div class='SettingName'>" // DIV A A A D A
	dat += "Gender:"
	dat += "</div>" // End of DIV A A A D A
	dat += PrefLink("[GetGenderString()]", "gender")
	dat += "</div>" // End of DIV A A A D
	dat += "<div class='SettingFlex' style='flex-basis: 100%;'>" // DIV A A A E
	dat += "<div class='SettingName'>" // DIV A A A E A
	dat += "I am a..."
	dat += "</div>" // End of DIV A A A E A
	dat += PrefLink("[GetTBSString()]", "tbs")
	dat += "</div>" // End of DIV A A A E
	dat += "<div class='SettingFlex' style='flex-basis: 100%;'>" // DIV A A A F
	dat += "<div class='SettingName'>" // DIV A A A F A
	dat += "I like to kiss..."
	dat += "</div>" // End of DIV A A A F A
	dat += PrefLink("[GetKisserString()]", "kisser")
	dat += "</div>" // End of DIV A A A F
	dat += "</div>" // End of DIV A A A
	dat += "</div>" // End of DIV A A
	dat += "<div class='BGsplit'>" // DIV A B
	dat += "<div class='SettingArrayCol'>" // DIV A B A
	dat += "<div class='SettingFlexCol'>" // DIV A B A A
	dat += "<div class='SettingNameCol'>" // DIV A B A A A
	dat += "Flavor Text:"
	dat += "</div>" // End of DIV A B A A A
	dat += PrefLink("[flavor_text]", "flavor_text")
	dat += "</div>" // End of DIV A B A A
	dat += "<div class='SettingFlexCol'>" // DIV A B A B
	dat += "<div class='SettingNameCol'>" // DIV A B A B A
	dat += "OOC Notes:"
	dat += "</div>" // End of DIV A B A B A
	dat += PrefLink("[ooc_notes]", "ooc_notes")
	dat += "</div>" // End of DIV A B A B
	dat += "</div>" // End of DIV A B A
	dat += "</div>" // End of DIV A B
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/VoiceProperties()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	
	dat += "<div class='SettingFlexCol' style='flex-basis: 50%;'>" // DIV A A
	dat += "<div class='SettingNameCol'>" // DIV A A A
	dat += "Blurble Sound"
	dat += "</div>" // End of DIV A A A
	dat += PrefLink("[blurble_sound]", "blurble_sound", span = "SettingValue")
	dat += "</div>" // End of DIV A A
	
	dat += "<div class='SettingFlexCol' style='flex-basis: 50%;'>" // DIV A B
	dat += "<div class='SettingNameCol'>" // DIV A B A
	dat += "You will blurble when you..."
	dat += "</div>" // End of DIV A B A
	dat += PrefLink("[blurble_trigger]", "blurble_trigger", span = "SettingValue")
	dat += "</div>" // End of DIV A B
	
	dat += "<div class='SettingFlexCol' style='flex-basis: 25%;'>" // DIV A C
	dat += "<div class='SettingNameCol'>" // DIV A C A
	dat += "Blurble Speed"
	dat += "</div>" // End of DIV A C A
	dat += PrefLink("[blurble_speed]", "blurble_speed", span = "SettingValue")
	dat += "</div>" // End of DIV A C
	
	dat += "<div class='SettingFlexCol' style='flex-basis: 25%;'>" // DIV A D
	dat += "<div class='SettingNameCol'>" // DIV A D A
	dat += "Blurble Volume"
	dat += "</div>" // End of DIV A D A
	dat += PrefLink("[blurble_volume]", "blurble_volume", span = "SettingValue")
	dat += "</div>" // End of DIV A D
	
	dat += "<div class='SettingFlexCol' style='flex-basis: 25%;'>" // DIV A E
	dat += "<div class='SettingNameCol'>" // DIV A E A
	dat += "Blurble Pitch"
	dat += "</div>" // End of DIV A E A
	dat += PrefLink("[blurble_pitch]", "blurble_pitch", span = "SettingValue")
	dat += "</div>" // End of DIV A E
	
	dat += "<div class='SettingFlexCol' style='flex-basis: 25%;'>" // DIV A F
	dat += "<div class='SettingNameCol'>" // DIV A F A
	dat += "Max Words Blurbled"
	dat += "</div>" // End of DIV A F A
	dat += PrefLink("[max_words_blurbled]", "max_words_blurbled", span = "SettingValue")
	dat += "</div>" // End of DIV A F
	
	dat += "<div class='SettingFlexCol' style='flex-basis: 25%;'>" // DIV A G
	dat += "<div class='SettingNameCol'>" // DIV A G A
	dat += "Runechat Color"
	dat += "</div>" // End of DIV A G A
	var/list/data = list(PREFDAT_COLKEY_IS_FEATURE = TRUE)
	dat += ColorBox("runechat_color", data = data)
	dat += "</div>" // End of DIV A G

	dat += "<div class='SettingFlexCol' style='flex-basis: 75%;'>" // DIV A H
	dat += "</div>" // End of DIV A H ^ This is a spacer
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/MiscProperties()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV Q
	dat += "<div class='SettingFlexCol' style='flex-basis: 100%;'>" // DIV Q A
	dat += "<div class='SettingValueSplit'>" // DIV Q A A
	dat += "<div class='SettingValueCol'>" // DIV Q A A A
	dat += "<div class='SettingNameCol'>" // DIV Q A A A A
	dat += "Account ID (Do not share!)"
	dat += "</div>" // End of DIV Q A A A A
	dat += "<div class='SettingFlexColInfo'>" // DIV Q A A A B
	dat += "[quester_uid]"
	dat += "</div>" // End of DIV Q A A A B
	dat += "</div>" // End of DIV Q A A A
	dat += "<div class='SettingFlexCol'>" // DIV Q A A B
	dat += "<div class='SettingNameCol'>" // DIV Q A A B A
	dat += "Account Balance"
	dat += "</div>" // End of DIV Q A A B A
	dat += "<div class='SettingFlexColInfo'>" // DIV Q A A B B
	dat += "[[SSeconomy.format_currency(saved_unclaimed_points, TRUE)]]"
	dat += "</div>" // End of DIV Q A A B B
	dat += "</div>" // End of DIV Q A A B
	dat += "</div>" // End of DIV Q A A
	dat += "</div>" // End of DIV Q A
	dat += "</div>" // End of DIV Q
	
	dat += "<div class='SettingArray'>" // DIV A
	
	dat += "<div class='SettingFlexCol' style='flex-basis: 33%;'>" // DIV A A
	dat += "<div class='SettingNameCol'>" // DIV A A A
	dat += "PDA Kind"
	dat += "</div>" // End of DIV A A A
	dat += PrefLink("[pda_kind]", "pda_kind", span = "SettingValueCol")
	dat += "</div>" // End of DIV A A

	dat += "<div class='SettingFlexCol' style='flex-basis: 33%;'>" // DIV A B
	dat += "<div class='SettingNameCol'>" // DIV A B A
	dat += "PDA Ringtone"
	dat += "</div>" // End of DIV A B A
	dat += PrefLink("[pda_ringtone]", "pda_ringtone", span = "SettingValueCol")
	dat += "</div>" // End of DIV A B

	dat += "<div class='SettingFlexCol' style='flex-basis: 33%;'>" // DIV A C
	dat += "<div class='SettingNameCol'>" // DIV A C A
	dat += "PDA Color"
	dat += "</div>" // End of DIV A C A

	var/list/data = list(PREFDAT_COLKEY_IS_VAR = TRUE)
	dat += ColorBox("pda_color", data = data)
	dat += "</div>" // End of DIV A C

	dat += "<div class='SettingFlexCol' style='flex-basis: 50%;'>" // DIV A D
	dat += "<div class='SettingNameCol'>" // DIV A D A
	dat += "Backpack Kind"
	dat += "</div>" // End of DIV A D A
	dat += PrefLink("[backpack_kind]", "backpack_kind", span = "SettingValueCol")
	dat += "</div>" // End of DIV A D

	dat += "<div class='SettingFlexCol' style='flex-basis: 50%;'>" // DIV A E
	dat += "<div class='SettingNameCol'>" // DIV A E A
	dat += "Persistent Scars"
	dat += "<div class='SettingValueSplit'>" // DIV A E A A
	dat += "<div class='SettingValueCol' style='flex-basis: 50%;'>" // DIV A E A A A
	dat += PrefLink("[persistent_scars]", "persistent_scars", span = "SettingValueCol")
	dat += "</div>" // End of DIV A E A A A
	dat += "<div class='SettingValueCol' style='flex-basis: 50%;'>" // DIV A E A A B
	dat += PrefLink("[persistent_scars_clear]", "persistent_scars_clear", span = "SettingValueCol")
	dat += "</div>" // End of DIV A E A A B

	dat += "<div class='SettingFlexCol' style='flex-basis: 100%;'>" // DIV A F
	dat += "<div class='SettingNameCol'>" // DIV A F A
	dat += "Attribute Stats (Affects Rolls)"
	dat += "</div>" // End of DIV A F A
	dat += "<div class='SettingValueSplit'>" // DIV A F B
	dat += "<div class='SettingValueCol'>" // DIV A F B A
	dat += "<div class='SettingName'>" // DIV A F B A A
	dat += "Strength"
	dat += "</div>" // End of DIV A F B A A
	dat += PrefLink("[special_s]", "strength", span = "SettingValueCol")
	dat += "</div>" // End of DIV A F B A

	dat += "<div class='SettingValueCol'>" // DIV A F B B
	dat += "<div class='SettingName'>" // DIV A F B B A
	dat += "Perception"
	dat += "</div>" // End of DIV A F B B A
	dat += PrefLink("[special_p]", "perception", span = "SettingValueCol")
	dat += "</div>" // End of DIV A F B B

	dat += "<div class='SettingValueCol'>" // DIV A F B C
	dat += "<div class='SettingName'>" // DIV A F B C A
	dat += "Endurance"
	dat += "</div>" // End of DIV A F B C A
	dat += PrefLink("[special_e]", "endurance", span = "SettingValueCol")
	dat += "</div>" // End of DIV A F B C

	dat += "<div class='SettingValueCol'>" // DIV A F B D
	dat += "<div class='SettingName'>" // DIV A F B D A
	dat += "Charisma"
	dat += "</div>" // End of DIV A F B D A
	dat += PrefLink("[special_c]", "charisma", span = "SettingValueCol")
	dat += "</div>" // End of DIV A F B D

	dat += "<div class='SettingValueCol'>" // DIV A F B E
	dat += "<div class='SettingName'>" // DIV A F B E A
	dat += "Intelligence"
	dat += "</div>" // End of DIV A F B E A
	dat += PrefLink("[special_i]", "intelligence", span = "SettingValueCol")
	dat += "</div>" // End of DIV A F B E

	dat += "<div class='SettingValueCol'>" // DIV A F B F
	dat += "<div class='SettingName'>" // DIV A F B F A
	dat += "Agility"
	dat += "</div>" // End of DIV A F B F A
	dat += PrefLink("[special_a]", "agility", span = "SettingValueCol")
	dat += "</div>" // End of DIV A F B F

	dat += "<div class='SettingValueCol'>" // DIV A F B G
	dat += "<div class='SettingName'>" // DIV A F B G A
	dat += "Luck"
	dat += "</div>" // End of DIV A F B G A
	dat += PrefLink("[special_l]", "luck", span = "SettingValueCol")
	dat += "</div>" // End of DIV A F B G

	dat += "</div>" // End of DIV A F B
	dat += "</div>" // End of DIV A F

	dat += "<div class='SettingFlexCol' style='flex-basis: 100%;'>" // DIV A G
	dat += "<div class='SettingName>" // DIV A G A
	dat += "Quirks"
	dat += "</div>" // End of DIV A G A
	dat += "<div class='SettingValueSplitRowable'>" // DIV A G B
	dat += RowifyQuirks()
	dat += "</div>" // End of DIV A G B
	dat += "</div>" // End of DIV A G
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/AppearanceMisc()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='SettingFlex'>" // DIV A A
	dat += "<div class='SettingName'>" // DIV A A A
	dat += "Species Type:"
	dat += "</div>" // End of DIV A A A
	var/specname = pref_species.name
	dat += PrefLink(specname, "species")
	dat += "<div class='SettingName'>" // DIV A A B
	dat += "Body model:"
	dat += "</div>" // End of DIV A A B
	var/bmod = "N/A"
	if(gender != NEUTER && pref_species.sexes) // oh yeah, my pref species sexes a lot
		features["body_model"] == MALE ? "Masculine" : "Feminine"
		dat += PrefLink(bmod, "body_model")
	if(LAZYLEN(pref_species.allowed_limb_ids))
		if(!chosen_limb_id || !(chosen_limb_id in pref_species.allowed_limb_ids))
			chosen_limb_id = pref_species.limbs_id || pref_species.id
		dat += "<div class='SettingName'>" // DIV A A C
		dat += "Body Sprite:"
		dat += "</div>" // End of DIV A A C
		dat += PrefLink("[chosen_limb_id]", "bodysprite")
	if(LAZYLEN(pref_species.alt_prefixes))
		dat += "<div class='SettingName'>" // DIV A A C
		dat += "Alt Style:"
		dat += "</div>" // End of DIV A A C
		var/altfix = alt_appearance ? "[alt_appearance]" : "Select"
		dat += PrefLink(altfix, "alt_prefix")
		dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	dat += "<div class='SettingArray'>" // DIV B
	dat += "<div class='SettingFlex'>" // DIV B A
	dat += "<div class='SettingName'>" // DIV B A A
	dat += "Species Name:"
	dat += "</div>" // End of DIV B A A
	var/spename = custom_species ? custom_species : pref_species.name
	dat += PrefLink(spename, "species")
	dat += "<div class='SettingName'>" // DIV B A B
	dat += "Blood Color:"
	dat += "</div>" // End of DIV B A B
	if(features["blood_color"] == "")
		features["blood_color"] = "FF0000" // red
	var/list/data = list(PREFDAT_COLKEY_IS_FEATURE = TRUE)
	dat += ColorBox("blood_color", data = data)
	dat += "<div class='SettingName'>" // DIV B A C
	dat += "Rainbow Blood?"
	dat += "</div>" // End of DIV B A C
	var/rbw = features["blood_color"] == "rainbow" ? "Yes" : "No"
	dat += PrefLink("[rbw]", "rainbow_blood")
	dat += "</div>" // End of DIV B A
	dat += "</div>" // End of DIV B
	dat += "<div class='SettingArray'>" // DIV C
	dat += "<div class='SettingFlex'>" // DIV C A
	dat += "<div class='SettingName'>" // DIV C A A
	dat += "Meat Type:"
	dat += "</div>" // End of DIV C A A
	var/meat = features["meat_type"] || "Meaty"
	dat += PrefLink("[meat]", "meat_type")
	dat += "<div class='SettingName'>" // DIV C A B
	dat += "Taste:"
	dat += "</div>" // End of DIV C A B
	if(!features["taste"])
		features["taste"] = "something"
	var/tasted = features["taste"] || "somthing"
	dat += PrefLink(tasted, "taste")
	dat += "</div>" // End of DIV C A
	dat += "</div>" // End of DIV C
	dat += "<div class='SettingArray'>" // DIV D
	dat += "<div class='SettingFlex'>" // DIV D A
	dat += "<div class='SettingName'>" // DIV D A A
	dat += "Scale:"
	dat += "</div>" // End of DIV D A A
	var/bscale = features["body_size"]*100
	dat += PrefLink("[bscale]", "body_size")
	dat += "<div class='SettingName'>" // DIV D A B
	dat += "Width:"
	dat += "</div>" // End of DIV D A B
	var/bwidth = features["body_width"]*100
	dat += PrefLink(bwidth, "width")
	dat += "<div class='SettingName'>" // DIV D A C
	dat += "Scaling"
	dat += "</div>" // End of DIV D A C
	var/fuzsharp = fuzzy ? "Fuzzy" : "Sharp"
	dat += PrefLink(fuzsharp, "scaling")
	dat += "</div>" // End of DIV D A
	dat += "</div>" // End of DIV D
	dat += "<div class='SettingArray'>" // DIV E
	dat += "<div class='SettingFlex'>" // DIV E A
	dat += "<div class='SettingName'>" // DIV E A A
	dat += "Offset &udarr;"
	dat += "</div>" // End of DIV E A A
	var/pye = features["pixel_y"] > 0 ? "+[features["pixel_y"]]" : "[features["pixel_y"]]"
	dat += PrefLink(pye, "pixel_y")
	dat += "<div class='SettingName'>" // DIV E A B
	dat += "Offset &lrarr;"
	dat += "</div>" // End of DIV E A B
	var/pxe = features["pixel_x"] > 0 ? "+[features["pixel_x"]]" : "[features["pixel_x"]]"
	dat += PrefLink(pxe, "pixel_x")
	dat += "<div class='SettingName'>" // DIV E A C
	dat += "Legs:"
	dat += "</div>" // End of DIV E A C
	var/d_legs = features["legs"]
	dat += PrefLink(d_legs, "legs")
	dat += "</div>" // End of DIV E A
	var/use_skintones = pref_species.use_skintones
	if(use_skintones) // humans suck
		dat += "<div class='SettingFlex'>" // DIV E B
		dat += "<div class='SettingName'>" // DIV E B A
		dat += "Skintone:"
		dat += "</div>" // End of DIV E B A
		if(use_custom_skin_tone)
			data = list(PREFDAT_COLKEY_IS_VAR = TRUE)
			dat += ColorBox("skin_tone", data = data)
		else
			dat += PrefLink("[skin_tone]", "skintone")
		dat += "</div>" // End of DIV E B
	dat += "</div>" // End of DIV E
	return dat.Join()

/datum/preferences/proc/AppearanceHairEyes()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='SettingArray'>" // DIV A A
	// ^^ you might be wondering why theres two of these
	dat += "<div class='SettingFlexCol'>" // DIV A A A
	dat += "<div class='SettingName'>" // DIV A A A A
	dat += "Eyes"
	dat += "</div>" // End of DIV A A A A
	dat += "<div class='SettingValueSplit'>" // DIV A A A B
	dat += "<div class='SettingNameCol'>" // DIV A A A B A
	dat += "Style:"
	dat += "</div>" // End of DIV A A A B A
	dat += PrefLink("<", "eye_type", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "eye_type", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink(capitalize("[eye_type]"), "eye_type")
	dat += "<div class='SettingNameCol'>" // DIV A A A B B
	dat += "Left Color:"
	dat += "</div>" // End of DIV A A A B B
	var/list/feat_data = list(PREFDAT_COLKEY_IS_FEATURE = TRUE)
	var/list/var_data = list(PREFDAT_COLKEY_IS_VAR = TRUE)
	dat += ColorBox("left_eye_color", data = var_data)
	dat += "<div class='SettingNameCol'>" // DIV A A A B C
	dat += "Right Color:"
	dat += "</div>" // End of DIV A A A B C
	dat += ColorBox("right_eye_color", data = var_data)
	dat += "</div>" // End of DIV A A A B
	dat += "</div>" // End of DIV A A A

	dat += "<div class='SettingFlexCol'>" // DIV A A B
	dat += "<div class='SettingName'>" // DIV A A B A
	dat += "Hairea 1"
	dat += "</div>" // End of DIV A A B A
	dat += "<div class='SettingValueSplit'>" // DIV A A B B
	dat += "<div class='SettingNameCol'>" // DIV A A B B A
	dat += "Style:"
	dat += "</div>" // End of DIV A A B B A
	dat += PrefLink("<", "hair_style", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "hair_style", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink("[hair_style]", "hair_style")
	dat += "<div class='SettingNameCol'>" // DIV A A B B B
	dat += "Color:"
	dat += "</div>" // End of DIV A A B B B
	dat += ColorBox("hair_color", data = var_data)
	dat += "</div>" // End of DIV A A B B
	dat += "<div class='SettingValueSplit'>" // DIV A A B C
	dat += "<div class='SettingNameCol'>" // DIV A A B C A
	dat += "Gradient:"
	dat += "</div>" // End of DIV A A B C A
	dat += PrefLink("<", "hair_gradient_style_1", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "hair_gradient_style_1", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink("[features["grad_style"]]", "hair_gradient_style_1")
	dat += "<div class='SettingNameCol'>" // DIV A A B C B
	dat += "Color:"
	dat += "</div>" // End of DIV A A B C B
	dat += ColorBox("hair_gradient_color_1", data = feat_data)
	dat += "</div>" // End of DIV A A B C
	dat += "</div>" // End of DIV A A B
	dat += "</div>" // End of DIV A A
	dat += "<div class='SettingArray'>" // DIV A B
	dat += "<div class='SettingFlexCol'>" // DIV A B A
	dat += "<div class='SettingName'>" // DIV A B A A
	dat += "Hairea 2"
	dat += "</div>" // End of DIV A B A A
	dat += "<div class='SettingValueSplit'>" // DIV A B A B
	dat += "<div class='SettingNameCol'>" // DIV A B A B A
	dat += "Style:"
	dat += "</div>" // End of DIV A B A B A
	dat += PrefLink("<", "hair_style_2", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "hair_style_2", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink("[features["hair_style_2"]]", "hair_style_2")
	dat += "<div class='SettingNameCol'>" // DIV A B A B B
	dat += "Color:"
	dat += "</div>" // End of DIV A B A B B
	dat += ColorBox("hair_color_2", data = feat_data)
	dat += "</div>" // End of DIV A B A B
	dat += "<div class='SettingValueSplit'>" // DIV A B A C
	dat += "<div class='SettingNameCol'>" // DIV A B A C A
	dat += "Gradient:"
	dat += "</div>" // End of DIV A B A C A
	dat += PrefLink("<", "grad_style_2", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "grad_style_2", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink("[features["grad_style_2"]]", "grad_style_2")
	dat += "<div class='SettingNameCol'>" // DIV A B A C B
	dat += "Color:"
	dat += "</div>" // End of DIV A B A C B
	dat += ColorBox("grad_color_2", data = feat_data)
	dat += "</div>" // End of DIV A B A C
	dat += "</div>" // End of DIV A B A
	dat += "</div>" // End of DIV A B
	dat += "<div class='SettingArray'>" // DIV A C
	dat += "<div class='SettingFlexCol'>" // DIV A C A
	dat += "<div class='SettingName'>" // DIV A C A A
	dat += "Facial Hair"
	dat += "</div>" // End of DIV A C A A
	dat += "<div class='SettingValueSplit'>" // DIV A C A B
	dat += "<div class='SettingNameCol'>" // DIV A C A B A
	dat += "Style:"
	dat += "</div>" // End of DIV A C A B A
	dat += PrefLink("<", "facial_hair_style", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "facial_hair_style", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink("[facial_hair_style]", "facial_hair_style")
	dat += "<div class='SettingNameCol'>" // DIV A C A B B
	dat += "Color:"
	dat += "</div>" // End of DIV A C A B B
	dat += ColorBox("facial_hair_color", data = var_data)
	dat += "</div>" // End of DIV A C A B
	dat += "</div>" // End of DIV A C A
	dat += "</div>" // End of DIV A C
	dat += "</div>" // End of DIV A
	// As am I
	return dat.Join()

/// Body parts, body parts, getting me erect
/datum/preferences/proc/AppearanceParts()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	for(var/mutant_part in GLOB.all_mutant_parts)
		if(mutant_part == "mam_body_markings")
			continue
		if(!parent.can_have_part(mutant_part))
			continue
		dat += "<div class='PartsFlex'>" // DIV A A A
		dat += "<div class='SettingFlexCol'>" // DIV A A A A
		dat += "<div class='SettingNameCol'>" // DIV A A A A A
		dat += "[GLOB.all_mutant_parts[mutant_part]]"
		dat += "</div>" // End of DIV A A A A A
		dat += "<div class='SettingValueSplit'>" // DIV A A A A B
		dat += "<div class='SettingNameCol'>" // DIV A A A A B A
		dat += "Style:"
		dat += "</div>" // End of DIV A A A A B A
		dat += PrefLink("<", "change_part", list("partkind" = mutant_part, PREFDAT = GO_PREV), span = "SmolButton")
		dat += PrefLink(">", "change_part", list("partkind" = mutant_part, PREFDAT = GO_NEXT), span = "SmolButton")
		dat += PrefLink("[features[mutant_part]]", "change_part", list("partkind" = mutant_part))
		dat += "</div>" // End of DIV A A A A B
		/// now for the hell that is *colors*
		dat += "<div class='SettingValueSplit'>" // DIV A A A A C
		var/color_type = GLOB.colored_mutant_parts[mutant_part]
		var/list/feat_data = list(PREFDAT_COLKEY_IS_FEATURE = TRUE)
		if(color_type)
			dat += ColorBox(color_type, data = feat_data)
		else // this is the hell
			if(features["color_scheme"] != ADVANCED_CHARACTER_COLORING)
				features["color_scheme"] = ADVANCED_CHARACTER_COLORING // screw you, use it
			var/find_part = features[mutant_part] || pref_species.mutant_bodyparts[mutant_part]
			var/find_part_list = GLOB.mutant_reference_list[mutant_part]
			if(!find_part || find_part == "None" || !find_part_list)
				continue
			var/datum/sprite_accessory/accessory = find_part_list[find_part]
			if(!accessory)
				continue
			// fuuck you POOJ
			if(accessory.color_src != MATRIXED && \
				accessory.color_src != MUTCOLORS && \
				accessory.color_src != MUTCOLORS2 && \
				accessory.color_src != MUTCOLORS3)
				continue // something something mutcolors are deprecated, not that it matters
			var/mutant_string = accessory.mutant_part_string
			var/primary_feature = "[mutant_string]_primary"
			var/secondary_feature = "[mutant_string]_secondary"
			var/tertiary_feature = "[mutant_string]_tertiary"
			/// these just sanitize the colors, pay no attention!!!
			if(!features[primary_feature])
				features[primary_feature] = features["mcolor"]
			if(!features[secondary_feature])
				features[secondary_feature] = features["mcolor2"]
			if(!features[tertiary_feature])
				features[tertiary_feature] = features["mcolor3"]
			var/matrixed_sections = accessory.matrixed_sections
			if(accessory.color_src == MATRIXED)
				if(!matrixed_sections)
					message_admins("Sprite Accessory Failure (customization): Accessory [accessory.type] is a matrixed item without any matrixed sections set!")
					continue
				// this part properly shuffles the colors around becausE THANKS POOJ
				switch(matrixed_sections)
					if(MATRIX_GREEN) //only composed of a green section
						primary_feature = secondary_feature //swap primary for secondary, so it properly assigns the second colour, reserved for the green section
					if(MATRIX_BLUE)
						primary_feature = tertiary_feature //same as above, but the tertiary feature is for the blue section
					if(MATRIX_RED_BLUE) //composed of a red and blue section
						secondary_feature = tertiary_feature //swap secondary for tertiary, as blue should always be tertiary
					if(MATRIX_GREEN_BLUE) //composed of a green and blue section
						primary_feature = secondary_feature //swap primary for secondary, as first option is green, which is linked to the secondary
						secondary_feature = tertiary_feature //swap secondary for tertiary, as second option is blue, which is linked to the tertiary
					// BUT WHAT ABOUT FULL RGB well tahts already set up
			/// NOW, the colors are all set up, display the color pickers
			dat += ColorBox(primary_feature, data = feat_data)
			if(accessory.ShouldHaveSecondaryColor())
				dat += ColorBox(secondary_feature, data = feat_data)
				if(accessory.ShouldHaveTertiaryColor())
					dat += ColorBox(tertiary_feature, data = feat_data) // WAS THAT SO HARD, POOJ?
		dat += "</div>" // End of DIV A A A A C
		dat += "</div>" // End of DIV A A A
	dat += "</div>" // End of DIV A A
	/// robot parts
	dat += "<div class='SettingArray'>" // DIV A B
	dat += "<div class='SettingFlexCol'>" // DIV A B A
	dat += "<div class='SettingName'>" // DIV A B A A
	dat += "Limb Modifications"
	for(var/modification in modified_limbs)
		dat += "<div class='SettingValueSplit'>"
		dat += "<div class='SettingNameCol'>"
		dat += "[modification]"
		dat += "</div>"
		dat += PrefLink("X", "modify_limbs", list("remove", modification), span = "SmolButton")
		var/toshow = modified_limbs[modification][1]
		if(toshow == LOADOUT_LIMB_PROSTHETIC)
			toshow = modified_limbs[modification][2]
		dat += PrefLink(toshow, "modify_limbs", list("modify", modification))
		dat += "</div>"
	dat += "<div class='SettingValueSplit'>" // DIV A B A B
	dat += PrefLink("+ Add Something!", "modify_limbs", list(PREFDAT = "add"))
	dat += "</div>" // End of DIV A B A B
	dat += "</div>" // End of DIV A B A
	dat += "</div>" // End of DIV A B
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/AppearanceMarkings()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='SettingFlexCol'>" // DIV A A
	dat += "<div class='SettingName'>" // DIV A A A
	dat += "Cool Markings"
	dat += "</div>" // End of DIV A A A
	if(!parent.parent.can_have_part("mam_body_markings"))
		dat += "<div class='SettingNameCol'>" // DIV A A A B
		dat += "Oh no, you can't have any! Tough luck :("
		dat += "</div>" // End of DIV A A A B
		dat += "</div>" // End of DIV A A
		dat += "</div>" // End of DIV A
		return dat.Join()
	// we use mam markings, ma'am
	if(LAZYLEN(features["mam_body_markings"]))
		var/list/markings = features["mam_body_markings"]
		if(!islist(markings))
			markings = list()
		// we're gonna group em turnwise by the limb they're on
		/// FORMAT: list("Head" = list(HTML glonch))
		var/list/markings_by_part = list()
		var/list/rev_markings = reverseList(markings)
		for(var/list/mark in rev_markings)
			var/limb_value = mark[MARKING_LIMB_INDEX_NUM]
			var/limb_name = GLOB.bodypart_names[num2text(limb_value)]
			if(!markings_by_part[limb_name])
				markings_by_part[limb_name] = list()
			/// make the HTML glonch
			var/m_uid = mark[MARKING_UID]
			var/cm_dat = ""
			cm_dat += "<div class='SettingValueSplit'>" // DIV A A A B A
			cm_dat += "<div class='SettingNameCol ForceBuffer'>" // DIV A A A B A A
			cm_dat += "[mark[MARKING_NAME]]"
			cm_dat += "</div>" // End of DIV A A A B A A
			cm_dat += MarkingPrefLink(
				"X",
				PREFCMD_MARKING_REMOVE,
				m_uid,
				span = "SmolButton"
			)
			cm_dat += MarkingPrefLink(
				"&uarr;",
				PREFCMD_MARKING_MOVE_UP,
				m_uid,
				span = "SmolButton"
			)
			cm_dat += MarkingPrefLink(
				"&darr;",
				PREFCMD_MARKING_MOVE_DOWN,
				m_uid,
				span = "SmolButton"
			)
			cm_dat += MarkingPrefLink(
				"<",
				PREFCMD_MARKING_PREV,
				m_uid,
				span = "SmolButton"
			)
			cm_dat += MarkingPrefLink(
				">",
				PREFCMD_MARKING_NEXT,
				m_uid,
				span = "SmolButton"
			)
			cm_dat += MarkingPrefLink(
				"[mark[MARKING_NAME]]",
				PREFCMD_MARKING_EDIT,
				m_uid
			)
			cm_dat += "</div>" // End of DIV A A A B A
			/// and here come the colors
			cm_dat += "<div class='SettingValueSplit'>" // DIV A A A B B
			var/datum/sprite_accessory/mam_body_markings/S = GLOB.mam_body_markings_list[mark[2]]
			var/matrixed_sections = S.covered_limbs[limb_name]
			if(S && matrixed_sections)
				// if it has nothing initialize it to white
				if(LAZYLEN(mark) == 2)
					mark.len = 3
					var/first = "#FFFFFF"
					var/second = "#FFFFFF"
					var/third = "#FFFFFF"
					if(features["mcolor"])
						first = "#[features["mcolor"]]"
					if(features["mcolor2"])
						second = "#[features["mcolor2"]]"
					if(features["mcolor3"])
						third = "#[features["mcolor3"]]"
					mark[MARKING_COLOR_LIST] = list(first, second, third) // just assume its 3 colours if it isnt it doesnt matter we just wont use the other values
				// index magic
				var/primary_index = 1
				var/secondary_index = 2
				var/tertiary_index = 3
				switch(matrixed_sections)
					if(MATRIX_GREEN)
						primary_index = 2
					if(MATRIX_BLUE)
						primary_index = 3
					if(MATRIX_RED_BLUE)
						secondary_index = 2
					if(MATRIX_GREEN_BLUE)
						primary_index = 2
						secondary_index = 3
				cm_dat += MarkingColorBox(mark, primary_index, m_uid)
				if(matrixed_sections == MATRIX_RED_BLUE || \
					matrixed_sections == MATRIX_GREEN_BLUE || \
					matrixed_sections == MATRIX_RED_GREEN || \
					matrixed_sections == MATRIX_ALL)
					cm_dat += MarkingColorBox(mark, secondary_index, m_uid)
				if(matrixed_sections == MATRIX_ALL)
					cm_dat += MarkingColorBox(mark, tertiary_index, m_uid)
			cm_dat += "</div>" // End of DIV A A A B B
			/// just kidding, we're not sorting anything!
			markings_by_part += cm_dat
		/// now we display the markings
		for(var/part in markings_by_part)
			dat += "[part]"
	dat += "</div>" // End of DIV A
	return dat.Join()


/datum/preferences/proc/AppearanceUnderlyingUndies()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='SettingArray'>" // DIV A A	
	dat += "<div class='PartsContainer'>" // DIV A A A
	dat += "<div class='PartsFlex'>" // DIV A A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A A
	dat += "Topwear"
	dat += "</div>" // End of DIV A A A A A A
	dat += "<div class='SettingValueSplit'>" // DIV A A A A A B
	dat += "<div class='SettingNameCol'>" // DIV A A A A A B A
	dat += "Style:"
	dat += "</div>" // End of DIV A A A A A B A
	dat += PrefLink("<", "undershirt", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "undershirt", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink("[undershirt]", "undershirt")
	dat += "</div>" // End of DIV A A A A A B
	dat += "<div class='SettingValueSplit'>" // DIV A A A A A C
	dat += "<div class='SettingNameCol'>" // DIV A A A A A C A
	dat += "Color:"
	dat += "</div>" // End of DIV A A A A A C A
	var/list/data = list(PREFDAT_COLKEY_IS_VAR = TRUE)
	dat += ColorBox("undershirt_color", data = data)
	dat += "</div>" // End of DIV A A A A A C
	dat += "</div>" // End of DIV A A A A A
	dat += "</div>" // End of DIV A A A
	dat += "<div class='PartsFlex'>" // DIV A A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A A B A A
	dat += "Underwear"
	dat += "</div>" // End of DIV A A A B A A
	dat += "<div class='SettingValueSplit'>" // DIV A A A B A B
	dat += "<div class='SettingNameCol'>" // DIV A A A B A B A
	dat += "Style:"
	dat += "</div>" // End of DIV A A A B A B A
	dat += PrefLink("<", "underwear", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "underwear", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink("[underwear]", "underwear")
	dat += "</div>" // End of DIV A A A B A B
	dat += "<div class='SettingValueSplit'>" // DIV A A A B A C
	dat += "<div class='SettingNameCol'>" // DIV A A A B A C A
	dat += "Color:"
	dat += "</div>" // End of DIV A A A B A C A
	dat += ColorBox("undie_color", data = data)
	dat += "</div>" // End of DIV A A A B A C
	dat += "</div>" // End of DIV A A A B A
	dat += "</div>" // End of DIV A A A
	dat += "<div class='PartsFlex'>" // DIV A A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A A C A A
	dat += "Socks"
	dat += "</div>" // End of DIV A A A C A A
	dat += "<div class='SettingValueSplit'>" // DIV A A A C A B
	dat += "<div class='SettingNameCol'>" // DIV A A A C A B A
	dat += "Style:"
	dat += "</div>" // End of DIV A A A C A B A
	dat += PrefLink("<", "socks", list(PREFDAT = GO_PREV), span = "SmolButton")
	dat += PrefLink(">", "socks", list(PREFDAT = GO_NEXT), span = "SmolButton")
	dat += PrefLink("[socks]", "socks")
	dat += "</div>" // End of DIV A A A C A B
	dat += "<div class='SettingValueSplit'>" // DIV A A A C A C
	dat += "<div class='SettingNameCol'>" // DIV A A A C A C A
	dat += "Color:"
	dat += "</div>" // End of DIV A A A C A C A
	dat += ColorBox("socks_color", data = data)
	dat += "</div>" // End of DIV A A A C A C
	dat += "</div>" // End of DIV A A A C A
	dat += "</div>" // End of DIV A A A
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/AppearanceUnderlyingLayering()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<table class='TabHeader'>" // DIV A A
	// header row
	dat += "<tr>" // DIV A A A
	dat += "<td>" // DIV A A A A
	dat += "Part"
	dat += "</td>" // End of DIV A A A A
	dat += "<td colspan='2'>" // DIV A A A B
	dat += "Shift"
	dat += "</td>" // End of DIV A A A B
	dat += "<td colspan='2'>" // DIV A A A C
	dat += "Hidden by..."
	dat += "</td>" // End of DIV A A A C
	dat += "<td>" // DIV A A A D
	dat += "Override"
	dat += "</td>" // End of DIV A A A D
	dat += "<td>" // DIV A A A E
	dat += "See on others"
	dat += "</td>" // End of DIV A A A E
	dat += "<td>" // DIV A A A F
	dat += "Has"
	dat += "</td>" // End of DIV A A A F
	dat += "</tr>" // End of DIV A A A
	/// now the true fun begins
	/// okay we've all ahd our fun with the c_string, time to use json like a real adult
	var/list/cakestring = features["genital_order"]
	cakestring = reverseList(cakestring) // so the order makes sense
	//cakestring should have every genital known to man, so this should be fine
	// first, filter out any non-visible parts
	for(var/haz_donk in cakestring)
		var/datum/genital_data/GD = GLOB.genital_data_system[haz_donk]
		if(!(GD.genital_flags & GENITAL_CAN_HAVE))
			cakestring -= haz_donk
			continue
		if(!(GD.genital_flags & GENITAL_INTERNAL))
			cakestring -= haz_donk
			continue
	var/index = 1
	for(var/has_donk in cakestring)
		var/datum/genital_data/GD = GLOB.genital_data_system[has_donk]
		dat += "<tr>"
		dat += "<td>"
		dat += "[GD.name]"
		dat += "</td>"
		dat += "<td>"
		if(index > 1) // dir is flipped, because the list is reversed
			dat += PrefLink("&uarr;", PREFCMD_SHIFT_GENITAL, list("part" = has_donk, "dir" = "down"), span = "SmolButton")
		else
			dat += "&nbsp;"
		dat += "</td>"
		dat += "<td>"
		if(index < LAZYLEN(cakestring))
			dat += PrefLink("&darr;", PREFCMD_SHIFT_GENITAL, list("part" = has_donk, "dir" = "up"), span = "SmolButton")
		else
			dat += "&nbsp;"
		dat += "</td>"
		dat += "<td>"
		var/undiehidspan
		if(features[GD.vis_flags_key] & GENITAL_RESPECT_UNDERWEAR)
			udiehidspan = "TabCellselected"
		dat += PrefLink("Underwear", PREFCMD_HIDE_GENITAL, list("part" = has_donk, "hide" = "undies"), span = undiehidspan)
		dat += "</td>"
		dat += "<td>"
		var/clotheshidspan
		if(features[GD.vis_flags_key] & GENITAL_RESPECT_CLOTHES)
			clotheshidspan = "TabCellselected"
		dat += PrefLink("Clothes", PREFCMD_HIDE_GENITAL, list("part" = has_donk, "hide" = "clothes"), span = clotheshidspan)
		dat += "</td>"
		dat += "<td>"
		var/peen_vis_override
		if(CHECK_BITFIELD(features[GD.override_key], GENITAL_ALWAYS_HIDDEN))
			peen_vis_override = "Always Hidden"
		else if(CHECK_BITFIELD(features[GD.override_key], GENITAL_ALWAYS_VISIBLE))
			peen_vis_override = "Always Visible"
		else
			peen_vis_override = "Check Coverage"
		dat += PrefLink(peen_vis_override, PREFCMD_OVERRIDE_GENITAL, list("part" = has_donk), span = "SmolButton")
		dat += "</td>"
		dat += "<td>"
		var/peen_see_span
		if(!(features["genital_hide"] & GD.hide_flag))
			peen_see_span = "TabCellselected"
		dat += PrefLink("Yes", PREFCMD_SEE_GENITAL, list("part" = has_donk), span = peen_see_span)
		dat += "</td>"
		dat += "<td>"
		var/peen_has_span
		var/peen_word = "No"
		if(features[GD.has_key])
			peen_has_span = "TabCellselected"
			peen_word = "Yes"
		dat += PrefLink(peen_word, PREFCMD_TOGGLE_GENITAL, list("part" = has_donk), span = peen_has_span)
		dat += "</td>"
		dat += "</tr>"
		index += 1
	dat += "<tr>"
	dat += "<td colspan='8'>"
	dat += PrefLink("P-Hud Whitelisting", PREFCMD_PHUD_WHITELIST)
	dat += "</td>"
	dat += "</tr>"
	dat += "</table>"
	dat += "</div>"
	return dat.Join()

// this one is built based on which genital sub sub tab is open
/datum/preferences/proc/AppearanceUnderlyingGenitals()
	var/datum/genital_data/GD = GLOB.genital_data_system[current_sub_subtab]
	if(!GD)
		return "OH NO THERES A BUG HERE TELL DAN ERROR CODE: SQUISHY FOX BINGUS 2000"
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='SettingFlexCol'>" // DIV A A
	dat += "<div class='SettingValueSplit'>" // DIV A A A
	dat += "<div class='SettingNameCol ForceBuffer'>" // DIV A A A A
	dat += "Has one:"
	dat += "</div>" // End of DIV A A A A
	var/yesno = "No"
	if(features[GD.has_key])
		yesno = "Yes"
	dat += PrefLink(yesno, PREFCMD_TOGGLE_GENITAL, list("part" = current_sub_subtab))
	var/can_color = GD.genital_flags & GENITAL_CAN_RECOLOR
	if(can_color)
		var/list/feat_data = list(PREFDAT_COLKEY_IS_FEATURE = TRUE)
		dat += ColorBox(GD.color_key, data = feat_data)
	dat += "</div>" // End of DIV A A A
	if(!(GD.genital_flags & GENITAL_INTERNAL))
		var/can_shape = GD.genital_flags & GENITAL_CAN_RESHAPE
		var/can_size = GD.genital_flags & GENITAL_CAN_RESIZE
		if(can_shape || can_size)
			dat += "<div class='SettingValueSplit'>" // DIV A A B
			if(can_shape)
				dat += "<div class='SettingNameCol ForceBuffer'>" // DIV A A B A
				dat += "Shape:"
				dat += "</div>" // End of DIV A A B A
				dat += PrefLink("[capitalize(features[GD.shape_key])]", PREFCMD_CHANGE_GENITAL_SHAPE, list("part" = current_sub_subtab))
			if(can_size)
				dat += "<div class='SettingNameCol ForceBuffer'>" // DIV A A B B
				dat += "Size:"
				dat += "</div>" // End of DIV A A B B
				dat += PrefLink("[GD.SizeString(features[GD.size_key])]", PREFCMD_CHANGE_GENITAL_SIZE, list("part" = current_sub_subtab))
			dat += "</div>" // End of DIV A A B
		var/hidden_by_clothes = GD.genital_flags & GENITAL_RESPECT_CLOTHES
		var/hbc_span = ""
		if(hidden_by_clothes)
			hbc_span = "TabCellselected"
		var/hidden_by_undies = GD.genital_flags & GENITAL_RESPECT_UNDERWEAR
		var/hbu_span = ""
		if(hidden_by_undies)
			hbu_span = "TabCellselected"
		dat += "<div class='SettingValueSplit'>" // DIV A A C
		dat += "<div class='SettingNameCol ForceBuffer'>" // DIV A A C A
		dat += "Hidden by:"
		dat += "</div>" // End of DIV A A C A
		dat += PrefLink("Clothes", PREFCMD_HIDE_GENITAL, list("part" = current_sub_subtab, "hide" = "clothes"), span = hbc_span)
		dat += PrefLink("Underpants", PREFCMD_HIDE_GENITAL, list("part" = current_sub_subtab, "hide" = "undies"), span = hbu_span)
		dat += "</div>" // End of DIV A A C
		var/override = "Check Coverage"
		if(CHECK_BITFIELD(features[GD.override_key], GENITAL_ALWAYS_HIDDEN))
			override = "Always Hidden"
		else if(CHECK_BITFIELD(features[GD.override_key], GENITAL_ALWAYS_VISIBLE))
			override = "Always Visible"
		dat += "<div class='SettingValueSplit'>" // DIV A A D
		dat += "<div class='SettingNameCol ForceBuffer'>" // DIV A A D A
		dat += "Override:"
		dat += "</div>" // End of DIV A A D A
		dat += PrefLink(override, PREFCMD_OVERRIDE_GENITAL, list("part" = current_sub_subtab))
		dat += "</div>" // End of DIV A A D
		var/see_on_others = "No"
		if(!(features["genital_hide"] & GD.hide_flag))
			see_on_others = "Yes"
		dat += "<div class='SettingValueSplit'>" // DIV A A E
		dat += "<div class='SettingNameCol ForceBuffer'>" // DIV A A E A
		dat += "See on others:"
		dat += "</div>" // End of DIV A A E A
		dat += PrefLink(see_on_others, PREFCMD_SEE_GENITAL, list("part" = current_sub_subtab))
		dat += "</div>" // End of DIV A A E
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	return dat.Join()

/// the unholy evil death bringer of the preferences tab
/datum/preferences/proc/Loadout()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='FlexTable'>" // DIV A A
	dat += "<div class='SettingName'>" // DIV A A A
	var/gear_points = CONFIG_GET(number/initial_gear_points)
	var/list/chosen_gear = loadout_data["SAVE_[loadout_slot]"]
	if(chosen_gear)
		for(var/loadout_item in chosen_gear)
			var/loadout_item_path = loadout_item[LOADOUT_ITEM]
			if(loadout_item_path)
				var/datum/gear/loadout_gear = text2path(loadout_item_path)
				if(loadout_gear)
					gear_points -= initial(loadout_gear.cost)
	else
		chosen_gear = list()
	var/points_color = "#00FF00"
	if(gear_points <= 0)
		points_color = "#FF0000"
	dat += "You have <font color='[points_color]'>[gear_points]</font> points!"
	dat += "</div>" // End of DIV A A A
	dat += PrefLink("Reset", PREFCMD_LOADOUT_RESET, list("loadout_slot" = loadout_slot), span = "SmolButton")
	dat += "<span class='Spacer'></span>"
	dat += PrefLink("X", PREFCMD_LOADOUT_SEARCH_CLEAR, span = "SmolButton")
	var/searchterm = search_term ? copytext(search_term, 1, 30) : "Search"
	dat += PrefLink("[searchterm]", PREFCMD_LOADOUT_SEARCH, span = "SmolButton Wider100")
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	// now we need to build the actual gear list
	// Categories!
	if(!GLOB.loadout_categories[gear_category] && gear_category != GEAR_CAT_ALL_EQUIPPED)
		gear_category = GLOB.loadout_categories[1]
	dat += "<div class='FlexTable'>" // DIV A A
	for(var/category in (GEAR_CAT_ALL_EQUIPPED | GLOB.loadout_categories))
		var/selspan = ""
		if(category == gear_category)
			selspan = "TabCellselected"
		dat += PrefLink(category, PREFCMD_LOADOUT_CATEGORY, list("category" = html_encode(category)), span = selspan)
	dat += "</div>" // End of DIV A A
	dat += "<div class='CoolDivider'></div>" // DIV A B End of DIV A B
	// Subcategories!
	var/list/subcategories = GLOB.loadout_categories[gear_category]
	if(gear_category != GEAR_CAT_ALL_EQUIPPED && !subcategories.Find(gear_subcategory))
		gear_subcategory = subcategories[1]
	dat += "<div class='FlexTable'>" // DIV A C
	for(var/subcategory in subcategories)
		var/selspan = ""
		if(subcategory == gear_subcategory)
			selspan = "TabCellselected"
		dat += PrefLink(subcategory, PREFCMD_LOADOUT_SUBCATEGORY, list("subcategory" = html_encode(subcategory)), span = selspan)
	dat += "</div>" // End of DIV A C
	dat += "<div class='CoolDivider'></div>" // DIV A D End of DIV A D
	// now we need to build the actual gear list
	// first lets get all the gear
	var/list/gear_list = list()
	var/list/mystuff = list()
	var/list/my_saved = loadout_data["SAVE_[loadout_slot]"]
	var/minestuff = gear_category == GEAR_CAT_ALL_EQUIPPED
	for(var/loadout_gear in my_saved)
		my_stuff["[loadout_gear[LOADOUT_ITEM]]"] = TRUE // typecache!
	var/list/flatlyss
	if(search_term || gear_category == GEAR_CAT_ALL_EQUIPPED)
		var/list/searchmine = list()
		if(gear_category == GEAR_CAT_ALL_EQUIPPED)
			searchmine = my_stuff
		else
			searchmine = list()
		flatlyss = GetGearFlatList(search_term, searchmine)
	else
		for(var/name in GLOB.loadout_items[gear_category][gear_subcategory])
			flatlyss += GLOB.loadout_items[gear_category][gear_subcategory][name]
	// now we need to sort the gear
	flatlyss = sort_list(flatlyss, /proc/cmp_gear_name_asc)
	// now we need to display the gear
	dat += "<div class='SettingArray'>" // DIV A E
	dat += "<div class='PartsContainer'>" // DIV A E A
	for(var/datum/gear/gear in flatlyss)
		var/donoritem = gear.donoritem
		if(donoritem && !gear.donator_ckey_check(user.ckey))
			continue
		var/i_have_it = my_stuff["[gear.type]"]
		var/edited_name
		var/edited_desc
		var/edited_color
		if(i_have_it)
			var/list/loadout_item = has_loadout_gear(loadout_slot, "[gear.type]")
			if(loadout_item)
				if(LAZYLEN(loadout_item[LOADOUT_CUSTOM_NAME]))
					edited_name = loadout_item[LOADOUT_CUSTOM_NAME]
				if(LAZYLEN(loadout_item[LOADOUT_CUSTOM_DESC]))
					edited_desc = loadout_item[LOADOUT_CUSTOM_DESC]
				if(LAZYLEN(loadout_item[LOADOUT_CUSTOM_COLOR]))
					edited_color = loadout_item[LOADOUT_CUSTOM_COLOR]
		dat += "<div class='PartsFlex'>" // DIV A E A A
		dat += "<div class='FlexTable'>" // DIV A E A A A
		var/list/namespan = list()
		if(i_have_it)
			namespan += "TabCellselected"
		namespan += "NotSoSmolBox"
		if(edited_name)
			namespan += "EditedEntry"
		var/truenamespan = namespan.Join(" ")
		var/namedisplay = edited_name ? edited_name : gear.name
		dat += PrefLink(namedisplay, PREFCMD_LOADOUT_TOGGLE, list("gear" = "[gear.type]"), span = truenamespan)
		var/canafford = (gear_points - gear.cost) >= 0
		var/costspan = "SettingName SmolBox"
		if(!canafford)
			costspan += " CantAfford"
		dat += "<div class='SettingName SmolBox'>" // DIV A E A A A B
		dat += "[gear.cost] pts"
		dat += "</div>" // End of DIV A E A A A B
		var/descspan = "SettingValueSplit"
		if(edited_desc)
			descspan += " EditedEntry"
		dat += "<div class='[descspan]'>" // DIV A E A A A C
		dat += "<div class='LoadoutDesc'>" // DIV A E A A A C A
		var/descdisplay = edited_desc ? edited_desc : gear.desc
		dat += descdisplay
		dat += "</div>" // End of DIV A E A A A C A
		dat += "</div>" // End of DIV A E A A A C
		if(i_have_it) // show the customization things
			dat += "<div class='SettingValueSplit'>" // DIV A E A A A D
			dat += GearColorBox(gear, edited_color)
			dat += PrefLink("Edit <br>Name", PREFCMD_LOADOUT_RENAME, list("gear" = "[gear.type]"), span = "SmolButton NotSoSmolBox")
			dat += PrefLink("Edit <br>Desc", PREFCMD_LOADOUT_REDESC, list("gear" = "[gear.type]"), span = "SmolButton NotSoSmolBox")
			dat += "</div>" // End of DIV A E A A A D
		dat += "</div>" // End of DIV A E A A A
		dat += "</div>" // End of DIV A E A A
	dat += "</div>" // End of DIV A E A
	dat += "</div>" // End of DIV A E
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/GamePreferencesGeneral()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	// Widescreen
	dat += "<div class='PartsFlex'>" // DIV A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A
	dat += "Widescreen"
	dat += "</div>" // End of DIV A A A A A
	var/showtext1 = "Disabled (15x15)"
	if(widescreenpref)
		showtext1 = "Enabled ([CONFIG_GET(string/default_view)])"
	dat += PrefLink(showtext1, PREFCMD_WIDESCREEN_TOGGLE)
	dat += "</div>" // End of DIV A A A A
	dat += "</div>" // End of DIV A A A
	// Auto Stand
	dat += "<div class='PartsFlex'>" // DIV A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A B A A
	dat += "Auto Stand"
	dat += "</div>" // End of DIV A A B A A
	var/showtext2 = "Disabled"
	if(autostand)
		showtext2 = "Enabled"
	dat += PrefLink(showtext2, PREFCMD_AUTOSTAND_TOGGLE)
	dat += "</div>" // End of DIV A A B A
	dat += "</div>" // End of DIV A A B
	// Force Slot Storage HUD
	dat += "<div class='PartsFlex'>" // DIV A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A C A A
	dat += "Force Slot Storage HUD"
	dat += "</div>" // End of DIV A A C A A
	var/showtext3 = "Disabled"
	if(no_tetris_storage)
		showtext3 = "Enabled"
	dat += PrefLink(showtext3, PREFCMD_TETRIS_STORAGE_TOGGLE)
	dat += "</div>" // End of DIV A A C A
	dat += "</div>" // End of DIV A A C
	// Gun Cursor
	dat += "<div class='PartsFlex'>" // DIV A A D
	dat += "<div class='SettingFlexCol'>" // DIV A A D A
	dat += "<div class='SettingNameCol'>" // DIV A A D A A
	dat += "Gun Cursor"
	dat += "</div>" // End of DIV A A D A A
	var/showtext4 = "Disabled"
	if(cb_toggles & AIM_CURSOR_ON)
		showtext4 = "Enabled"
	dat += PrefLink(showtext4, PREFCMD_GUNCURSOR_TOGGLE)
	dat += "</div>" // End of DIV A A D A
	dat += "</div>" // End of DIV A A D
	// Screen Shake
	dat += "<div class='PartsFlex'>" // DIV A A E
	dat += "<div class='SettingFlexCol'>" // DIV A A E A
	dat += "<div class='SettingNameCol'>" // DIV A A E A A
	dat += "Screen Shake"
	dat += "</div>" // End of DIV A A E A A
	var/showtext5 = "None"
	if(screenshake == 100)
		showtext5 = "Full"
	else if(screenshake != 0)
		showtext5 = "[screenshake]"
	dat += PrefLink(showtext5, PREFCMD_SCREENSHAKE_TOGGLE)
	dat += "</div>" // End of DIV A A E A
	dat += "</div>" // End of DIV A A E
	// Damage Screen Shake
	dat += "<div class='PartsFlex'>" // DIV A A F
	dat += "<div class='SettingFlexCol'>" // DIV A A F A
	dat += "<div class='SettingNameCol'>" // DIV A A F A A
	dat += "Damage Screen Shake"
	dat += "</div>" // End of DIV A A F A A
	var/showtext6 = "Only when down"
	if(damagescreenshake == 1)
		showtext6 = "On"
	else if(damagescreenshake == 0)
		showtext6 = "Off"
	dat += PrefLink(showtext6, PREFCMD_DAMAGESCREENSHAKE_TOGGLE)
	dat += "</div>" // End of DIV A A F A
	dat += "</div>" // End of DIV A A F
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/GamePreferencesUI()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	// UI Style
	dat += "<div class='PartsFlex'>" // DIV A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A
	dat += "UI Style"
	dat += "</div>" // End of DIV A A A A A
	dat += PrefLink("[ui_style]", PREFCMD_UI_STYLE)
	dat += "</div>" // End of DIV A A A A
	dat += "</div>" // End of DIV A A A
	// tgui Monitors
	dat += "<div class='PartsFlex'>" // DIV A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A B A A
	dat += "tgui Monitors"
	dat += "</div>" // End of DIV A A B A A
	var/showtext1 = "All"
	if(tgui_lock)
		showtext1 = "Primary"
	dat += PrefLink(showtext1, PREFCMD_TGUI_LOCK)
	dat += "</div>" // End of DIV A A B A
	dat += "</div>" // End of DIV A A B
	// tgui Style
	dat += "<div class='PartsFlex'>" // DIV A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A C A A
	dat += "tgui Style"
	dat += "</div>" // End of DIV A A C A A
	var/showtext2 = "No Frills"
	if(tgui_fancy)
		showtext2 = "Fancy"
	dat += PrefLink(showtext2, PREFCMD_TGUI_FANCY)
	dat += "</div>" // End of DIV A A C A
	dat += "</div>" // End of DIV A A C
	// Input Mode Hotkey
	dat += "<div class='PartsFlex'>" // DIV A A D
	dat += "<div class='SettingFlexCol'>" // DIV A A D A
	dat += "<div class='SettingNameCol'>" // DIV A A D A A
	dat += "Input Mode Hotkey"
	dat += "</div>" // End of DIV A A D A A
	dat += PrefLink("[input_mode_hotkey]", PREFCMD_INPUT_MODE_HOTKEY)
	dat += "</div>" // End of DIV A A D A
	dat += "</div>" // End of DIV A A D
	// Action Buttons
	dat += "<div class='PartsFlex'>" // DIV A A E
	dat += "<div class='SettingFlexCol'>" // DIV A A E A
	dat += "<div class='SettingNameCol'>" // DIV A A E A A
	dat += "Action Buttons"
	dat += "</div>" // End of DIV A A E A A
	var/showtext3 = "Unlocked"
	if(buttons_locked)
		showtext3 = "Locked In Place"
	dat += PrefLink(showtext3, PREFCMD_ACTION_BUTTONS)
	dat += "</div>" // End of DIV A A E A
	dat += "</div>" // End of DIV A A E
	// Window Flashing
	dat += "<div class='PartsFlex'>" // DIV A A F
	dat += "<div class='SettingFlexCol'>" // DIV A A F A
	dat += "<div class='SettingNameCol'>" // DIV A A F A A
	dat += "Window Flashing"
	dat += "</div>" // End of DIV A A F A A
	var/showtext4 = "Disabled"
	if(windowflashing)
		showtext4 = "Enabled"
	dat += PrefLink(showtext4, PREFCMD_WINFLASH)
	dat += "</div>" // End of DIV A A F A
	dat += "</div>" // End of DIV A A F
	// Ambient Occlusion
	dat += "<div class='PartsFlex'>" // DIV A A G
	dat += "<div class='SettingFlexCol'>" // DIV A A G A
	dat += "<div class='SettingNameCol'>" // DIV A A G A A
	dat += "Ambient Occlusion"
	dat += "</div>" // End of DIV A A G A A
	var/showtext5 = "Disabled"
	if(ambientocclusion)
		showtext5 = "Enabled"
	dat += PrefLink(showtext5, PREFCMD_AMBIENTOCCLUSION)
	dat += "</div>" // End of DIV A A G A
	dat += "</div>" // End of DIV A A G
	// Fit Viewport
	dat += "<div class='PartsFlex'>" // DIV A A H
	dat += "<div class='SettingFlexCol'>" // DIV A A H A
	dat += "<div class='SettingNameCol'>" // DIV A A H A A
	dat += "Fit Viewport"
	dat += "</div>" // End of DIV A A H A A
	var/showtext6 = "Manual"
	if(auto_fit_viewport)
		showtext6 = "Auto"
	dat += PrefLink(showtext6, PREFCMD_AUTO_FIT_VIEWPORT)
	dat += "</div>" // End of DIV A A H A
	dat += "</div>" // End of DIV A A H
	// HUD Button Flashes
	dat += "<div class='PartsFlex'>" // DIV A A I
	dat += "<div class='SettingFlexCol'>" // DIV A A I A
	dat += "<div class='SettingNameCol'>" // DIV A A I A A
	dat += "HUD Button Flashes"
	dat += "</div>" // End of DIV A A I A A
	var/showtext7 = "Disabled"
	if(hud_toggle_flash)
		showtext7 = "Enabled"
	dat += PrefLink(showtext7, PREFCMD_HUD_TOGGLE_FLASH)
	dat += "</div>" // End of DIV A A I A
	dat += "</div>" // End of DIV A A I
	// HUD Button Flash Color
	dat += "<div class='PartsFlex'>" // DIV A A J
	dat += "<div class='SettingFlexCol'>" // DIV A A J A
	dat += "<div class='SettingNameCol'>" // DIV A A J A A
	dat += "HUD Button Flash Color"
	dat += "</div>" // End of DIV A A J A A
	dat += "<div class='SettingValueSplit'>" // DIV A A J A B
	dat += ColorBox("hud_toggle_color")
	dat += "</div>" // End of DIV A A J A B
	dat += "</div>" // End of DIV A A J A
	dat += "</div>" // End of DIV A A J
	// FPS
	dat += "<div class='PartsFlex'>" // DIV A A K
	dat += "<div class='SettingFlexCol'>" // DIV A A K A
	dat += "<div class='SettingNameCol'>" // DIV A A K A A
	dat += "FPS"
	dat += "</div>" // End of DIV A A K A A
	dat += PrefLink("[clientfps]", PREFCMD_CLIENTFPS)
	dat += "</div>" // End of DIV A A K A
	dat += "</div>" // End of DIV A A K
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/GamePreferencesChat()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	// See Pull Requests
	dat += "<div class='PartsFlex'>" // DIV A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A
	dat += "See Pull Requests"
	dat += "</div>" // End of DIV A A A A A
	var/showtext1 = "Disabled"
	if(chat_toggles & CHAT_PULLR)
		showtext1 = "Enabled"
	dat += PrefLink(showtext1, PREFCMD_PULL_REQUESTS)
	dat += "</div>" // End of DIV A A A A
	dat += "</div>" // End of DIV A A A
	// Show Health Smileys
	dat += "<div class='PartsFlex'>" // DIV A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A B A A
	dat += "Show Health Smileys"
	dat += "</div>" // End of DIV A A B A A
	var/showtext2 = "Disabled"
	if(show_health_smilies)
		showtext2 = "Enabled"
	dat += PrefLink(showtext2, PREFCMD_HEALTH_SMILEYS)
	dat += "</div>" // End of DIV A A B A
	dat += "</div>" // End of DIV A A B
	// Max PFP Examine Image Height
	dat += "<div class='PartsFlex'>" // DIV A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A C A A
	dat += "Max PFP Examine Image Height"
	dat += "</div>" // End of DIV A A C A A
	dat += PrefLink("[see_pfp_max_hight]px", PREFCMD_MAX_PFP_HEIGHT)
	dat += "</div>" // End of DIV A A C A
	dat += "</div>" // End of DIV A A C
	// Max PFP Examine Image Width
	dat += "<div class='PartsFlex'>" // DIV A A D
	dat += "<div class='SettingFlexCol'>" // DIV A A D A
	dat += "<div class='SettingNameCol'>" // DIV A A D A A
	dat += "Max PFP Examine Image Width"
	dat += "</div>" // End of DIV A A D A A
	dat += PrefLink("[see_pfp_max_widht]%", PREFCMD_MAX_PFP_WIDTH)
	dat += "</div>" // End of DIV A A D A
	dat += "</div>" // End of DIV A A D
	// Auto OOC
	dat += "<div class='PartsFlex'>" // DIV A A E
	dat += "<div class='SettingFlexCol'>" // DIV A A E A
	dat += "<div class='SettingNameCol'>" // DIV A A E A A
	dat += "Auto OOC"
	dat += "</div>" // End of DIV A A E A A
	var/showtext3 = "Disabled"
	if(auto_ooc)
		showtext3 = "Enabled"
	dat += PrefLink(showtext3, PREFCMD_AUTO_OOC)
	dat += "</div>" // End of DIV A A E A
	dat += "</div>" // End of DIV A A E
	// Income Updates
	dat += "<div class='PartsFlex'>" // DIV A A F
	dat += "<div class='SettingFlexCol'>" // DIV A A F A
	dat += "<div class='SettingNameCol'>" // DIV A A F A A
	dat += "Income Updates"
	dat += "</div>" // End of DIV A A F A A
	var/showtext4 = "Muted"
	if(chat_toggles & CHAT_BANKCARD)
		showtext4 = "Allowed"
	dat += PrefLink(showtext4, PREFCMD_INCOME_UPDATES)
	dat += "</div>" // End of DIV A A F A
	dat += "</div>" // End of DIV A A F
	// Hear Radio Static
	dat += "<div class='PartsFlex'>" // DIV A A G
	dat += "<div class='SettingFlexCol'>" // DIV A A G A
	dat += "<div class='SettingNameCol'>" // DIV A A G A A
	dat += "Hear Radio Static"
	dat += "</div>" // End of DIV A A G A A
	var/showtext5 = "Muted"
	if(chat_toggles & CHAT_HEAR_RADIOSTATIC)
		showtext5 = "Allowed"
	dat += PrefLink(showtext5, PREFCMD_RADIO_STATIC)
	dat += "</div>" // End of DIV A A G A
	dat += "</div>" // End of DIV A A G
	// Hear Radio Blurbles
	dat += "<div class='PartsFlex'>" // DIV A A H
	dat += "<div class='SettingFlexCol'>" // DIV A A H A
	dat += "<div class='SettingNameCol'>" // DIV A A H A A
	dat += "Hear Radio Blurbles"
	dat += "</div>" // End of DIV A A H A A
	var/showtext6 = "Muted"
	if(chat_toggles & CHAT_HEAR_RADIOBLURBLES)
		showtext6 = "Allowed"
	dat += PrefLink(showtext6, PREFCMD_RADIO_BLURBLES)
	dat += "</div>" // End of DIV A A H A
	dat += "</div>" // End of DIV A A H
	// BYOND Membership Publicity
	if(usr.client)
		if(unlock_content)
			dat += "<div class='PartsFlex'>" // DIV A A I
			dat += "<div class='SettingFlexCol'>" // DIV A A I A
			dat += "<div class='SettingNameCol'>" // DIV A A I A A
			dat += "BYOND Membership Publicity"
			dat += "</div>" // End of DIV A A I A A
			var/showtext7 = "Hidden"
			if(toggles & MEMBER_PUBLIC)
				showtext7 = "Public"
			dat += PrefLink(showtext7, PREFCMD_BYOND_PUBLICITY)
			dat += "</div>" // End of DIV A A I A
			dat += "</div>" // End of DIV A A I
		if(unlock_content || check_rights(R_ADMIN))
			// OOC Color
			dat += "<div class='PartsFlex'>" // DIV A A J
			dat += "<div class='SettingFlexCol'>" // DIV A A J A
			dat += "<div class='SettingNameCol'>" // DIV A A J A A
			dat += "OOC Color"
			dat += "</div>" // End of DIV A A J A A
			dat += "<div class='SettingValueSplit'>" // DIV A A J A B
			dat += ColorBox("ooccolor")
			dat += "</div>" // End of DIV A A J A B
			dat += "</div>" // End of DIV A A J A
			dat += "</div>" // End of DIV A A J
			// Antag OOC Color
			// div += "<div class='PartsFlex'>" // DIV A A K
			// div += "<div class='SettingFlexCol'>" // DIV A A K A
			// div += "<div class='SettingNameCol'>" // DIV A A K A A
			// div += "Antag OOC Color"
			// div += "</div>" // End of DIV A A K A A
			// div += "<div class='SettingValueSplit'>" // DIV A A K A B
			// div += ColorBox("aooccolor")
			// div += "</div>" // End of DIV A A K A B
			// div += "</div>" // End of DIV A A K A
			// div += "</div>" // End of DIV A A K
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/GamePreferencesRunechat()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	// Show Runechat Chat Bubbles
	dat += "<div class='PartsFlex'>" // DIV A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A
	dat += "Show Runechat Chat Bubbles"
	dat += "</div>" // End of DIV A A A A A
	var/showtext1 = "Disabled"
	if(chat_on_map)
		showtext1 = "Enabled"
	dat += PrefLink(showtext1, PREFCMD_CHAT_ON_MAP)
	dat += "</div>" // End of DIV A A A A
	dat += "</div>" // End of DIV A A A
	// Runechat message char limit
	dat += "<div class='PartsFlex'>" // DIV A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A B A A
	dat += "Runechat message char limit"
	dat += "</div>" // End of DIV A A B A A
	dat += PrefLink("[max_chat_length]", PREFCMD_MAX_CHAT_LENGTH)
	dat += "</div>" // End of DIV A A B A
	dat += "</div>" // End of DIV A A B
	// Runechat message width
	dat += "<div class='PartsFlex'>" // DIV A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A C A A
	dat += "Runechat message width"
	dat += "</div>" // End of DIV A A C A A
	dat += PrefLink("[chat_width]", PREFCMD_CHAT_WIDTH)
	dat += "</div>" // End of DIV A A C A
	dat += "</div>" // End of DIV A A C
	// Runechat off-screen
	dat += "<div class='PartsFlex'>" // DIV A A D
	dat += "<div class='SettingFlexCol'>" // DIV A A D A
	dat += "<div class='SettingNameCol'>" // DIV A A D A A
	dat += "Runechat off-screen"
	dat += "</div>" // End of DIV A A D A A
	var/showtext2 = "Disabled"
	if(offscreen)
		showtext2 = "Enabled"
	dat += PrefLink(showtext2, PREFCMD_OFFSCREEN)
	dat += "</div>" // End of DIV A A D A
	dat += "</div>" // End of DIV A A D
	// See Runechat for non-mobs
	dat += "<div class='PartsFlex'>" // DIV A A E
	dat += "<div class='SettingFlexCol'>" // DIV A A E A
	dat += "<div class='SettingNameCol'>" // DIV A A E A A
	dat += "See Runechat for non-mobs"
	dat += "</div>" // End of DIV A A E A A
	var/showtext3 = "Disabled"
	if(see_chat_non_mob)
		showtext3 = "Enabled"
	dat += PrefLink(showtext3, PREFCMD_SEE_CHAT_NON_MOB)
	dat += "</div>" // End of DIV A A E A
	dat += "</div>" // End of DIV A A E
	// See Runechat emotes
	dat += "<div class='PartsFlex'>" // DIV A A F
	dat += "<div class='SettingFlexCol'>" // DIV A A F A
	dat += "<div class='SettingNameCol'>" // DIV A A F A A
	dat += "See Runechat emotes"
	dat += "</div>" // End of DIV A A F A A
	var/showtext4 = "Disabled"
	if(see_rc_emotes)
		showtext4 = "Enabled"
	dat += PrefLink(showtext4, PREFCMD_SEE_RC_EMOTES)
	dat += "</div>" // End of DIV A A F A
	dat += "</div>" // End of DIV A A F
	// Use Runechat color in chat log
	dat += "<div class='PartsFlex'>" // DIV A A G
	dat += "<div class='SettingFlexCol'>" // DIV A A G A
	dat += "<div class='SettingNameCol'>" // DIV A A G A A
	dat += "Use Runechat color in chat log"
	dat += "</div>" // End of DIV A A G A A
	var/showtext5 = "Disabled"
	if(color_chat_log)
		showtext5 = "Enabled"
	dat += PrefLink(showtext5, PREFCMD_COLOR_CHAT_LOG)
	dat += "</div>" // End of DIV A A G A
	dat += "</div>" // End of DIV A A G
	// See Runechat / hear sounds above/below you
	dat += "<div class='PartsFlex'>" // DIV A A H
	dat += "<div class='SettingFlexCol'>" // DIV A A H A
	dat += "<div class='SettingNameCol'>" // DIV A A H A A
	dat += "See Runechat / hear sounds above/below you"
	dat += "</div>" // End of DIV A A H A A
	dat += PrefLink("[upperlowerfloor]", PREFCMD_UPPERLOWERFLOOR)
	dat += "</div>" // End of DIV A A H A
	dat += "</div>" // End of DIV A A H
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/GamePreferencesGhost()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	// Ghost Ears
	dat += "<div class='PartsFlex'>" // DIV A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A
	dat += "Ghost Ears"
	dat += "</div>" // End of DIV A A A A A
	var/showtext1 = "Nearest Creatures"
	if(chat_toggles & CHAT_GHOSTEARS)
		showtext1 = "All Speech"
	dat += PrefLink(showtext1, PREFCMD_GHOST_EARS)
	dat += "</div>" // End of DIV A A A A
	dat += "</div>" // End of DIV A A A
	// Ghost Radio
	dat += "<div class='PartsFlex'>" // DIV A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A B A A
	dat += "Ghost Radio"
	dat += "</div>" // End of DIV A A B A A
	var/showtext2 = "No Messages"
	if(chat_toggles & CHAT_GHOSTRADIO)
		showtext2 = "All Messages"
	dat += PrefLink(showtext2, PREFCMD_GHOST_RADIO)
	dat += "</div>" // End of DIV A A B A
	dat += "</div>" // End of DIV A A B
	// Ghost Sight
	dat += "<div class='PartsFlex'>" // DIV A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A C A A
	dat += "Ghost Sight"
	dat += "</div>" // End of DIV A A C A A
	var/showtext3 = "Nearest Creatures"
	if(chat_toggles & CHAT_GHOSTSIGHT)
		showtext3 = "All Emotes"
	dat += PrefLink(showtext3, PREFCMD_GHOST_SIGHT)
	dat += "</div>" // End of DIV A A C A
	dat += "</div>" // End of DIV A A C
	// Ghost Whispers
	dat += "<div class='PartsFlex'>" // DIV A A D
	dat += "<div class='SettingFlexCol'>" // DIV A A D A
	dat += "<div class='SettingNameCol'>" // DIV A A D A A
	dat += "Ghost Whispers"
	dat += "</div>" // End of DIV A A D A A
	var/showtext4 = "Nearest Creatures"
	if(chat_toggles & CHAT_GHOSTWHISPER)
		showtext4 = "All Speech"
	dat += PrefLink(showtext4, PREFCMD_GHOST_WHISPERS)
	dat += "</div>" // End of DIV A A D A
	dat += "</div>" // End of DIV A A D
	// Ghost PDA
	dat += "<div class='PartsFlex'>" // DIV A A E
	dat += "<div class='SettingFlexCol'>" // DIV A A E A
	dat += "<div class='SettingNameCol'>" // DIV A A E A A
	dat += "Ghost PDA"
	dat += "</div>" // End of DIV A A E A A
	var/showtext5 = "Nearest Creatures"
	if(chat_toggles & CHAT_GHOSTPDA)
		showtext5 = "All Messages"
	dat += PrefLink(showtext5, PREFCMD_GHOST_PDA)
	dat += "</div>" // End of DIV A A E A
	dat += "</div>" // End of DIV A A E
	if(unlock_content || check_rights(R_ADMIN))
		// Ghost Form
		dat += "<div class='PartsFlex'>" // DIV A A F
		dat += "<div class='SettingFlexCol'>" // DIV A A F A
		dat += "<div class='SettingNameCol'>" // DIV A A F A A
		dat += "Ghost Form"
		dat += "</div>" // End of DIV A A F A A
		dat += PrefLink("[ghost_form]", PREFCMD_GHOST_FORM)
		dat += "</div>" // End of DIV A A F A
		dat += "</div>" // End of DIV A A F
		// Ghost Orbit
		dat += "<div class='PartsFlex'>" // DIV A A G
		dat += "<div class='SettingFlexCol'>" // DIV A A G A
		dat += "<div class='SettingNameCol'>" // DIV A A G A A
		dat += "Ghost Orbit"
		dat += "</div>" // End of DIV A A G A A
		dat += PrefLink("[ghost_orbit]", PREFCMD_GHOST_ORBIT)
		dat += "</div>" // End of DIV A A G A
		dat += "</div>" // End of DIV A A G
	var/showtext5 = "If you see this something went wrong."
	switch(ghost_accs)
		if(GHOST_ACCS_FULL)
			showtext5 = GHOST_ACCS_FULL_NAME
		if(GHOST_ACCS_DIR)
			showtext5 = GHOST_ACCS_DIR_NAME
		if(GHOST_ACCS_NONE)
			showtext5 = GHOST_ACCS_NONE_NAME
	// Ghost Accessories
	dat += "<div class='PartsFlex'>" // DIV A A H
	dat += "<div class='SettingFlexCol'>" // DIV A A H A
	dat += "<div class='SettingNameCol'>" // DIV A A H A A
	dat += "Ghost Accessories"
	dat += "</div>" // End of DIV A A H A A
	dat += PrefLink(showtext5, PREFCMD_GHOST_ACCS)
	dat += "</div>" // End of DIV A A H A
	dat += "</div>" // End of DIV A A H
	var/showtext6 = "If you see this something went wrong."
	switch(ghost_others)
		if(GHOST_OTHERS_THEIR_SETTING)
			showtext6 = GHOST_OTHERS_THEIR_SETTING_NAME
		if(GHOST_OTHERS_DEFAULT_SPRITE)
			showtext6 = GHOST_OTHERS_DEFAULT_SPRITE_NAME
		if(GHOST_OTHERS_SIMPLE)
			showtext6 = GHOST_OTHERS_SIMPLE_NAME
	// Ghosts of Others
	dat += "<div class='PartsFlex'>" // DIV A A I
	dat += "<div class='SettingFlexCol'>" // DIV A A I A
	dat += "<div class='SettingNameCol'>" // DIV A A I A A
	dat += "Ghosts of Others"
	dat += "</div>" // End of DIV A A I A A
	dat += PrefLink(showtext6, PREFCMD_GHOST_OTHERS)
	dat += "</div>" // End of DIV A A I A
	dat += "</div>" // End of DIV A A I
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/GamePreferencesAudio()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	// Play Hunting Horn Sounds
	dat += "<div class='PartsFlex'>" // DIV A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A
	dat += "Play Hunting Horn Sounds"
	dat += "</div>" // End of DIV A A A A A
	var/showtext1 = "Disabled"
	if(toggles & SOUND_HUNTINGHORN)
		showtext1 = "Enabled"
	dat += PrefLink(showtext1, PREFCMD_HUNTINGHORN)
	dat += "</div>" // End of DIV A A A A
	dat += "</div>" // End of DIV A A A
	// Sprint Depletion Sound
	dat += "<div class='PartsFlex'>" // DIV A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A B A A
	dat += "Sprint Depletion Sound"
	dat += "</div>" // End of DIV A A B A A
	var/showtext2 = "Disabled"
	if(toggles & SOUND_SPRINTBUFFER)
		showtext2 = "Enabled"
	dat += PrefLink(showtext2, PREFCMD_SPRINTBUFFER)
	dat += "</div>" // End of DIV A A B A
	dat += "</div>" // End of DIV A A B
	// Play Admin MIDIs
	dat += "<div class='PartsFlex'>" // DIV A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A C A A
	dat += "Play Admin MIDIs"
	dat += "</div>" // End of DIV A A C A A
	var/showtext3 = "Disabled"
	if(toggles & SOUND_MIDI)
		showtext3 = "Enabled"
	dat += PrefLink(showtext3, PREFCMD_MIDIS)
	dat += "</div>" // End of DIV A A C A
	dat += "</div>" // End of DIV A A
	// Play Lobby Music
	dat += "<div class='PartsFlex'>" // DIV A A D
	dat += "<div class='SettingFlexCol'>" // DIV A A D A
	dat += "<div class='SettingNameCol'>" // DIV A A D A A
	dat += "Play Lobby Music"
	dat += "</div>" // End of DIV A A D A A
	var/showtext4 = "Disabled"
	if(toggles & SOUND_LOBBY)
		showtext4 = "Enabled"
	dat += PrefLink(showtext4, PREFCMD_LOBBY_MUSIC)
	dat += "</div>" // End of DIV A A D A
	dat += "</div>" // End of DIV A A D
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/GamePreferencesAdmin()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	// Adminhelp Sounds
	dat += "<div class='PartsFlex'>" // DIV A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A
	dat += "Adminhelp Sounds"
	dat += "</div>" // End of DIV A A A A A
	var/showtext1 = "Disabled"
	if(toggles & SOUND_ADMINHELP)
		showtext1 = "Enabled"
	dat += PrefLink(showtext1, PREFCMD_ADMINHELP)
	dat += "</div>" // End of DIV A A A A
	dat += "</div>" // End of DIV A A A
	// Announce Login
	dat += "<div class='PartsFlex'>" // DIV A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A B A A
	dat += "Announce Login"
	dat += "</div>" // End of DIV A A B A A
	var/showtext2 = "Disabled"
	if(toggles & ANNOUNCE_LOGIN)
		showtext2 = "Enabled"
	dat += PrefLink(showtext2, PREFCMD_ANNOUNCE_LOGIN)
	dat += "</div>" // End of DIV A A B A
	dat += "</div>" // End of DIV A A B
	// Combo HUD Lighting
	dat += "<div class='PartsFlex'>" // DIV A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A C A A
	dat += "Combo HUD Lighting"
	dat += "</div>" // End of DIV A A C A A
	var/showtext3 = "No Change"
	if(toggles & COMBOHUD_LIGHTING)
		showtext3 = "Full-bright"
	dat += PrefLink(showtext3, PREFCMD_COMBOHUD_LIGHTING)
	dat += "</div>" // End of DIV A A C A
	dat += "</div>" // End of DIV A A C
	// Split Admin Tabs
	dat += "<div class='PartsFlex'>" // DIV A A D
	dat += "<div class='SettingFlexCol'>" // DIV A A D A
	dat += "<div class='SettingNameCol'>" // DIV A A D A A
	dat += "Split Admin Tabs"
	dat += "</div>" // End of DIV A A D A A
	var/showtext4 = "Disabled"
	if(toggles & SPLIT_ADMIN_TABS)
		showtext4 = "Enabled"
	dat += PrefLink(showtext4, PREFCMD_SPLIT_ADMIN_TABS)
	dat += "</div>" // End of DIV A A D A
	dat += "</div>" // End of DIV A A D
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/GamePreferencesContent()
	var/list/dat = list()
	dat += "<div class='SettingArray'>" // DIV A
	dat += "<div class='PartsContainer'>" // DIV A A
	// Arousal
	dat += "<div class='PartsFlex'>" // DIV A A A
	dat += "<div class='SettingFlexCol'>" // DIV A A A A
	dat += "<div class='SettingNameCol'>" // DIV A A A A A
	dat += "Arousal"
	dat += "</div>" // End of DIV A A A A A
	var/showtext1 = "Disabled"
	if(arousable)
		showtext1 = "Enabled"
	dat += PrefLink(showtext1, PREFCMD_AROUSABLE)
	dat += "</div>" // End of DIV A A A A
	dat += "</div>" // End of DIV A A A
	// Genital examine text
	dat += "<div class='PartsFlex'>" // DIV A A B
	dat += "<div class='SettingFlexCol'>" // DIV A A B A
	dat += "<div class='SettingNameCol'>" // DIV A A B A A
	dat += "Genital examine text"
	dat += "</div>" // End of DIV A A B A A
	var/showtext2 = "Disabled"
	if(cit_toggles & GENITAL_EXAMINE)
		showtext2 = "Enabled"
	dat += PrefLink(showtext2, PREFCMD_GENITAL_EXAMINE)
	dat += "</div>" // End of DIV A A B A
	dat += "</div>" // End of DIV A A B
	// Butt Slapping
	dat += "<div class='PartsFlex'>" // DIV A A C
	dat += "<div class='SettingFlexCol'>" // DIV A A C A
	dat += "<div class='SettingNameCol'>" // DIV A A C A A
	dat += "Butt Slapping"
	dat += "</div>" // End of DIV A A C A A
	var/showtext3 = "Allowed"
	if(cit_toggles & NO_butt_SLAP)
		showtext3 = "Disallowed"
	dat += PrefLink(showtext3, PREFCMD_BUTT_SLAP)
	dat += "</div>" // End of DIV A A C A
	dat += "</div>" // End of DIV A A
	// Auto Wag
	dat += "<div class='PartsFlex'>" // DIV A A D
	dat += "<div class='SettingFlexCol'>" // DIV A A D A
	dat += "<div class='SettingNameCol'>" // DIV A A D A A
	dat += "Auto Wag"
	dat += "</div>" // End of DIV A A D A A
	var/showtext4 = "Disabled"
	if(cit_toggles & AUTO_WAG)
		showtext4 = "Enabled"
	dat += PrefLink(showtext4, PREFCMD_AUTO_WAG)
	dat += "</div>" // End of DIV A A D A
	dat += "</div>" // End of DIV A A
	// Master Vore Toggle
	dat += "<div class='PartsFlex'>" // DIV A A E
	dat += "<div class='SettingFlexCol'>" // DIV A A E A
	dat += "<div class='SettingNameCol'>" // DIV A A E A A
	dat += "Master Vore Toggle"
	dat += "</div>" // End of DIV A A E A A
	var/showtext5 = "All Disabled"
	if(master_vore_toggle)
		showtext5 = "Per Preferences"
	dat += PrefLink(showtext5, PREFCMD_MASTER_VORE_TOGGLE)
	dat += "</div>" // End of DIV A A E A
	dat += "</div>" // End of DIV A A E
	// Being Prey
	dat += "<div class='PartsFlex'>" // DIV A A F
	dat += "<div class='SettingFlexCol'>" // DIV A A F A
	dat += "<div class='SettingNameCol'>" // DIV A A F A A
	dat += "Being Prey"
	dat += "</div>" // End of DIV A A F A A
	var/showtext6 = "Disallowed"
	if(allow_being_prey)
		showtext6 = "Allowed"
	dat += PrefLink(showtext6, PREFCMD_ALLOW_BEING_PREY)
	dat += "</div>" // End of DIV A A F A
	dat += "</div>" // End of DIV A A F
	// Being Fed Prey
	dat += "<div class='PartsFlex'>" // DIV A A G
	dat += "<div class='SettingFlexCol'>" // DIV A A G A
	dat += "<div class='SettingNameCol'>" // DIV A A G A A
	dat += "Being Fed Prey"
	dat += "</div>" // End of DIV A A G A A
	var/showtext7 = "Disallowed"
	if(allow_being_fed_prey)
		showtext7 = "Allowed"
	dat += PrefLink(showtext7, PREFCMD_ALLOW_BEING_FED_PREY)
	dat += "</div>" // End of DIV A A G A
	dat += "</div>" // End of DIV A A G
	// Digestion Damage
	dat += "<div class='PartsFlex'>" // DIV A A H
	dat += "<div class='SettingFlexCol'>" // DIV A A H A
	dat += "<div class='SettingNameCol'>" // DIV A A H A A
	dat += "Digestion Damage"
	dat += "</div>" // End of DIV A A H A A
	var/showtext8 = "Disallowed"
	if(allow_digestion_damage)
		showtext8 = "Allowed"
	dat += PrefLink(showtext8, PREFCMD_ALLOW_DIGESTION_DAMAGE)
	dat += "</div>" // End of DIV A A H A
	dat += "</div>" // End of DIV A A H
	// Digestion Death
	dat += "<div class='PartsFlex'>" // DIV A A I
	dat += "<div class='SettingFlexCol'>" // DIV A A I A
	dat += "<div class='SettingNameCol'>" // DIV A A I A A
	dat += "Digestion Death"
	dat += "</div>" // End of DIV A A I A A
	var/showtext9 = "Disallowed"
	if(allow_digestion_death)
		showtext9 = "Allowed"
	dat += PrefLink(showtext9, PREFCMD_ALLOW_DIGESTION_DEATH)
	dat += "</div>" // End of DIV A A I A
	dat += "</div>" // End of DIV A A I
	// Vore Messages
	dat += "<div class='PartsFlex'>" // DIV A A J
	dat += "<div class='SettingFlexCol'>" // DIV A A J A
	dat += "<div class='SettingNameCol'>" // DIV A A J A A
	dat += "Vore Messages"
	dat += "</div>" // End of DIV A A J A A
	var/showtext10 = "Hidden"
	if(allow_vore_messages)
		showtext10 = "Visible"
	dat += PrefLink(showtext10, PREFCMD_ALLOW_VORE_MESSAGES)
	dat += "</div>" // End of DIV A A J A
	dat += "</div>" // End of DIV A A J
	// Vore Trash Messages
	dat += "<div class='PartsFlex'>" // DIV A A K
	dat += "<div class='SettingFlexCol'>" // DIV A A K A
	dat += "<div class='SettingNameCol'>" // DIV A A K A A
	dat += "Vore Trash Messages"
	dat += "</div>" // End of DIV A A K A A
	var/showtext11 = "Hidden"
	if(allow_trash_messages)
		showtext11 = "Visible"
	dat += PrefLink(showtext11, PREFCMD_ALLOW_TRASH_MESSAGES)
	dat += "</div>" // End of DIV A A K A
	dat += "</div>" // End of DIV A A K
	// Vore Death Messages
	dat += "<div class='PartsFlex'>" // DIV A A L
	dat += "<div class='SettingFlexCol'>" // DIV A A L A
	dat += "<div class='SettingNameCol'>" // DIV A A L A A
	dat += "Vore Death Messages"
	dat += "</div>" // End of DIV A A L A A
	var/showtext12 = "Hidden"
	if(allow_death_messages)
		showtext12 = "Visible"
	dat += PrefLink(showtext12, PREFCMD_ALLOW_DEATH_MESSAGES)
	dat += "</div>" // End of DIV A A L A
	dat += "</div>" // End of DIV A A L
	// Vore Eating Sounds
	dat += "<div class='PartsFlex'>" // DIV A A M
	dat += "<div class='SettingFlexCol'>" // DIV A A M A
	dat += "<div class='SettingNameCol'>" // DIV A A M A A
	dat += "Vore Eating Sounds"
	dat += "</div>" // End of DIV A A M A A
	var/showtext13 = "Muted"
	if(allow_eating_sounds)
		showtext13 = "Audible"
	dat += PrefLink(showtext13, PREFCMD_ALLOW_EATING_SOUNDS)
	dat += "</div>" // End of DIV A A M A
	dat += "</div>" // End of DIV A A M
	// Digestion Sounds
	dat += "<div class='PartsFlex'>" // DIV A A N
	dat += "<div class='SettingFlexCol'>" // DIV A A N A
	dat += "<div class='SettingNameCol'>" // DIV A A N A A
	dat += "Digestion Sounds"
	dat += "</div>" // End of DIV A A N A A
	var/showtext14 = "Muted"
	if(allow_digestion_sounds)
		showtext14 = "Audible"
	dat += PrefLink(showtext14, PREFCMD_ALLOW_DIGESTION_SOUNDS)
	dat += "</div>" // End of DIV A A N A
	dat += "</div>" // End of DIV A A N
	dat += "</div>" // End of DIV A A
	dat += "</div>" // End of DIV A
	return dat.Join()





/* 

 */

/* 




 */






/datum/preferences/proc/GetGearFlatList(search, list/mystuff, mine)
	var/list/flatlyss = list()
	for(var/category in GLOB.loadout_categories)
		for(var/subcategory in GLOB.loadout_categories[category])
			for(var/name in GLOB.loadout_items[category][subcategory])
				var/gear = GLOB.loadout_items[category][subcategory][name]
				if(gear)
					if(mine)
						if(!onlymine["[gear.type]"])
							continue
					if(search)
						if(!findtext(name, search))
							continue
					flatlyss += gear
	return flatlyss

/datum/preferences/proc/GearColorBox(gear, edited_color)
	var/list/datae = list(
		PREFDAT_COLKEY_IS_COLOR = TRUE,
		PREFDAT_IS_GEAR = TRUE,
		PREFDAT_GEAR_PATH = "[gear.type]",
		PREFDAT_LOADOUT_SLOT = loadout_slot
	)
	return ColorBox(edited_color, data = datae)

/datum/preferences/proc/RowifyQuirks()
	if(!LAZYLEN(char_quirks))
		return QuirkEntry("None!", "NEUTRAL")
	var/list/goodquirks = list()
	var/list/neutquirks = list()
	var/list/badquirks = list()
	for(var/quirk in char_quirks)
		var/datum/quirk/Q = SSquirks.GetQuirk(quirk)
		switch(Q.value)
			if(-INFINITY to -1)
				badquirks += Q
			if(1 to INFINITY)
				goodquirks += Q
			else
				neutquirks += Q
	var/list/dat = list()
	for(var/datum/quirk/Q in goodquirks)
		dat += QuirkEntry(Q.name, "GOOD")
	for(var/datum/quirk/Q in neutquirks)
		dat += QuirkEntry(Q.name, "NEUTRAL")
	for(var/datum/quirk/Q in badquirks)
		dat += QuirkEntry(Q.name, "BAD")
	return dat.Join()

/datum/preferences/proc/QuirkEntry(q_name, quality)
	var/list/dat = list()
	dat += "<div class='SettingValueRowable'>" // DIV A
	var/q_span = ""
	switch(quality)
		if("GOOD")
			q_span = "QuirkGood"
		if("BAD")
			q_span = "QuirkBad"
		else
			q_span = "QuirkNeutral"
	dat += "<span class='[q_span]'>[q_name]</span>"
	dat += "</div>" // End of DIV A
	return dat.Join()

/// Builds a cool toolbar for colorstuff
/// has two parts: a top and a bottom
/// the top has the Big Three mutant colors (and the undies button)
/// the bottom has a history of colors (up to, oh, 5?)
/datum/preferences/proc/ColorToolbar()
	var/list/dat = list()
	dat += "<div class='SettingFlexCol'>" // DIV A
	dat += "<div class='SettingValueSplit'>" // DIV A A
	var/list/data = list(PREFDAT_COLKEY_IS_FEATURE = TRUE)
	dat += ColorBox("mcolor" data = data)
	dat += ColorBox("mcolor2" data = data)
	dat += ColorBox("mcolor3" data = data)
	dat += "<span class='Spacer'></span>"
	dat += "<div class='SettingFlex' style='white-space: nowrap;'>" // DIV A A A
	var/chundies = preview_hide_undies ? "Hiding Undies" : "Showing Undies"
	dat += PrefLink("[chundies]", "showing_undies", kind = "BUTTON")
	dat += "</div>" // End of DIV A A A
	dat += "</div>" // End of DIV A A
	/// History of colors
	dat += "<div class='SettingValueSplit'>" // DIV A B
	CleanupColorHistory()
	for(var/color in color_history)
		dat += ColorBox(color, TRUE)
	dat += "</div>" // End of DIV A B
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/ColorBox(colkey, history = FALSE, list/data = list())
	var/list/dat = list()
	data[PREFDAT_COLOR] = colkey
	dat += "<div class='ColorContainer'>" // DIV A
	var/col = "FFFFFF"
	if(history)
		col = colkey
		dat += "<div class='ColorBoxxo CrunchBox' style='background-color: #[col];'>"
		dat += "[colkey]"
		dat += "</div>" // End of DIV A A
	else
		if(data[PREFDAT_COLKEY_IS_COLOR])
			col = colkey
		else
			col = GetColor(colkey)
		dat += PrefLink("[col]", PREFCMD_CHANGECOLOR, data, span = "ColorBoxxo", style = "background-color: #[col];")
	var/cbut = "<i class='fa fa-copy'></i>"
	dat += PrefLink("[cbut]", PREFCMD_COPYCOLOR, data, span = "SmolButton")
	var/pbut = "<i class='fa fa-paste'></i>"
	dat += PrefLink("[pbut]", PREFCMD_PASTECOLOR, data, span = "SmolButton")
	if(history)
		dat += PrefLink("X", PREFCMD_DELCOLOR, data, span = "SmolButton")
	dat += "</div>" // End of DIV A
	return dat.Join()

/datum/preferences/proc/CleanupColorHistory()
	if(!LAZYLEN(color_history))
		return
	color_history.len = min(5, color_history.len)

/datum/preferences/proc/CopyColor(col_hex)
	if(!is_color(col_hex))
		return
	color_history -= col_hex
	color_history.Insert(1, col_hex)
	current_color = col_hex
	CleanupColorHistory()

/datum/preferences/proc/PasteColor(colkey)
	if(!is_color(current_color))
		return
	SetColor(colkey, current_color)

/datum/preferences/proc/RemoveColor(col_hex)
	color_history -= col_hex
	CleanupColorHistory()

/datum/preferences/proc/SetColor(colkey, set_to)
	GetColor(colkey, set_to) // COOL PROC DAN

/datum/preferences/proc/GetColor(colkey, set_to)
	if(is_color(GLOB.features_that_are_colors[colkey]))
		if(istext(set_to))
			features[colkey] = "[set_to]"
		return features[colkey]
	/// because we have some colors in the features and SOME colors as hardvars
	/// we need to suck this dikc
	var/maybecolor = vars["[colkey]"]
	if(is_color(maybecolor))
		if(istext(set_to))
			vars["[colkey]"] = "[set_to]"
		return maybecolor
	stack_trace("GetColor: Couldn't find color for [colkey]!")
	return "FFFFFF"

// pda_color
// undie_color
// shirt_color
// socks_color
// hair_color
// facial_hair_color
// left_eye_color
// right_eye_color
// personal_chat_color
// hud_toggle_color

/datum/preferences/proc/MarkingColorBox(list/marking = list(), col_index)
	var/truecolor = marking[MARKING_COLOR_LIST][col_index]
	var/marking_uid = marking[MARKING_UID]
	var/marking_slot = col_index
	var/list/data = list(
		PREFDAT_COLKEY_IS_COLOR = TRUE,
		PREFDAT_IS_MARKING = TRUE,
		PREFDAT_MARKING_UID = marking_uid,
		PREFDAT_MARKING_SLOT = marking_slot
	)
	return ColorBox(truecolor, data = data)

/datum/preferences/proc/MarkingPrefLink(text, cmd, marking_uid, span)
	var/command = PREFCMD_MARKING_EDIT
	var/list/data = list(PREFDAT_MARKING_UID = marking_uid)
	data[PREFDAT_MARKING_ACTION] = cmd
	return PrefLink(text, command, data, span = span)

/datum/preferences/proc/CoolDivider()
	return "<div class='WideDivider'></div>"


/* 

 */


// Author: GremlingSS
// Not all of my work, it's porting over vorestation's gradient system into TG and adapting it basically.
// This is gonna be fun, wish me luck!~
//
// Also, as obligated to my coding standards, I must design a shitpost related to the code, but because it's hard to think of a meme
// I'm gonna just pull one out my ass and hope it's funny.


/* // Disabled random features from providing random gradients, simply to avoid reloading save file errors.
random_features(intendedspecies, intended_gender)
	. = ..(intendedspecies, intended_gender)
	
	var/grad_color = random_color()

	var/list/output = .

	output += list(
		"grad_color"			= grad_color,
		"grad_style"			= pick(GLOB.hair_gradients))

	return output


randomize_human(mob/living/carbon/human/H)
//	H.dna.features["flavor_text"] = "" // I'm so tempted to put lorem ipsum in the flavor text so freaking badly please someone hold me back god.
	H.dna.features["grad_color"] = random_color()
	H.dna.features["grad_style"] = pick(GLOB.hair_gradients)
	..(H)
*/

/mob/living/carbon/human/proc/change_hair_gradient(hair_gradient)
	if(dna.features["grad_style"] == hair_gradient)
		return

	if(!(hair_gradient in GLOB.hair_gradients))
		return

	dna.features["grad_style"] = hair_gradient

	update_hair()
	return 1



/datum/preferences/process_link(mob/user, list/href_list)
	switch(href_list["task"])
		if("input")
			switch(href_list["preference"])
				if("grad_color")
					var/new_grad_color = input(user, "Choose your character's fading hair colour:", "Character Preference","#"+features["grad_color"]) as color|null
					if(new_grad_color)
						features["grad_color"] = sanitize_hexcolor(new_grad_color, 6, default = COLOR_ALMOST_BLACK)

				if("grad_style")
					var/new_grad_style
					new_grad_style = input(user, "Choose your character's hair fade style:", "Character Preference")  as null|anything in GLOB.hair_gradients
					if(new_grad_style)
						features["grad_style"] = new_grad_style
				
				if("grad_color_2")
					var/new_grad_color = input(user, "Choose your character's fading hair colour:", "Character Preference","#"+features["grad_color_2"]) as color|null
					if(new_grad_color)
						features["grad_color_2"] = sanitize_hexcolor(new_grad_color, 6, default = COLOR_ALMOST_BLACK)

				if("grad_style_2")
					var/new_grad_style
					new_grad_style = input(user, "Choose your character's hair fade style:", "Character Preference")  as null|anything in GLOB.hair_gradients
					if(new_grad_style)
						features["grad_style_2"] = new_grad_style
				
				if("hair_color_2")
					var/new_color = input(user, "Choose your character's fading hair colour:", "Character Preference","#"+features["hair_color_2"]) as color|null
					if(new_color)
						features["hair_color_2"] = sanitize_hexcolor(new_color, 6, default = COLOR_ALMOST_BLACK)

				if("hair_style_2")
					var/new_style
					new_style = input(user, "Choose your character's hair fade style:", "Character Preference")  as null|anything in GLOB.hair_styles_list
					if(new_style)
						features["hair_style_2"] = new_style
				
				if("previous_hair_style_2")
					features["hair_style_2"] = previous_list_item(features["hair_style_2"], GLOB.hair_styles_list)
				
				if("next_hair_style_2")
					features["hair_style_2"] = next_list_item(features["hair_style_2"], GLOB.hair_styles_list)
	..()


