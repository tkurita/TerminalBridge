global MessageUtility
global CommandBuilder
global KeyValueDictionary
global EditorClient
global UtilityHandlers
global StringEngine
global UnixScriptExecuter
global TerminalClient

property interactiveExecuters : missing value

on initialize()
	set TerminalClient to call method "sharedTerminalClient" of class "TerminalClient"
end initialize

on getExecuter given interactive:interactiveFlag
	--log "start getExecuter"
	set theScriptFile to missing value
	set theScriptCommand to missing value
	set theOutput to missing value
	set theProcessName to missing value
	set theName to missing value
	set baseCommand to missing value
	set useOwnTerm to false
	set keyValue to missing value
	set theOutput to ""
	set thePrompt to missing value
	set theExecuter to missing value
	set docMode to missing value
	
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
		set theScriptCommand to call method "commandForMode:" of TerminalClient with parameter docMode
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
				else if theParagraph starts with "#prompt" then
					if length of theParagraph > 8 then
						set thePrompt to stripHeadTailSpaces(text 9 thru -1 of theParagraph) of UtilityHandlers
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
			set theExecuter to getValue of interactiveExecuters given forKey:keyValue
		end if
		
		if thePrompt is missing value then
			if docMode is missing value then
				set docMode to getDocumentMode() of EditorClient
			end if
			set thePrompt to call method "promptForMode:" of TerminalClient with parameter docMode
		end if
	end if
	
	if theExecuter is not missing value then
		setPrompt(thePrompt) of theExecuter
		return theExecuter
	end if
	
	set theCommandBuilder to makeObj(theScriptFile, theScriptCommand) of CommandBuilder
	set postOption of theCommandBuilder to theOutput
	
	set theExecuter to UnixScriptExecuter's makeObj(theCommandBuilder)
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
	
	if theExecuter is not missing value then
		setPrompt(thePrompt) of theExecuter
	end if
	
	--log "end getExecuter"
	return theExecuter
end getExecuter
