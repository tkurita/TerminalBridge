global PathAnalyzer
global TerminalCommander
global MessageUtility
global lineFeed

on newBaseExecuter(theScriptFile, theScriptCommand)
	script UnixScriptExecuterBase
		property scriptCommand : theScriptCommand
		property scriptFile : theScriptFile
		property postOption : ""
		property preOption : ""
		property commandOption : ""
		property commandArg : ""
		
		on setRunOptions(optionRecord)
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
		
		on buildCommand()
			set pathRecord to do(scriptFile) of PathAnalyzer
			set theFolder to folderReference of pathRecord
			
			--build cd command
			set theFolder to quoted form of POSIX path of theFolder
			set cdCommand to "cd  " & theFolder
			
			--build the command for script execution
			if preOption is not "" then
				set theScriptCommand to preOption & space & scriptCommand
			end if
			
			if commandOption is not "" then
				set theScriptCommand to theScriptCommand & space & commandOption
			end if
			
			set theScriptCommand to theScriptCommand & space & (name of pathRecord)
			
			if commandArg is not "" then
				set theScriptCommand to theScriptCommand & space & commandArg
			end if
			
			if postOption is not "" then
				set theScriptCommand to theScriptCommand & space & postOption
			end if
			
			return cdCommand & lineFeed & theScriptCommand
			
		end buildCommand
	end script
	
	return UnixScriptExecuterBase
end newBaseExecuter


on newFilterScriptExecuter from theScriptFile
	log "start newFilterScriptExecuter"
	set firstLine to read theScriptFile before lineFeed
	
	if firstLine starts with "#!" then
		set theScriptCommand to text 3 thru -1 of firstLine
	else
		set invalidCommand to localized string "invalidCommand"
		tell application "Finder"
			set theName to name of theScriptFile
		end tell
		set theMessage to aDoc & space & sQ & theName & eQ & space & invalidCommand
		showMessageOnmi(theMessage) of MessageUtility
		error "The document does not start with #!." number 1620
	end if
	
	set theBaseExecuter to newBaseExecuter(theScriptFile, theScriptCommand)
	
	script FilterScriptExecuter
		property parent : theBaseExecuter
		
		on runScript()
			log "start runScript in FilterScriptExecuter"
			set allCommand to my buildCommand()
			log "exec command : " & allCommand
			return do shell script allCommand
		end runScript
	end script
end newFilterScriptExecuter

on newUnixScriptExecuter()
	tell application "mi"
		set theFile to file of document 1
		set theName to name of document 1
		set modifiedFlag to modified of document 1
	end tell
	
	try
		set theScriptFile to theFile as alias
		set savingFlag to true
	on error
		set savingFlag to false
	end try
	
	set aDoc to localized string "aDocument"
	set sQ to localized string "startQuote"
	set eQ to localized string "endQuote"
	
	if savingFlag then
		if modifiedFlag then
			
			set isModified to localized string "isModified"
			set doYouSaveText to localized string "doYouSave"
			
			tell application "mi"
				try
					set theResult to display dialog (aDoc & space & sQ & theName & eQ & space & isModified & return & doYouSaveText)
				on error number -128
					error "The documen is modified. Saving the document is canceld by user." number 1610
				end try
				save document 1
			end tell
		end if
		
		tell application "mi"
			tell document 1
				set firstLine to first paragraph
				set secondLine to second paragraph
			end tell
		end tell
		
		if firstLine starts with "#!" then
			set theScriptCommand to text 3 thru -1 of firstLine
			if theScriptCommand ends with return then
				set theScriptCommand to text 1 thru -2 of theScriptCommand
			end if
		else
			set invalidCommand to localized string "invalidCommand"
			set theMessage to aDoc & space & sQ & theName & eQ & space & invalidCommand
			showMessageOnmi(theMessage) of MessageUtility
			error "The document does not start with #!." number 1620
		end if
		
		if secondLine starts with "#output " then
			set theOutput to text 9 thru -1 of secondLine
			if theOutput ends with return then
				set theOutput to text 1 thru -2 of theOutput
			end if
		else
			set theOutput to ""
		end if
	else
		set isNotSaved to localized string "isNotSaved"
		set theMessage to (aDoc & space & sQ & theName & eQ & space & isNotSaved)
		showMessageOnmi(theMessage) of MessageUtility
		error "The documet is not saved" number 1600
	end if
	
	set theBaseExecuter to newBaseExecuter(theScriptFile, theScriptCommand)
	set postOption of theBaseExecuter to theOutput
	
	script UnixScriptExecuter
		property parent : theBaseExecuter
		global FreeTime
		
		on runScript given activation:activateFlag
			set allCommand to my buildCommand()
			doCommands of TerminalCommander for allCommand given activation:activateFlag
			beep
			set FreeTime to 0
		end runScript
	end script
	
	return UnixScriptExecuter
end newUnixScriptExecuter

