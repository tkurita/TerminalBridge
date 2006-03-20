on showErrorInFrontmostApp(errNum, errMsg)
	set errorLabel to localized string "errorLabel"
	set theMessage to errorLabel & space & errNum & return & (name of current application) & " : " & errMsg
	using terms from application "System Events" -- without this statemet, display dialog means a showing panel intead of display dialog command in Standard Additions.
		tell application (path to frontmost application as Unicode text)
			display dialog theMessage buttons {"OK"} default button "OK" with icon caution
		end tell
	end using terms from
end showErrorInFrontmostApp

on showError(errNum, errPlace, errMsg)
	activate
	set errorLabel to localized string "errorLabel"
	set theMessage to errorLabel & space & errNum & " in " & errPlace & return & errMsg
	display dialog theMessage buttons {"OK"} default button "OK" with icon 0
end showError

on showMessage(theMessage)
	activate
	display dialog theMessage buttons {"OK"} default button "OK" with icon note
end showMessage

on showMessageOnmi(theMessage)
call method "activateAppOfType:" of class "SmartActivate" with parameter "MMKE"
	tell application "mi"
		display dialog theMessage buttons {"OK"} default button "OK" with icon note
	end tell
end showMessageOnmi