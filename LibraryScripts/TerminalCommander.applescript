property LibraryFolder : (path to home folder as Unicode text) & "Factories:Script factory:ProjectsX:UnixScriptTools for mi:Library Scripts:"
property parent : load script file (LibraryFolder & "TerminalCommander.scpt")

on activateTerminal()
	call method "activateAppOfType:" of class "SmartActivate" with parameter "trmx"
	return true
end activateTerminal

on getExecutionString()
	set execString to contents of default entry "ExecutionString" of user defaults
	if execString is "" then
		set execString to missing value
	end if
	return execString
end getExecutionString

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

on getUseCtrlVEscapes()
	return contents of default entry "UseCtrlVEscapes" of user defaults
end getUseCtrlVEscapes
