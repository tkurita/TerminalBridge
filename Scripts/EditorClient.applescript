property parent : load("miClient") of application (get "UnixScriptToolsLib")

on show_message_asking(msg)
	tell current application's class "NRunningApplication"
		activateAppOfIdentifier_("net.mimikaki.mi")
	end tell
	
	tell application "mi"
		try
			display dialog msg
		on error
			return false
		end try
	end tell
	return true
end show_message_asking

on show_message_buttons(msg, button_list, default_button)
	tell current application's class "NRunningApplication"
		activateAppOfIdentifier_("net.mimikaki.mi")
	end tell
	tell application "mi"
		try
			set a_result to display dialog msg buttons button_list default button default_button
		on error
			set a_result to {button returned:missing value}
		end try
	end tell
	return a_result
end show_message_buttons

on show_message(msg)
	tell current application's class "NRunningApplication"
		activateAppOfIdentifier_("net.mimikaki.mi")
	end tell
	tell application "mi"
		display alert msg
	end tell
end show_message
