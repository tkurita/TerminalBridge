property EditorClient : module "miClient"
property XText : module

property quoteSet : {"'", quote}
property backslash : ASCII character 128

property _parenthesis_level : 0
property _bracket_level : 0
property _square_level : 0

property _startLineIndex : missing value
property _current_line_index : missing value
property _search_direction : 1
property _par_max : missing value

property _line_stack : {}

property kForward : 1
property kBackword : -1

on run
	main()
end run

on initialize()
	set _parenthesis_level to 0
	set _bracket_level to 0
	set _square_level to 0
	set _par_max to count_paragraph() of EditorClient
	--set _line_stack to {}
end initialize

on main()
	initialize()
	store_delimiters() of XText
	
	set _startLineIndex to EditorClient's index_current_paragraph()
	set _search_direction to kForward
	set _current_line_index to _startLineIndex
	
	set a_line to EditorClient's paragraph_at(_startLineIndex)
	set _line_stack to {a_line}
	
	parseCodeLine(a_line)
	--log check_bracket_level()
	repeat while (check_bracket_level() > 0)
		set a_line to nextLine()
		parseCodeLine(a_line)
	end repeat
	
	set _search_direction to kBackword
	set _current_line_index to _startLineIndex
	repeat while (check_bracket_level() < 0)
		set a_line to nextLine()
		parseCodeLine(a_line)
	end repeat
	set theResult to XText's |join|(_line_stack, "")
	restore_delimiters() of XText
	return theResult
end main

on check_bracket_level()
	(*
	log "_parenthesis_level : " & _parenthesis_level
	log "_bracket_level : " & _bracket_level
	log "_square_level : " & _square_level
	*)
	if (_parenthesis_level > 0) or (_bracket_level > 0) or (_square_level > 0) then
		return kForward
	else if (_parenthesis_level < 0) or (_bracket_level < 0) or (_square_level < 0) then
		return kBackword
	else
		return 0
	end if
end check_bracket_level

on parseCodeLine(a_line)
	--log a_line
	set pre_bracket_level to _bracket_level
	set preChar to ""
	repeat with n from 1 to length of a_line
		set theChar to character n of a_line
		if theChar is in quoteSet then
			set restLine to text (n + 1) thru -1 of a_line
			parseStringLine(restLine)
			exit repeat
		else if (theChar is "#") and (preChar is not "$") then
			exit repeat
		else if theChar is "{" then
			set _bracket_level to _bracket_level + 1
		else if theChar is "}" then
			set _bracket_level to _bracket_level - 1
		else if theChar is "(" then
			set _parenthesis_level to _parenthesis_level + 1
		else if theChar is ")" then
			set _parenthesis_level to _parenthesis_level - 1
		else if theChar is "[" then
			set _square_level to _square_level + 1
		else if theChar is "]" then
			set _square_level to _square_level - 1
		else if (theChar is "<") and (preChar is "<") then
			set endWord to last word of a_line
			parseHereText(endWord)
			exit repeat
		end if
		
		set preChar to theChar
	end repeat
	--log (pre_bracket_level - _bracket_level)
end parseCodeLine

on parseStringLine(a_line)
	local theChar
	set preChar to ""
	repeat with n from 1 to length of a_line
		set theChar to character n of a_line
		if (theChar is in quoteSet) and (preChar is not backslash) then
			set restLine to text (n + 1) thru -1 of a_line
			parseCodeLine(restLine)
			exit repeat
		end if
		set preChar to theChar
	end repeat
end parseStringLine

on parseHereText(endWord)
	repeat
		set a_line to nextLine()
		set a_line to strip_head_tail_spaces(a_line) of XText
		if a_line is endWord then
			exit repeat
		end if
	end repeat
end parseHereText

on nextLine()
	--log "_search_direction : " & _search_direction
	set _current_line_index to _current_line_index + _search_direction
	if not ((0 < _current_line_index) and (_current_line_index < (_par_max + 1))) then
		error "Can't find block. Check syntax" number 1650
	end if
	set a_line to EditorClient's paragraph_at(_current_line_index)
	if _search_direction > 0 then
		set end of _line_stack to a_line
	else
		set beginning of _line_stack to a_line
	end if
end nextLine
