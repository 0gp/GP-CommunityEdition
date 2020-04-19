// Functions to work with configuration files


to loadConfigFiles cfName {
  if (and (isClass cfName 'String') (cfName != 'default')) {
    zFile = (read (new 'ZipFile') (readFile (join 'runtime/configs/' cfName '.cfg') true))
    setGlobal 'configName' cfName
  } else {
    zFile = (read (new 'ZipFile') (readFile 'runtime/default.cfg' true))
	setGlobal 'configName' 'default'
  }
  print (join '--- Config ''' cfName ''' loaded ---')
  setGlobal 'globalConfiguration' (jsonParse (toString (extractFile zFile 'config.json')))
  loadPaletteConfig
}



to readConfigFile fName stringFlag {
  if (isNil stringFlag) { stringFlag = true }
  cfName = (global 'configName')
  if (cfName != 'default') {
    zFile = (read (new 'ZipFile') (readFile (join 'runtime/configs/' cfName '.cfg') true))
  } else {
    zFile = (read (new 'ZipFile') (readFile 'runtime/default.cfg' true))
  }
  fileContent = (extractFile zFile fName)
  if stringFlag {
    return (toString fileContent)
  }
  return fileContent
}

to loadPaletteConfig {
	loadModuleFromString (topLevelModule) (readConfigFile 'palette.gp' )
}

to configAt key {
  return (at (global 'globalConfiguration') key)
}
