(* shared script objects *)
global WindowControllerBase

on makeObj()
	copy WindowControllerBase to newWindowControllerBase
	
	script FilterPaletteObj
		global ScriptListObj
		global DefaultsManager
		
		property parent : newWindowControllerBase
		property selectedItem : missing value
		property scriptTable : missing value
		
		on initialize()
			set scriptTable to table view "ScriptList" of scroll view "ScriptList" of my targetWindow
			initialize(my targetWindow) of ScriptListObj
			continue initialize()
		end initialize
		
		on readDefaults()
			log "start readDefaults"
			set selectedItem to readDefaultValueWith("selectedItem", 0) of DefaultsManager
			continue readDefaults()
		end readDefaults
		
		on writeDefaults()
			set selectedItem to selected row of scriptTable
			set contents of default entry "selectedItem" of user defaults to selectedItem
			continue writeDefaults()
		end writeDefaults
		
		on applyDefaults()
			log "start applyDefaults"
			set selected row of scriptTable to selectedItem
			log "before continue applyDefaults"
			continue applyDefaults()
			log "end applyDefaults"
		end applyDefaults
	end script
end makeObj