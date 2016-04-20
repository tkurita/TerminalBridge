global CommandBuilder
global XDict
global EditorClient
global XText
global UnixScriptExecuter
global TerminalClient
--global XFile
global PathInfo

property _interactiveExecuters : missing value
property _hcommandLabels : {"useOwnTerm", "escapeChars", "output", "prompt", "interactive", "shareTerm"}

on initialize()
	tell current application's class "TerminalClient"
		set TerminalClient to sharedTerminalClient()
	end tell
end initialize

on document_info given allowUnSaved:isAllowUnsaved, allowModified:isAllowModified
	--log "start document_info"
	if not EditorClient's exists_document() then
		error "No opened documents in mi." number 1670
	end if
	set a_name to EditorClient's document_name()
	set a_script_file to EditorClient's document_file_as_alias()
	if (not isAllowUnsaved) and (a_script_file is missing value) then
		set msg to XText's make_with(localized string "DocIsNotSaved")'s format_with({a_name})
		EditorClient's show_message(msg's as_unicode())
		error "The documet is not saved" number 1600
	end if
	
	if not isAllowModified then
		set modified_flag to EditorClient's is_modified()
		if modified_flag then
			if not EditorClient's save_with_asking(localized string "DocumentIsModified_AskSave") then
				error "The documen is modified. Saving the document is canceld by user." number 1610
			end if
		end if
	end if
	if a_script_file is not missing value then
		a_script_file as alias
		set a_script_file to PathInfo's make_with(a_script_file)
	end if
	--log "end document_info"
	return {name:a_name, file:a_script_file}
end document_info

