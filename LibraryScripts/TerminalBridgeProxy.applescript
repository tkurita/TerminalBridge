property _terminal_bridge : "TerminalBridge"

on resolve_terminal_bridge()
	if application (my _terminal_bridge) is running then
		tell application "System Events"
					-- Under Yosemite we can't coerce a System Events alias into text, then "as alias" is inserted.
			return (file of application process (my _terminal_bridge) as alias) as text
		end tell
	end if
	
	set ver to version of current application
	considering numeric strings
		set mi_third to (ver ≥ "3.0")
	end considering
	if mi_third then
		set sub_path to "mi3:" & my _terminal_bridge & ".app"
		set path_list to {(path to application support from user domain as Unicode text) & sub_path}
	else
		set sub_path to "mi:" & my _terminal_bridge & ".app"
		set path_list to {(path to application support from user domain as Unicode text) & sub_path, ¬
			(path to preferences from user domain as Unicode text) & sub_path}
	end if
	
	try
		repeat with a_path in path_list
			a_path as alias
			return a_path
		end repeat
	end try
	display alert "Can't find TerminalBridge."
	return missing value
end resolve_terminal_bridge

on resolve_tool_server()
	return resolve_terminal_bridge()
end resolve_tool_server

on localized_string(a_key, insert_texts)
	set a_text to localized string a_key in bundle alias (my _tool_server)
	tell XText
		store_delimiters()
		set a_text to formated_text given template:a_text, args:insert_texts
		restore_delimiters()
	end tell
	return a_text
end localized_string

on make
	set a_path to resolve_terminal_bridge()
	script TerminalBridgeProxy
		property _tool_server : a_path
	end script
	
	return TerminalBridgeProxy
end make

on do_command(arg)
	try
		tell application (my _tool_server)
			launch
			using terms from application "TerminalBridge"
				ignoring application responses
					perform task with script arg
				end ignoring
			end using terms from
		end tell
	on error msg
		display alert msg
		return false
	end try
	return true
end do_command

on terminate()
	tell application "System Events"
		set a_list to application processes whose name is my _terminal_bridge
	end tell
	
	if a_list is not {} then
		tell application (name of (item 1 of a_list))
			quit
		end tell
	end if
end terminate

on debug()
	script CommandHandler
		on do(sender)
			sender's UnixScriptController's run_in_terminal(missing value)
		end do
	end script
	(make)'s do_command(CommandHandler)
end debug

on run
	debug()
end run