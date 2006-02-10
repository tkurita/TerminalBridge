global TerminalCommander
global appController

property terminalSettingBox : missing value

on controlClicked(theObject)
	set theName to name of theObject
	--log theName
	if theName is "ApplyColors" then
		applyColorsToTerminal()
	else if theName is "RevertColors" then
		revertColorsToTerminal()
	else if theName is "SaveColors" then
		getColorSettingsFromWindow()
		writeColorSettings()
	end if
end controlClicked

on revertToFactoryColorSettings()
	tell TerminalCommander
		set isChangeBackground of it to call method "factoryDefaultForKey:" of appController with parameter "IsChangeBackground"
		set backgroundColor of it to call method "factoryDefaultForKey:" of appController with parameter "BackgroundColor"
		set terminalOpaqueness of it to call method "factoryDefaultForKey:" of appController with parameter "TerminalOpaqueness"
		set isChangeNormalText of it to call method "factoryDefaultForKey:" of appController with parameter "IsChangeNormalText"
		set normalTextColor of it to call method "factoryDefaultForKey:" of appController with parameter "NormalTextColor"
		set isChangeBoldText of it to call method "factoryDefaultForKey:" of appController with parameter "IsChangeBoldText"
		set boldTextColor of it to call method "factoryDefaultForKey:" of appController with parameter "BoldTextColor"
		set isChangeCursor of it to call method "factoryDefaultForKey:" of appController with parameter "IsChangeCursor"
		set cursorColor of it to call method "factoryDefaultForKey:" of appController with parameter "CursorColor"
		set isChangeSelection of it to call method "factoryDefaultForKey:" of appController with parameter "IsChangeSelection"
		set selectionColor of it to call method "factoryDefaultForKey:" of appController with parameter "SelectionColor"
	end tell
end revertToFactoryColorSettings

on revertToFactorySetting()
	call method "revertToFactoryDefaultForKey:" of appController with parameter "Shell"
	call method "revertToFactoryDefaultForKey:" of appController with parameter "UseCtrlVEscapes"
	call method "revertToFactoryDefaultForKey:" of appController with parameter "ShellMode"
	call method "revertToFactoryDefaultForKey:" of appController with parameter "ExecutionString"
	
	--colors
	revertToFactoryColorSettings()
	
	writeSettings()
end revertToFactorySetting

on loadColorSettings()
	tell user defaults
		set isChangeBackground of TerminalCommander to contents of default entry "IsChangeBackground"
		set backgroundColor of TerminalCommander to contents of default entry "BackgroundColor"
		set terminalOpaqueness of TerminalCommander to contents of default entry "TerminalOpaqueness"
		set isChangeNormalText of TerminalCommander to contents of default entry "IsChangeNormalText"
		set normalTextColor of TerminalCommander to contents of default entry "NormalTextColor"
		set isChangeBoldText of TerminalCommander to contents of default entry "IsChangeBoldText"
		set boldTextColor of TerminalCommander to contents of default entry "BoldTextColor"
		set isChangeCursor of TerminalCommander to contents of default entry "IsChangeCursor"
		set cursorColor of TerminalCommander to contents of default entry "CursorColor"
		set isChangeSelection of TerminalCommander to contents of default entry "IsChangeSelection"
		set selectionColor of TerminalCommander to contents of default entry "SelectionColor"
	end tell
end loadColorSettings

on loadSettings()
	--log "start loadSettings of TerminalSettingObj"
	tell TerminalCommander
		set customTitle of it to call method "factoryDefaultForKey:" of appController with parameter "CustomTitle"
		set stringEncoding of it to call method "factoryDefaultForKey:" of appController with parameter "StringEncoding"
	end tell
	--colors
	loadColorSettings()
	
	--TerminalCommander Setting
	set displayShellPath of TerminalCommander to false
	set displayCustomTitle of TerminalCommander to true
	set displayDeviceName of TerminalCommander to true
end loadSettings

on writeSettings()
	writeColorSettings()
end writeSettings

on writeColorSettings()
	tell user defaults
		set contents of default entry "IsChangeBackground" to isChangeBackground of TerminalCommander
		set contents of default entry "BackgroundColor" to backgroundColor of TerminalCommander
		set contents of default entry "TerminalOpaqueness" to terminalOpaqueness of TerminalCommander
		set contents of default entry "IsChangeNormalText" to isChangeNormalText of TerminalCommander
		set contents of default entry "NormalTextColor" to normalTextColor of TerminalCommander
		set contents of default entry "IsChangeBoldText" to isChangeBoldText of TerminalCommander
		set contents of default entry "BoldTextColor" to boldTextColor of TerminalCommander
		set contents of default entry "IsChangeCursor" to isChangeCursor of TerminalCommander
		set contents of default entry "CursorColor" to cursorColor of TerminalCommander
		set contents of default entry "IsChangeSelection" to isChangeSelection of TerminalCommander
		set contents of default entry "SelectionColor" to selectionColor of TerminalCommander
	end tell
