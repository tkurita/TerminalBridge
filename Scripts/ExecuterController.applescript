global MessageUtility
global CommandBuilder
global KeyValueDictionary
global EditorClient
global StringEngine
global UnixScriptExecuter
global TerminalClient

property interactiveExecuters : missing value
property _aDoc : missing value
property _sQ : missing value
property _eQ : missing value
property _hcommandLabels : {"useOwnTerm", "escapeChars", "process", "output", "prompt", "interactive"}

on initialize()
	set TerminalClient to call method "sharedTerminalClient" of class "TerminalClient"
	set _aDoc to localized string "aDocument"
	set _sQ to localized string "startQuote"
	set _eQ to localized string "endQuote"
end initialize

on getDocumentInfo given allowUnSaved:isAllowUnsaved, allowModified:isAllowModified
	--log "start getDocumentInfo"
	set theName to getDocumentName() of EditorClient
	set theScriptFile to getDocumentFileAlilas() of EditorClient
	
	if (not isAllowUnsaved) and (theScriptFile is missing value) then
		set isNotSaved to localized string "isNotSaved"
		set theMessage to (_aDoc & space & _sQ & theName & _eQ & space & isNotSaved)
		showMessage(theMessage) of EditorClient
		error "The documet is not saved" number 1600
	end if
	
	if not isAllowModified then
		set modifiedFlag to isModified() of EditorClient
		if modifiedFlag then
			if not saveWithAsking() of EditorClient then
				error "The documen is modified. Saving the document is canceld by user." number 1610
			end if
		end if
	end if
	return {name:theName, file:theScriptFile}
end getDocumentInfo

on resolveCommand(docInfo)
	--log "start resolveCommand"
	set firstLine to getParagraph(1) of EditorClient
	
	set theScriptCommand to missing value
	if firstLine starts with "#!" then
		set theScriptCommand to text 3 thru -1 of firstLine
		set theScriptCommand to StringEngine's stripHeadTailSpaces(theScriptCommand)
	end if
	
	set docMode to missing value
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
		set theMessage to _aDoc & space & _sQ & (name of docInfo) & _eQ & space & invalidCommand
		showMessage(theMessage) of EditorClient
		error "The document does not start with #!." number 1620
	end if
	--log "end resolveCommand"
	return {command:theScriptCommand, mode:docMode, baseCommand:missing value}
end resolveCommand

on resolveHeaderCommand()
	--log "start resolveHeaderCommand"
	set headerCommands to makeObjWithKeysAndValues({"useOwnTerm"}, {false}) of KeyValueDictionary
	set ith to 1
	repeat
		set theParagraph to getParagraph(ith) of EditorClient
		if theParagraph starts with "#" then
			ignoring case
				repeat with labelName in my _hcommandLabels
					set labelName to contents of labelName
					set theLabel to "#" & labelName
					if theParagraph starts with theLabel then
						if labelName is "useOwnTerm" then
							set theValue to true
						else
							set valPos to (length of theLabel) + 2
							if length of theParagraph is less than or equal to valPos then
								exit repeat
							end if
							set theValue to StringEngine's stripHeadTailSpaces(text valPos thru -1 of theParagraph)
							if labelName is "escapeChars" then
								set theValue to run script theValue
							end if
						end if
						setValue of headerCommands given forKey:labelName, withValue:theValue
						exit repeat
					end if
				end repeat
			end ignoring
		else
			exit repeat
		end if
		set ith to ith + 1
	end repeat
	return headerCommands
end resolveHeaderCommand

on getInteractiveExecuter(docInfo, commandInfo, headerCommands)
	--log "start getInteractiveExecuter"
	--	log docInfo
	--	log commandInfo
	--	log headerCommands
	tell StringEngine
		storeDelimiter()
		set comList to everyTextItem from (command of commandInfo) by space
		set baseCommand of commandInfo to last word of (first item of comList)
		restoreDelimiter()
	end tell
	
	if (getValue of headerCommands given forKey:"useOwnTerm") and (file of docInfo is not missing value) then
		set keyValue to file of docInfo
	else
		set keyValue to baseCommand of commandInfo
	end if
	
	if (getValue of headerCommands given forKey:"process") is missing value then
		setValue of headerCommands given forKey:"process", withValue:baseCommand of commandInfo
	end if
	set theExecuter to missing value
	
	if (interactiveExecuters is missing value) then
		set interactiveExecuters to makeObj() of KeyValueDictionary
	else
		set theExecuter to getValue of interactiveExecuters given forKey:keyValue
	end if
	
	if (getValue of headerCommands given forKey:"prompt") is missing value then
		if (mode of commandInfo) is missing value then
			set mode of commandInfo to getDocumentMode() of EditorClient
		end if
		set theDefPrompt to call method "promptForMode:" of TerminalClient with parameter (mode of commandInfo)
		try -- theDefPrompt may be undefined
			setValue of headerCommands given forKey:"prompt", withValue:theDefPrompt
		end try
	end if
	
	--log "end getInteractiveExecuter"
	return {keyValue, theExecuter}
end getInteractiveExecuter

on getExecuter given interactive:interactiveFlag, allowBusyStatus:isAllowBusy
	--log "start getExecuter"
	(* get info of front document of Editor *)
	set docInfo to getDocumentInfo given allowUnSaved:interactiveFlag, allowModified:interactiveFlag
	
	(* resolve command name *)
	set commandInfo to resolveCommand(docInfo)
	
	(* get header commands *)
	set headerCommands to resolveHeaderCommand()
	--log (headerCommands's dumpData())
	
	(* get interactive executer *)
	if interactiveFlag then
		set interactiveCommand to getValue of headerCommands given forKey:"interactive"
		if interactiveCommand is not missing value then
			set command of commandInfo to interactiveCommand
		end if
		set {keyValue, theExecuter} to getInteractiveExecuter(docInfo, commandInfo, headerCommands)
		if theExecuter is not missing value then
			setScriptFile(file of docInfo) of theExecuter
			setOptions(headerCommands) of theExecuter
			return theExecuter
		end if
	end if
	
	(* make new Executer *)
	set theCommandBuilder to makeObj(file of docInfo, command of commandInfo) of CommandBuilder
	--set postOption of theCommandBuilder to output of headerCommands
	
	set theExecuter to UnixScriptExecuter's makeObj(theCommandBuilder)
	--setCleanCommands(process of headerCommands) of theExecuter
	setOptions(headerCommands) of theExecuter
	
	if interactiveFlag then
		set theTitle to "* Inferior " & baseCommand of commandInfo
		if getValue of headerCommands given forKey:"useOwnTerm" then
			set theTitle to theTitle & "--" & (name of docInfo)
		end if
		
		if setTargetTerminal of theExecuter given title:(theTitle & " *"), ignoreStatus:isAllowBusy then
			setValue of interactiveExecuters given forKey:keyValue, withValue:theExecuter
		else
			set theExecuter to missing value
		end if
	end if
	(*
	if theExecuter is not missing value then
		--log "executer is found"
		setOptions(headerCommands) of theExecuter
	end if
	*)
	--log "end getExecuter"
	return theExecuter
end getExecuter
