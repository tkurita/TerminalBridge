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

on copyItem(sourceItem, saveLocation, newName)
	set tmpFolder to path to temporary items
	tell application "Finder"
		set theItem to (duplicate sourceItem to tmpFolder with replacing) as alias
		set name of theItem to newName
		return (move theItem to saveLocation with replacing) as alias
	end tell
end copyItem