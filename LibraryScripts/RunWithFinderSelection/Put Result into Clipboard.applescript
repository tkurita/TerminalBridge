property TerminalBridgeProxy : "@module"

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

on main()
	script CommandHandler
		on do(sender)
			sender's UnixScriptController's run_with_finder_selection({postOption:"|pbcopy"})
		end do
	end script
	
	(make TerminalBridgeProxy)'s do_command(CommandHandler)
end main
