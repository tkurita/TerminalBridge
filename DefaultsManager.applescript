property factorySettingDict : missing value

on loadFactorySettings(fileName)
	tell main bundle
		set factorySettingFile to path for resource fileName extension "plist"
	end tell
	set factorySettingDict to call method "dictionaryWithContentsOfFile:" of class "NSDictionary" with parameter factorySettingFile
end loadFactorySettings

on getFactorySetting for entryName
	return call method "valueForKey:" of factorySettingDict with parameter entryName
end getFactorySetting

on initializeDefaultValue(entryName, defaultValue)
	tell user defaults
		if not (exists default entry entryName) then
			make new default entry at end of default entries with properties {name:entryName, contents:defaultValue}
		end if
	end tell
end initializeDefaultValue

on readDefaultValue(entryName)
	tell user defaults
		if exists default entry entryName then
			return contents of default entry entryName
		else
			set defaultValue to getFactorySetting of me for entryName
			make new default entry at end of default entries with properties {name:entryName, contents:defaultValue}
			return defaultValue
		end if
	end tell
end readDefaultValue

on readDefaultValueWith(entryName, defaultValue)
	tell user defaults
		if exists default entry entryName then
			return contents of default entry entryName
		else
			make new default entry at end of default entries with properties {name:entryName, contents:defaultValue}
			return defaultValue
		end if
	end tell
end readDefaultValueWith
