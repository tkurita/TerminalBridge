global ExecuterController
global EditorClient
global TerminalCommander
global StringEngine
global UtilityHandlers

(* execute tex commands called from tools from mi  ====================================*)
(*= interactive process *)
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
	set theResult to bringToFront of theExecuter with allowBusyStatus
	if not theResult then
		set theResult to openNewTerminal() of theExecuter
	end if
	
	if theResult then
		set theResult to bringToFront of theExecuter with allowBusyStatus
	else
		showMessage("can't open new terminal") of EditorClient -- this message should not be shown.
	end if
	--end if
	
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
					storeDelimiters() of it
					set theCommand to joinUTextList of it for command_list by ""
					set theCommand to uTextReplace of it for theCommand from tab by "  "
					restoreDelimiters() of it
				end tell
				
			end if
		end if
		
	else
		tell StringEngine
			storeDelimiters() of it
			set theCommand to uTextReplace of it for theCommand from tab by "  "
			restoreDelimiters() of it
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
	theScriptExecuter's setRunOptions(optionRecord)
	return theScriptExecuter
end getCommonTerminal

(*==  simply run in Terminal *)
on RunInTerminal(optionRecord)
	set an_executer to getCommonTerminal(optionRecord)
	if an_executer is missing value then return
	
	runScript of an_executer with activation
end RunInTerminal

(* == run with Finder's selection *)
on getFinderSelection(optionRecord)
	tell application "Finder"
		set theList to selection
	end tell
	set itemText to (quoted form of POSIX path of (item 1 of theList as alias))
	repeat with theItem in (rest of theList)
		set itemText to itemText & space & (quoted form of POSIX path of (theItem as alias))
	end repeat
	return itemText
end getFinderSelection

on runWithFinderSelection(optionRecord)
	--log "start runWithFinderSelection"
	set an_executer to getCommonTerminal(optionRecord)
	if a_execter is missing value then return
	
	set commandArg of theScriptExecuter to getFinderSelection()
	runScript of theScriptExecuter with activation
end runWithFinderSelection

(*== send command without CommandBuilder *)
on sendCommandInCommonTerm(optionRecord)
	set theCommand to StringEngine's stripHeadTailSpaces(command of optionRecord)
	set theCommand to cleanYenmark(theCommand) of UtilityHandlers
	doCommands of TerminalCommander for theCommand with activation
	beep
end sendCommandInCommonTerm
