global MessageUtility
global CommandBuilder
global KeyValueDictionary
global EditorClient
global StringEngine
global UnixScriptExecuter
global TerminalClient
global PathAnalyzer

property interactiveExecuters : missing value
property _aDoc : missing value
property _sQ : missing value
property _eQ : missing value
property _hcommandLabels : {"useOwnTerm", "escapeChars", "process", "output", "prompt", "interactive", "shareTerm"}

on initialize()
	set TerminalClient to call method "sharedTerminalClient" of class "TerminalClient"
	set _aDoc to localized string "aDocument"
	set _sQ to localized string "startQuote"
	set _eQ to localized string "endQuote"
end initialize

on getDocumentInfo given allowUnSaved:isAllowUnsaved, allowModified:isAllowModified
	--log "start getDocumentInfo"
	set a_name to document_name() of EditorClient
	set a_script_file to document_file_as_alias() of EditorClient
	
	if (not isAllowUnsaved) and (a_script_file is missing value) then
		set isNotSaved to localized string "isNotSaved"
		set theMessage to (_aDoc & space & _sQ & a_name & _eQ & space & isNotSaved)
		showMessage(theMessage) of EditorClient
		error "The documet is not saved" number 1600
	end if
	
	if not isAllowModified then
		set modified_flag to is_modified() of EditorClient
		if modified_flag then
			if not save_with_asking() of EditorClient then
				error "The documen is modified. Saving the document is canceld by user." number 1610
			end if
		end if
	end if
	return {name:a_name, file:a_script_file}
end getDocumentInfo

on resolveCommand(docInfo)
	--log "start resolveCommand"
	set firstLine to paragraph_at_index(1) of EditorClient
	
	set theScriptCommand to missing value
	if firstLine starts with "#!" then
		set theScriptCommand to text 3 thru -1 of firstLine
		set theScriptCommand to StringEngine's strip_head_tail_spaces(theScriptCommand)
	end if
	
	set docMode to missing value
	if theScriptCommand is missing value then
		set docMode to document_mode() of EditorClient
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
	set headerCommands to make_with_lists({"useOwnTerm"}, {false}) of KeyValueDictionary
	set ith to 1
	repeat
		set a_paragraph to paragraph_at_index(ith) of EditorClient
		if a_paragraph starts with "#" then
			ignoring case
				repeat with a_label in my _hcommandLabels
					set a_label to contents of a_label
					set theLabel to "#" & a_label
					if a_paragraph starts with theLabel then
						if a_label is "useOwnTerm" then
							set a_value to true
						else
							set valPos to (length of theLabel) + 2
							if length of a_paragraph is less than or equal to valPos then
								exit repeat
							end if
							set a_value to StringEngine's strip_head_tail_spaces(text valPos thru -1 of a_paragraph)
							if a_label is "escapeChars" then
								set a_value to run script a_value
							end if
						end if
						set_value of headerCommands given for_key:a_label, with_value:a_value
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
		store_delimiters()
		set comList to split for (command of commandInfo) by space
		set baseCommand of commandInfo to last word of (first item of comList)
		restore_delimiters()
	end tell
	
	if (file of docInfo is not missing value) then
		if (headerCommands's value_for_key("useOwnTerm")) then
			set keyValue to file of docInfo
		else
			set shared_path to headerCommands's value_for_key("shareTerm")
			if shared_path is missing value then
				set keyValue to baseCommand of commandInfo
			else
				set folder_path to POSIX path of PathAnalyzer's folder_of(file of docInfo)
				set keyValue to POSIX file (folder_path & "/" & shared_path) as alias
				--setValue of headerCommands given forKey:"shareTerm", withValue:keyValue
			end if
		end if
	else
		set keyValue to baseCommand of commandInfo
	end if
	
	if (headerCommands's value_for_key("process")) is missing value then
		set_value of headerCommands given for_key:"process", with_value:baseCommand of commandInfo
	end if
	
	if (headerCommands's value_for_key("prompt")) is missing value then
		if (mode of commandInfo) is missing value then
			set mode of commandInfo to document_mode() of EditorClient
		end if
		set theDefPrompt to call method "promptForMode:" of TerminalClient with parameter (mode of commandInfo)
		try -- theDefPrompt may be undefined
			set_value of headerCommands given for_key:"prompt", with_value:theDefPrompt
		end try
	end if
	
	set theExecuter to missing value
	if (interactiveExecuters is missing value) then
		set interactiveExecuters to KeyValueDictionary's make_obj()
	else
		set theExecuter to interactiveExecuters's value_for_key(keyValue)
	end if
	
	--log "end getInteractiveExecuter"
	return {keyValue, theExecuter}
end getInteractiveExecuter

on getExecuter given interactive:interactiveFlag, allowBusyStatus:isAllowBusy
	--log "start getExecuter"
	set theExecuter to missing value
	(* get info of front document of Editor *)
	set docInfo to getDocumentInfo given allowUnSaved:interactiveFlag, allowModified:interactiveFlag
	
	(* resolve command name *)
	set commandInfo to resolveCommand(docInfo)
	
	(* get header commands *)
	set headerCommands to resolveHeaderCommand()
	--log (headerCommands's dumpData())
	
	(* get interactive executer *)
	if interactiveFlag then
		set {keyValue, theExecuter} to getInteractiveExecuter(docInfo, commandInfo, headerCommands)
		if theExecuter is not missing value then
			theExecuter's updateScriptFile(file of docInfo)
			theExecuter's setOptions(headerCommands)
		end if
	else
		removeItem of headerCommands given forKey:"interactive"
	end if
	
	(* make new Executer *)
	if theExecuter is missing value then
		set theCommandBuilder to CommandBuilder's makeObj(file of docInfo, command of commandInfo)
		
		set theExecuter to UnixScriptExecuter's makeObj(theCommandBuilder)
		setOptions(headerCommands) of theExecuter
		
		if interactiveFlag then
			set theTitle to "* Inferior " & baseCommand of commandInfo
			if headerCommands's value_for_key("useOwnTerm") then
				set theTitle to theTitle & "--" & (name of docInfo)
			else
				set shared_path to headerCommands's value_for_key("shareTerm")
				if (shared_path is not missing value) then
					set doc_name to PathAnalyzer's name_of(keyValue)
					set theTitle to theTitle & "--" & doc_name
				end if
			end if
			
			if setTargetTerminal of theExecuter given title:(theTitle & " *"), ignoreStatus:isAllowBusy then
				set_value of interactiveExecuters given for_key:keyValue, with_value:theExecuter
			else
				set theExecuter to missing value
			end if
		end if
	end if
	
	--log "end getExecuter"
	return theExecuter
end getExecuter
