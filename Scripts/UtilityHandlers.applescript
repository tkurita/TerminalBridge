global XText
global appController

property yenmark : missing value
property backslash : missing value

on clean_yenmark(a_xtext)
	if yenmark is missing value then
		tell appController
			set yenmark to factoryDefaultForKey_("yenmark") as text
			set backslash to factoryDefaultForKey_("backslash") as text
		end tell
	end if
	if class of a_xtext is script then
		set a_result to a_xtext's replace(yenmark, backslash)
	else
		set a_result to XText's make_with(a_xtext)'s replace(yenmark, backslash)'s as_unicode()
	end if
end clean_yenmark
