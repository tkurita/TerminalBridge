(* shared script objects *)
on loadLib(theName)
	return loadLib(theName) of application (get "UnixScriptToolsLib")
end loadLib

property PathAnalyzer : loadLib("PathAnalyzer")
property StringEngine : loadLib("StringEngine")
property KeyValueDictionary : loadLib("KeyValueDictionary")
property TerminalCommanderBase : loadLib("TerminalCommander")

property TerminalCommander : missing value
property TerminalSettingObj : missing value
property UtilityHandlers : missing value
property MessageUtility : missing value
property appController : missing value

property ExecuterController : missing value
property UnixScriptExecuter : missing value
property UnixScriptObj : missing value
property SettingWindowObj : missing value
property CommandBuilder : missing value
property EditorClient : missing value
property TerminalClient : missing value

(*shared constants *)
property dQ : ASCII character 34
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
	--showInteractiveTerminal() of UnixScriptObj
	--log "start launched"
	--openWindow() of SettingWindowObj
	--getLastResult() of UnixScriptObj
	--open {commandID:"runWithFinderSelection", argument:{postOption:"|pbcopy"}}
	--RunInTerminal()
	--runWithFSToClipboard()
	--sendSelection() of UnixScriptObj
	--checkSyntax()
	(*end of debug code*)
end launched

on open theObject
	if class of theObject is record then
		set theCommandID to commandID of theObject
		try
			set theArg to argument of theObject
		on error
			set theArg to missing value
		end try
		
		if theCommandID is "runWithFinderSelection" then
			runWithFinderSelection(theArg) of UnixScriptObj
		else if theCommandID is "RunInTerminal" then
			RunInTerminal(theArg) of UnixScriptObj
		else if theCommandID is "sendSelection" then
			sendSelection() of UnixScriptObj
		else if theCommandID is "showInteractiveTerminal" then
			showInteractiveTerminal() of UnixScriptObj
		else if theCommandID is "sendCommand" then
			sendCommand(theArg) of UnixScriptObj
		else if theCommandID is "getLastResult" then
			getLastResult() of UnixScriptObj
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

on will finish launching theObject
	--log "start will finish launching"	
	showStartupMessage("Loading Scripts ...")
	--set appController to call method "delegate"
	set appController to call method "sharedAppController" of class "AppController"
	set UtilityHandlers to importScript("UtilityHandlers")
	set MessageUtility to importScript("MessageUtility")
	set TerminalCommander to makeObj() of (importScript("TerminalCommander"))
	set TerminalSettingObj to importScript("TerminalSettingObj")
	
	set UnixScriptExecuter to importScript("UnixScriptExecuter")
	set CommandBuilder to importScript("CommandBuilder")
	set ExecuterController to importScript("ExecuterController")
	ExecuterController's initialize()
	set UnixScriptObj to importScript("UnixScriptObj")
	
	set SettingWindowObj to importScript("SettingWindowObj")
	set EditorClient to importScript("EditorClient")
	--log "end of importScripts"
	
	showStartupMessage("Loading Preferences ...")
	--log "before loadSetting() of TerminalSettingObj"
	loadSettings() of TerminalSettingObj
	--log "end of initializing TerminalSettingObj"
	
	--log "end finish launching"
end will finish launching

on showStartupMessage(theMessage)
	set contents of text field "StartupMessage" of window "Startup" to theMessage
end showStartupMessage

on selected tab view item theObject tab view item tabViewItem
	selectedTab(tabViewItem) of SettingWindowObj
end selected tab view item

