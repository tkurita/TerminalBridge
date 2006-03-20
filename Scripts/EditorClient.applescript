global StringEngine

on getDocumentFileAlilas()
	tell application "mi"
		set theFile to file of document 1
	end tell
	try
		return theFile as alias
	on error
		return missing value
	end try
end getDocumentFileAlilas

on getDocumentMode()
	tell application "mi"
		return mode of document 1
	end tell
end getDocumentMode

on getDocumentName()
	tell application "mi"
		return name of document 1
	end tell
end getDocumentName

on isModified()
	tell application "mi"
		return modified of document 1
	end tell
end isModified

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

on showMessage(theMessage)
	call method "activateAppOfType:" of class "SmartActivate" with parameter "MMKE"
	tell application "mi"
		display dialog theMessage buttons {"OK"} default button "OK"
	end tell
end showMessage

on getParagraph(ith)
	tell application "mi"
		tell document 1
			return paragraph ith
		end tell
	end tell
end getParagraph

on getSelection()
	tell application "mi"
		tell document 1
			return selection object 1
		end tell
	end tell
end getSelection

on getCurrentLine()
	tell application "mi"
		tell document 1
			return paragraph 1 of selection object 1
		end tell
	end tell
end getCurrentLine

on insertText(theString)
	tell application "mi"
		tell document 1
			set selection object 1 to theString
		end tell
	end tell
end insertText