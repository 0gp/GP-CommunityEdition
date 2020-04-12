defineClass AuthoringSpecs specsList specsByOp opCategory language translationDictionary

method allOpNames AuthoringSpecs {
  result = (toList (keys specsByOp))
  editor = (findProjectEditor)
  if (notNil editor) {
	addAll result (keys (blockSpecs (project editor)))
  }
  return result
}

// initialization

method initialize AuthoringSpecs {
  // Initialize the specsByOp and opCategory dictionaries.
  // Note: specsByOp maps an op to a list of matching specs.

  clear this
  initializeCategoriesColor
  addSpecs this (initialSpecs this)
  return this
}

method clear AuthoringSpecs {
  specsList = (list)
  specsByOp = (dictionary)
  opCategory = (dictionary)
  language = 'English'
  translationDictionary = nil
  return this
}

method addSpecs AuthoringSpecs newSpecs {
  category = ''
  for entry newSpecs {
	add specsList entry
	if (isClass entry 'String') {
	  if ('-' != entry) { category = entry }
	} else {
	  op = (at entry 2)
	  specsForOp = (at specsByOp op (list))
	  add specsForOp (specForEntry this entry)
	  atPut specsByOp op specsForOp
	  if (not (contains opCategory op)) {
		atPut opCategory op category
	  }
	}
  }
  // special cases for the block finder for blocks that are in multiple categories
  atPut opCategory 'randomColor' 'Color'
  atPut opCategory 'transparent' 'Color'
}

method recordBlockSpec AuthoringSpecs op spec {
  // Record a block spec for the give op. Called when creating/changing functions and methods.
  editor = (findProjectEditor)
  if (isNil editor) { return } // should not happen
  atPut (blockSpecs (project editor)) op spec
}

// queries

method allSpecs AuthoringSpecs {
  result = (list)
  for entry specsList {
	if (isClass entry 'Array') { add result entry }
  }
  return result
}

method specForEntry AuthoringSpecs e {
  // Return a BlockSpec for the given entry array.

  blockType = (at e 1)
  op = (at e 2)
  specString = (at e 3)
  slotTypes = ''
  if ((count e) > 3) { slotTypes = (at e 4) }
  slotDefaults = (array)
  if ((count e) > 4) { slotDefaults = (copyArray e ((count e) - 4) 5) }
  return (blockSpecFromStrings op blockType specString slotTypes slotDefaults)
}

method specForOp AuthoringSpecs op cmdOrReporter {
  // Return a BlockSpec for the given op, or nil if there isn't one.
  // If cmdOrReporter is supplied, use it to disambiguate when there
  // there are multiple blocks specs matching the given op.

  matchingSpecs = (at specsByOp op (array))
  editor = (findProjectEditor)
  if (notNil editor) {
	projectSpecs = (blockSpecs (project editor))
	if (contains projectSpecs op) {
	  // if project defines op, try that first
	  matchingSpecs = (join (array (at projectSpecs op)) matchingSpecs)
    }
  }
  if (isEmpty matchingSpecs) { return nil }
  if (or ((count matchingSpecs) == 1) (isNil cmdOrReporter)) {
	return (translateToCurrentLanguage this (first matchingSpecs))
  }

  // filter by block type
  isReporter = (isClass cmdOrReporter 'Reporter')
  filtered = (list)
  for s matchingSpecs {
	if (isReporter == ('r' == (blockType s))) {
		add filtered s
	}
  }
  if ((count filtered) == 1) { return (translateToCurrentLanguage this (first filtered)) } // unique match
  if (isEmpty filtered) { filtered = matchingSpecs } // revert if no matches

  // filter by arg count
  argCount = (count (argList cmdOrReporter))
  filtered2 = (list)
  for s filtered {
	if (argCount == (slotCount s)) {
		add filtered2 s
	}
  }
  if ((count filtered2) > 0) { return (translateToCurrentLanguage this (first filtered2)) }
  return (translateToCurrentLanguage this (first filtered))
}

method specsFor AuthoringSpecs category {
  // Return a list of BlockSpecs for the given category.

  editor = (findProjectEditor)
  if (notNil editor) {
	if (contains (extraCategories (project editor)) category) {
	  return (specsForCategory (project editor) category)
	}
  }
  result = (list)
  currentCategory = ''
  for entry specsList {
	if (isClass entry 'String') {
	  if ('-' == entry) {
		if (currentCategory == category) { add result '-' }
	  } else {
		currentCategory = entry
	  }
	} (currentCategory == category) {
	  add result (specForEntry this entry)
	}
  }
  return result
}

method categoryFor AuthoringSpecs op {
  return (at opCategory op)
}

method hasTopLevelSpec AuthoringSpecs op {
  return (contains specsByOp op)
}

// block colors

method blockColorForOp AuthoringSpecs op {
  if (true == (global 'alanMode')) {
	if ('comment' == op) { return (gray 237) }
	c = (blockColorForCategory this (at opCategory op))
	return (alansBlockColorForCategory this (at opCategory op))
  }
  if ('comment' == op) { return (colorHSV 55 0.6 0.93) }
  return (blockColorForCategory this (at opCategory op))
}

