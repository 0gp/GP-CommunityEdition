defineClass settings morph

to saveSettings {
  local 'dict' (dictionary)
  local 'keys' (list 'embed' 'projectPath' 'stageResolution' 'keyboardHotfix' 'fullscreen')
  for i keys {
    add dict i (global i)
  }
  self_writeFile (join (runtimeFolder) 'settings.json') (stringify (initialize (new 'JSONWriter')) dict true)
  inform (global 'page') 'Save operation completed'
}

to loadSettings {
  if (global 'app') {
    local 'dict' (jsonParse (readEmbeddedFile 'settings.json'))
  } else {
    local 'dict' (jsonParse (self_readFile (join (runtimeFolder) 'settings.json')))
  }

  for i (keys dict) {
    setGlobal i (at dict i 1)
  }
}
