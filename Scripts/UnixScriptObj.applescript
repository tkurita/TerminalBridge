global ExecuterController
global EditorClient
global TerminalCommander
global StringEngine
global UtilityHandlers
global XDict

(*== execute tex commands called from tools from mi  *)
(*=== interactive process *)
on getLastResult()
	--log "start getLastResult in UnixScriptObj"
	set theExecuter to getExecuter of ExecuterController with interactive without allowBusyStatus
	
	try
		set theResult to getLastResult() of theExecuter
	on error errMsg number 1640
		set theMessage to localized string "cantFindTerminal"
		showMessage(theMessage) of EditorClient
		return
	end try
	
	if theResult is missing value then
		set theMessage to localized string "noLastResult"
		showMessage(theMessage) of EditorClient
		return
	end if
	
	if ((count paragraph of theResult) is 2) and (paragraph 2 of theResult is "") then
		set selectionRec to getSelectionRecord() of EditorClient
		if (cursorInParagraph of selectionRec is not 0) then
			set theResult to first paragraph of theResult
		end if
	end if
	insert_text(theResult) of EditorClient
	--log "end getLastResult in UnixScriptObj"
end getLastResult

on showInteractiveTerminal()
	--log "start showInteractiveTerminal"
	set theExecuter to getExecuter of ExecuterController with interactive and allowBusyStatus
	(*if theExecuter is missing value then
		display alert "UnixScriptServer: the Executer is not found"
		consoleLog("UnixScriptServer: the Executer is not found") of UtilityHandlers
		-- このブロックはいらないかもしれない。theExecuter は いつ missing value　になる？
		if getTargetTerminal of TerminalCommander with allowBusyStatus then
			set theResult to bringToFront() of TerminalCommander
		else
			set theResult to false
		end if
	else*)
	set theResult to bring_to_front of theExecuter with allowBusyStatus
	if not theResult then
		set theResult to openNewTerminal() of theExecuter
		if theResult then
			set theResult to bring_to_front of theExecuter with allowBusyStatus
		else
			showMessage("can't open new terminal") of EditorClient -- this message should not be shown.
		end if
	end if
	
	if not theResult then
		set theMessage to localized string "cantFindTerminal"
		showMessage(theMessage) of EditorClient
	end if
end showInteractiveTerminal

on sendCommand(theCommand)
	--log "start sendCommand in UnixScriptObj"
	try
		set theScriptExecuter to getExecuter of ExecuterController with interactive without allowBusyStatus
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
		end if
		return
	end try
	
	if theScriptExecuter is missing value then
		return
	end if
	if theCommand is not "" then
		sendCommand of theScriptExecuter for theCommand with allowBusyStatus
	end if
end sendCommand

on isEndWithStrings(theString, stringList)
	set theResult to false
	if theString ends with return then
		set theString to text 1 thru -2 of theString
	end if
	repeat with a_string in stringList
		if theString ends with a_string then
			set theResult to true
			exit repeat
		end if
	end repeat
	return theResult
end isEndWithStrings

on sendSelection(arg)
	--log "start sendSelection"
	try
		set theScriptExecuter to getExecuter of ExecuterController with interactive without allowBusyStatus
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
		end if
		return
	end try
	
	if theScriptExecuter is missing value then
		return
	end if
	
	set theCommand to get_selection() of EditorClient
	if theCommand is "" then
		set theCommand to current_paragraph() of EditorClient
		if theCommand is return then return
		
		if arg is missing value then
			set line_end_escapes to missing value
		else
			try
				set line_end_escapes to lineEndEscape of arg
			on error
				set line_end_escapes to missing value
			end try
		end if
		
		if line_end_escapes is not missing value then
			if isEndWithStrings(theCommand, line_end_escapes) then
				set current_index to index_current_paragraph() of EditorClient
				set next_index to current_index + 1
				set next_line to paragraph_at_index(next_index) of EditorClient
				set command_list to {theCommand, next_line}
				repeat while (isEndWithStrings(next_line, line_end_escapes))
					set next_index to next_index + 1
					set next_line to paragraph_at_index(next_index) of EditorClient
					set end of command_list to next_line
				end repeat
				tell StringEngine
					store_delimiters() of it
					set theCommand to join of it for command_list by ""
					set theCommand to replace of it for theCommand from tab by "  "
					restore_delimiters() of it
				end tell
				
			end if
		end if
		
	else
		tell StringEngine
			store_delimiters() of it
			set theCommand to replace of it for theCommand from tab by "  "
			restore_delimiters() of it
		end tell
	end if
	
	if theCommand is not "" then
		sendCommand of theScriptExecuter for theCommand with allowBusyStatus
	end if
end sendSelection

(*= non-interactive commands *)
on getCommonTerminal(optionRecord)
	try
		set theScriptExecuter to getExecuter of ExecuterController without interactive and allowBusyStatus
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
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
		showMessage("No Selection in Finder") of EditorClient
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
on sendCommandInCommonTerm(optionRecord)
	set a_command to StringEngine's strip_head_tail_spaces(command of optionRecord)
	set a_command to cleanYenmark(a_command) of UtilityHandlers
	do_command of TerminalCommander for a_command with activation
	beep
end sendCommandInCommonTerm

property _namedTerms : missing value

on get_named_term(a_name)
	set target_term to missing value
	if my _namedTerms is missing value then
		set my _namedTerms to make XDict
	else
		set target_term to my _namedTerms's value_for_key(a_name)
	end if
	
	if target_term is missing value then
		copy TerminalCommander to target_term
		TerminalCommander's forgetTerminal()
		target_term's forget()
		target_term's set_custom_title("* " & a_name & " *")
		my _namedTerms's set_value(a_name, target_term)
	end if
	
	return target_term
end get_named_term

on send_in_named_term(opt_rec)
	set target_term to get_named_term(termTitle of opt_rec)
	set a_command to StringEngine's strip_head_tail_spaces(command of opt_rec)
	set a_command to cleanYenmark(a_command) of UtilityHandlers
	do_command of target_term for a_command with activation
end send_in_named_term