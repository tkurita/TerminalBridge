property EditorClient : module "miClient"
property XText : module

property _textList : {}

on text_list()
	return my _textList
end text_list

on set_text_list(a_list)
	set my _textList to a_list
end set_text_list

on findBeginning(idx)
	set a_result to false
	repeat while idx > 0
		set a_line to EditorClient's paragraph_at(idx)
		set a_line to XText's strip(a_line)
		if a_line is not "" then
			set beginning of _textList to a_line
			if a_line starts with "function" then
				set a_result to true
				exit repeat
			else if a_line starts with "endfunction" then
				set a_result to false
				exit repeat
			end if
		end if
		set idx to idx - 1
	end repeat
	
	return a_result
end findBeginning

on findEnding(idx)
	set a_result to false
	set n_par to EditorClient's count_paragraph()
	repeat while idx is less than or equal to n_par
		set a_line to EditorClient's paragraph_at(idx)
		set a_line to XText's strip(a_line)
		if a_line is not "" then
			set end of _textList to a_line
			if a_line starts with "endfunction" then
				set a_result to true
				exit repeat
			else if a_line starts with "function" then
				set a_result to false
				exit repeat
			end if
		end if
		set idx to idx + 1
	end repeat
	
	return a_result
end findEnding