// Functions to work with configuration files


to loadConfigFiles cfName {
  setGlobal 'configName' cfName
  setGlobal 'globalConfiguration' (jsonParse (readFile (join 'runtime/configs/' cfName '/config.json' )))
  loadPaletteConfig
}

to readConfigFile fName {
  return (readFile (join 'runtime/configs/' (global 'configName') '/' fName))
}

to loadPaletteConfig {
	cfName = (global 'configName')
	loadModuleFromString (topLevelModule) (readConfigFile 'palette.gp')
}

to configAt key {
  return (at (global 'globalConfiguration') key)
}
