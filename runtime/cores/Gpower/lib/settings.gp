defineClass settings morph

to saveSettings {
  local 'dict' (dictionary)
  local 'keys' (list 'embed' 'projectPath' 'stageResolution' 'keyboardHotfix' 'fullscreen')
  for i keys {
    add dict i (global i)
  }
  writeCoreFile 'settings.json' (stringify (initialize (new 'JSONWriter')) dict true)
  inform (global 'page') 'Save operation completed'
}

to loadSettings {
  if (global 'app') {
    local 'dict' (jsonParse (readCoreFile 'settings.json'))
  } else {
    local 'dict' (jsonParse (readCoreFile 'settings.json'))
  }

  for i (keys dict) {
    setGlobal i (at dict i 1)
  }
}
