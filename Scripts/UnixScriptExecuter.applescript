global TerminalCommander
global TerminalClient
global UtilityHandlers
global XText
global XList
global EditorClient

(* constants of result of checkTerminalStatus *)
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
		setCleanCommands(my _options's value_for_key("process"))
	on error number 900
	end try
	
	try
		my _commandBuilder's set_post_option(my _options's value_for_key("output"))
	on error number 900
	end try
	
	try
		set interactiveCommand to my _options's value_for_key("interactive")
		my _commandBuilder's set_command(interactiveCommand)
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
	if getTargetTerminal of (my _targetTerminal) given allowBusyStatus:isAllowBusy then
		return bringToFront() of (my _targetTerminal)
	else
		return false
	end if
end bring_to_front

on make_obj(a_commandBuilder)
	--log "start makeObj in UnixScriptExecuter"
	script UnixScriptExecuter
		property _commandBuilder : a_commandBuilder
		property processName : missing value
		property _targetTerminal : missing value
		property _commandPrompt : missing value
		property _options : missing value
		
		(*** handlers for interactive mode ***)
		(*!
		== checkTerminalStatus
		Check busy status of a terminal window. 
		When the terminal window is busy, it will ask next actions of "cancel", "open new term" and "show the term" to user
		process setting of _tergetTerminal is concerned.
		
		=== Parameter 
		* checkCount -- a number of trial after 1 sec delay.
		
		=== Result
		boolean -- true when the terminal is not busy or a new terminal is opened.
		*)
		on checkTerminalStatus(checkCount)
			--log "start checkTerminalStatus"
			set theresult to kTerminalReady
			if (contents of default entry "useExecCommand" of user defaults) then
				set processList to getProcesses() of my _targetTerminal
			else
				set processList to getProcessesOnShell() of my _targetTerminal
			end if
			--log processList
			if isBusy() of my _targetTerminal then
				--log "targetTermianl is Busy "
				(*
				tell StringEngine
					store_delimiters()
					set supportProcesses to split for my processName by ";"
					restore_delimiters()
				end tell
				*)
				set supportProcesses to XText's make_with(processName)'s as_list_with(";")
				--log supportProcesses
				set newProcesses to {}
				repeat with theItem in processList
					if theItem is not in supportProcesses then
						set end of newProcesses to contents of theItem
					end if
				end repeat
				
				if length of newProcesses is 0 then
					if checkCount < 3 then
						delay 1
						return checkTerminalStatus(checkCount + 1)
					end if
				end if
				set processTexts to XList's make_with(newProcesses)'s as_unicode_with(return)
				(*
				tell StringEngine
					store_delimiters()
					set processTexts to join for newProcesses by return
					restore_delimiters()
				end tell
				*)
				
				set termName to getTerminalName() of my _targetTerminal
				set theMessage to UtilityHandlers's localized_string("cantExecCommand", {termName, processTexts})
				set buttonList to {localized string "cancel", localized string "openTerm", localized string "showTerm"}
				set theMessageResult to show_message_buttons(theMessage, buttonList, item 3 of buttonList) of EditorClient
				--log "after show_message_buttons"
				set theReturned to button returned of theMessageResult
				if theReturned is item 3 of buttonList then
					bringToFront() of my _targetTerminal
					set theresult to kShowTerminal
				else if theReturned is item 2 of buttonList then
					set theresult to openNewTerminal()
					if theresult then
						set theresult to kTerminalReady
					else
						set theresult to kCancel
					end if
				else
					set theresult to kCancel
				end if
			else
				if (processList is {}) then
					set theresult to openNewTerminal()
					if theresult then
						set theresult to kTerminalReady
					else
						set theresult to kCancel
					end if
				end if
			end if
			--log "end of checkTerminalStatus"
			return theresult
		end checkTerminalStatus
		
		on setTargetTerminal given title:theCustomTitle, ignoreStatus:isIgnoreStatus
			--log "start setTargetTerminal"
			set theresult to true
			copy TerminalCommander to my _targetTerminal
			tell my _targetTerminal
				forget()
				set_custom_title(theCustomTitle)
				setCleanCommands(processName)
				setWindowCloseAction("2")
			end tell
			(* -- 2006.10.06 必ず、terminal window を確保する必要があるのか？
			set a_command to my buildInteractiveCommand()
			--log "after buildInteractiveCommand"
			set a_command to cleanYenmark(a_command) of UtilityHandlers
			--log "after cleanYenmark"
			if getTargetTerminal of (my _targetTerminal) with allowBusyStatus then
				if not isIgnoreStatus then
					set theResult to checkTerminalStatus(0)
				end if
			else
				set theResult to doCommands of (my _targetTerminal) for a_command without activation
			end if
			*)
			--log "end setTargetTerminal"
			return theresult
		end setTargetTerminal
		
		on cleanup_command_text(a_command)
			set a_command to XText's make_with(a_command)'s strip()
			set a_command to UtilityHandlers's clean_yenmark(a_command)
			return a_command
		end cleanup_command_text
		
		on sendCommand for a_command given allowBusyStatus:isBusyAllowed
			--log "start sendCommand in executer"
			set x_command to cleanup_command_text(a_command)
			try
				set escapeChars to _options's value_for_key("escapeChars")
				repeat with a_char in escapeChars
					set x_command to x_command's replace(a_char, (backslash of UtilityHandlers) & a_char)
				end repeat
			end try
			set a_command to x_command's as_unicode()
			--log "before getTargetTerminal"
			if getTargetTerminal of (my _targetTerminal) given allowBusyStatus:isBusyAllowed then
				--log "before checkTerminalStatus in sendCommand in executer"
				set the_result to checkTerminalStatus(0)
				if the_result is kTerminalReady then
					--log "will doCmdInCurrentTerm"
					--log a_command
					doCmdInCurrentTerm of (my _targetTerminal) for a_command without activation
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
		end sendCommand
		
		on getLastResult()
			--log "start getLastResult in UnixScriptExecuter"
			if not (getTargetTerminal of (my _targetTerminal) without allowBusyStatus) then
				error "No Terminal found." number 1640
				return missing value
			end if
			
			set theContents to my _targetTerminal's getContents()
			set theresult to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {theContents, my _commandPrompt}
			
			if theresult is -1 then
				set theContents to my _targetTerminal's getHistory()
				set theresult to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {theContents, my _commandPrompt}
			end if
			
			if theresult is not 1 then
				return missing value
			end if
			
			--log "end getLastResult in UnixScriptExecuter"
			return call method "lastResultWithCR" of TerminalClient
		end getLastResult
		
		on openNewTerminal()
			--log "start openNewTerminal"
			--set interactiveCommand to _commandBuilder's buildInteractiveCommand()
			set interactiveCommand to _commandBuilder's interactive_command()
			set interactiveCommand to UtilityHandlers's cleanYenmark(interactiveCommand)
			--log interactiveCommand
			return doCmdInNewTerm of (my _targetTerminal) for interactiveCommand without activation
		end openNewTerminal
		
		on openNewTermForCommand(a_command)
			--log "start openNewTermForCommand"
			--set interactiveCommand to _commandBuilder's buildInteractiveCommand()
			set interactiveCommand to _commandBuilder's interactive_command()
			set interactiveCommand to UtilityHandlers's cleanYenmark(interactiveCommand)
			set interactiveCommand to interactiveCommand & return & a_command
			--log interactiveCommand
			return doCmdInNewTerm of (my _targetTerminal) for interactiveCommand without activation
		end openNewTermForCommand
		
		on setPrompt(thePrompt)
			--log "start setPrompt"
			if thePrompt is not missing value then
				set my _commandPrompt to thePrompt
			end if
			--log "end setPrompt"
		end setPrompt
		
		on setCleanCommands(theProcesses)
			set processName to theProcesses & ";" & (contents of default entry "CleanCommands" of user defaults)
		end setCleanCommands
		
		(*** handlers for shell mode ***)
		on runScript given activation:activateFlag
			set allCommand to _commandBuilder's build_command()
			doCommands of TerminalCommander for allCommand given activation:activateFlag
			beep
		end runScript
		
		on sendCommandInCommonTerm for a_command given activation:activateFlag
			set x_command to cleanup_command_text(a_command)
			doCommands of TerminalCommander for x_command's as_unicode() given activation:activateFlag
			beep
		end sendCommandInCommonTerm
	end script
end make_obj