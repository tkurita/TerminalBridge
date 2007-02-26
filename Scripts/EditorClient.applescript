global StringEngine

property parent : loadLib("miClient") of application (get "UnixScriptToolsLib")

on saveWithAsking()
	set doYouSaveText to localized string "doYouSave"
	tell application "mi"
		set theName to name of document 1
	end tell
	
	tell StringEngine
		storeDelimiter()
		set docIsModified to insertTexts for {theName} into (localized string "docIsModified")
		restoreDelimiter()
	end tell
	
	tell application "mi"
		try
			set theResult to display dialog (docIsModified & return & doYouSaveText)
		on error number -128
			return false
		end try
		save document 1
		return true
	end tell
end saveWithAsking

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
