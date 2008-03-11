global TerminalSettings
global appController

property WindowController : missing value
property targetWindow : missing value

property isLoadedTerminalSetting : false

on initilize()
	set WindowController to call method "alloc" of class "SettingWindowController"
	set WindowController to call method "initWithWindowNibName:" of WindowController with parameter "Setting"
	set targetWindow to call method "window" of WindowController
	selectedTab(current tab view item of tab view "SettingTabs" of my targetWindow)
	--applyDefaults()
end initilize

on open_window()
	--log "start open_window in SettingWindowController"
	if WindowController is missing value then
		initilize()
	end if
	activate
	call method "showWindow:" of WindowController
end open_window

on RevertToDefault()
	--log "start RevertToDefault"
	set currentTab to current tab view item of tab view "SettingTabs" of my targetWindow
	set a_name to name of currentTab
	if a_name is "TerminalSetting" then
		revert_to_factory_setting() of TerminalSettings
	else if a_name is "CommandAndProcess" then
		call method "revertToFactoryDefaultForKey:" of appController with parameter "CleanCommands"
		call method "revertToFactoryDefaultForKey:" of appController with parameter "ModeDefaults"
	end if
	selectedTab(currentTab)
end RevertToDefault

on selectedTab(tabViewItem)
	set a_name to name of tabViewItem
	if a_name is "TerminalSetting" then
		loadTerminalSetting(tabViewItem)
	end if
end selectedTab

on loadTerminalSetting(theView)
	if not isLoadedTerminalSetting then
		set_setting_to_window(theView) of TerminalSettings
		set isLoadedTerminalSetting to true
	end if
end loadTerminalSetting
