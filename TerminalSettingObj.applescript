global TerminalCommander
global UtilityHandlers

property terminalSettingBox : missing value
property FactorySetting : missing value

on loadColorSettings()
	set isChangeBackground of TerminalCommander to readDefaultValue("IsChangeBackground", isChangeBackground of FactorySetting) of UtilityHandlers
	set backgroundColor of TerminalCommander to readDefaultValue("BackgroundColor", backgroundColor of FactorySetting) of UtilityHandlers
	set terminalOpaqueness of TerminalCommander to readDefaultValue("TerminalOpaqueness", terminalOpaqueness of FactorySetting) of UtilityHandlers
	set isChangeNormalText of TerminalCommander to readDefaultValue("IsChangeNormalText", isChangeNormalText of FactorySetting) of UtilityHandlers
	set normalTextColor of TerminalCommander to readDefaultValue("NormalTextColor", normalTextColor of FactorySetting) of UtilityHandlers
	set isChangeBoldText of TerminalCommander to readDefaultValue("IsChangeBoldText", isChangeBoldText of FactorySetting) of UtilityHandlers
	set boldTextColor of TerminalCommander to readDefaultValue("BoldTextColor", boldTextColor of FactorySetting) of UtilityHandlers
	set isChangeCursor of TerminalCommander to readDefaultValue("IsChangeCursor", isChangeCursor of FactorySetting) of UtilityHandlers
	set cursorColor of TerminalCommander to readDefaultValue("CursorColor", cursorColor of FactorySetting) of UtilityHandlers
	set isChangeSelection of TerminalCommander to readDefaultValue("IsChangeSelection", isChangeSelection of FactorySetting) of UtilityHandlers
	set selectionColor of TerminalCommander to readDefaultValue("SelectionColor", selectionColor of FactorySetting) of UtilityHandlers
end loadColorSettings

on loadSettings(theFactorySetting)
	set FactorySetting to theFactorySetting
	
	set customTitle of TerminalCommander to customTitle of FactorySetting
	set stringEncoding of TerminalCommander to stringEncoding of FactorySetting
	set useLoginShell of TerminalCommander to readDefaultValue("UseLoginShell", useLoginShell of FactorySetting) of UtilityHandlers
	set shellPath of TerminalCommander to readDefaultValue("Shell", shellPath of FactorySetting) of UtilityHandlers
	set useCtrlVEscapes of TerminalCommander to readDefaultValue("UseCtrlVEscapes", useCtrlVEscapes of FactorySetting) of UtilityHandlers
	set executionString of TerminalCommander to readDefaultValue("ExecutionString", executionString of FactorySetting) of UtilityHandlers
	--colors
	loadColorSettings()
	
	--TerminalCommander Setting
	set displayShellPath of TerminalCommander to false
	set displayCustomTitle of TerminalCommander to true
	set displayDeviceName of TerminalCommander to true
end loadSettings

on writeSettings()
	tell user defaults
		set contents of default entry "UseLoginShell" to useLoginShell of TerminalCommander
		set contents of default entry "Shell" to shellPath of TerminalCommander
		set contents of default entry "UseCtrlVEscapes" to useCtrlVEscapes of TerminalCommander
		set contents of default entry "ExecutionString" to executionString of TerminalCommander
		--colors
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
end writeSettings

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

on saveSettingsFromWindow() -- get all values from and window and save into preference
	tell terminalSettingBox
		set useLoginShell of TerminalCommander to ((state of cell "UseLoginShell" of matrix "ShellMode") is on state)
		set theShellPath to contents of text field "ShellPath"
		if theShellPath is not "" then
			set shellPath of TerminalCommander to theShellPath
		end if
		
		if state of button "UseCtrlVEscapes" is 1 then
			set useCtrlVEscapes of TerminalCommander to "YES"
		else
			set useCtrlVEscapes of TerminalCommander to "NO"
		end if
		
		set executionString of TerminalCommander to contents of text field "ExecutionString"
		
		my getColorSettingsFromWindow()
	end tell
	
	writeSettings()
end saveSettingsFromWindow

on setColorsToWindow()
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

on setSettingToWindow()
	tell terminalSettingBox
		if useLoginShell of TerminalCommander then
			set state of cell "UseLoginShell" of matrix "ShellMode" to on state
			set state of cell "UseCommand" of matrix "ShellMode" to off state
		else
			set state of cell "UseCommand" of matrix "ShellMode" to on state
			set state of cell "UseLoginShell" of matrix "ShellMode" to off state
		end if
		
		set contents of text field "ShellPath" to shellPath of TerminalCommander
		
		if useCtrlVEscapes of TerminalCommander is "YES" then
			set state of button "UseCtrlVEscapes" to 1
		else
			set state of button "UseCtrlVEscapes" to 0
		end if
		
		set contents of text field "ExecutionString" to executionString of TerminalCommander
		
	end tell
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