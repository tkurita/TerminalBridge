global MessageUtility
global CommandBuilder
global KeyValueDictionary
global EditorClient
global UtilityHandlers
global StringEngine
global appController

property interactiveExecuters : missing value

(*global variables in this sxript *)
property theScriptFile : missing value
property theScriptCommand : missing value
property theOutput : missing value
property theProcessName : missing value
property theName : missing value
property baseCommand : missing value
property useOwnTerm : missing value
property keyValue : missing value

on initialize()
	set theScriptFile to missing value
	set theScriptCommand to missing value
	set theOutput to missing value
	set theProcessName to missing value
	set theName to missing value
	set baseCommand to missing value
	set useOwnTerm to missing value
	set keyValue to missing value
end initialize

on lookupExecuter given interactive:interactiveFlag
	--log "start lookupExecuter"
	set theName to getDocumentName() of EditorClient
	
	set aDoc to localized string "aDocument"
	set sQ to localized string "startQuote"
	set eQ to localized string "endQuote"
	
	set theScriptFile to getDocumentFileAlilas() of EditorClient
	if theScriptFile is missing value then
		set isNotSaved to localized string "isNotSaved"
		set theMessage to (aDoc & space & sQ & theName & eQ & space & isNotSaved)
		showMessage(theMessage) of EditorClient
		error "The documet is not saved" number 1600
	end if
	
	if not interactiveFlag then
		set modifiedFlag to isModified() of EditorClient
		if modifiedFlag then
			if not saveWithAsking() of EditorClient then
				error "The documen is modified. Saving the document is canceld by user." number 1610
			end if
		end if
	end if
	
	set firstLine to getParagraph(1) of EditorClient
	
	set theScriptCommand to missing value
	if firstLine starts with "#!" then
		set theScriptCommand to text 3 thru -1 of firstLine
		set theScriptCommand to stripHeadTailSpaces(theScriptCommand) of UtilityHandlers
	end if
	
	if theScriptCommand is missing value then
		set docMode to getDocumentMode() of EditorClient
		set theScriptCommand to call method "getDefaultCommandForMode:" of appController with parameter docMode
		try
			get theScriptCommand
		on error number -2753
			set theScriptCommand to missing value
		end try
	end if
	
	if theScriptCommand is missing value then
		set invalidCommand to localized string "invalidCommand"
		set theMessage to aDoc & space & sQ & theName & eQ & space & invalidCommand
		showMessage(theMessage) of EditorClient
		error "The document does not start with #!." number 1620
	end if
	
	set theOutput to ""
	set theProcessName to missing value
	set useOwnTerm to false
	set ith to 2
	repeat
		set theParagraph to getParagraph(ith) of EditorClient
		if theParagraph starts with "#" then
			ignoring case
				if theParagraph starts with "#output" then
					set theOutput to stripHeadTailSpaces(text 9 thru -1 of theOutput) of UtilityHandlers
				else if theParagraph starts with "#process" then
					if length of theParagraph > 9 then
						set theProcessName to stripHeadTailSpaces(text 10 thru -1 of theParagraph) of UtilityHandlers
					end if
				else if theParagraph starts with "#useOwnTerm" then
					set useOwnTerm to true
				end if
			end ignoring
		else
			exit repeat
		end if
		set ith to ith + 1
	end repeat
	
	if interactiveFlag then
		set baseCommand to first word of theScriptCommand
		
		if useOwnTerm then
			set keyValue to theScriptFile
		else
			set keyValue to baseCommand
		end if
		
		if theProcessName is missing value then
			set theProcessName to baseCommand
		end if
		
		if (interactiveExecuters is missing value) then
			set interactiveExecuters to makeObj() of KeyValueDictionary
		else
			return getValue of interactiveExecuters given forKey:keyValue
		end if
	end if
	--log "end lookupExecuter"
	return missing value
end lookupExecuter

