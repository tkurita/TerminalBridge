on isExists(filePath)
	try
		filePath as alias
		return true
	on error
		return false
	end try
end isExists

on isRunning(appName)
	tell application "System Events"
		return exists application process appName
	end tell
end isRunning