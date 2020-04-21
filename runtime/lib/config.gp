// Functions to work with configuration files

to loadConfig cfName {
  if (and (isClass cfName 'String') (cfName != 'default') ((lastConfigName) != cfName)) {
	extractConfig cfName
  } ((lastConfigName) != 'default') {
	extractDefaultConfig
  }
  loadConfigFiles
  print 'Config loaded'
  print
}

to extractDefaultConfig {
  print 'Extracting Default Config...'
  clearConfigFiles
  zFile = (read (new 'ZipFile') (readFile 'runtime/default.cfg' true))
  for f (fileNames zFile) {
    writeFile (join 'runtime/config/' f) (extractFile zFile f)
  }
  print 'Done'
}

to extractConfig cfName {
  print (join 'Extracting config ''' cfName '''...')
  path = (userConfigFolder)
  if (not (contains (listFiles path) (join cfName '.cfg'))) {
    print (join 'ERROR: ''' cfName '.cfg'' doesn''t exist')
	extractDefaultConfig
	return
  }
  clearConfigFiles
  zFile = (read (new 'ZipFile') (readFile (join path '/' cfName '.cfg') true))
  zFileDefault = (read (new 'ZipFile') (readFile 'runtime/default.cfg' true))
  configFiles = (fileNames zFile)
  defaultFiles = (fileNames zFileDefault)
  configOnlyFiles = (intersection configFiles defaultFiles) 
  defaultOnlyFiles = (withoutAll defaultFiles configOnlyFiles)
  print
  for i defaultOnlyFiles { print i }
  print
  for f configOnlyFiles {
    writeFile (join 'runtime/config/' f) (extractFile zFile f)
  }
  for f defaultOnlyFiles {
    writeFile (join 'runtime/config/' f) (extractFile zFileDefault f)
  }
  print 'Done'
}

to loadConfigFiles {
  setGlobal 'configName' (at (jsonParse (readConfigFile 'info.json')) 'configName')
  setGlobal 'globalConfiguration' (jsonParse (readConfigFile 'config.json'))
  loadPaletteConfig
}

to clearConfigFiles {
  for f (listFiles 'runtime/config/') {
    deleteFile (join 'runtime/config/' f)
  }
}

to lastConfigName {
  if (not (isClass (readFile 'runtime/config/info.json') 'String' )) { return nil }
  dict = (jsonParse (readFile 'runtime/config/info.json'))
  return (at dict 'configName')
}

to userConfigFolder {
  // Folder where the user can add configs files
  path = (gpModFolder)
  if (not (contains (listDirectories path) 'Configs')) {
    makeDirectory (join path '/Configs')
  }
  if (contains (listDirectories path) 'Configs') {
    path = (join path '/Configs')
  }
  return path
}

to readConfigFile fName binaryFlag {
  if (isNil binaryFlag) { binaryFlag = false }
  fileContent = (readFile (join 'runtime/config/' fName) binaryFlag)
  return fileContent
}

to loadPaletteConfig {
	loadModuleFromString (topLevelModule) (readConfigFile 'palette.gp' )
}

to configAt key {
  return (at (global 'globalConfiguration') key)
}
