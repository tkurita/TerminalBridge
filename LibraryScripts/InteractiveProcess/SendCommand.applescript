property TerminalBridgeProxy : "@module"
property _command : missing value

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

on set_command(a_text)
	set my _command to a_text
end set_command

on main()
	script CommandHandler
		on do(sender)
			sender's UnixScriptController's send_command(my _command)
		end do
	end script
	
	(make TerminalBridgeProxy)'s do_command(CommandHandler)
end main
