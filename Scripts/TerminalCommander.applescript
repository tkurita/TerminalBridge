global TerminalCommanderBase

on buildup()
	script TerminalCommanderExtend
		property parent : TerminalCommanderBase
		
		on send_command for a_command
			--log "before boolForKey in send_command"
			tell current application's class "NSUserDefaults"
				tell its standardUserDefaults()
					set activate_flag to boolForKey_("ActivateTerminal") as boolean
				end tell
			end tell
            do_with({command:a_command, with_activation:activate_flag})
		end send_command
		
		on activate_terminal()
            tell current application's class "NSRunningApplication"
                activateAppOfIdentifier_("com.apple.Terminal")
            end tell
			return true
		end activate_terminal
		
		on execution_string()
			--log "start execution_string"
			tell current application's class "NSUserDefaults"
				tell its standardUserDefaults()
					set exec_string to stringForKey_("ExecutionString") as text
				end tell
			end tell
			if exec_string is "" then
				set exec_string to missing value
			end if
			return exec_string
		end execution_string
		
		on custom_title()
			return continue custom_title()
		end custom_title

        on settings_name()
			--log "start settings_name"
			set a_name to missing value
			if my _delegate is not missing value then
				set a_name to my _delegate's settings_name()
			end if
			if a_name is missing value then
				tell current application's class "NSUserDefaults"
					tell its standardUserDefaults()
						set a_name to stringForKey_("SettingsSetName")
					end tell
				end tell
			end if
			if a_name is not missing value then
				set a_name to a_name as text
			end if
			return a_name
		end settings_name
	end script
	return TerminalCommanderExtend
end buildup