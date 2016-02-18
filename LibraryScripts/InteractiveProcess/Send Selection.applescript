property TerminalBridgeProxy : module
(*
on _compile()
	boot (module loader of application (get "UnixScriptToolsLib")) for me
	return missing value
end _compile
property _ : _compile()
*)
property backslash : ASCII character 128
property _lineend_escapes : {backslash}

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

on add_lineend_escape(a_char)
	set end of my _lineend_escapes to a_char
end add_lineend_escape

on main()
	script CommandHandler
		on do(sender)
			sender's UnixScriptController's send_selection({lineEndEscape:my _lineend_escapes})
		end do
	end script
	
	(make TerminalBridgeProxy)'s do_command(CommandHandler)
end main
