global UnixScriptExecuter

(* execute tex commands called from tools from mi  ====================================*)

(* simply run in Terminal *)

on RunInTerminal(optionRecord)
	try
		set theScriptExecuter to makeObj() of UnixScriptExecuter
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
		end if
		return
	end try
	setRunOptions(optionRecord) of theScriptExecuter
	runScript of theScriptExecuter with activation
end RunInTerminal

--run with Finder's selection
on getFinderSelection()
	tell application "Finder"
		set theList to selection
	end tell
	set itemText to (quoted form of POSIX path of (item 1 of theList as alias))
	repeat with theItem in (rest of theList)
		set itemText to itemText & space & (quoted form of POSIX path of (theItem as alias))
	end repeat
	return itemText
end getFinderSelection

on runWithFinderSelection(optionRecord)
	--log "start runWithFinderSelection"
	try
		set theScriptExecuter to makeObj() of UnixScriptExecuter
	on error errMsg number errNum
		if errNum is not in {1600, 1610, 1620} then
			error errMsg number errNum
		end if
		return
	end try
	setRunOptions(optionRecord) of theScriptExecuter
	set commandArg of theScriptExecuter to getFinderSelection()
	--log postOption of theScriptExecuter
	runScript of theScriptExecuter with activation
end runWithFinderSelection
