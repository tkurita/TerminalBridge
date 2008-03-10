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
		setPrompt(my _options's value_for_key("prompt"))
	on error number 900
	end try
	try
		set_clean_commands(my _options's value_for_key("process"))
	on error number 900
	end try
	
	try
		my _commandBuilder's set_post_option(my _options's value_for_key("output"))
	on error number 900
	end try
	
	try
		set a_command to my _options's value_for_key("interactive")
		my _commandBuilder's set_command(a_command)
	on error number 900
	end try
	
	--log "end setOptions"
end set_options

on set_run_options(opt_record)
	my _commandBuilder's set_run_options(opt_record)
end set_run_options

on update_script_file(a_file)
	my _commandBuilder's set_target_file(a_file)
end update_script_file

on bring_to_front given allowBusyStatus:isAllowBusy
	--log "start bring_to_front in UnixScriptExecuter"
	if resolve_terminal of (my _target_terminal) given allowBusyStatus:isAllowBusy then
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
		
		@param checkCount -- a number of trial after 1 sec delay.
		
		@result
		boolean -- true when the terminal is not busy or a new terminal is opened.
		*)
on check_terminal_status(checkCount)
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
			if checkCount < 3 then
				delay 1
				return check_terminal_status(checkCount + 1)
			end if
		end if
		set process_texts to XList's make_with(new_processes)'s as_unicode_with(return)
		set a_name to terminal_name() of my _target_terminal
		set msg to UtilityHandlers's localized_string("cantExecCommand", {a_name, process_texts})
		set buttonList to {localized string "cancel", localized string "openTerm", localized string "showTerm"}
		set theMessageResult to show_message_buttons(msg, buttonList, item 3 of buttonList) of EditorClient
		--log "after show_message_buttons"
		set theReturned to button returned of theMessageResult
		if theReturned is item 3 of buttonList then
			bring_to_front() of my _target_terminal
			set a_result to kShowTerminal
		else if theReturned is item 2 of buttonList then
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

on send_command for a_command given allowBusyStatus:isBusyAllowed
	--log "start sendCommand in executer"
	set x_command to cleanup_command_text(a_command)
	try
		set escapeChars to _options's value_for_key("escapeChars")
		repeat with a_char in escapeChars
			set x_command to x_command's replace(a_char, (backslash of UtilityHandlers) & a_char)
		end repeat
	end try
	set a_command to x_command's as_unicode()
	--log "before resolve_terminal"
	if resolve_terminal of (my _target_terminal) given allowBusyStatus:isBusyAllowed then
		--log "before check_terminal_status in sendCommand in executer"
		set the_result to check_terminal_status(0)
		if the_result is kTerminalReady then
			--log "will do_in_current_term"
			--log a_command
			do_in_current_term of (my _target_terminal) for a_command without activation
		else if the_result is kShowTerminal then
			set the clipboard to a_command
		else
			return false
		end if
	else
		openNewTermForCommand(a_command)
	end if
	
	--log "end sendCommand"
	return true
end send_command

on openNewTermForCommand(a_command)
	--log "start openNewTermForCommand"
	set a_command to _commandBuilder's interactive_command()
	set a_command to UtilityHandlers's clean_yenmark(a_command)
	set a_command to a_command & return & a_command
	--log a_command
	return do_in_new_term of (my _target_terminal) for a_command without activation
end openNewTermForCommand

on setPrompt(thePrompt)
	--log "start setPrompt"
	if thePrompt is not missing value then
		set my _commandPrompt to thePrompt
	end if
	--log "end setPrompt"
end setPrompt

on set_clean_commands(processes)
	set my _process_name to processes & ";" & (contents of default entry "CleanCommands" of user defaults)
end set_clean_commands

on last_result()
	--log "start getLastResult in UnixScriptExecuter"
	if not (resolve_terminal of (my _target_terminal) without allowBusyStatus) then
		error "No Terminal found." number 1640
		return missing value
	end if
	
	set a_contents to my _target_terminal's window_contents()
	set a_result to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {a_contents, my _commandPrompt}
	
	if a_result is -1 then
		set a_contents to my _target_terminal's buffer_history()
		set a_result to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {a_contents, my _commandPrompt}
	end if
	
	if a_result is not 1 then
		return missing value
	end if
	
	--log "end getLastResult in UnixScriptExecuter"
	return call method "lastResultWithCR" of TerminalClient
end last_result

on open_new_terminal()
	--log "start open_new_terminal"
	set a_command to _commandBuilder's interactive_command()
	set a_command to UtilityHandlers's clean_yenmark(a_command)
	--log a_command
	return do_in_new_term of (my _target_terminal) for a_command without activation
end open_new_terminal


(*!@group handlers for shell mode *)
on runScript given activation:activateFlag
	set a_command to _commandBuilder's build_command()
	do_command of TerminalCommander for a_command given activation:activateFlag
	beep
end runScript

on send_to_common_term for a_command given activation:activateFlag
	set x_command to cleanup_command_text(a_command)
	do_command of TerminalCommander for x_command's as_unicode() given activation:activateFlag
	beep
end send_to_common_term

on make_obj(a_commandBuilder)
	--log "start makeObj in UnixScriptExecuter"
	script UnixScriptExecuter
		property _commandBuilder : a_commandBuilder
		property _process_name : missing value
		property _target_terminal : missing value
		property _commandPrompt : missing value
		property _options : missing value
		
		
		
	end script
end make_obj