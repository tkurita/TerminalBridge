(* shared script objects *)
property LibraryFolder : "IGAGURI HD:Users:tkurita:Factories:Script factory:ProjectsX:UnixScriptTools for mi:Library Scripts:"
property PathAnalyzer : load script file (LibraryFolder & "PathAnalyzer")
property TerminalCommander : load script file (LibraryFolder & "TerminalCommander")
property StringEngine : StringEngine of TerminalCommander

property TerminalSettingObj : missing value
property UtilityHandlers : missing value
property MessageUtility : missing value
property DefaultsManager : missing value

property ScriptListObj : missing value
property FilterPaletteObj : missing value
property UnixScriptExecuter : missing value
property UnixScriptObj : missing value
property SettingWindowObj : missing value
property WindowControllerBase : missing value


(*shared constants *)
property dQ : ASCII character 34
property yenmark : ASCII character 92
property lineFeed : ASCII character 10
property idleTime : 1

(* shared variable *)
property isShouldShow : false
property FreeTime : 0 -- second
property DialogOwner : missing value
-- property miAppRef : missing value

(* application setting *)
property lifeTime : 60 -- minutes

(* events of application*)

on importScript(scriptName)
	--log "start importScript"
	--log scriptName
	tell main bundle
		set scriptPath to path for script scriptName extension "scpt"
	end tell
	--log "end importScript"
	return load script POSIX file scriptPath
end importScript

on launched theObject
	(*debug code*)
	--log "start launched"
	--openWindow(window "UnixFilters") of FilterPaletteObj
	--openWindow(window "Setting") of SettingWindowObj
	--open {commandID:"runWithFinderSelection", argument:{postOption:"|pbcopy"}}
	--RunInTerminal()
	--runWithFSToClipboard()
	--checkSyntax()
	(*end of debug code*)
end launched

on open theObject
	if class of theObject is record then
		set theCommandID to commandID of theObject
		try
			set optionRecord to argument of theObject
		on error
			set optionRecord to missing value
		end try
		
		if theCommandID is "runWithFinderSelection" then
			runWithFinderSelection(optionRecord) of UnixScriptObj
		else if theCommandID is "RunInTerminal" then
			RunInTerminal(optionRecord) of UnixScriptObj
		else if theCommandID is "setting" then
			openWindow(window "Setting") of SettingWindowObj
		else if theCommandID is "ShowUnixFilters" then
			openWindow(window "UnixFilters") of FilterPaletteObj
		else if theCommandID is "Help" then
			call method "showHelp:"
		end if
		set FreeTime to 0
	end if
	--display dialog theCommandID
	return true
end open

on idle theObject
	--log "start idle"
	
	if (FreeTime / 60) > lifeTime then
		quit
	end if
	
	if (isOpened of FilterPaletteObj) then
		set frontAppPath to path to frontmost application as Unicode text
		set isShouldShow to (frontAppPath ends with ":UnixScriptServer.app:") or (frontAppPath ends with ":mi:")
		updateVisibility(isShouldShow) of FilterPaletteObj
		--updateVisibility(isShouldShow) of SettingWindowObj
	else
		set FreeTime to FreeTime + idleTime
		
	end if
	return idleTime
end idle

on clicked theObject
	set theName to name of theObject
	(* buttons of Setting Window *)
	if theName is "OKButton" then
		saveSettingsFromWindow() of TerminalSettingObj
		saveSettingsFromWindow()
		closeWindow() of SettingWindowObj
	else if theName is "CancelButton" then
		closeWindow() of SettingWindowObj
	else if theName is "ApplyColors" then
		applyColorsToTerminal() of TerminalSettingObj
	else if theName is "RevertColors" then
		revertColorsToTerminal() of TerminalSettingObj
	else if theName is "Save" then
		saveSettingsFromWindow() of TerminalSettingObj
		saveSettingsFromWindow()
		(* buttons of FilterPalette *)
	else if theName is "EditScript" then
		set theScript to getSelectedScript() of ScriptListObj
		tell application "Finder"
			open theScript
		end tell
	else if theName is "RenameScript" then
		renameScript() of ScriptListObj
		
	else if theName is "NewScript" then
		set enterNewScriptNameMsg to localized string "enterNewScriptName"
		newScript(enterNewScriptNameMsg) of ScriptListObj
	end if
