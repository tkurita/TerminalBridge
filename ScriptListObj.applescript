property LibraryFolder : "IGAGURI HD:Users:tkurita:Factories:Script factory:ProjectsX:UnixScriptTools for mi:Library Scripts:"
property FileSorter : load script file (LibraryFolder & "FileSorter")
global lineFeed
global UtilityHandlers
global DialogOwner
global StringEngine
global MessageUtility
global UnixScriptExecuter
global DefaultsManager

script ScriptSorter
	property parent : FileSorter
	
	on getTargetItems()
		set nameList to list folder my targetContainer without invisibles
		set containerPath to my targetContainer as Unicode text
		set theList to {}
		repeat with ith from 1 to length of nameList
			set end of theList to (containerPath & (item ith of nameList)) as alias
		end repeat
		return {theList, nameList}
	end getTargetItems
	
	on buildIndexArray()
		set {itemList, nameList} to getTargetItems()
		set indexList to {}
		repeat with ith from 1 to length of itemList
			set end of indexList to extractInfo(item ith of itemList)
		end repeat
		return {itemList, nameList, indexList}
	end buildIndexArray
	
	on getContainer()
		log "start getContainer"
		set thePath to (path to preferences folder from user domain as Unicode text) & "mi:UnixScriptTools:Scripts:"
		try
			set theAlias to thePath as alias
		on error errMsg number -43
			log errMsg
			set resourcePath to resource path of main bundle
			set scriptsZip to quoted form of (resourcePath & "/Scripts.zip")
			set unixScriptToolsPath to quoted form of POSIX path of ((path to preferences folder from user domain as Unicode text) & "mi:UnixScriptTools:")
			do shell script "ditto --sequesterRsrc -x -k " & scriptsZip & space & unixScriptToolsPath
			set theAlias to thePath as alias
			tell application "Finder"
				set arrangement of icon view options of container window of theAlias to snap to grid
			end tell
		end try
		return theAlias
	end getContainer
	
	on sortDirectionOfIconView()
		return "column direction"
	end sortDirectionOfIconView
end script

property scriptList : missing value
property lastRebuildDate : missing value
property lastScriptName : missing value
property selectedDataRow : missing value
property selectedItemAlias : missing value
property scriptListDataSource : missing value
property scriptFolder : missing value
property scriptTable : missing value
property targetWindow : missing value

on initialize(theWindow)
	log "start initilize of ScriptListObj"
	set scriptFolder to getContainer() of ScriptSorter
	set targetWindow to theWindow
	set scriptTable to table view "ScriptList" of scroll view "ScriptList" of theWindow
	set scriptListDataSource to data source of scriptTable
	if scriptList is missing value then
		readScriptList()
	else
		updateScriptList()
	end if
end initialize

on copyItem(sourceItem, saveLocation, newName)
	set tmpFolder to path to temporary items
	tell application "Finder"
		set theItem to (duplicate sourceItem to tmpFolder with replacing) as alias
		set name of theItem to newName
		set creator type of theItem to "MMKE"
		set file type of theItem to "TEXT"
		return (move theItem to saveLocation with replacing) as alias
	end tell
end copyItem

on getSelectedScript()
	set selectedDataRow to selected data row of scriptTable
	try
		set lastScriptName to contents of data cell "Name" of selectedDataRow
	on error number -2753
		set noSelectionMsg to localized string "noSelection"
		display dialog noSelectionMsg attached to window "UnixFilters" buttons {"OK"} default button "OK" with icon 0
		error number -128
	end try
	set selectedItemAlias to ((scriptFolder as Unicode text) & lastScriptName) as alias
	if alias of (info for selectedItemAlias) then
		try
			tell application "Finder"
				set selectedItemAlias to original item of selectedItemAlias
			end tell
		on error number -1728 -- no original alias file
			set theMessage to localized string "noOriginalItem"
			display dialog theMessage attached to window "UnixFilters" buttons {"OK"} default button "OK" with icon 0
			error "No Original item for the filter script." number 1630
		end try
	end if
	return selectedItemAlias
end getSelectedScript

