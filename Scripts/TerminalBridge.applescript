property NSRunningApplication : class "NSRunningApplication"

script TerminalBridgeController
	property parent : class "NSObject"
	
	property XText : "@module"
	property XList : "@module"
	property XFile : "@module"
	property PathInfo : "@module"
	property XDict : "@module"
	property TerminalCommanderBase : "@module TerminalCommander"
	property _ : (application (get "UnixScriptToolsLib"))'s loader()'s setup(me)
	
	property TerminalCommander : missing value
	property UtilityHandlers : missing value
	
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
	
	(* IB outlets *)
	property appController : missing value
	property startupMessageField : missing value
	
	on import_script(a_name)
		--log "start import_script"
		set a_script to load script (path to resource a_name & ".scpt")
		return a_script
	end import_script
	
	on performDebug()
		UnixScriptController's show_interactive_terminal()
	end performDebug
	
	on performTask_(a_script)
		set a_script to a_script as script
		a_script's do(me)
	end performTask_
	
	on setup()
		startupMessageField's setStringValue_("Loading Scripts ...")
		set UtilityHandlers to import_script("UtilityHandlers")
		set TerminalCommander to buildup() of (import_script("TerminalCommander"))
		tell TerminalCommander
			set_custom_title(appController's factoryDefaultForKey_("CustomTitle") as text)
		end tell
		
		set UnixScriptExecuter to import_script("UnixScriptExecuter")
		set CommandBuilder to import_script("CommandBuilder")
		set ExecuterController to import_script("ExecuterController")
		ExecuterController's initialize()
		set UnixScriptController to import_script("UnixScriptController")
		
		set SettingWindowController to import_script("SettingWindowController")
		set EditorClient to import_script("EditorClient")
	end setup
	
	on activate_process(app_id)
        NSRunningApplication's activateAppOfIdentifier_(app_id)
	end activate_process
end script
