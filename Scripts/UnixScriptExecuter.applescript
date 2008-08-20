global TerminalCommander
global TerminalClient
global UtilityHandlers
global XText
global XList
global EditorClient

(* constants of result of check_terminal_status *)
property kTerminalReady : "TerminalReady"
property kShowTerminal : "ShowTerminal"
property kCancel : "Cancel"

(*== Common Handlers *)
on set_options(opt_dict)
	set my _options to opt_dict
	try
		set_prompt(my _options's value_for_key("prompt"))
	on error number 900
	end try
	try
		set_clean_commands(my _options's value_for_key("process"))
	on error number 900
	end try
	
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

on set_run_options(opt_record)
	my _command_builder's set_run_options(opt_record)
end set_run_options

on update_script_file(a_xfile)
	my _command_builder's set_target_file(a_xfile)
end update_script_file

on bring_to_front given allowing_busy:isAllowBusy
	--log "start bring_to_front in UnixScriptExecuter"
	if resolve_terminal of (my _target_terminal) given allowing_busy:isAllowBusy then
		return bring_to_front() of (my _target_terminal)
	else
		return false
	end if
end bring_to_front

on cleanup_command_text(a_command)
	set a_command to XText's make_with(a_command)'s strip()
	set a_command to UtilityHandlers's clean_yenmark(a_command)
	return a_command
end cleanup_command_text

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
	if (contents of default entry "useExecCommand" of user defaults) then
		set process_list to running_processes() of my _target_terminal
	else
		set process_list to processes_on_shell() of my _target_terminal
	end if
	--log process_list
	if is_busy() of my _target_terminal then
		--log "targetTermianl is Busy "
		set support_processes to XText's make_with(my _process_name)'s as_list_with(";")
		--log support_processes
		set new_processes to {}
		repeat with an_item in process_list
			if an_item is not in support_processes then
				set end of new_processes to contents of an_item
			end if
		end repeat
		
		if length of new_processes is 0 then
			if n_checks < 3 then
				delay 1
				return check_terminal_status(n_checks + 1)
			end if
		end if
		set process_texts to XList's make_with(new_processes)'s as_unicode_with(return)
		set a_name to terminal_name() of my _target_terminal
		set msg to UtilityHandlers's localized_string("cantExecCommand", {a_name, process_texts})
		set button_names to {localized string "cancel", localized string "openTerm", localized string "showTerm"}
		set a_result to show_message_buttons(msg, button_names, item 3 of button_names) of EditorClient
		--log "after show_message_buttons"
		set button_result to button returned of a_result
		if button_result is item 3 of button_names then
			bring_to_front() of my _target_terminal
			set a_result to kShowTerminal
		else if button_result is item 2 of button_names then
			set a_result to open_new_terminal()
			if a_result then
				set a_result to kTerminalReady
			else
				set a_result to kCancel
			end if
		else
			set a_result to kCancel
		end if
	else
		if (process_list is {}) then
			set a_result to open_new_terminal()
			if a_result then
				set a_result to kTerminalReady
			else
				set a_result to kCancel
			end if
		end if
	end if
	--log "end of check_terminal_status"
	return a_result
end check_terminal_status

on prepare_terminal_with_owner(a_xfile)
	set my _owner_file to a_xfile
	set a_result to true
	set my _target_terminal to make TerminalCommander
	tell my _target_terminal
		forget()
		set_clean_commands(my _process_name)
		set_window_close_action("2")
	end tell
	--log "end set_target_terminal"
	return a_result
end prepare_terminal_with_owner

(*
on set_target_terminal given title:a_title, ignoreStatus:isIgnoreStatus
	--log "start set_target_terminal"
	set a_result to true
	set my _target_terminal to make TerminalCommander
	tell my _target_terminal
		forget()
		set_custom_title(a_title)
		set_clean_commands(my _process_name)
		set_window_close_action("2")
	end tell
	--log "end set_target_terminal"
	return a_result
end set_target_terminal
*)

on send_command for a_command given allowing_busy:isBusyAllowed
	--log "start send_command in executer"
	--log a_command
	set x_command to cleanup_command_text(a_command)
	try
		set escape_chars to my _options's value_for_key("escapeChars")
		repeat with a_char in escape_chars
			--log "will escape"
			set x_command to x_command's replace(a_char, (backslash of UtilityHandlers) & a_char)
			--log x_command
		end repeat
	end try
	set a_command to x_command's as_unicode()
	--log "before resolve_terminal"
	if resolve_terminal of (my _target_terminal) given allowing_busy:isBusyAllowed then
		--log "before check_terminal_status in sendCommand in executer"
		set a_result to check_terminal_status(0)
		if a_result is kTerminalReady then
			--log "will do_in_current_term"
			--log a_command
			do_in_current_term of (my _target_terminal) for a_command without activation
		else if a_result is kShowTerminal then
			set the clipboard to a_command
		else
			return false
		end if
	else
		open_new_term_for_command(a_command)
	end if
	
	--log "end send_command"
	return true
end send_command

on open_new_term_for_command(a_command)
	--log "start open_new_term_for_command"
	set a_command to UtilityHandlers's clean_yenmark(a_command)
	set interactive_command to my _command_builder's interactive_command()
	set all_command to interactive_command & return & a_command
	--log all_command
	return do_in_new_term of (my _target_terminal) for all_command without activation
end open_new_term_for_command

on set_prompt(a_prompt)
	--log "start set_prompt"
	if a_prompt is not missing value then
		set my _command_prompt to a_prompt
	end if
	--log "end set_prompt"
end set_prompt

on set_clean_commands(processes)
	set my _process_name to processes & ";" & (contents of default entry "CleanCommands" of user defaults)
end set_clean_commands

on last_result()
	--log "start getLastResult in UnixScriptExecuter"
	if not (resolve_terminal of (my _target_terminal) without allowing_busy) then
		error "No Terminal found." number 1640
		return missing value
	end if
	
	set a_contents to my _target_terminal's window_contents()
	set a_result to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {a_contents, my _command_prompt}
	
	if a_result is -1 then
		set a_contents to my _target_terminal's buffer_history()
		set a_result to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {a_contents, my _command_prompt}
	end if
	
	if a_result is not 1 then
		return missing value
	end if
	
	--log "end getLastResult in UnixScriptExecuter"
	return call method "lastResultWithCR" of TerminalClient
end last_result

on build_terminal_title()
	-- log "start build_terminal_title"
	set a_title to "* Inferior " & my _command_builder's base_command()
	if my _owner_file is not missing value then
		my _owner_file's update_cache()
		set a_title to a_title & "--" & my _owner_file's item_name()
	end if
	-- log ("end build_terminal_title" & a_title)
	return a_title & " *"
end build_terminal_title

on open_new_terminal()
	--log "start open_new_terminal"
	set a_command to my _command_builder's interactive_command()
	set a_command to UtilityHandlers's clean_yenmark(a_command)
	my _target_terminal's set_custom_title(build_terminal_title())
	--log "before end of open_new_terminal"
	return do_in_new_term of (my _target_terminal) for a_command without activation
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
	--log "start makeObj in UnixScriptExecuter"
	script UnixScriptExecuter
		property _command_builder : a_command_builder
		property _process_name : missing value
		property _target_terminal : missing value
		property _command_prompt : missing value
		property _options : missing value
		property _owner_file : missing value
	end script
end make_with