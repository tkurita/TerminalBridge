property _comment_char : "#" as Unicode text

on run
	try
		main()
	on error msg number errno
		if errno is not -128 then
			activate
			display alert msg message "Error Number : " & errno
		end if
	end try
end run

on main()
	tell application "mi"
		tell document 1
			set paracount to (count paragraphs of selection object 1)
			if paracount is 0 then
				set paracount to 1
			end if
			set firstpara to index of paragraph 1 of selection object 1
			repeat with n from firstpara to firstpara + paracount - 1
				copy my _comment_char to insertion point 1 of paragraph n
			end repeat
		end tell
	end tell
end main
