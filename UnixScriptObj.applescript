global TerminalCommander
global StringEngine
global MessageUtility
global PerlExecuter
global ScriptListObj

(* handlers and script object for getting perl script file and execution  =====================*)
on runForClipboardContents(sourceItem)
	--log properties of cell "InNewWindow" of matrix "ResultMode" of window "PerlPalette"
	copy PerlExecuter to thePerlExecuter
	set perlScriptFile of thePerlExecuter to sourceItem
	set inputOption of thePerlExecuter to "pbpaste |"
	set outputOption of thePerlExecuter to "|pbcopy"
	set useNewWindow to ((state of cell "InNewWindow" of matrix "ResultMode" of window "PerlPalette") is on state)
	execPerlScript of thePerlExecuter without activation
	waitEndOfCommand(500) of TerminalCommander
	
	set preferred type of pasteboard "general" to "string"
	set theData to contents of pasteboard "general"
	--line feed to carige return
	if theData is not "" then
		set theList to every paragraph of theData
		startStringEngine() of StringEngine
		set theData to joinStringList of StringEngine for theList by return
		stopStringEngine() of StringEngine
		
		if useNewWindow then
			set docTitle to (lastScriptName of ScriptListObj) & "-stdout-" & ((current date) as string)
			tell application "mi"
				make new document with data theData with properties {name:docTitle}
				--set asksaving of document docTitle to false
			end tell
		else
			tell application "mi"
				set content of selection object 1 of document 1 to theData
			end tell
		end if
	end if
end runForClipboardContents

on newPerlExecuter()
	tell application "mi"
		set theFile to file of document 1
		set theName to name of document 1
		set modifiedFlag to modified of document 1
	end tell
	
	try
		set thePerlScriptFile to theFile as alias
		set savingFlag to true
	on error
		set savingFlag to false
	end try
	
	if savingFlag then
		if modifiedFlag then
			set aDoc to localized string "aDocument"
			set isModified to localized string "isModified"
			set sQ to localized string "startQuote"
			set eQ to localized string "endQuote"
			set doYouSaveText to localized string "doYouSave"
			
			tell application "mi"
				try
					set theResult to display dialog (aDoc & space & sQ & theName & eQ & space & isModified & return & doYouSaveText)
				on error number -128
					error "The documen is modified. Saving the document is canceld by user." number 1310
				end try
				save document 1
			end tell
		end if
		copy PerlExecuter to thePerlExecuter
		set perlScriptFile of thePerlExecuter to thePerlScriptFile
		return thePerlExecuter
	else
		set aDoc to localized string "aDocument"
		set sQ to localized string "startQuote"
		set eQ to localized string "endQuote"
		set isNotSaved to localized string "isNotSaved"
		set theMessage to (aDoc & space & sQ & theName & eQ & space & isNotSaved)
		showMessageOnmi(theMessage) of MessageUtility
		error "The documet is not saved" number 1300
	end if
end newPerlExecuter

(* end: handlers and script object for getting perl script file and execution  =====================*)

(* execute tex commands called from tools from mi  ====================================*)

--run with special options
on runDebugMode()
	try
		set thePerlExecuter to newPerlExecuter()
	on error errMsg number errNum
		if errNum is not in {1300, 1310} then
			error errMsg number errNum
		end if
		return
	end try
	set perlOptions of thePerlExecuter to "-d "
	execPerlScript of thePerlExecuter with activation
end runDebugMode

on checkSyntax()
	try
		set thePerlExecuter to newPerlExecuter()
	on error errMsg number errNum
		if errNum is not in {1300, 1310} then
			error errMsg number errNum
		end if
		return
	end try
	set perlOptions of thePerlExecuter to "-c "
	execPerlScript of thePerlExecuter with activation
end checkSyntax

--simply run in Terminal
on outputToClipboard()
	try
		set thePerlExecuter to newPerlExecuter()
	on error errMsg number errNum
		if errNum is not in {1300, 1310} then
			error errMsg number errNum
		end if
		return
	end try
	set outputOption of thePerlExecuter to " |pbcopy"
	execPerlScript of thePerlExecuter with activation
end outputToClipboard

on RunInTerminal()
	try
		set thePerlExecuter to newPerlExecuter()
	on error errMsg number errNum
		if errNum is not in {1300, 1310} then
			error errMsg number errNum
		end if
		return
	end try
	execPerlScript of thePerlExecuter with activation
end RunInTerminal

--run with Finder's selection
on getFinderSelection()
	set itemText to "" as Unicode text
	tell application "Finder"
		set theList to selection
	end tell
	repeat with theItem in theList
		set itemText to itemText & space & (quoted form of POSIX path of (theItem as alias))
	end repeat
	return itemText
end getFinderSelection

on runWithFinderSelection()
	try
		set thePerlExecuter to newPerlExecuter()
	on error errMsg number errNum
		if errNum is not in {1300, 1310} then
			error errMsg number errNum
		end if
		return
	end try
	set outputOption of thePerlExecuter to getFinderSelection()
	execPerlScript of thePerlExecuter with activation
end runWithFinderSelection

on runWithFSToClipboard()
	try
		set thePerlExecuter to newPerlExecuter()
	on error errMsg number errNum
		if errNum is not in {1300, 1310} then
			error errMsg number errNum
		end if
		return
	end try
	set finderSelection to getFinderSelection()
	set outputOption of thePerlExecuter to finderSelection & " |pbcopy"
	execPerlScript of thePerlExecuter with activation
end runWithFSToClipboard