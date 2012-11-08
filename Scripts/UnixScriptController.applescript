global ExecuterController
global EditorClient
global TerminalCommander
global XText
global UtilityHandlers
global XDict
global XList

property _ignoring_errors : {1600, 1610, 1620, 1660, 1670}
(*== execute tex commands called from tools from mi  *)
(*=== interactive process *)
on last_result()
	--log "start getLastResult in UnixScriptController"
	set an_executer to get_executer of ExecuterController for missing value with interactive without allowing_busy
	
	try
		set a_result to an_executer's last_result()
	on error msg number 1640
		set a_msg to localized string "cantFindTerminal"
		show_message(a_msg) of EditorClient
		return
	end try
	
	if a_result is missing value then
		set a_msg to localized string "noLastResult"
		show_message(a_msg) of EditorClient
		return
	end if
	
	if ((count paragraph of a_result) is 2) and (paragraph 2 of a_result is "") then
		set selectionRec to EditorClient's selection_info()
		if (cursorInParagraph of selectionRec is not 0) then
			set a_result to first paragraph of a_result
		end if
	end if
	insert_text(a_result) of EditorClient
	--log "end getLastResult in UnixScriptController"
end last_result

on show_interactive_terminal()
	--log "start show_interactive_terminal"
	try
		set an_executer to get_executer of ExecuterController for missing value with interactive and allowing_busy
	on error msg number errno
		if errno is not in my _ignoring_errors then
			error msg number errno
		end if
		return false
	end try
	set a_result to bring_to_front of an_executer with allowing_busy
	if not a_result then
		set a_result to open_new_terminal() of an_executer
		if a_result then
			set a_result to bring_to_front of an_executer with allowing_busy
		else
			show_message("can't open new terminal") of EditorClient -- this message should not be shown.
		end if
	end if
	if not a_result then
		set msg to localized string "cantFindTerminal"
		show_message(msg) of EditorClient
	end if
end show_interactive_terminal

on send_command(a_command)
	--log "start send_command in UnixScriptController"
	try
		set an_executer to get_executer of ExecuterController for missing value with interactive without allowing_busy
	on error errmsg number errnum
		if errnum is not in my _ignoring_errors then
			error errmsg number errnum
		end if
		return
	end try
	if an_executer is missing value then
		return
	end if
	if a_command is not "" then
		send_command of an_executer for a_command with allowing_busy
	end if
	--log "end send_command in UnixScriptController"
end send_command

on is_end_with_strings(a_string, string_list)
	set a_result to false
	set lineend to ""
	if a_string's ends_with(return) then
		set lineend to return
	end if
	repeat with end_text in string_list
		if a_string's ends_with(end_text & lineend) then
			set a_result to true
			exit repeat
		end if
	end repeat
	return a_result
end is_end_with_strings

on send_selection(arg)
	--log "start send_selection"
	try
		set an_executer to get_executer of ExecuterController for missing value with interactive without allowing_busy
	on error errmsg number errnum
		if errnum is not in my _ignoring_errors then
			error errmsg number errnum
		end if
		return
	end try
	
	if an_executer is missing value then
		return
	end if
	
	set x_command to XText's make_with(selection_contents() of EditorClient)
	if length of x_command is 0 then
		set a_command to current_paragraph() of EditorClient
		if a_command is return then return
		
		if arg is missing value then
			set line_end_escapes to missing value
		else
			try
				set line_end_escapes to lineEndEscape of arg
			on error
				set line_end_escapes to missing value
			end try
		end if
		set x_command to XText's make_with(a_command)
		if line_end_escapes is not missing value then
			if is_end_with_strings(x_command, line_end_escapes) then
				set current_index to index_current_paragraph() of EditorClient
				set next_index to current_index + 1
				set next_line to paragraph_at(next_index) of EditorClient
				set command_list to {x_command's as_unicode(), next_line}
				repeat while (is_end_with_strings(XText's make_with(next_line), line_end_escapes))
					set next_index to next_index + 1
					set next_line to paragraph_at(next_index) of EditorClient
					set end of command_list to next_line
				end repeat
				set x_command to XList's make_with(command_list)'s as_xtext_with("")'s replace(tab, " ")
			end if
		end if
		
	else
		set x_command to x_command's replace(tab, " ")
	end if
	if length of x_command > 0 then
		send_command of an_executer for (x_command's as_unicode()) with allowing_busy
	end if
end send_selection

(*= non-interactive commands *)
on common_terminal(optionRecord)
	--log "start common_terminal"
	try
		set an_executer to get_executer of ExecuterController for optionRecord without interactive and allowing_busy
	on error errmsg number errnum
		if errnum is not in {1600, 1610, 1620, 1670} then
			error errmsg number errnum
		end if
		return missing value
	end try
	an_executer's set_run_options(optionRecord)
	return an_executer
end common_terminal

(*===  simply run in Terminal
Abailable labels for optionRecord
- command
- commandOption
- postOption
- preOption
- commandArg
*)
on run_in_terminal(optionRecord)
	--log "start run_in_terminal"
	set an_executer to common_terminal(optionRecord)
	if an_executer is missing value then return
	
	run_script of an_executer with activation
end run_in_terminal

(*=== run with Finder's selection *)
on getFinderSelection()
	tell application "Finder"
		set a_list to selection
	end tell
	if length of a_list is 0 then
		return missing value
	end if
	
	set itemText to (quoted form of POSIX path of (item 1 of a_list as alias))
	repeat with an_item in (rest of a_list)
		set itemText to itemText & space & (quoted form of POSIX path of (an_item as alias))
	end repeat
	return itemText
end getFinderSelection

on run_with_finder_selection(optionRecord)
	--log "start run_with_finder_selection"
	set a_selection to getFinderSelection()
	if a_selection is missing value then
		show_message("No Selection in Finder") of EditorClient
		return
	end if
	if optionRecord is missing value then
		set optionRecord to {commandArg:a_selection}
	else
		set optionRecord to optionRecord & {commandArg:a_selection}
	end if
	
	set an_executer to common_terminal(optionRecord)
	if an_executer is missing value then return
	
	run_script of an_executer with activation
end run_with_finder_selection

(*=== send command without CommandBuilder *)
on send_to_common_term(optionRecord)
	--log "start send_to_common_term"
	set a_command to XText's make_with(command of optionRecord)'s strip()
	set a_command to UtilityHandlers's clean_yenmark(a_command)
	do_command of TerminalCommander for (a_command's as_unicode()) with activation
	--log "end send_to_common_term"
	beep
end send_to_common_term

property _namedTerms : missing value

on get_named_term(a_name)
	set target_term to missing value
	if my _namedTerms is missing value then
		set my _namedTerms to make XDict
	end if
	try
		set target_term to my _namedTerms's value_for_key(a_name)
	on error number 900
		set target_term to TerminalCommander's make_with_title("* " & a_name & " *")
		target_term's forget()
		my _namedTerms's set_value(a_name, target_term)
	end try
	
	return target_term
end get_named_term

on send_in_named_term(opt_rec)
	set target_term to get_named_term(termTitle of opt_rec)
	set a_command to XText's make_with(command of opt_rec)'s strip()
	set a_command to UtilityHandlers's clean_yenmark(a_command)
	do_command of target_term for (a_command's as_unicode()) with activation
end send_in_named_term