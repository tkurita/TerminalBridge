property XText : module
on _compile()
	boot (module loader of application (get "UnixScriptToolsLib")) for me
	return missing value
end _compile
property _ : _compile()

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

on set_comment_char(a_char)
	set my _comment_char to a_char
end set_comment_char

on main()
	tell application "mi"
		tell document 1
			set paracount to (count paragraphs of selection object 1)
			set firstpara to index of paragraph 1 of selection object 1
			repeat with n from firstpara to firstpara + paracount - 1
				set a_paragraph to paragraph n
				set {heading_spaces, a_text} to XText's strip_beginning(a_paragraph)
				if a_text starts with my _comment_char then
					set an_offset to offset of my _comment_char in a_paragraph
					set character an_offset of paragraph n to ""
				end if
			end repeat
		end tell
	end tell
end main

