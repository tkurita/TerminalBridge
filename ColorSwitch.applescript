
property colorWellNames : {"BackgroundColor", "NormalTextColor", "BoldTextColor", "CursorColor", "SelectionColor"}

on clicked theObject
	set theState to (state of theObject is 1)
	set theTag to tag of theObject as integer
	set targetWellName to item theTag of colorWellNames
	set enabled of color well targetWellName of super view of theObject to theState
	if theTag is 1 then
		set enabled of slider "BackTransparency" of super view of theObject to theState
	end if
	
end clicked
