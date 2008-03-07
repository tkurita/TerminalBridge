global ExecuterController
global EditorClient
global TerminalCommander
--global StringEngine
global XText
global UtilityHandlers
global XDict
global XList

(*== execute tex commands called from tools from mi  *)
(*=== interactive process *)
on getLastResult()
	--log "start getLastResult in UnixScriptController"
	set an_executer to getExecuter of ExecuterController for missing value with interactive without allowBusyStatus
	
	try
		set a_result to getLastResult() of an_executer
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
		set selectionRec to getSelectionRecord() of EditorClient
		if (cursorInParagraph of selectionRec is not 0) then
			set a_result to first paragraph of a_result
		end if
	end if
	insert_text(a_result) of EditorClient
	--log "end getLastResult in UnixScriptController"
end getLastResult

on showInteractiveTerminal()
	--log "start showInteractiveTerminal"
	set an_executer to getExecuter of ExecuterController for missing value with interactive and allowBusyStatus
	(*if an_executer is missing value then
		display alert "UnixScriptServer: the Executer is not found"
		consoleLog("UnixScriptServer: the Executer is not found") of UtilityHandlers
		-- このブロックはいらないかもしれない。an_executer は いつ missing value　になる？
		if resolve_terminal of TerminalCommander with allowBusyStatus then
			set a_result to bring_to_front() of TerminalCommander
		else
			set a_result to false
		end if
	else*)
	set a_result to bring_to_front of an_executer with allowBusyStatus
	if not a_result then
		set a_result to openNewTerminal() of an_executer
		if a_result then
			set a_result to bring_to_front of an_executer with allowBusyStatus
		else
			show_message("can't open new terminal") of EditorClient -- this message should not be shown.
		end if
	end if
	
	if not a_result then
		set theMessage to localized string "cantFindTerminal"
		show_message(theMessage) of EditorClient
	end if
end showInteractiveTerminal

on send_command(a_command)
	--log "start sendCommand in UnixScriptController"
	try
		set theScriptExecuter to getExecuter of ExecuterController for missing value with interactive without allowBusyStatus
	on error errMsg number errnum
		if errnum is not in {1600, 1610, 1620, 1660} then
			error errMsg number errnum
		end if
		return
	end try
	
	if theScriptExecuter is missing value then
		return
	end if
	if a_command is not "" then
		send_command of theScriptExecuter for a_command with allowBusyStatus
	end if
end send_command

on is_end_with_strings(a_string, string_list)
	set a_result to false
	if a_string's ends_with(return) then
		set a_string to a_string's text_in_range(1, -2)
	end if
	repeat with end_text in string_list
		if a_string's ends_with(end_text) then
			set a_result to true
			exit repeat
		end if
	end repeat
	return a_result
end is_end_with_strings

on sendSelection(arg)
	--log "start sendSelection"
	try
		set theScriptExecuter to getExecuter of ExecuterController for missing value with interactive without allowBusyStatus
	on error errMsg number errnum
		if errnum is not in {1600, 1610, 1620, 1660} then
			error errMsg number errnum
		end if
		return
	end try
	
	if theScriptExecuter is missing value then
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
				set next_line to paragraph_at_index(next_index) of EditorClient
				set command_list to {x_command's as_unicode(), next_line}
				repeat while (is_end_with_strings(XText's make_with(next_line), line_end_escapes))
					set next_index to next_index + 1
					set next_line to paragraph_at_index(next_index) of EditorClient
					set end of command_list to next_line
				end repeat
				set x_command to XList's make_with(command_list)'s as_xtext_with("")'s replace(tab, " ")
			end if
		end if
		
	else
		set x_command to x_command's replace(tab, " ")
	end if
	
	if length of x_command > 0 then
		send_command of theScriptExecuter for (x_command's as_unicode()) with allowBusyStatus
	end if
end sendSelection

(*= non-interactive commands *)
on getCommonTerminal(optionRecord)
	try
		set theScriptExecuter to getExecuter of ExecuterController for optionRecord without interactive and allowBusyStatus
	on error errMsg number errnum
		if errnum is not in {1600, 1610, 1620} then
			error errMsg number errnum
		end if
		return missing value
	end try
	theScriptExecuter's set_run_options(optionRecord)
	return theScriptExecuter
end getCommonTerminal

(*===  simply run in Terminal *)
on RunInTerminal(optionRecord)
	set an_executer to getCommonTerminal(optionRecord)
	if an_executer is missing value then return
	
	runScript of an_executer with activation
end RunInTerminal

(*=== run with Finder's selection *)
on getFinderSelection()
	tell application "Finder"
		set a_list to selection
	end tell
	if length of a_list is 0 then
		return missing value
	end if
	
	set itemText to (quoted form of POSIX path of (item 1 of a_list as alias))
	repeat with theItem in (rest of a_list)
		set itemText to itemText & space & (quoted form of POSIX path of (theItem as alias))
	end repeat
	return itemText
end getFinderSelection

on runWithFinderSelection(optionRecord)
	--log "start runWithFinderSelection"
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
	
	set an_executer to getCommonTerminal(optionRecord)
	if an_executer is missing value then return
	
	runScript of an_executer with activation
end runWithFinderSelection

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
	else
		try
			set target_term to my _namedTerms's value_for_key(a_name)
		on error number 900
			copy TerminalCommander to target_term
			TerminalCommander's forget()
			target_term's forget()
			target_term's set_custom_title("* " & a_name & " *")
			my _namedTerms's set_value(a_name, target_term)
		end try
	end if
	
	return target_term
end get_named_term

on send_in_named_term(opt_rec)
	set target_term to get_named_term(termTitle of opt_rec)
	set a_command to XText's make_with(command of opt_rec)'s strip()
	set a_command to UtilityHandler's clean_yenmark(a_command)
	do_command of target_term for (a_command's as_unicode()) with activation
end send_in_named_term