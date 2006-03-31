global TerminalCommander
global TerminalClient
global UtilityHandlers
global StringEngine
global EditorClient

on makeObj(theCommandBuilder)
	script UnixScriptExecuter
		property parent : theCommandBuilder
		property processName : missing value
		property targetTerminal : missing value
		property commandPrompt : missing value
		
		on getLastResult()
			--log "start getLastResult in UnixScriptExecuter"
			if not (getTargetTerminal of (my targetTerminal) without allowBusyStatus) then
				error "No Terminal found." number 1640
				return missing value
			end if
			
			set theContents to my targetTerminal's getContents()
			set theResult to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {theContents, my commandPrompt}
			
			if theResult is -1 then
				set theContents to my targetTerminal's getHistory()
				set theResult to call method "extactLastResult:withPrompt:" of TerminalClient with parameters {theContents, my commandPrompt}
			end if
			
			if theResult is not 1 then
				return missing value
			end if
			
			--log "end getLastResult in UnixScriptExecuter"
			return call method "lastResultWithCR" of TerminalClient
		end getLastResult
		
		on setPrompt(thePrompt)
			--log "start setPrompt"
			if thePrompt is not missing value then
				set commandPrompt to thePrompt
			end if
			--log "end setPrompt"
		end setPrompt
		
		on setCleanCommands(theProcesses)
			set processName to theProcesses & ";" & (contents of default entry "CleanCommands" of user defaults)
		end setCleanCommands
		
		on bringToFront given allowBusyStatus:isAllowBusy
			if getTargetTerminal of (my targetTerminal) given allowBusyStatus:isAllowBusy then
				return bringToFront() of (my targetTerminal)
			else
				return false
			end if
		end bringToFront
		
		on runScript given activation:activateFlag
			set allCommand to my buildCommand()
			doCommands of TerminalCommander for allCommand given activation:activateFlag
			beep
		end runScript
		
		on openNewTerminal()
			set interactiveCommand to my buildInteractiveCommand()
			set interactiveCommand to cleanYenmark(interactiveCommand) of UtilityHandlers
			return doCmdInNewTerm of targetTerminal for interactiveCommand without activation
		end openNewTerminal
		
		on openNewTermForCommand(theCommand)
			set interactiveCommand to my buildInteractiveCommand()
			set interactiveCommand to cleanYenmark(interactiveCommand) of UtilityHandlers
			set interactiveCommand to interactiveCommand & return & theCommand
			return doCmdInNewTerm of targetTerminal for interactiveCommand without activation
		end openNewTermForCommand
		
		on sendCommand(theCommand)
			--log "start sendCommand in executer"
			set theCommand to cleanYenmark(theCommand) of UtilityHandlers
			
			if getTargetTerminal of (my targetTerminal) with allowBusyStatus then
				--log "before checkTerminalStatus in sendCommand in executer"
				if checkTerminalStatus() then
					doCmdInCurrentTerm of (my targetTerminal) for theCommand without activation
				else
					return false
				end if
			else
				openNewTermForCommand(theCommand)
			end if
			
			--log "end sendCommand"
			return true
		end sendCommand
		
		on checkTerminalStatus()
			--log "start checkTerminalStatus"
			set theResult to true
			set processList to getProcessesOnShell() of my targetTerminal
			--log processList
			if isBusy() of my targetTerminal then
				--log "targetTermianl is Busy "
				tell StringEngine
					startStringEngine() of it
					set supportProcesses to everyTextItem of it from my processName by ";"
					stopStringEngine() of it
				end tell
				--log supportProcesses
				set newProcceses to {}
				repeat with theItem in processList
					if theItem is not in supportProcesses then
						set end of newProcceses to contents of theItem
					end if
				end repeat
				
				set processTexts to joinUTextList of StringEngine for newProcceses by return
				set termName to getTerminalName() of my targetTerminal
				set theMessage to getLocalizedString of UtilityHandlers given keyword:"cantExecCommand", insertTexts:{termName, processTexts}
				set buttonList to {localized string "cancel", localized string "openTerm", localized string "showTerm"}
				set theMessageResult to showMessageWithButtons(theMessage, buttonList, item 3 of buttonList) of EditorClient
				--log "after showMessageWithButtons"
				set theReturned to button returned of theMessageResult
				if theReturned is item 3 of buttonList then
					bringToFront() of my targetTerminal
					set theResult to false
				else if theReturned is item 2 of buttonList then
					set theResult to openNewTerminal()
				else
					set theResult to false
				end if
			else
				if (processList is {}) then
					set theResult to openNewTerminal()
				end if
			end if
			--log "end of checkTerminalStatus"
			return theResult
		end checkTerminalStatus
		
		on setTargetTerminal given title:theCustomTitle, ignoreStatus:isIgnoreStatus
			--log "start setTargetTerminal"
			set theResult to true
			copy TerminalCommander to targetTerminal
			forgetTerminal() of targetTerminal
			setCustomTitle(theCustomTitle) of targetTerminal
			setCleanCommands(processName) of targetTerminal
			setWindowCloseAction("2") of targetTerminal
			set theCommand to my buildInteractiveCommand()
			--log "after buildInteractiveCommand"
			set theCommand to cleanYenmark(theCommand) of UtilityHandlers
			--log "after cleanYenmark"
			if getTargetTerminal of (my targetTerminal) with allowBusyStatus then
				if not isIgnoreStatus then
					set theResult to checkTerminalStatus()
				end if
			else
				set theResult to doCommands of targetTerminal for theCommand without activation
			end if
			--log "end setTargetTerminal"
			return theResult
		end setTargetTerminal
	end script
end makeObj