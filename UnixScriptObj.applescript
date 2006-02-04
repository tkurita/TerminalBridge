global UnixScriptExecuter
global EditorClient
global TerminalCommander
global UtilityHandlers
global StringEngine

(* execute tex commands called from tools from mi  ====================================*)
(* interactive process *)
on showInteractiveTerminal()
	--log "start showInteractiveTerminal"
	set theExecuter to getExecuter of UnixScriptExecuter with interactive
	if theExecuter is missing value then
		--log "the Executer is not found"
		if getTargetTerminal of TerminalCommander without allowBusyStatus then
			set theResult to bringToFront() of TerminalCommander
		else
			set theResult to false
		end if
	else
		set theResult to bringToFront() of theExecuter
	end if
	
	if not theResult then
		set theMessage to localized string "cantFindTerminal"
		showMessage(theMessage) of EditorClient
	end if
end showInteractiveTerminal

on sendCommand(theCommand)
	--log "start sendCommand in UnixScriptOjb"
	try
		set theScriptExecuter to getExecuter of UnixScriptExecuter with interactive
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
		end if
		return
	end try
	
	if theScriptExecuter is missing value then
		return
	end if
	
	set theCommand to stripHeadTailSpaces(theCommand) of UtilityHandlers
	if theCommand is not "" then
		sendCommand(theCommand) of theScriptExecuter
	end if
end sendCommand

on sendSelection()
	--log "start sendSelection"
	try
		set theScriptExecuter to getExecuter of UnixScriptExecuter with interactive
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
		end if
		return
	end try
	
	if theScriptExecuter is missing value then
		return
	end if
	
	set theCommand to getSelection() of EditorClient
	if theCommand is "" then
		set theCommand to getCurrentLine() of EditorClient
		set theCommand to stripHeadTailSpaces(theCommand) of UtilityHandlers
	else
		set theCommand to stripHeadTailSpaces(theCommand) of UtilityHandlers
		tell StringEngine
			startStringEngine() of it
			set theCommand to uTextReplace of it for theCommand from tab by "  "
			stopStringEngine() of it
		end tell
	end if
	
	if theCommand is not "" then
		sendCommand(theCommand) of theScriptExecuter
	end if
end sendSelection

(* simply run in Terminal *)
on RunInTerminal(optionRecord)
	try
		set theScriptExecuter to getExecuter of UnixScriptExecuter without interactive
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
		end if
		return
	end try
	setRunOptions(optionRecord) of theScriptExecuter
	runScript of theScriptExecuter with activation
end RunInTerminal

--run with Finder's selection
on getFinderSelection()
	tell application "Finder"
		set thelist to selection
	end tell
	set itemText to (quoted form of POSIX path of (item 1 of thelist as alias))
	repeat with theItem in (rest of thelist)
		set itemText to itemText & space & (quoted form of POSIX path of (theItem as alias))
	end repeat
	return itemText
end getFinderSelection

on runWithFinderSelection(optionRecord)
	--log "start runWithFinderSelection"
	try
		set theScriptExecuter to getExecuter of UnixScriptExecuter with interactive
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
		end if
		return
	end try
	setRunOptions(optionRecord) of theScriptExecuter
	set commandArg of theScriptExecuter to getFinderSelection()
	--log postOption of theScriptExecuter
	runScript of theScriptExecuter with activation
end runWithFinderSelection
