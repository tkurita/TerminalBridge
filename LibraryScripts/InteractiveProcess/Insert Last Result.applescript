property TerminalBridgeProxy : module
on _compile()
	boot (module loader of application (get "UnixScriptToolsLib")) for me
	return missing value
end _compile
property _ : _compile()

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
			sender's UnixScriptController's last_result()
		end do
	end script
	
	(make TerminalBridgeProxy)'s do_command(CommandHandler)
end main
