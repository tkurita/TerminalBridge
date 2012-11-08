global XText
global linefeed

on set_post_option(an_option)
	set my _postOption to an_option
end set_post_option

on set_command(a_command)
	set my _command to a_command
end set_command

on set_target_file(a_xfile)
	set my _target_file to a_xfile
end set_target_file

on set_run_options(opts)
	try
		set my _command to command of opts
	end try
	try
		set my _commandOption to commandOption of opts
	end try
	try
		set my _postOption to postOption of opts
	end try
	try
		set my _preOption to preOption of opts
	end try
	try
		set my _commandArg to commandArg of opts
	end try
end set_run_options

on base_command()
	set a_list to XText's make_with(my _command)'s as_list_with(space)
	set a_result to last word of (first item of a_list)
	if a_result is "env" then
		set a_result to second item of a_list
	end if
	return a_result
end base_command

on interactive_command()
	--log "start buildInteractiveCommand"
	if my _target_file is missing value then
		set cd_command to ""
	else
		--build cd command
		set a_folder to my _target_file's parent_folder()'s posix_path()'s quoted form
		set cd_command to "cd " & a_folder
	end if
	
	set a_command to my _command
	if my _commandOption is not "" then
		set a_command to a_command & space & my _commandOption
	end if
	set a_flag to false
	tell current application's class "NSUserDefaults"'s standardUserDefaults()
		set a_flag to boolForKey_("useExecCommand") as boolean
	end tell
	if a_flag then
		set a_command to "exec " & a_command
	end if
	--log cdCommand & lineFeed & theScriptCommand
	--log "end buildInteractiveCommand"
	return cd_command & linefeed & a_command
end interactive_command

on build_command()
	--build cd command
	set a_folder to my _target_file's parent_folder()'s posix_path()'s quoted form
	set cd_command to "cd " & a_folder
	
	--build the command for script execution
	if my _preOption is not in my _invalidValues then
		set a_command to my _preOption & space & my _command
	else
		set a_command to my _command
	end if
	
	if my _commandOption is not in my _invalidValues then
		set a_command to a_command & space & my _commandOption
	end if
	
	set qname to my _target_file's item_name()'s quoted form
	if " %f" is in a_command then
		set a_command to XText's make_with(a_command)'s replace("%f", qname)'s as_unicode()
	else
		set a_command to a_command & space & qname
	end if
	if my _commandArg is not in my _invalidValues then
		set a_command to a_command & space & my _commandArg
	end if
	
	if my _postOption is not in my _invalidValues then
		set a_command to a_command & space & my _postOption
	end if
	
	return cd_command & linefeed & a_command
	
end build_command

on make_for_file(a_xfile, a_command)
	script CommandBuilder
		property _command : a_command
		property _target_file : a_xfile
		property _postOption : ""
		property _preOption : ""
		property _commandOption : ""
		property _commandArg : ""
		property _invalidValues : {"", missing value}
	end script
	
	return CommandBuilder
end make_for_file
