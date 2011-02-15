property XText : module
property XList : module
property XFile : module
property XDict : module
property TerminalCommanderBase : module "TerminalCommander"
property loader : boot (module loader of application (get "UnixScriptToolsLib")) for me

property TerminalCommander : missing value
property TerminalSettings : missing value
property UtilityHandlers : missing value
property MessageUtility : missing value
property appController : missing value

property ExecuterController : missing value
property UnixScriptExecuter : missing value
property UnixScriptController : missing value
property SettingWindowController : missing value
property CommandBuilder : missing value
property EditorClient : missing value
property TerminalClient : missing value

(*shared constants *)
property linefeed : ASCII character 10
property backslash : ASCII character 128

(* events of application*)
on import_script(scriptName)
	--log "start import_script"
	--log scriptName
	tell main bundle
		set scriptPath to path for script scriptName extension "scpt"
	end tell
	--log "end import_script"
	return load script POSIX file scriptPath
end import_script

on launched theObject
	hide window "Startup"
	(*debug code*)
	--show_interactive_terminal() of UnixScriptController
	--log "start launched"
	--open_window() of SettingWindowController
	--last_result() of UnixScriptController
	--open {commandID:"runWithFinderSelection", argument:{postOption:"|pbcopy"}}
	--UnixScriptController's send_selection({lineEndEscape:{backslash, "..."}})
	--run_in_terminal(missing value) of UnixScriptController
	--runWithFSToClipboard()
	--send_selection(missing value) of UnixScriptController
	--checkSyntax()
	(*end of debug code*)
end launched

on open theObject
	if class of theObject is record then
		try
			set command_class to commandClass of theObject
		on error
			return true
		end try
		if command_class is "action" then
			theObject's commandScript's do(me)
		end if
	end if
	--display dialog command_id
	return true
end open

on choose menu item theObject
	set a_name to name of theObject
	if a_name is "Preference" then
		show window "Setting"
	end if
end choose menu item

on will finish launching theObject
	--log "start will finish launching"	
	showStartupMessage("Loading Scripts ...")
	--set appController to call method "delegate"
	set appController to call method "sharedAppController" of class "AppController"
	set UtilityHandlers to import_script("UtilityHandlers")
	set MessageUtility to import_script("MessageUtility")
	set TerminalCommander to buildup() of (import_script("TerminalCommander"))
	tell TerminalCommander
		set_custom_title(call method "factoryDefaultForKey:" of appController with parameter "CustomTitle")
	end tell
	
	set UnixScriptExecuter to import_script("UnixScriptExecuter")
	set CommandBuilder to import_script("CommandBuilder")
	set ExecuterController to import_script("ExecuterController")
	ExecuterController's initialize()
	set UnixScriptController to import_script("UnixScriptController")
	
	set SettingWindowController to import_script("SettingWindowController")
	set EditorClient to import_script("EditorClient")
	--log "end of import_scripts"
	
	--showStartupMessage("Loading Preferences ...")
	--log "before loadSetting() of TerminalSettings"
	--log "end of initializing TerminalSettings"
	
	--log "end finish launching"
end will finish launching

on showStartupMessage(msg)
	set contents of text field "StartupMessage" of window "Startup" to msg
end showStartupMessage

