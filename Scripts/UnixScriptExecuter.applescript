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
		
		on bringToFront()
			if getTargetTerminal of (my targetTerminal) without allowBusyStatus then
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
			doCmdInNewTerm of targetTerminal for interactiveCommand without activation
		end openNewTerminal
		
		on sendCommand(theCommand)
			--log "start sendCommand in executer"
			set theCommand to cleanYenmark(theCommand) of UtilityHandlers
			
			if getTargetTerminal of (my targetTerminal) with allowBusyStatus then
				if checkTerminalStatus() then
					doCmdInCurrentTerm of (my targetTerminal) for theCommand without activation
				else
					return false
				end if
			else
				openNewTerminal()
				doCmdInCurrentTerm of (my targetTerminal) for theCommand without activation
			end if
			
			--log "end sendCommand"
			return true
		end sendCommand
		
		on checkTerminalStatus()
			--log "start checkTerminalStatus"
			set processList to getProcessesOnShell() of my targetTerminal
			--log processList
			if isBusy() of my targetTerminal then
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
				if showMessageWithAsk(theMessage) of EditorClient then
					openNewTerminal()
					return true
				else
					return false
				end if
			else
				if (processList is {}) then
					openNewTerminal()
				end if
			end if
			
			return true
		end checkTerminalStatus
		
		on setTargetTerminal(theCustomTitle)
			--log "start setTargetTerminal"
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
				return checkTerminalStatus()
			else
				doCommands of targetTerminal for theCommand without activation
			end if
			--log "end setTargetTerminal"
			return true
		end setTargetTerminal
	end script
end makeObj