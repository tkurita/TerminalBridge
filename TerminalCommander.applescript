(*
property LibraryFolder : "IGAGURI HD:Users:tkurita:Factories:Script factory:LibrariesX:TerminalCommander:Library Scripts:"
property StringEngine : load script file (LibraryFolder & "StringEngine")
*)
global StringEngine
--property linefeed : ASCII character 10

--terminal defaults set from applescript
property customTitle : missing value
property displayShellPath : missing value
property displayCustomTitle : missing value
property displayDeviceName : missing value
property stringEncoding : missing value

--terminal appearance
property isChangeBackground : false
property terminalOpaqueness : missing value
property backgroundColor : missing value
property isChangeNormalText : false
property normalTextColor : missing value
property isChangeBoldText : false
property boldTextColor : missing value
property isChangeCursor : false
property cursorColor : missing value
property isChangeSelection : false
property selectionColor : missing value

--public properties
property terminalName : missing value
property terminalReference : missing value

--internal parameter
property isTerminalLaunched : missing value
property defaultObjList : {}
property numWindow : missing value

on writeTerminalPref(theKey, theValue)
	if theValue is not missing value then
		do shell script "defaults write com.apple.Terminal " & theKey & space & "'" & theValue & "'"
	end if
end writeTerminalPref

on readTerminalPref(theKey)
	return do shell script "defaults read com.apple.Terminal " & theKey
end readTerminalPref

on deleteTerminalPref(theKey)
	do shell script "defaults delete com.apple.Terminal " & theKey
end deleteTerminalPref

on normalizeColor(theColor)
	set normalizedColor to {}
	repeat with theItem in theColor
		set end of normalizedColor to theItem / 65535
	end repeat
	return normalizedColor
end normalizeColor

on changeDefaultTerminalColor()
	try
		set thePreTextColors to readTerminalPref("TextColors")
		set theExistsEntry to true
	on error
		set thePreTextColors to "0.000 0.000 0.000 1.000 1.000 1.000 0.000 0.000 0.000 0.000 0.000 0.000 1.000 1.000 1.000 0.000 0.000 0.000 0.666 0.666 0.666 0.333 0.333 0.333"
		set theExistsEntry to false
	end try
	startStringEngine() of StringEngine
	set theColorList to everyTextItem of StringEngine from thePreTextColors by space
	set theIsChangedColors to false
	
	if (normalTextColor is missing value) or (not isChangeNormalText) then
		set newNormalTextColor to items 1 thru 3 of theColorList
	else
		set theIsChangedColors to true
		set newNormalTextColor to normalizeColor(normalTextColor)
	end if
	
	if (backgroundColor is missing value) or (not isChangeBackground) then
		set newBackgroundColor to items 4 thru 6 of theColorList
	else
		set newBackgroundColor to normalizeColor(backgroundColor)
		set theIsChangedColors to true
	end if
	
	if (boldTextColor is missing value) or (not isChangeBoldText) then
		set newBoldTextColor to items 7 thru 9 of theColorList
	else
		set newBoldTextColor to normalizeColor(boldTextColor)
		set theIsChangedColors to true
	end if
	
	if (selectionColor is missing value) or (not isChangeSelection) then
		set newSelectionColor to items 19 thru 21 of theColorList
	else
		set newSelectionColor to normalizeColor(selectionColor)
		set theIsChangedColors to true
	end if
	
	if (cursorColor is missing value) or (not isChangeCursor) then
		set newcursorColor to items 22 thru 24 of theColorList
	else
		set newcursorColor to normalizeColor(cursorColor)
		set theIsChangedColors to true
	end if
	
	if theIsChangedColors then
		set newTextColors to newNormalTextColor & newBackgroundColor & newBoldTextColor & newBoldTextColor & newBackgroundColor & newNormalTextColor & newSelectionColor & newcursorColor
		set newTextColors to joinStringList of StringEngine for newTextColors by space
		writeTerminalPref("TextColors", newTextColors)
	end if
	
	stopStringEngine() of StringEngine
	
	script TerminalColorObj
		property preTextColors : thePreTextColors
		property isChangedColors : theIsChangedColors
		property existsEntry : theExistsEntry
		
		on revertColors()
			if isChangedColors then
				if existsEntry then
					writeTerminalPref("TextColors", preTextColors)
				else
					deleteTerminalPref("TextColors")
				end if
			end if
		end revertColors
		
	end script
	return TerminalColorObj
end changeDefaultTerminalColor

on entryDefaultsObj(theKey, theValue)
	script defaultObj
		property entryName : theKey
		property newValue : theValue
		property preValue : missing value
		property existsEntry : true
		
		on setDefaultValue()
			try
				set preValue to readTerminalPref(entryName)
			on error
				set existsEntry to false
			end try
			
			writeTerminalPref(entryName, newValue)
		end setDefaultValue
		
		on revertDefaultValue()
			if existsEntry then
				writeTerminalPref(entryName, preValue)
			else
				deleteTerminalPref(entryName)
			end if
			
		end revertDefaultValue
	end script
	
	if theValue is not missing value then
		setDefaultValue() of defaultObj
		set end of defaultObjList to defaultObj
	end if
end entryDefaultsObj

on changeTerminalPref()
	set defaultObjList to {}
	set theShellPath to getShellPath()
	entryDefaultsObj("Shell", theShellPath)
	set useCtrlVEscapes to contents of default entry "UseCtrlVEscapes" of user defaults
	entryDefaultsObj("UseCtrlVEscapes", useCtrlVEscapes)
	entryDefaultsObj("StringEncoding", stringEncoding)
	--entryDefaultsObj("CustomTitle", customTitle)
	--entryDefaultsObj("ExecutionString", executionString)
	if (terminalOpaqueness is not missing value) and isChangeBackground then
		entryDefaultsObj("TerminalOpaqueness", terminalOpaqueness / 65535)
	end if