on getExecuter given interactive:interactiveFlag
	--log "start getExecuter"
	initialize()
	set theExecuter to lookupExecuter given interactive:interactiveFlag
	
	if theExecuter is not missing value then
		return theExecuter
	end if
	
	set theCommandBuilder to makeObj(theScriptFile, theScriptCommand) of CommandBuilder
	set postOption of theCommandBuilder to theOutput
	
	set theExecuter to makeObj(theCommandBuilder)
	setCleanCommands(theProcessName) of theExecuter
	
	if interactiveFlag then
		set theTitle to "* Inferior " & baseCommand
		if useOwnTerm then
			set theTitle to theTitle & "--" & theName
		end if
		
		if setTargetTerminal(theTitle & " *") of theExecuter then
			setValue of interactiveExecuters given forKey:keyValue, withValue:theExecuter
		else
			set theExecuter to missing value
		end if
	end if
	--log "end getExecuter"
	return theExecuter
end getExecuter

on makeObj(theCommandBuilder)
	script UnixScriptExecuter
		global TerminalCommander
		
		property parent : theCommandBuilder
		property processName : missing value
		property targetTerminal : missing value
		
		on setCleanCommands(theProcesses)
			set processName to theProcesses & ";" & (contents of default entry "CleanCommands" of user defaults)
		end setCleanCommands
		
		on bringToFront()
			if getTargetTerminal of (my targetTerminal) without allowBusyStatus then
				return bringToFront() of (my targetTerminal)
			else
				return false
			end if
		end bringToFront
		
		on runScript given activation:activateFlag
			set allCommand to my buildCommand()
			doCommands of TerminalCommander for allCommand given activation:activateFlag
			beep
		end runScript
		
		on openNewTerminal()
			set interactiveCommand to my buildInteractiveCommand()
			set interactiveCommand to cleanYenmark(interactiveCommand) of UtilityHandlers
			doCmdInNewTerm of targetTerminal for interactiveCommand without activation
		end openNewTerminal
		
		on sendCommand(theCommand)
			--log "start sendCommand in executer"
			set theCommand to cleanYenmark(theCommand) of UtilityHandlers
			
			if getTargetTerminal of (my targetTerminal) with allowBusyStatus then
				if checkTerminalStatus() then
					doCmdInCurrentTerm of (my targetTerminal) for theCommand without activation
				else
					return false
				end if
			else
				openNewTerminal()
				doCmdInCurrentTerm of (my targetTerminal) for theCommand without activation
			end if
			
			--log "end sendCommand"
			return true
		end sendCommand
		
		on checkTerminalStatus()
			--log "start checkTerminalStatus"
			set processList to getProcessesOnShell() of my targetTerminal
			--log processList
			if isBusy() of my targetTerminal then
				set supportProcesses to everyTextItem of StringEngine from my processName by ";"
				--log supportProcesses
				set newProcceses to {}
				repeat with theItem in processList
					if theItem is not in supportProcesses then
						set end of newProcceses to contents of theItem
					end if
				end repeat
				
				set processTexts to joinUTextList of StringEngine for newProcceses by return
				set termName to getTerminalName() of my targetTerminal
				set theMessage to getLocalizedString of UtilityHandlers given keyword:"cantExecCommand", insertTexts:{termName, processTexts}
				if showMessageWithAsk(theMessage) of EditorClient then
					openNewTerminal()
					return true
				else
					return false
				end if
			else
				if (processList is {}) then
					openNewTerminal()
				end if
			end if
			
			return true
		end checkTerminalStatus
		
		on setTargetTerminal(theCustomTitle)
			--log "start setTargetTerminal"
			copy TerminalCommander to targetTerminal
			forgetTerminal() of targetTerminal
			setCustomTitle(theCustomTitle) of targetTerminal
			setCleanCommands(processName) of targetTerminal
			setWindowCloseAction("2") of targetTerminal
			set theCommand to my buildInteractiveCommand()
			--log "after buildInteractiveCommand"
			set theCommand to cleanYenmark(theCommand) of UtilityHandlers
			--log "after cleanYenmark"
			if getTargetTerminal of (my targetTerminal) with allowBusyStatus then
				return checkTerminalStatus()
			else
				doCommands of targetTerminal for theCommand without activation
			end if
			--log "end setTargetTerminal"
			return true
		end setTargetTerminal
	end script
end makeObj