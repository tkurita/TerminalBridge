global TerminalSettingObj

property WindowController : missing value
property targetWindow : missing value

on initilize()
	set WindowController to call method "alloc" of class "SettingWindowController"
	set WindowController to call method "initWithWindowNibName:" of WindowController with parameter "Setting"
	set targetWindow to call method "window" of WindowController
	applyDefaults()
end initilize

on openWindow()
	--log "start openWIndow in SettingWindowObj"
	if WindowController is missing value then
		initilize()
	end if
	activate
	call method "showWindow:" of WindowController
end openWindow

on RevertToDefault()
	--log "start RevertToDefault"
	revertToFactorySetting() of TerminalSettingObj
	applyDefaults()
end RevertToDefault

on applyDefaults()
	--set terminalSettingBox of TerminalSettingObj to box "TerminalSetting" of window "Setting"
	setSettingToWindow(box "TerminalSetting" of targetWindow) of TerminalSettingObj
	--log "end of applyDefaults in SettingWindowObj"
end applyDefaults

on saveSettingsFromWindow() -- get all values from and window and save into preference
	saveSettingsFromWindow() of TerminalSettingObj
end saveSettingsFromWindow
