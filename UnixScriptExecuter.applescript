global PathAnalyzer
global TerminalCommander

property perlCommand : "perl -w"
property perlScriptFile : missing value
property perlOptions : ""
property outputOption : ""
property inputOption : ""

on execPerlScript given activation:activateFlag
	set pathRecord to do(perlScriptFile) of PathAnalyzer
	set theFolder to folderReference of pathRecord
	
	--set theFolder to posixPath theFolder with quotes
	set theFolder to quoted form of POSIX path of theFolder
	set cdCommand to "cd  " & theFolder
	set thePerlCommand to inputOption & perlCommand & space & perlOptions & space & (name of pathRecord) & outputOption
	set cdperlCommand to cdCommand & return & thePerlCommand
	
	doCommands of TerminalCommander for cdperlCommand given activation:activateFlag
	beep
	set FreeTime to 0
end execPerlScript