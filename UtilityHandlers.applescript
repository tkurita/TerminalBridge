on isExists(filePath)
	try
		filePath as alias
		return true
	on error
		return false
	end try
end isExists

on initializeDefaultValue(entryName, defaultValue)
	tell user defaults
		if not (exists default entry entryName) then
			make new default entry at end of default entries with properties {name:entryName, contents:defaultValue}
		end if
	end tell
end initializeDefaultValue

on readDefaultValue(entryName, defaultValue)
	tell user defaults
		if exists default entry entryName then
			return contents of default entry entryName
		else
			make new default entry at end of default entries with properties {name:entryName, contents:defaultValue}
			return defaultValue
		end if
	end tell
end readDefaultValue

on isRunning(appName)
	tell application "System Events"
		return exists application process appName
	end tell
end isRunning