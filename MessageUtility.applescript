on showError(errNum, errMsg)
	activate
	set errorLabel to localized string "errorLabel"
	set theMessage to errorLabel & space & errNum & return & errMsg
	display dialog theMessage buttons {"OK"} default button "OK" with icon caution
end showError

on showMessage(theMessage)
	activate
	display dialog theMessage buttons {"OK"} default button "OK" with icon note
end showMessage

on showMessageOnmi(theMessage)
	tell application "mi"
		activate
		display dialog theMessage buttons {"OK"} default button "OK" with icon note
	end tell
end showMessageOnmi