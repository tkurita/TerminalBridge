global TerminalCommander
global TerminalClient
global UtilityHandlers
global XText
global XList
global PathInfo
global EditorClient
global appController


(* constants of result of check_terminal_status *)
property kTerminalReady : "TerminalReady"
property kShowTerminal : "ShowTerminal"
property kNewTerminal : "NewTerminal"
property kCancel : "Cancel"

(*== Common Handlers *)
on set_options(opt_dict)
	set my _options to opt_dict
	try
		my _command_builder's set_post_option(my _options's value_for_key("output"))
	on error number 900
	end try
	
	try
		set a_command to my _options's value_for_key("interactive")
		my _command_builder's set_command(a_command)
	on error number 900
	end try
	
	--log "end setOptions"
end set_options

on set_docmode(a_mode)
	set my _docmode to a_mode
end set_docmode

on set_run_options(opt_record)
	my _command_builder's set_run_options(opt_record)
end set_run_options

on update_script_file(a_xfile)
	my _command_builder's set_target_file(a_xfile)
end update_script_file

on bring_to_front given allowing_busy:isAllowBusy
	--log "start bring_to_front in UnixScriptExecuter"
	if resolve_terminal of (my _target_terminal) given allowing_busy:isAllowBusy then
		--log "success to resolve_terminal"
		set a_result to (my _target_terminal)'s bring_to_front()
	else
		--log "fail to resolove_terminal"
		set a_result to false
	end if
	--log ("result of bring_to_front:" & a_result)
	return a_result
end bring_to_front

on cleanup_command_text(a_command)
	set a_command to XText's make_with(a_command)'s strip()
	set a_command to UtilityHandlers's clean_yenmark(a_command)
	return a_command
end cleanup_command_text

on is_ready_prompt()
	--log "start is_ready_prompt"
	set a_prompt to command_prompt()
	if a_prompt is missing value then return false
	set a_contents to my _target_terminal's window_contents()
	return TerminalClient's isReadyTerminalContents_withPrompt_(a_contents, a_prompt) as boolean
end is_ready_prompt

on settings_name()
	set a_name to TerminalClient's settingsNameForMode_(my _docmode)
	if a_name is not missing value then
		set a_name to a_name as text
	end if
	return a_name
end settings_name

(*@group handlers for interactive mode *)
(*!@abstruct
Check busy status of a terminal window. 
When the terminal window is busy, it will ask next actions of "cancel", "open new term" and "show the term" to user
process setting of _tergetTerminal is concerned.

@param n_checks -- a number of trial after 1 sec delay.

@result
boolean -- true when the terminal is not busy or a new terminal is opened.
*)
on check_terminal_status(n_checks)
	--log "start check_terminal_status"
	set a_result to kTerminalReady
	--log process_list
	if is_busy() of my _target_terminal then
		--log "targetTermianl is Busy "
		if is_ready_prompt() then
			set a_result to kTerminalReady
		else
			set a_term to my _target_terminal's terminal_window()
			tell application "Terminal"
				set support_processes to clean commands of a_term
			end tell
			
			set process_list to processes_on_shell() of my _target_terminal
			set new_processes to {}
			repeat with an_item in process_list
				if an_item is not in support_processes then
					set end of new_processes to contents of an_item
				end if
			end repeat
			
			if length of new_processes > 0 then
				set a_name to terminal_name() of my _target_terminal
				set a_result to appController's displayCantExecWindowForTerminalName_processes_(a_name, new_processes) as text
			end if
			if a_result is kShowTerminal then
				bring_to_front() of my _target_terminal
			else if a_result is kNewTerminal then
				set a_result to open_new_terminal()
			else if a_result is "AddProcesses" then
				tell application "Terminal"
					tell current settings of a_term
						set current_list to clean commands
						set clean commands to (current_list & new_processes)
					end tell
				end tell
				set a_result to kTerminalReady
			end if
		end if
	end if
	--log "end of check_terminal_status"
	return a_result
end check_terminal_status

on prepare_terminal_with_owner(a_xfile)
	--log "start prepare_terminal_with_owner"
	set my _owner_file to a_xfile
	set a_result to true
	set my _target_terminal to make TerminalCommander
	set a_title to build_terminal_title()
	tell my _target_terminal
		forget()
		set_custom_title(a_title)
		set_delegate(me)
	end tell
	return a_result
end prepare_terminal_with_owner

