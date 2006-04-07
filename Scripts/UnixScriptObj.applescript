global ExecuterController
global EditorClient
global TerminalCommander
global StringEngine

(* execute tex commands called from tools from mi  ====================================*)
(* interactive process *)
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
	
	insertText(theResult) of EditorClient
	--log "end getLastResult in UnixScriptObj"
end getLastResult

on showInteractiveTerminal()
	--log "start showInteractiveTerminal"
	set theExecuter to getExecuter of ExecuterController with interactive and allowBusyStatus
	if theExecuter is missing value then
		--log "the Executer is not found"
		-- このブロックはいらないかもしれない。theExecuter は いつ missing value　になる？
		if getTargetTerminal of TerminalCommander with allowBusyStatus then
			set theResult to bringToFront() of TerminalCommander
		else
			set theResult to false
		end if
	else
		set theResult to bringToFront of theExecuter with allowBusyStatus
	end if
	
	if not theResult then
		set theMessage to localized string "cantFindTerminal"
		showMessage(theMessage) of EditorClient
	end if
end showInteractiveTerminal

on sendCommand(theCommand)
	--log "start sendCommand in UnixScriptOjb"
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
	
	set theCommand to StringEngine's stripHeadTailSpaces(theCommand)
	if theCommand is not "" then
		sendCommand(theCommand) of theScriptExecuter
	end if
end sendCommand

on sendSelection()
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
	
	set theCommand to getSelection() of EditorClient
	if theCommand is "" then
		set theCommand to getCurrentLine() of EditorClient
		if theCommand is not "" then
			set theCommand to StringEngine's stripHeadTailSpaces(theCommand)
		end if
	else
		set theCommand to StringEngine's stripHeadTailSpaces(theCommand)
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
		set theScriptExecuter to getExecuter of ExecuterController without interactive and allowBusyStatus
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
	try
		set theScriptExecuter to getExecuter of ExecuterController with interactive without allowBusyStatus
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