to initializeCategoriesColor {
  // initialize a dictionary 
  catColor = (dictionary)
  for i (fullSpecs) {
    if (isClass i 'String') { catName = i }
	if (isClass i 'Color') { atPut catColor catName i }
  }
  setGlobal 'categoriesColor' catColor
}

method blockColorForCategory AuthoringSpecs cat {
  defaultColor = (color 4 148 220)
  catColors = (global 'categoriesColor')
  if (contains catColors cat ) { return (at catColors cat )}
  return defaultColor
}

method alansBlockColorForCategory AuthoringSpecs cat {
  defaultColor = (gray 190) // 180
  if (isOneOf cat 'Control' 'Functions') {
	return (gray 200) // 190
  } ('Variables' == cat) {
	return (gray 185) // 175
  } ('Operators' == cat) {
	return (gray 220) // 230
  }
  return defaultColor
}

to setBlockColors c1 c2 c3 c4 {
  // Allows experimentation with block colors.
  setGlobal 'controlColor' c1
  setGlobal 'variableColor' c2
  setGlobal 'operatorsColor' c3
  setGlobal 'defaultColor' c4
  fixBlockColors
}

to setBlockTextColor c {
  setGlobal 'blockTextColor' c
  fixBlockColors
}

to resetBlockColors {
  // Revert to original block colors.
  setGlobal 'controlColor' (color 230 168 34)
  setGlobal 'variableColor' (color 243 118 29)
  setGlobal 'operatorsColor' (color 98 194 19)
  setGlobal 'defaultColor' (color 4 148 220)
  setGlobal 'blockTextColor' (gray 255)
  fixBlockColors
}

to fixBlockColors {
  // update colors of existing blocks
  for b (allInstances (class 'Block')) {
	expr = (expression b)
	if (notNil expr) {
	  setBlockColor b (primName expr)
	  redraw b
	}
	textColor = (global 'blockTextColor')
	if (isNil textColor) { textColor = (gray 0) }
	for m (parts (morph b)) {
	  if (isClass (handler m) 'Text') { setColor (handler m) textColor }
	}
  }
}

// translation

method language AuthoringSpecs { return language }

method setLanguage AuthoringSpecs newLang {
  translationData = (readEmbeddedFile (join 'translations/' newLang '.txt'))
  if (isNil translationData) {
	// if not embedded file, try reading external file
	translationData = (readFile (join 'translations/' newLang '.txt'))
  }
  if (isNil translationData) {
	// if still nil, we may be in the wrong dir
	translationData = (readFile (join '../translations/' newLang '.txt'))
  }
  if (isNil translationData) {
	language = 'English'
	translationDictionary = nil
  } else {
	language = newLang
	installTranslation this translationData
  }
}

method translateToCurrentLanguage AuthoringSpecs spec {
  if (not (needsTranslation this spec)) { return spec }

  newSpecStrings = (list)
  for s (specs spec) {
	add newSpecStrings (at translationDictionary s s)
  }
  result = (clone spec)
  setField result 'specs' newSpecStrings
  return result
}

method needsTranslation AuthoringSpecs spec {
  // Return true if any of the spec strings of spec needs to be translated.

  if (isNil translationDictionary) { return false }
  for s (specs spec) {
	if (contains translationDictionary s) { return true }
  }
  return false
}

method installTranslation AuthoringSpecs translationData langName {
  // Translations data is string consisting of three-line entries:
  //	original string
  //	translated string
  //	<blank line>
  //	...
  // Lines starting with # are treated as comments

  translationDictionary = (dictionary)
  lines = (toList (lines translationData))
  while ((count lines) >= 2) {
	from = (removeFirst lines)
	// ignore comments and blank lines
	while (and
			((count lines) >= 2)
			(or (beginsWith from '#') (from == ''))) {
		from = (removeFirst lines)
	}
	if ((count lines) >= 1) {
		to = (removeFirst lines)
		atPut translationDictionary from to
	}
  }
  if (notNil langName) { language = langName }
}

to localized aString {
  localization = (localizedOrNil aString)
  if (or (isNil localization) (localization == '--MISSING--')) {
	return aString
  } else {
	return localization
  }
}

to localizedOrNil aString {
  if (isNil aString) { return nil }
  dict = (getField (authoringSpecs) 'translationDictionary')
  if (isNil dict) {
	return aString
  } else {
	return (at dict aString)
  }
}

// authoring specs

method initialSpecs AuthoringSpecs {
	specs = (list)
	for i (fullSpecs) {
	if (not (isClass i 'Color')) { add specs i }
	}
	return (toArray specs)
}

to authoringSpecs {
  // Return the global AuthoringSpecs instance.
  if (isNil (global 'authoringSpecs')) {
	setGlobal 'authoringSpecs' (initialize (new 'AuthoringSpecs'))
  }
  return (global 'authoringSpecs')
}