on resolve_command(doc_info, command_info)
	--log "start resolve_command"
	if command_info is missing value then
		set command_info to {command:missing value, mode:missing value, baseCommand:missing value}
	else
		try
			get command of command_info
		on error
			set command_info to command_info & {command:missing value}
		end try
		set command_info to command_info & {mode:missing value, baseCommand:missing value}
	end if
	
	set firstLine to paragraph_at(1) of EditorClient
	
	if firstLine starts with "#!" then
		set a_command to text 3 thru -1 of firstLine
		set a_command to XText's strip(a_command)
		set command of command_info to a_command
	end if
	
	set mode of command_info to document_mode() of EditorClient
	if command of command_info is missing value then
		set a_command to TerminalClient's commandForMode_(mode of command_info) as text
		try
			get a_command
			set command of command_info to a_command
		end try
	end if
	
	if command of command_info is missing value then
		set msg to XText's make_with(localized string "DocHasNotCommand")'s format_with({doc_info's name})
		EditorClient's show_message(msg's as_unicode())
		error "The document does not start with #!." number 1620
	end if
	--log "end resolve_command"
	return command_info
end resolve_command

on resolveHeaderCommand()
	--log "start resolveHeaderCommand"
	set hearder_coms to make_with_lists({"useOwnTerm"}, {false}) of XDict
	set ith to 1
	repeat
		set a_paragraph to paragraph_at(ith) of EditorClient
		try
			get a_paragraph
		on error
			exit repeat -- reach to the end of the document
		end try
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
							set a_value to XText's strip(text valPos thru -1 of a_paragraph)
							if a_label is "escapeChars" then
								set a_value to run script a_value
							end if
						end if
						hearder_coms's set_value(a_label, a_value)
						exit repeat
					end if
				end repeat
			end ignoring
		else
			exit repeat
		end if
		set ith to ith + 1
	end repeat
	--log hearder_coms's dump()
	--log "end resolveHeaderCommand"
	return hearder_coms
end resolveHeaderCommand

on interactive_executer(doc_info, command_info, hearder_coms)
	-- log "start interactive_executer"
	--	log doc_info
	--	log command_info
	--	log hearder_coms
	set comList to XText's make_with(command of command_info)'s as_list_with(space)
    set candidate to last word of (first item of comList)
    if candidate is "env" then
        set baseCommand of command_info to last word of (second item of comList)
    else
        set baseCommand of command_info to candidate
    end if
	
	if (file of doc_info is not missing value) then
		if (hearder_coms's value_for_key("useOwnTerm")) then
			set executer_key to doc_info's file's as_alias()
		else
			if hearder_coms's has_key("shareTerm") then
				set shared_path to hearder_coms's value_for_key("shareTerm")
				if shared_path does not start with "/" then
					set folder_path to doc_info's file's parent_folder()'s posix_path()
					set shared_path to folder_path & "/" & shared_path
				end if
				
				try
					set executer_key to (shared_path as POSIX file) as alias
				on error msg number -1700
					set a_message to localized string "noShareTermFile"
					set a_message to XText's make_with(a_message)'s format_with({shared_path})'s as_unicode()
					set ignore_label to localized string "ignore"
					set cancel_label to localized string "cancel"
					set a_result to EditorClient's show_message_buttons(a_message, Å 
                                            {cancel_label, ignore_label}, ignore_label)
					if button returned of a_result is ignore_label then
						set executer_key to baseCommand of command_info
						hearder_coms's remove_for_key("shareTerm")
					else
						error "No shareTerm File." number 1660
					end if
				end try
			else
				set executer_key to baseCommand of command_info
			end if
		end if
	else
		set executer_key to baseCommand of command_info
	end if
	
	set an_executer to missing value
	if (my _interactiveExecuters is missing value) then
		set my _interactiveExecuters to make XDict
	else
		try
			set an_executer to my _interactiveExecuters's value_for_key(executer_key)
		on error number 900
			log "no cached excuter for " & executer_key
		end try
	end if
	--log "executer_key : " & executer_key
	--log "end of interactive_executer"
	return {executer_key, an_executer}
end interactive_executer

on get_executer for command_info given interactive:interactiveFlag, allowing_busy:isAllowBusy
	--log "start get_executer"
	set an_executer to missing value
	(* get info of front document of Editor *)
	
	set doc_info to document_info given allowUnSaved:interactiveFlag, allowModified:interactiveFlag
	
	(* resolve command name *)
	set command_info to resolve_command(doc_info, command_info)
	
	--log "get header commands"
	set hearder_coms to resolveHeaderCommand()
	--log (hearder_coms's dump())
	
	--log "get interactive executer"
	if interactiveFlag then
		set {executer_key, an_executer} to interactive_executer(doc_info, command_info, hearder_coms)
		if an_executer is not missing value then
			an_executer's update_script_file(file of doc_info)
			if not hearder_coms's has_key("interactive") then
				hearder_coms's set_value("interactive", command of command_info)
			end if
			an_executer's set_options(hearder_coms)
			an_executer's set_docmode(mode of command_info)
		end if
	else
		hearder_coms's remove_for_key("interactive")
	end if
	
	--log "make new Executer"
	if an_executer is missing value then
		-- log "will make new Executer"
		set a_command_builder to CommandBuilder's make_for_file(file of doc_info, command of command_info)
		set an_executer to UnixScriptExecuter's make_with(a_command_builder)
		an_executer's set_options(hearder_coms)
		an_executer's set_docmode(mode of command_info)
		-- log "before make interactive terminal"
		if interactiveFlag then
			set terminal_owner to missing value
			if hearder_coms's value_for_key("useOwnTerm") then
				set terminal_owner to doc_info's file
			else
				try
					set shared_path to hearder_coms's value_for_key("shareTerm")
					set terminal_owner to PathInfo's make_with(executer_key)
				end try
			end if
			if an_executer's prepare_terminal_with_owner(terminal_owner) then
				my _interactiveExecuters's set_value(executer_key, an_executer)
			else
				set an_executer to missing value
			end if
		end if
	end if
	
	--log "end get_executer"
	return an_executer
end get_executer
