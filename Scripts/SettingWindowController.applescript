global TerminalSettings
global appController

property WindowController : missing value
property targetWindow : missing value

on initilize()
	set WindowController to call method "alloc" of class "SettingWindowController"
	set WindowController to call method "initWithWindowNibName:" of WindowController with parameter "Setting"
	set targetWindow to call method "window" of WindowController
end initilize

on open_window()
	--log "start open_window in SettingWindowController"
	if WindowController is missing value then
		initilize()
	end if
	activate
	call method "showWindow:" of WindowController
end open_window