end clicked

on choose menu item theObject
	set theName to name of theObject
	if theName is "Preference" then
		show window "Setting"
	else if theName is "UnixFilters" then
		show window "UnixFilters"
	else if theName is "OpenScriptFolder" then
		set theFolder to (getContainer() of ScriptSorter of ScriptListObj)
		tell application "Finder"
			activate
			open theFolder
		end tell
	end if
end choose menu item

on awake from nib theObject
	set theName to name of theObject
	--log "start awake from nib for " & theName
	if theName is "UnixFilters" then
		set hides when deactivated of theObject to false
		set floating of theObject to true
		
	else if theName is "scriptDataSource" then
		tell theObject
			make new data column at the end of the data columns with properties {name:"name"}
		end tell
	else if theName is "Setting" then
		--set floating of theObject to true
	end if
	--log "end awake from nib"
end awake from nib

on double clicked theObject
	runFilterScript() of ScriptListObj
end double clicked

on dialog ended theObject with reply theReply
	if DialogOwner is "RenameScript" then
		doRename(theReply) of ScriptListObj
	else if DialogOwner is "NewScript" then
		makeNewScript(theReply) of ScriptListObj
	end if
end dialog ended

on will finish launching theObject
	--log "start will finish launching"
	set DefaultsManager to importScript("DefaultsManager")
	loadFactorySettings("FactorySettings") of DefaultsManager
	
	set UtilityHandlers to importScript("UtilityHandlers")
	set MessageUtility to importScript("MessageUtility")
	set TerminalSettingObj to importScript("TerminalSettingObj")
	
	set UnixScriptExecuter to importScript("UnixScriptExecuter")
	set UnixScriptObj to importScript("UnixScriptObj")
	
	set ScriptListObj to importScript("ScriptListObj")
	set WindowControllerBase to importScript("WindowControllerBase")
	set SettingWindowObj to importScript("SettingWindowObj")
	set SettingWindowObj to makeObj() of SettingWindowObj
	set FilterPaletteObj to importScript("FilterPaletteObj")
	set FilterPaletteObj to makeObj() of FilterPaletteObj
	
	log "end of importScripts"
	
	set terminalSettingBox of TerminalSettingObj to box "TerminalSetting" of window "Setting"
	log "before loadSetting() of TerminalSettingObj"
	loadSettings() of TerminalSettingObj
	log "end of initializing TerminalSettingObj"
	loadSettings()
	--center window "Setting"
	--set miAppRef to path to application "mi" as alias
	log "end finish launching"
end will finish launching

on will close theObject
	set theName to name of theObject
	if theName is "UnixFilters" then
		prepareClose() of FilterPaletteObj
	else if theName is "Setting" then
		prepareClose() of SettingWindowObj
	end if
end will close

on should zoom theObject proposed bounds proposedBounds
	set theName to name of theObject
	if theName is "Setting" then
		return toggleCollapseWIndow of SettingWindowObj
	else if theName is "UnixFilters" then
		return toggleCollapsePanel of FilterPaletteObj
	end if
end should zoom

on will resize theObject proposed size proposedSize
	return size of theObject
end will resize

on will open theObject
	(*Add your script here.*)
end will open

on loadSettings()
	--commands
	set lifeTime to readDefaultValue("LifeTime") of DefaultsManager
end loadSettings

on writeSettings()
	tell user defaults
		set contents of default entry "LifeTime" to lifeTime
	end tell
end writeSettings

on saveSettingsFromWindow() -- get all values from and window and save into preference
	tell window "Setting"
		set theLifeTime to (contents of text field "LifeTime") as string
		if theLifeTime is not "" then
			set lifeTime to theLifeTime as integer
		end if
	end tell
	
	writeSettings()
end saveSettingsFromWindow
