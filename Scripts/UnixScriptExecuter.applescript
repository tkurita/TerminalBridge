global TerminalCommander
global TerminalClient
global UtilityHandlers
global StringEngine
global EditorClient

(* constants of result of checkTerminalStatus *)
property kTerminalReady : "TerminalReady"
property kShowTerminal : "ShowTerminal"
property kCancel : "Cancel"

on makeObj(theCommandBuilder)
	--log "start makeObj in UnixScriptExecuter"
	script UnixScriptExecuter
		property _commandBuilder : theCommandBuilder
		property processName : missing value
		property _targetTerminal : missing value
		property _commandPrompt : missing value
		property _options : missing value
		
		(*** common handlers ***)
		on setOptions(theVal)
			--log "start setOptions"
			set my _options to theVal
			setPrompt(getValue of _options given forKey:"prompt")
			setCleanCommands(getValue of _options given forKey:"process")
			_commandBuilder's setPostOption(getValue of _options given forKey:"output")
			
			set interactiveCommand to getValue of _options given forKey:"interactive"
			if interactiveCommand is not missing value then
				_commandBuilder's setCommand(interactiveCommand)
			end if
			
			--log "end setOptions"
		end setOptions
		
		on setRunOptions(optionRecord)
			_commandBuilder's setRunOptions(optionRecord)
		end setRunOptions
		
		on updateScriptFile(theFile)
			_commandBuilder's setScriptFile(theFile)
		end updateScriptFile
		
		on bringToFront given allowBusyStatus:isAllowBusy
			if getTargetTerminal of (my _targetTerminal) given allowBusyStatus:isAllowBusy then
				return bringToFront() of (my _targetTerminal)
			else
				return false
			end if
		end bringToFront
		
		(*** handlers for interactive mode ***)
		(*!
		== checkTerminalStatus
		Check busy status of a terminal window. 
		When the terminal window is busy, it will ask next actions of "cancel", "open new term" and "show the term" to user
		process setting of _tergetTerminal is concerned.
		
		=== Parameter 
		* checkCount -- a number of trial after 1 sec delay.
		
		=== Result
		boolean -- true when the terminal is not busy or a new terminal is opened.
		*)
		on checkTerminalStatus(checkCount)
			--log "start checkTerminalStatus"
			set theResult to kTerminalReady
			if (contents of default entry "useExecCommand" of user defaults) then
				set processList to getProcesses() of my _targetTerminal
			else
				set processList to getProcessesOnShell() of my _targetTerminal
			end if
			--log processList
			if isBusy() of my _targetTerminal then
				--log "targetTermianl is Busy "
				tell StringEngine
					storeDelimiter()
					set supportProcesses to everyTextItem from my processName by ";"
					restoreDelimiter()
				end tell
				--log supportProcesses
				set newProcesses to {}
				repeat with theItem in processList
					if theItem is not in supportProcesses then
						set end of newProcesses to contents of theItem
					end if
				end repeat
				
				if length of newProcesses is 0 then
					if checkCount < 3 then
						delay 1
						return checkTerminalStatus(checkCount + 1)
					end if
				end if
				
				tell StringEngine
					storeDelimiter()
					set processTexts to joinUTextList for newProcesses by return
					restoreDelimiter()
				end tell
				
				set termName to getTerminalName() of my _targetTerminal
				set theMessage to getLocalizedString of UtilityHandlers given keyword:"cantExecCommand", insertTexts:{termName, processTexts}
				set buttonList to {localized string "cancel", localized string "openTerm", localized string "showTerm"}
				set theMessageResult to showMessageWithButtons(theMessage, buttonList, item 3 of buttonList) of EditorClient
				--log "after showMessageWithButtons"
				set theReturned to button returned of theMessageResult
				if theReturned is item 3 of buttonList then
					bringToFront() of my _targetTerminal
					set theResult to kShowTerminal
				else if theReturned is item 2 of buttonList then
					set theResult to openNewTerminal()
					if theResult then
						set theResult to kTermianlReady
					else
						set theResult to kCancel
					end if
				else
					set theResult to kCancel
				end if
			else
				if (processList is {}) then
					set theResult to openNewTerminal()
					if theResult then
						set theResult to kTermianlReady
					else
						set theResult to kCancel
					end if
				end if
			end if
			--log "end of checkTerminalStatus"
			return theResult
		end checkTerminalStatus
		
		on setTargetTerminal given title:theCustomTitle, ignoreStatus:isIgnoreStatus
			--log "start setTargetTerminal"
			set theResult to true
			copy TerminalCommander to my _targetTerminal
			tell my _targetTerminal
				forgetTerminal()
				setCustomTitle(theCustomTitle)
				setCleanCommands(processName)
				setWindowCloseAction("2")
			end tell
			(* -- 2006.10.06 必ず、terminal window を確保する必要があるのか？
			set theCommand to my buildInteractiveCommand()
			--log "after buildInteractiveCommand"
			set theCommand to cleanYenmark(theCommand) of UtilityHandlers
			--log "after cleanYenmark"
			if getTargetTerminal of (my _targetTerminal) with allowBusyStatus then
				if not isIgnoreStatus then
					set theResult to checkTerminalStatus(0)
				end if
			else
				set theResult to doCommands of (my _targetTerminal) for theCommand without activation
			end if
			*)
			--log "end setTargetTerminal"
			return theResult
		end setTargetTerminal
		
		on clenupCommandText(theCommand)
			set theCommand to StringEngine's stripHeadTailSpaces(theCommand)
			set theCommand to cleanYenmark(theCommand) of UtilityHandlers
			return theCommand
		end clenupCommandText
		
		--on sendCommand(theCommand)
		on sendCommand for theCommand given allowBusyStatus:isBusyAllowed
			--log "start sendCommand in executer"
			set theCommand to clenupCommandText(theCommand)
			set escapeChars to getValue of _options given forKey:"escapeChars"
			if escapeChars is not missing value then
				tell StringEngine
					storeDelimiter()
					repeat with theChar in escapeChars
						set theCommand to uTextReplace for theCommand from theChar by (backslash of UtilityHandlers) & theChar
					end repeat
					restoreDelimiter()
				end tell
			end if
			
			if getTargetTerminal of (my _targetTerminal) given allowBusyStatus:isBusyAllowed then
				--log "before checkTerminalStatus in sendCommand in executer"
				set the_result to checkTerminalStatus(0)
				if the_result is kTerminalReady then
					--log "will doCmdInCurrentTerm"
					--log theCommand
					doCmdInCurrentTerm of (my _targetTerminal) for theCommand without activation
				else if the_result is kShowTerminal then
					set the clipboard to theCommand
				else
					return false
				end if
			else
				openNewTermForCommand(theCommand)
			end if
			
			--log "end sendCommand"
			return true
		end sendCommand
		
		on getLastResult()
			--log "start getLastResult in UnixScriptExecuter"
			if not (getTargetTerminal of (my _targetTerminal) without allowBusyStatus) then
				error "No Terminal found." number 1640
				return missing value
			end if
			
			set theContents to my _targetTerminal's getContents()
			set theResult to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {theContents, my _commandPrompt}
			
			if theResult is -1 then
				set theContents to my _targetTerminal's getHistory()
				set theResult to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {theContents, my _commandPrompt}
			end if
			
			if theResult is not 1 then
				return missing value
			end if
			
			--log "end getLastResult in UnixScriptExecuter"
			return call method "lastResultWithCR" of TerminalClient
		end getLastResult
		
		on openNewTerminal()
			--log "start openNewTerminal"
			set interactiveCommand to _commandBuilder's buildInteractiveCommand()
			set interactiveCommand to UtilityHandlers's cleanYenmark(interactiveCommand)
			--log interactiveCommand
			return doCmdInNewTerm of (my _targetTerminal) for interactiveCommand without activation
		end openNewTerminal
		
		on openNewTermForCommand(theCommand)
			--log "start openNewTermForCommand"
			set interactiveCommand to _commandBuilder's buildInteractiveCommand()
			set interactiveCommand to UtilityHandlers's cleanYenmark(interactiveCommand)
			set interactiveCommand to interactiveCommand & return & theCommand
			--log interactiveCommand
			return doCmdInNewTerm of (my _targetTerminal) for interactiveCommand without activation
		end openNewTermForCommand
		
		on setPrompt(thePrompt)
			--log "start setPrompt"
			if thePrompt is not missing value then
				set my _commandPrompt to thePrompt
			end if
			--log "end setPrompt"
		end setPrompt
		
		on setCleanCommands(theProcesses)
			set processName to theProcesses & ";" & (contents of default entry "CleanCommands" of user defaults)
		end setCleanCommands
		
		(*** handlers for shell mode ***)
		on runScript given activation:activateFlag
			set allCommand to _commandBuilder's buildCommand()
			doCommands of TerminalCommander for allCommand given activation:activateFlag
			beep
		end runScript
		
		on sendCommandInCommonTerm for theCommand given activation:activateFlag
			set theCommand to clenupCommandText(theCommand)
			doCommands of TerminalCommander for theCommand given activation:activateFlag
			beep
		end sendCommandInCommonTerm
	end script
end makeObj