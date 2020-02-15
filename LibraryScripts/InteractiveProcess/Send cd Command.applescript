property TerminalBridgeProxy : "@module"
property PathInfo : "@module"
property EditorClient : "@module miClient"

property _command : "cd"

on run
	try
		main()
	on error msg number errno
		if errno is not -128 then
			activate
			display alert msg message "Error Number : " & errno
		end if
	end try
end run

on set_command(command)
	set my _command to command
end set_command

on main()
	set a_path to EditorClient's document_file_as_alias()
	if a_path is missing value then
		display alert "èëóﬁÇÕï€ë∂Ç≥ÇÍÇƒÇ¢Ç‹ÇπÇÒÅB"
		return
	end if
	
	set a_path to PathInfo's folder_of(a_path)'s POSIX path's quoted form
	
	script CommandHandler
		on do(sender)
			sender's UnixScriptController's send_command(_command & space & a_path)
		end do
	end script
	
	(make TerminalBridgeProxy)'s do_command(CommandHandler)
end main


