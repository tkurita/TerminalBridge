global DefaultsManager

on makeObj(theWindow)
	script WindowController
		property DialogOwner : missing value
		property isAttached : false
		property targetPanel : missing value
		
		property isOpened : false
		property isShown : false
		property targetWindow : theWindow
		property isInitialized : false
		property windowBounds : {}
		property windowBoundsKey : missing value
		property isCollapsed : false
		property expandedBounds : missing value
		
		on initialize()
			--log "start initialize in WindowController"
			set windowBoundsKey to "WindowBounds_" & (name of targetWindow)
			readDefaults()
			applyDefaults()
			set isInitialized to true
			--log "end initialize in WindowController"
		end initialize
		
		on openWindow()
			--log "start openWindow in WindowController"
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
			--log "start closeWindow in WindowController"
			prepareClose()
			hide targetWindow
		end closeWindow
		
		on updateVisibility(isShouldShow)
			if isAttached then
				--log "attached"
				return
			end if
			
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
		
		on attachPanel(thePanel)
			if not isAttached then
				set isAttached to true
				set targetPanel to thePanel
				display targetPanel attached to targetWindow
				return true
			else
				return false
			end if
		end attachPanel
		
		on closeAttachedPanel()
			close panel targetPanel
			set isAttached to false
		end closeAttachedPanel
		
		on displayMessage(theMessage)
			if not (isAttached) then
				set isAttached to true
				display dialog theMessage attached to targetWindow buttons {"OK"} default button "OK"
				set DialogOwner to "Message_" & (name of targetWindow)
				return true
			else
				return false
			end if
		end displayMessage
		
		on dialogEnded()
			set isAttached to false
		end dialogEnded
		
		on prepareClose()
			--log "prepareClose in WindowController"
			set isOpened to false
			set isShown to false
			writeDefaults()
		end prepareClose
		
		on writeDefaults()
			--log "start writeDefaults in WindowController"
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
			--log "start applyDefaults in WindowController"
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
	end script
end makeObj