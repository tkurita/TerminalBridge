global WindowController
global TerminalSettingObj

on makeObj(theName)
	set theWindowController to makeObj(theName) of WindowController
	
	script SettingWindowObj
		global lifeTime
		global TerminalSettingObj
		
		property parent : theWindowController
		
		on openWindow()
			--log "start openWIndow in SettingWindowObj"
			activate
			continue openWindow()
		end openWindow
		
		on applyDefaults()
			set terminalSettingBox of TerminalSettingObj to box "TerminalSetting" of window "Setting"
			--log "before setSettingToWindow() of TerminalSettingObj"
			setSettingToWindow() of TerminalSettingObj
			--log "after setSettingToWindow() of TerminalSettingObj"
			tell my targetWindow
				set contents of text field "LifeTime" to (lifeTime / 60) as integer
			end tell
			continue applyDefaults()
			--log "end of applyDefaults in SettingWindowObj"
		end applyDefaults
		
		on prepareClose()
			set my isInitialized to false
			continue prepareClose()
		end prepareClose
		
		on writeSettings()
			tell user defaults
				set contents of default entry "LifeTime" to lifeTime as integer
			end tell
		end writeSettings
		
		on saveSettingsFromWindow() -- get all values from and window and save into preference
			saveSettingsFromWindow() of TerminalSettingObj
			
			tell window "Setting"
				set theLifeTime to (contents of text field "LifeTime") as string
				if theLifeTime is not "" then
					set lifeTime to (theLifeTime as integer) * 60
				end if
			end tell
			
			writeSettings()
		end saveSettingsFromWindow
	end script
	return SettingWindowObj
end makeObj