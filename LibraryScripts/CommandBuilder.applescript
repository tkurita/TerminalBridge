on makeObj(theScriptFile, theScriptCommand)
	script CommandBuilder
		global PathAnalyzer
		global lineFeed
		
		property scriptCommand : theScriptCommand
		property scriptFile : theScriptFile
		property postOption : ""
		property preOption : ""
		property commandOption : ""
		property commandArg : ""
		
		on setRunOptions(optionRecord)
			try
				set scriptCommand to scriptCommand of optionRecord
			end try
			try
				set commandOption to commandOption of optionRecord
			end try
			try
				set postOption to postOption of optionRecord
			end try
			try
				set preOption to preOption of optionRecord
			end try
			try
				set commandArg to commandArg of optionRecord
			end try
		end setRunOptions
		
		on getBaseCommand()
			return first word of my scriptCommand
		end getBaseCommand
		
		on buildInteractiveCommand()
			--log "start buildInteractiveCommand"
			if scriptFile is missing value then
				set cdCommand to ""
			else
				set pathRecord to analyzePath(my scriptFile) of PathAnalyzer
				set theFolder to folderReference of pathRecord
				--build cd command
				set theFolder to quoted form of POSIX path of theFolder
				set cdCommand to "cd " & theFolder
			end if
			
			set theScriptCommand to my scriptCommand
			if commandOption is not "" then
				set theScriptCommand to theScriptCommand & space & commandOption
			end if
			--log cdCommand & lineFeed & theScriptCommand
			--log "end buildInteractiveCommand"
			return cdCommand & lineFeed & theScriptCommand
		end buildInteractiveCommand
		
		on buildCommand()
			set pathRecord to analyzePath(scriptFile) of PathAnalyzer
			set theFolder to folderReference of pathRecord
			
			--build cd command
			set theFolder to quoted form of POSIX path of theFolder
			set cdCommand to "cd " & theFolder
			
			--build the command for script execution
			if preOption is not "" then
				set theScriptCommand to preOption & space & scriptCommand
			else
				set theScriptCommand to scriptCommand
			end if
			
			if commandOption is not "" then
				set theScriptCommand to theScriptCommand & space & commandOption
			end if
			
			set theScriptCommand to theScriptCommand & space & (quoted form of (name of pathRecord))
			
			if commandArg is not "" then
				set theScriptCommand to theScriptCommand & space & commandArg
			end if
			
			if postOption is not "" then
				set theScriptCommand to theScriptCommand & space & postOption
			end if
			
			return cdCommand & lineFeed & theScriptCommand
			
		end buildCommand
	end script
	
	return CommandBuilder
end makeObj