property TerminalBridgeProxy : "@module"

property _option : missing value

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

on set_option(opt)
	set my _option to opt
end set_option

on will_do()
end will_do

on main()
	will_do()
	script CommandHandler
		on do(sender)
			sender's UnixScriptController's run_in_terminal(my _option)
		end do
	end script
	
	(make TerminalBridgeProxy)'s do_command(CommandHandler)
end main