on send_command for a_command given allowing_busy:isBusyAllowed
	--log "start send_command in UnixScriptExecuter"
	set x_command to cleanup_command_text(a_command)
	
	try
		set escape_chars to my _options's value_for_key("escapeChars")
		repeat with a_char in escape_chars
			--log "will escape"
			set x_command to x_command's replace(a_char, (backslash of UtilityHandlers) & a_char)
			--log x_command
		end repeat
	end try
    script StripHeadSpaces
        on do(a_text)
            set a_result to XText's strip_beginning(a_text)
            return item 2 of a_result
        end do
    end script
    set a_command to XList's make_with(paragraphs of x_command's as_text())'s Å 
                    map(StripHeadSpaces)'s as_text_with(return)
	if resolve_terminal of (my _target_terminal) given allowing_busy:isBusyAllowed then
		set a_result to check_terminal_status(0)
		if a_result is kTerminalReady then
			set a_text to a_command as text
			do_in_current_term of (my _target_terminal) for a_text without activation
		else if a_result is kShowTerminal then
			set the clipboard to a_command
		else
			return false
		end if
	else
		open_new_term_for_command(a_command)
	end if
	
	--log "end send_command UnixScriptExecuter"
	return true
end send_command

on open_new_term_for_command(a_command)
	--log "start open_new_term_for_command"
	set interactive_command to my _command_builder's interactive_command()
	if a_command is not missing value then
		set a_command to UtilityHandlers's clean_yenmark(a_command)
		set all_command to interactive_command & return & a_command
	else
		set all_command to interactive_command
	end if
	--log all_command
	if my _fresh then
		set my _fresh to false
	else
		if my _owner_file is not missing value then
			set my _owner_file to PathInfo's make_with(my _owner_file's as_alias())
			my _target_terminal's set_custom_title(build_terminal_title())
		end if
	end if
	--log "before do_in_new_term"
	return do_in_new_term of (my _target_terminal) for all_command without activation
end open_new_term_for_command

on set_prompt(a_prompt)
	--log "start set_prompt"
	if a_prompt is not missing value then
		set my _command_prompt to a_prompt
	end if
	--log "end set_prompt"
end set_prompt

on command_prompt()
	--log "start command_prompt"
	set a_result to missing value
	if my _command_prompt is missing value then
		if my _docmode is not missing value then
			set a_prompt to TerminalClient's promptForMode_(my _docmode) as text
			try
				get a_prompt
			on error
				set a_prompt to missing value
			end try
			set a_result to a_prompt
		end if
	else
		set a_result to my _command_prompt
	end if
	--log "end command_prompt with result : " & a_result
	return a_result
end command_prompt

on last_result()
	--log "start last_result in UnixScriptExecuter"
	if not (resolve_terminal of (my _target_terminal) with allowing_busy) then
		error "No Terminal found." number 1640
		return missing value
	end if
	
	set a_contents to my _target_terminal's window_contents()
	set a_prompt to command_prompt()
	set a_result to TerminalClient's extactLastResult_withPrompt_(a_contents, a_prompt) as integer
	if a_result is -1 then
		set a_contents to my _target_terminal's buffer_history()
		set a_result to TerminalClient's extactLastResult_withPrompt_(a_contents, command_prompt()) as integer
	end if
	
	if a_result is not 1 then
		return missing value
	end if
	
	--log "end last_result in UnixScriptExecuter"
	return TerminalClient's lastResultWithCR() as text
end last_result

on build_terminal_title()
	-- log "start build_terminal_title"
	set a_title to "* Inferior " & my _command_builder's base_command()
	if my _owner_file is not missing value then
		--my _owner_file's update_cache()
		set a_title to a_title & "--" & my _owner_file's item_name()
	end if
	-- log ("end build_terminal_title" & a_title)
	return a_title & " *"
end build_terminal_title

on open_new_terminal()
	return open_new_term_for_command(missing value)
end open_new_terminal


(*!@group handlers for shell mode *)
on run_script given activation:activate_flag
	set a_command to my _command_builder's build_command()
	do_command of TerminalCommander for a_command given activation:activate_flag
	beep
end run_script

on send_to_common_term for a_command given activation:activateFlag
	set x_command to cleanup_command_text(a_command)
	do_command of TerminalCommander for x_command's as_unicode() given activation:activateFlag
	beep
end send_to_common_term

on make_with(a_command_builder)
	--log "start make_with in UnixScriptExecuter"
	script UnixScriptExecuter
		property _command_builder : a_command_builder
		property _target_terminal : missing value
		property _command_prompt : missing value
		property _options : missing value
		property _owner_file : missing value
		property _docmode : missing value
		property _fresh : true
	end script
end make_with