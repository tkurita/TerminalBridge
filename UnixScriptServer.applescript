property LibraryFolder : "IGAGURI HD:Users:tkurita:Factories:Script factory:ProjectsX:Perl mode for mi:Library Scripts:"
property PathAnalyzer : load script file (LibraryFolder & "PathAnalyzer")
property TerminalCommander : load script file (LibraryFolder & "TerminalCommander")
property StringEngine : StringEngine of TerminalCommander

property lifeTime : 60 -- minutes
property FreeTime : 0
property isLaunched : false
property DialogOwner : missing value

property dQ : ASCII character 34
property yenmark : ASCII character 92
property lineFeed : ASCII character 10

property FactorySetting : missing value
property TerminalSettingObj : missing value
property UtilityHandlers : missing value
property MessageUtility : missing value

property ScriptListObj : missing value
property PerlPaletteObj : missing value
property PerlExecuter : missing value
property PerlScriptObj : missing value

--global perlScriptFile, perlOptions, outputOption

(* events of application*)

on importScript(scriptName)
	tell main bundle
		set scriptPath to path for script scriptName extension "scpt"
	end tell
	return load script POSIX file scriptPath
end importScript

on initilize()
	if not isLaunched then
		set FactorySetting to importScript("FactorySetting")
		set UtilityHandlers to importScript("UtilityHandlers")
		set MessageUtility to importScript("MessageUtility")
		set TerminalSettingObj to importScript("TerminalSettingObj")
		
		set PerlExecuter to importScript("PerlExecuter")
		set PerlScriptObj to importScript("PerlScriptObj")
		
		set terminalSettingBox of TerminalSettingObj to box "TerminalSetting" of window "Setting"
		loadSettings() of TerminalSettingObj
		loadSettings()
		center window "Setting"
		set isLaunched to true
	end if
end initilize

on launched theObject
	initilize()
	(*debug code*)
	--show window "PerlPalette"
	--show window "Setting"
	--outputToClipboard()
	--RunInTerminal()
	--runWithFSToClipboard()
	--checkSyntax()
	(*end of debug code*)
end launched

on open theCommandID
	initilize()
	
	if theCommandID is "checkSyntax" then
		checkSyntax() of PerlScriptObj
	else if theCommandID is "runDebugMode" then
		runDebugMode() of PerlScriptObj
	else if theCommandID is "runWithFinderSelection" then
		runWithFinderSelection() of PerlScriptObj
	else if theCommandID is "runWithFSToClipboard" then
		runWithFSToClipboard() of PerlScriptObj
	else if theCommandID is "outputToClipboard" then
		outputToClipboard() of PerlScriptObj
	else if theCommandID is "RunInTerminal" then
		RunInTerminal() of PerlScriptObj
	else if theCommandID is "setting" then
		activate
		show window "Setting"
	else if theCommandID is "ShowPerlPalette" then
		show window "PerlPalette"
	else if theCommandID is "Help" then
		call method "showHelp:"
	end if
	
	--display dialog theCommandID
	set FreeTime to 0
	return true
end open

on idle theObject
	set FreeTime to FreeTime + 1
	if FreeTime > lifeTime then
		quit
	end if
	return 60
end idle

on will open theObject
	set theName to name of theObject
	if theName is "Setting" then
		setSettingToWindow() of TerminalSettingObj
		tell theObject
			set contents of text field "PerlCommand" to perlCommand of PerlExecuter
			set contents of text field "LifeTime" to lifeTime as integer
		end tell
		setColorsToWindow() of TerminalSettingObj
	else if theName is "PerlPalette" then
		initilize(theObject) of ScriptListObj
		
		if selectedItem of PerlPaletteObj is missing value then
			readPaletteDefaults() of PerlPaletteObj
			applyPaletteDefaults(theObject) of PerlPaletteObj
		end if
		
	end if
end will open

on clicked theObject
	set theName to name of theObject
	if theName is "OKButton" then
		saveSettingsFromWindow() of TerminalSettingObj
		saveSettingsFromWindow()
		hide window of theObject
	else if theName is "CancelButton" then
		hide window of theObject
	else if theName is "ApplyColors" then
		applyColorsToTerminal() of TerminalSettingObj
	else if theName is "RevertColors" then
		revertColorsToTerminal() of TerminalSettingObj
	else if theName is "Save" then
		saveSettingsFromWindow() of TerminalSettingObj
		saveSettingsFromWindow()
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
	else if theName is "PerlPalette" then
		show window "PerlPalette"
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
	
	if theName is "PerlPalette" then
		set hides when deactivated of theObject to false
		--set floating of theObject to true
		set PerlPaletteObj to importScript("PerlPaletteObj")
		
	else if theName is "scriptDataSource" then
		set ScriptListObj to importScript("ScriptListObj")
		tell theObject
			make new data column at the end of the data columns with properties {name:"name"}
		end tell
	end if
end awake from nib

on will quit theObject
	writePaletteDefaults(window "PerlPalette") of PerlPaletteObj
end will quit

on double clicked theObject
	tell application "mi"
		set theText to content of selection object 1 of front document
	end tell
	set theList to every paragraph of theText
	startStringEngine() of StringEngine
	set theText to joinStringList of StringEngine for theList by lineFeed
	stopStringEngine() of StringEngine
	set the clipboard to theText
	
	set sourceItem to getSelectedScript() of ScriptListObj
	if alias of (info for sourceItem) then
		try
			tell application "Finder"
				set sourceItem to original item of sourceItem
			end tell
		on error number -1728 -- no original alias file
			set sourceItem to missing value
			display dialog "No original Item for the alias file." attached to window "PerlPalette" buttons {"OK"} default button "OK" with icon 0
			return false
		end try
	end if
	
	runForClipboardContents(sourceItem) of PerlScriptObj
end double clicked


on dialog ended theObject with reply theReply
	if DialogOwner is "RenameScript" then
		doRename(theReply) of ScriptListObj
	else if DialogOwner is "NewScript" then
		makeNewScript(theReply) of ScriptListObj
	end if
end dialog ended

(* read and write defaults ===============================================*)

on loadSettings()
	--commands
	set perlCommand to readDefaultValue("PerlCommand", perlCommand of PerlExecuter) of UtilityHandlers
	
	set lifeTime to readDefaultValue("LifeTime", lifeTime) of UtilityHandlers
end loadSettings

on writeSettings()
	tell user defaults
		set contents of default entry "PerlCommand" to perlCommand of PerlExecuter
		set contents of default entry "LifeTime" to lifeTime
	end tell
end writeSettings
(* end : read and write defaults ===============================================*)

(* handlers get values from window ===============================================*)
on saveSettingsFromWindow() -- get all values from and window and save into preference
	tell window "Setting"
		
		set perlCommand of PerlExecuter to contents of text field "PerlCommand"
		
		set theLifeTime to (contents of text field "LifeTime") as string
		if theLifeTime is not "" then
			set lifeTime to theLifeTime as integer
		end if
	end tell
	
	writeSettings()
end saveSettingsFromWindow

(* end: handlers get values from window ===============================================*)