end writeColorSettings

on getColorSettingsFromWindow()
	tell box "TerminalColors" of terminalSettingBox
		set isChangeBackground of TerminalCommander to (state of button "BackSwitch" is 1)
		if isChangeBackground of TerminalCommander then
			set backgroundColor of TerminalCommander to color of color well "BackgroundColor"
			set terminalOpaqueness of TerminalCommander to contents of slider "BackTransparency"
		end if
		
		set isChangeNormalText of TerminalCommander to (state of button "NormalSwitch" is 1)
		if isChangeNormalText of TerminalCommander then
			set normalTextColor of TerminalCommander to color of color well "NormalTextColor"
		end if
		
		set isChangeBoldText of TerminalCommander to (state of button "BoldSwitch" is 1)
		if isChangeBoldText of TerminalCommander then
			set boldTextColor of TerminalCommander to color of color well "BoldTextColor"
		end if
		
		set isChangeCursor of TerminalCommander to (state of button "CursorSwitch" is 1)
		if isChangeCursor of TerminalCommander then
			set cursorColor of TerminalCommander to color of color well "cursorColor"
		end if
		
		set isChangeSelection of TerminalCommander to (state of button "SelectionSwitch" is 1)
		if isChangeSelection of TerminalCommander then
			set selectionColor of TerminalCommander to color of color well "selectionColor"
		end if
	end tell
end getColorSettingsFromWindow

on setColorsToWindow()
	--log "start setColorsToWindow"
	tell box "TerminalColors" of terminalSettingBox
		
		if isChangeBackground of TerminalCommander then
			set state of button "BackSwitch" to 1
			set enabled of color well "BackgroundColor" to true
			set enabled of slider "BackTransparency" to true
			set color of color well "BackgroundColor" to backgroundColor of TerminalCommander
			set contents of slider "BackTransparency" to terminalOpaqueness of TerminalCommander
		else
			set state of button "BackSwitch" to 0
			set enabled of color well "BackgroundColor" to false
			set enabled of slider "BackTransparency" to false
		end if
		
		if isChangeNormalText of TerminalCommander then
			set state of button "NormalSwitch" to 1
			set enabled of color well "NormalTextColor" to true
			set color of color well "NormalTextColor" to normalTextColor of TerminalCommander
		else
			set state of button "NormalSwitch" to 0
			set enabled of color well "NormalTextColor" to false
		end if
		
		if isChangeBoldText of TerminalCommander then
			set state of button "BoldSwitch" to 1
			set enabled of color well "BoldTextColor" to true
			set color of color well "BoldTextColor" to boldTextColor of TerminalCommander
		else
			set state of button "BoldSwitch" to 0
			set enabled of color well "BoldTextColor" to false
		end if
		
		if isChangeCursor of TerminalCommander then
			set state of button "CursorSwitch" to 1
			set enabled of color well "CursorColor" to true
			set color of color well "CursorColor" to cursorColor of TerminalCommander
		else
			set state of button "CursorSwitch" to 0
			set enabled of color well "CursorColor" to false
		end if
		
		if isChangeSelection of TerminalCommander then
			set state of button "SelectionSwitch" to 1
			set enabled of color well "SelectionColor" to true
			set color of color well "SelectionColor" to selectionColor of TerminalCommander
		else
			set state of button "SelectionSwitch" to 0
			set enabled of color well "SelectionColor" to false
		end if
	end tell
end setColorsToWindow

on setSettingToWindow(theView)
	--log "start setSettingToWindow"
	set terminalSettingBox to theView
	setColorsToWindow()
end setSettingToWindow

on applyColorsToTerminal()
	getColorSettingsFromWindow()
	if not applyTerminalColors() of TerminalCommander then
		doCommands of TerminalCommander for "echo Test colors" with activation
	end if
end applyColorsToTerminal

on revertColorsToTerminal()
	loadColorSettings()
	setColorsToWindow()
	if not applyTerminalColors() of TerminalCommander then
		doCommands of TerminalCommander for "echo Test colors" with activation
	end if
end revertColorsToTerminal