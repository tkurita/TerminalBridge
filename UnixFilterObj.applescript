global UtilityHandlers

property paletteBounds : {}
property selectedItem : missing value
property preferenceVersion : 1.0

on readPaletteDefaults()
	set theVersion to readDefaultValue("preferenceVersion", preferenceVersion) of UtilityHandlers
	if preferenceVersion > theVersion then
		set contents of default entry "preferenceVersion" of user defaults to preferenceVersion
		set paletteBounds to {}
	else
		set paletteBounds to readDefaultValue("paletteBounds", {}) of UtilityHandlers
	end if
	
	set selectedItem to readDefaultValue("selectedItem", 0) of UtilityHandlers
end readPaletteDefaults

on writePaletteDefaults(theWindow)
	set scriptTable to table view "ScriptList" of scroll view "ScriptList" of theWindow
	set selectedItem to selected row of scriptTable
	set contents of default entry "selectedItem" of user defaults to selectedItem
	set contents of default entry "paletteBounds" of user defaults to (bounds of theWindow as list)
end writePaletteDefaults

on applyPaletteDefaults(theWindow)
	set scriptTable to table view "ScriptList" of scroll view "ScriptList" of theWindow
	set selected row of scriptTable to selectedItem
	if paletteBounds is {} then
		center theWindow
	else
		set bounds of theWindow to paletteBounds
	end if
end applyPaletteDefaults