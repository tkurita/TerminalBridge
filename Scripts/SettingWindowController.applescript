global TerminalSettings
global appController

property WindowController : missing value
property targetWindow : missing value

on initilize()
	tell current application
		tell class "SettingWindowController"'s alloc()
			set WindowController to initWithWindowNibName_("Setting")
		end tell
	end tell
	set targetWindow to WindowController's |window|()
end initilize

on open_window()
	--log "start open_window in SettingWindowController"
	if WindowController is missing value then
		initilize()
	end if
	activate
	WindowController's showWindow_(me)
end open_window
