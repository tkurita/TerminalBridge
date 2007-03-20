global StringEngine

property parent : load("miClient") of application (get "UnixScriptToolsLib")

on save_with_asking()
	set do_you_save_msg to localized string "doYouSave"
	
	tell application "mi"
		set a_name to name of document 1
	end tell
	
	tell StringEngine
		store_delimiters()
		set doc_modified_msg to formated_text given template:(localized string "docIsModified"), args:{a_name}
		restore_delimiters()
	end tell
	
	tell application "mi"
		try
			set a_result to display dialog (doc_modified_msg & return & do_you_save_msg)
		on error number -128
			return false
		end try
		save document 1
		return true
	end tell
end save_with_asking

on showMessageWithAsk(theMessage)
	call method "activateAppOfType:" of class "SmartActivate" with parameter "MMKE"
	tell application "mi"
		try
			display dialog theMessage
		on error
			return false
		end try
	end tell
	return true
end showMessageWithAsk

on showMessageWithButtons(theMessage, buttonList, defaultButton)
	call method "activateAppOfType:" of class "SmartActivate" with parameter "MMKE"
	tell application "mi"
		try
			set theResult to display dialog theMessage buttons buttonList default button defaultButton
		on error
			set theResult to {button returned:missing value}
		end try
	end tell
	return theResult
end showMessageWithButtons

on showMessage(msg)
	call method "activateAppOfType:" of class "SmartActivate" with parameter "MMKE"
	tell application "mi"
		display alert msg
	end tell
end showMessage
