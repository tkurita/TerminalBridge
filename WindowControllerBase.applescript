global DefaultsManager

property isOpened : false
property isShown : false
property targetWindow : missing value
property isInitialized : false
property windowBounds : {}
property windowBoundsKey : missing value
property isCollapsed : false
property expandedBounds : missing value

on initialize()
	--log "start initialize in WindowControllerBase"
	set windowBoundsKey to (name of targetWindow) & "WindowBounds"
	readDefaults()
	applyDefaults()
	set isInitialized to true
	--log "end initialize in WindowControllerBase"
end initialize

on openWindow(theWindow)
	--log "start openWindow in WindowControllerBase"
	set targetWindow to theWindow
	if not isInitialized then
		initialize()
	end if
	if not isOpened then
		showWindow()
		set isOpened to true
	end if
end openWindow

on showWindow()
	show targetWindow
	set isShown to true
end showWindow

on hideWindow()
	hide targetWindow
	set isShown to false
end hideWindow

on closeWindow()
	log "start closeWindow in WindowControllerBase"
	prepareClose()
	hide targetWindow
end closeWindow

on updateVisibility(isShouldShow)
	if isShouldShow and isOpened then
		if not isShown then
			showWindow()
		end if
	else
		if isShown then
			hideWindow()
		end if
	end if
end updateVisibility

on prepareClose()
	log "prepareClose in WindowControllerBase"
	set isOpened to false
	set isShown to false
	writeDefaults()
end prepareClose

on writeDefaults()
	--log "start writeDefaults in WindowControllerBase"
	if isCollapsed then
		set saveBounds to expandedBounds
	else
		set saveBounds to (bounds of targetWindow as list)
	end if
	set contents of default entry windowBoundsKey of user defaults to saveBounds
end writeDefaults

on readDefaults()
	set windowBounds to readDefaultValueWith(windowBoundsKey, windowBounds) of DefaultsManager
end readDefaults

on applyDefaults()
	--log "start applyDefaults in WindowControllerBase"
	if windowBounds is {} then
		center targetWindow
	else
		set bounds of targetWindow to windowBounds
	end if
end applyDefaults

on toggleCollapseWIndow()
	return toggleCollapse(22)
end toggleCollapseWIndow

on toggleCollapsePanel()
	return toggleCollapse(16)
end toggleCollapsePanel

on toggleCollapse(titleHight)
	--log "start should zoom"
	set theBounds to bounds of targetWindow
	
	if isCollapsed then
		set item 2 of theBounds to (item 4 of theBounds) - ((item 4 of expandedBounds) - (item 2 of expandedBounds))
		set bounds of targetWindow to theBounds
		set isCollapsed to false
	else
		copy theBounds to expandedBounds
		set item 2 of theBounds to (item 4 of theBounds) - titleHight
		set bounds of targetWindow to theBounds
		set isCollapsed to true
	end if
	return false
end toggleCollapse