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
property WindowController : missing value


(*shared constants *)
property dQ : ASCII character 34
property yenmark : ASCII character 92
property lineFeed : ASCII character 10
property idleTime : 60 -- sec

(* shared variable *)
property isShouldShow : false
property FreeTime : 0 -- second
property DialogOwner : missing value
-- property miAppRef : missing value

(* application setting *)
property lifeTime : missing value -- second

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
	hide window "Startup"
	(*debug code*)
	--log "start launched"
	--openWindow() of SettingWindowObj
	--open {commandID:"runWithFinderSelection", argument:{postOption:"|pbcopy"}}
	--RunInTerminal()
	--runWithFSToClipboard()
	--checkSyntax()
	(*end of debug code*)
end launched

on open theObject
	if class of theObject is record then
		set FreeTime to 0
		
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
			openWindow() of SettingWindowObj
		else if theCommandID is "Help" then
			call method "showHelp:"
		end if
		
	end if
	--display dialog theCommandID
	return true
end open

on idle theObject
	--log "start idle"
	
	if (FreeTime) > lifeTime then
		quit
	end if
	
	set FreeTime to FreeTime + idleTime
	
	return idleTime
end idle

on clicked theObject
	set FreeTime to 0
	set theName to name of theObject
	(* buttons of Setting Window *)
	if theName is "OKButton" then
		saveSettingsFromWindow() of SettingWindowObj
		closeWindow() of SettingWindowObj
	else if theName is "CancelButton" then
		closeWindow() of SettingWindowObj
	else if theName is "ApplyColors" then
		applyColorsToTerminal() of TerminalSettingObj
	else if theName is "RevertColors" then
		revertColorsToTerminal() of TerminalSettingObj
	else if theName is "Save" then
		saveSettingsFromWindow() of SettingWindowObj
		(* buttons of FilterPalette *)
	end if
end clicked

on choose menu item theObject
	set theName to name of theObject
	if theName is "Preference" then
		show window "Setting"
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
	if theName is "Setting" then
		--set floating of theObject to true
	end if
	--log "end awake from nib"
end awake from nib

on double clicked theObject
	set FreeTime to 0
	runFilterScript() of ScriptListObj
end double clicked

on will finish launching theObject
	--log "start will finish launching"
	showStartupMessage("Loading Factory Settings ...")
	set DefaultsManager to importScript("DefaultsManager")
	loadFactorySettings("FactorySettings") of DefaultsManager
	
	showStartupMessage("Loading Scripts ...")
	set UtilityHandlers to importScript("UtilityHandlers")
	set MessageUtility to importScript("MessageUtility")
	set TerminalSettingObj to importScript("TerminalSettingObj")
	
	set UnixScriptExecuter to importScript("UnixScriptExecuter")
	set UnixScriptObj to importScript("UnixScriptObj")
	
	set WindowController to importScript("WindowController")
	set SettingWindowObj to importScript("SettingWindowObj")
	set SettingWindowObj to makeObj("Setting") of SettingWindowObj
	
	--log "end of importScripts"
	
	showStartupMessage("Loading Preferences ...")
	--log "before loadSetting() of TerminalSettingObj"
	loadSettings() of TerminalSettingObj
	--log "end of initializing TerminalSettingObj"
	loadSettings()
	--set miAppRef to path to application "mi" as alias
	--log "end finish launching"
end will finish launching

on will close theObject
	set theName to name of theObject
	
	if theName is "Setting" then
		prepareClose() of SettingWindowObj
	end if
end will close

on should zoom theObject proposed bounds proposedBounds
	set FreeTime to 0
	set theName to name of theObject
	if theName is "Setting" then
		return toggleCollapseWIndow() of SettingWindowObj
	end if
end should zoom

on will resize theObject proposed size proposedSize
	return size of theObject
end will resize

on will open theObject
	--log "start will open"
	set theName to name of theObject
	
	if theName is "Startup" then
		set level of theObject to 1
		center theObject
		set alpha value of theObject to 0.7
	end if
	--log "end will open"
end will open

on loadSettings()
	set lifeTime to (readDefaultValue("LifeTime") of DefaultsManager)
end loadSettings

on showStartupMessage(theMessage)
	set contents of text field "StartupMessage" of window "Startup" to theMessage
end showStartupMessage