on makeNewScript(theReply)
	set theButton to button returned of theReply
	set newName to text returned of theReply
	if (theButton is "OK") then
		set scriptFolderPath to scriptFolder as Unicode text
		if isExists(scriptFolderPath & newName) of UtilityHandlers then
			set isExistsMsg to localized string "isExists"
			set theMessage to newName & space & isExistsMsg
			newScript(theMessage)
			return
		else
			set resourcePath to resource path of main bundle
			set sourceItem to (POSIX file (resourcePath & "/scripttemplate.pl")) as alias
			set targetItem to copyItem(sourceItem, scriptFolder, newName)
			rebuild()
			tell application "Finder"
				open targetItem
			end tell
		end if
	end if
	set DialogOwner to missing value
end makeNewScript

on newScript(theMessage)
	set DialogOwner to "NewScript"
	set theReply to display dialog theMessage attached to targetWindow default answer "Untitled.pl"
end newScript

on doRename(theReply)
	set theButton to button returned of theReply
	set newName to text returned of theReply
	if (theButton is "OK") and (newName is not lastScriptName) then
		tell application "System Events"
			set name of selectedItemAlias to newName
		end tell
		set contents of data cell "Name" of selectedDataRow to newName
	end if
	set DialogOwner to missing value
end doRename

on renameScript()
	getSelectedScript()
	set enterNewNameMsg to localized string "enterNewName"
	set DialogOwner to "RenameScript"
	set theReply to display dialog enterNewNameMsg attached to targetWindow default answer lastScriptName
end renameScript

on readScriptList()
	--log "start readScriptList"
	if exists default entry "lastRebuildDate" of user defaults then
		set lastRebuildDate to contents of default entry "lastRebuildDate" of user defaults
		tell application "System Events"
			set currentModDate to modification date of scriptFolder
		end tell
		--display dialog (lastRebuildDate as string) & return & (currentModDate as string)
		
		if lastRebuildDate > currentModDate then
			set scriptList to readDefaultValueWith("scriptList", scriptList) of DefaultsManager
			append scriptListDataSource with scriptList
		else
			rebuild()
			writeScriptList()
		end if
		
	else
		rebuild()
		makeScriptListDefaults()
	end if
end readScriptList

on updateScriptList()
	set scriptFolder to getContainer() of ScriptSorter
	tell application "System Events"
		set currentModDate to modification date of scriptFolder
	end tell
	if lastRebuildDate > currentModDate then
		return false
	else
		rebuild()
		return true
	end if
end updateScriptList

on makeScriptListDefaults()
	make new default entry at end of default entries of user defaults with properties {name:"scriptList", contents:scriptList}
	make new default entry at end of default entries of user defaults with properties {name:"lastRebuildDate", contents:current date}
end makeScriptListDefaults

on rebuild()
	set {itemList, nameList, indexList} to sortByView() of ScriptSorter
	set scriptList to {}
	repeat with ith from 1 to length of nameList
		set end of scriptList to {|name|:item ith of nameList}
	end repeat
	delete (every data row of scriptListDataSource)
	append scriptListDataSource with scriptList
end rebuild

on writeScriptList()
	set contents of default entry "scriptList" of user defaults to scriptList
	set contents of default entry "lastRebuildDate" of user defaults to current date
end writeScriptList

on runFilterScript()
	log "start runFilterScript"
	(*get input data from mi*)
	tell application "mi"
		set theText to content of selection object 1 of front document
	end tell
	set theList to every paragraph of theText
	set beginning of theList to "<<EndOfData"
	set end of theList to "EndOfData"
	startStringEngine() of StringEngine
	set theText to joinStringList of StringEngine for theList by lineFeed
	stopStringEngine() of StringEngine
	--set the clipboard to theText
	
	set theScriptFile to getSelectedScript()
	set theFilterScriptExecuter to newFilterScriptExecuter of UnixScriptExecuter from theScriptFile
	set postOption of theFilterScriptExecuter to theText
	set theResult to runScript() of theFilterScriptExecuter
	
	if theResult is not "" then
		set useNewWindow to ((state of cell "InNewWindow" of matrix "ResultMode" of targetWindow) is on state)
		if useNewWindow then
			set docTitle to lastScriptName & "-stdout-" & ((current date) as string)
			tell application "mi"
				make new document with data theResult with properties {name:docTitle}
				--set asksaving of document docTitle to false
			end tell
		else
			tell application "mi"
				set content of selection object 1 of document 1 to theResult
			end tell
		end if
	end if
	beep
end runFilterScript