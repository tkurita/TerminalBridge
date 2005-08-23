
global MessageUtility
global CommandBuilder

on makeObj()
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
	
	set theCommandBuilder to makeObj(theScriptFile, theScriptCommand) of CommandBuilder
	set postOption of theCommandBuilder to theOutput
	
	script UnixScriptExecuter
		global TerminalCommander
		
		property parent : theCommandBuilder
		
		on runScript given activation:activateFlag
			set allCommand to my buildCommand()
			doCommands of TerminalCommander for allCommand given activation:activateFlag
			beep
		end runScript
	end script
	
	return UnixScriptExecuter
end makeObj

