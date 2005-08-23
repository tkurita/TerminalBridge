(* shared script objects *)
property LibraryFolder : "IGAGURI HD:Users:tkurita:Factories:Script factory:ProjectsX:UnixScriptTools for mi:Library Scripts:"
property PathAnalyzer : load script file (LibraryFolder & "PathAnalyzer")
property StringEngine : load script file (LibraryFolder & "StringEngine")

property TerminalCommander : missing value
property TerminalSettingObj : missing value
property UtilityHandlers : missing value
property MessageUtility : missing value
property DefaultsManager : missing value

property UnixScriptExecuter : missing value
property UnixScriptObj : missing value
property SettingWindowObj : missing value
property CommandBuilder : missing value

(*shared constants *)
property dQ : ASCII character 34
property yenmark : ASCII character 92
property lineFeed : ASCII character 10


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

on clicked theObject
	--log "start clicked"
	set theTag to tag of theObject
	if theTag is 1 then
		controlClicked(theObject) of TerminalSettingObj
	else if theTag is 5 then
		(* 5: Other Setting *)
		controlClicked(theObject) of SettingWindowObj
	else
		controlClicked(theObject)
	end if
end clicked

on controlClicked(theObject)
	set theName to name of theObject
	--set windowName to name of window of theObject
	if theName is "RevertToDefault" then
		RevertToDefault() of SettingWindowObj
	end if
end controlClicked

on choose menu item theObject
	set theName to name of theObject
	if theName is "Preference" then
		show window "Setting"
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

on will finish launching theObject
	--log "start will finish launching"
	showStartupMessage("Loading Factory Settings ...")
	set DefaultsManager to importScript("DefaultsManager")
	registerFactorySetting("FactorySettings") of DefaultsManager
	
	showStartupMessage("Loading Scripts ...")
	set UtilityHandlers to importScript("UtilityHandlers")
	set MessageUtility to importScript("MessageUtility")
	set TerminalCommander to importScript("TerminalCommander")
	set TerminalSettingObj to importScript("TerminalSettingObj")
	
	set CommandBuilder to importScript("CommandBuilder")
	set UnixScriptExecuter to importScript("UnixScriptExecuter")
	set UnixScriptObj to importScript("UnixScriptObj")
	
	set SettingWindowObj to importScript("SettingWindowObj")
	
	--log "end of importScripts"
	
	showStartupMessage("Loading Preferences ...")
	--log "before loadSetting() of TerminalSettingObj"
	loadSettings() of TerminalSettingObj
	--log "end of initializing TerminalSettingObj"
	
	--log "end finish launching"
end will finish launching

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

on end editing theObject
	--log "start end editing"
	set theTag to tag of theObject
	if theTag is 1 then
		endEditing(theObject) of TerminalSettingObj
	end if
end end editing

on showStartupMessage(theMessage)
	set contents of text field "StartupMessage" of window "Startup" to theMessage
end showStartupMessage