end changeTerminalPref

on revertTerminalPref()
	repeat with theDefaultObj in defaultObjList
		revertDefaultValue() of theDefaultObj
	end repeat
end revertTerminalPref

on getShellPath()
	set shellMode to contents of default entry "ShellMode" of user defaults
	if (shellMode is 0) then
		return system attribute "SHELL"
	else
		set shellPath to contents of default entry "Shell" of user defaults
		if (shellPath is "") then
			return system attribute "SHELL"
		else
			return shellPath
		end if
	end if
end getShellPath

on doCommands for shellCommands given activation:activateFlag
	if getTargetTerminal without allowBusyStatus then
		tell application "Terminal"
			set frontmost of terminalReference to true
		end tell
		
		if activateFlag then
			call method "smartActivate:" with parameter "trmx"
		end if
		
		tell application "Terminal"
			do script shellCommands in terminalReference
		end tell
	else
		my changeTerminalPref()
		set theTerminalColorObj to my changeDefaultTerminalColor()
		
		tell application "Terminal"
			if isTerminalLaunched then
				set numWindow to count window
			else
				set numWindow to 0
				if activateFlag then
					activate
					set activateFlag to false
				else
					launch
				end if
			end if
		end tell
		
		set executionString to contents of default entry "ExecutionString" of user defaults
		if executionString is not "" then
			set terminalReference to execCommand(executionString & return & shellCommands)
		else
			set terminalReference to execCommand(shellCommands)
		end if
		
		applyTtitleStetting()
		revertTerminalPref()
		revertColors() of theTerminalColorObj
		if activateFlag then
			call method "smartActivate:" with parameter "trmx"
		end if
	end if
end doCommands

on waitNewWindow()
	repeat
		tell application "Terminal"
			set currentNumWin to count window
		end tell
		if currentNumWin is not numWindow then
			exit repeat
		end if
		--log "waiting new window "
		delay 1
	end repeat
end waitNewWindow

on execCommand(theCommands)
	tell application "Terminal"
		if isTerminalLaunched then
			do script theCommands
			my waitNewWindow()
		else
			do script theCommands in window 1
		end if
		return window 1
	end tell
end execCommand

on registTerminal(theWindow)
	set terminalReference to theWindow
	tell application "Terminal"
		set terminalName to name of theWindow
	end tell
end registTerminal

on getTargetTerminal given allowBusyStatus:isBusyAllowed
	tell application "System Events"
		set isTerminalLaunched to exists application process "Terminal"
	end tell
	
	if not isTerminalLaunched then
		set terminalReference to missing value
		return false
	end if
	
	tell application "Terminal"
		if exists terminalReference then
			--if name of terminalReference is terminalName then
			if isBusyAllowed then
				return true
			else if not (busy of terminalReference) then
				return true
			end if
			--end if
		end if
	end tell
	
	set terminalReference to missing value
	return findTerminalByCustomTitle given allowBusyStatus:isBusyAllowed
end getTargetTerminal

--find terminal window by custom title
on findTerminalByCustomTitle given allowBusyStatus:isBusyAllowed
	if customTitle is missing value then
		return false
	end if
	
	set successToFind to false
	tell application "Terminal"
		set nWin to count windows
		repeat with ith from 1 to nWin
			set theTitle to custom title of window ith
			if theTitle is customTitle then
				if isBusyAllowed then
					set successToFind to true
					my registTerminal(window ith)
					exit repeat
				else if not (busy of window ith) then
					my registTerminal(window ith)
					set successToFind to true
					exit repeat
				end if
			end if
		end repeat
	end tell
	return successToFind
end findTerminalByCustomTitle

on applyTerminalColors()
	if not (getTargetTerminal with allowBusyStatus) then
		return false
	end if
	
	tell application "Terminal"
		if (normalTextColor is not missing value) and (isChangeNormalText) then
			set normal text color of terminalReference to normalTextColor
		end if
		if (backgroundColor is not missing value) and (isChangeBackground) then
			set background color of terminalReference to backgroundColor & {terminalOpaqueness}
		end if
		if (boldTextColor is not missing value) and (isChangeBoldText) then
			set bold text color of terminalReference to boldTextColor
		end if
		
		if (cursorColor is not missing value) or (isChangeCursor) then
			set cursor color of terminalReference to cursorColor
		end if
	end tell
	return true
end applyTerminalColors

on applyTtitleStetting()
	tell application "Terminal"
		tell terminalReference
			if customTitle is not missing value then
				set custom title to customTitle
			end if
			if displayShellPath is not missing value then
				set title displays shell path to displayShellPath
			end if
			if displayCustomTitle is not missing value then
				set title displays custom title to displayCustomTitle
			end if
			if displayDeviceName is not missing value then
				set title displays device name to displayDeviceName
			end if
		end tell
		
		set terminalName to name of terminalReference
	end tell
end applyTtitleStetting

on waitEndOfCommand(timeLimit)
	set beforeTimeLimit to false
	delay 1
	set totalDelay to 1
	tell application "Terminal"
		if exists terminalReference then
			repeat while (totalDelay is less than or equal to timeLimit)
				if busy of terminalReference then
					delay 1
					set totalDelay to totalDelay + 1
					--display dialog "busy"
				else
					--display dialog "free"
					set beforeTimeLimit to true
					exit repeat
				end if
			end repeat
		else
			display dialog "A window " & terminalName & " does not exist"
		end if
	end tell
	return beforeTimeLimit
end waitEndOfCommand
