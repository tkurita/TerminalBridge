global WindowControllerBase

on makeObj()
	copy WindowControllerBase to newWindowControllerBase
	
	script SettingWindowObj
		global lifeTime
		global TerminalSettingObj
		
		property parent : newWindowControllerBase
		
		on openWindow(theWindow)
			activate
			continue openWindow(theWindow)
		end openWindow
		
		on applyDefaults()
			setSettingToWindow() of TerminalSettingObj
			log "after setSettingToWindow() of TerminalSettingObj"
			tell my targetWindow
				set contents of text field "LifeTime" to lifeTime as integer
			end tell
			continue applyDefaults()
		end applyDefaults
		
		on prepareClose()
			set my isInitialized to false
			continue prepareClose()
		end prepareClose
	end script
	return SettingWindowObj
end makeObj