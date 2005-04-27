global StringEngine

on importScript(scriptName)
	tell main bundle
		set scriptPath to path for script scriptName extension "scpt"
	end tell
	return load script POSIX file scriptPath
end importScript

on loadPlistDictionary(baseName)
	tell main bundle
		set plistFile to path for resource baseName extension "plist"
	end tell
	return call method "dictionaryWithContentsOfFile:" of class "NSDictionary" with parameter plistFile
end loadPlistDictionary

on getKeyValue for entryName from dictionaryValue
	return call method "objectForKey:" of dictionaryValue with parameter entryName
	--return call method "valueForKey:" of dictionaryValue with parameter entryName
end getKeyValue

on stripHeadTailSpaces(theText)
	if theText starts with space then
		set theText to stripHeadTailSpaces(text 2 thru -1 of theText)
	else if theText ends with space then
		set theText to stripHeadTailSpaces(text 1 thru -2 of theText)
	else
		return theText
	end if
end stripHeadTailSpaces

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

on deleteListItem for theItem from theList
	set nList to length of theList
	repeat with ith from 1 to nList
		if theItem is item ith of theList then
			if ith is 1 then
				set theList to rest of theList
				exit repeat
			else if ith is nList
				set theList to item 1 thru -2 of theList
				exit repeat
			else
				set theList to (item 1 thru (ith -1) of theList)&(item (ith + 1) thru -1 of theList)
				exit repeat
			end if
		end if
	end repeat
	return theList
end deleteListItem

on getLocalizedString given keyword:theKeyword, insertTexts:insertList
	--log "start getLocalizedString"
	set theText to localized string theKeyword
	--log theKeyword & ":" & theText
	repeat with ith from 1 to (length of insertList)
		set insertText to item ith of insertList
		tell StringEngine
			startStringEngine() of it
			set theText to uTextReplace of it for theText from "$" & (ith as Unicode text) by insertText
			stopStringEngine() of it
		end tell
	end repeat
	--log "end getLocalizedString"
	return theText
end getLocalizedString
