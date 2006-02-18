global TerminalSettingObj
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
	set currentTab to current tab view item of tab view "SettingTabs" of my targetWindow
	set theName to name of currentTab
	if theName is "TerminalSetting" then
		revertToFactorySetting() of TerminalSettingObj
	else if theName is "CommandAndProcess" then
		call method "revertToFactoryDefaultForKey:" of appController with parameter "CleanCommands"
		call method "revertToFactoryDefaultForKey:" of appController with parameter "ModeDefaults"
	end if
	selectedTab(currentTab)
end RevertToDefault

on selectedTab(tabViewItem)
	set theName to name of tabViewItem
	if theName is "TerminalSetting" then
		loadTerminalSetting(tabViewItem)
	end if
end selectedTab

on loadTerminalSetting(theView)
	if not isLoadedTerminalSetting then
		setSettingToWindow(theView) of TerminalSettingObj
		set isLoadedTerminalSetting to true
	end if
end loadTerminalSetting
