defineClass TextEditorLine contents lineStart

method contents TextEditorLine { return contents }
method lineStart TextEditorLine { return lineStart }
method setLineStart TextEditorLine n { lineStart = n }

to newTextEditorLine aString lineStart {
  return (new 'TextEditorLine' aString lineStart)
}

defineClass TextEditor morph slider fontName fontSize lines wrapCache firstWrapLine firstLine desiredWidth selStart selEnd selAnchor

// openPage
// ed = (testEditor)

to testEditor {
  ed = (newTextEditor 'Hello, World!')
  addPart (global 'page') (morph ed)
  setGutenburgText ed (readFile '20000Leagues.txt')
  return ed
}

method lines TextEditor { return lines } // debugging

method checkLines TextEditor {
  pos = 0
  for i (count lines) {
	line = (at lines i)
	if (pos != (lineStart line)) {
	  error 'Mismatch at:' i ';' pos '!=' (lineStart line)
	}
	pos += ((count (contents line)) + 1)
	i += 1
  }
  return 'okay'
}

// To do:
// [x] support changing window size (reflow, change slider height, redraw, etc.)
// [ ] maintain approx. scroll position when changing window width
// [ ] selection: set, get, draw, get selection contents
// [ ] editing operations: insert text, delete seletion, cut/copy/paste

to newTextEditor aString {
  result = (initialize (new 'TextEditor'))
  if (notNil aString) { setText result aString }
  return result
}

method initialize TextEditor {
  morph = (newMorph this)
  setGrabRule (morph this) 'ignore'
  slider = (slider 'vertical')
  setAction slider (action 'setScroll' this)
  addPart morph (morph slider)
  fontName = 'Arial'
  fontSize = (14 * (global 'scale'))
  lines = (list)
  wrapCache = (list)
  firstWrapLine = 1
  firstLine = 1
  desiredWidth = nil
  setSelection this 0
  setExtent (morph this) 600 800
  return this
}

method fontName TextEditor { return fontName }
method fontSize TextEditor { return (fontSize / (global 'scale')) }

method setFontAndSize TextEditor newName newSize {
  if (notNil newName) { fontName = newName }
  if (notNil newSize) { fontSize = (newSize * (global 'scale')) }
  desiredWidth = nil
  redraw this
}

method text TextEditor {
  result = (list)
  for line lines {
	s = (contents line)
	add result s
  }
  return (joinStringArray (toArray result) (newline))
}

method setText TextEditor aString {
  lines = (list)
  pos = 0
  lastLine = nil
  for s (lines aString) {
	add lines (newTextEditorLine s pos)
	lastLine = s
	pos += ((count s) + 1)
  }
  if (and (notNil lastLine) ((count lastLine) == 0)) {
	finalChar = (substring aString ((count aString) - 1))
	if (or (finalChar == (newline)) (finalChar == (cr)))  {
	  removeLast lines
	}
  }
  redraw this
}

method setGutenburgText TextEditor aString {
  // Load a plain-text book in which argraph breaks are indicated by a blank line.
  lines = (list)
  paragraph = (list)
  pos = 0
  for s (lines aString) {
	if (isEmpty s) {
	  if (not (isEmpty paragraph)) {
		paraString = (joinStrings paragraph ' ')
		add lines (newTextEditorLine paraString pos)
		pos += ((count paraString) + 1)
		add lines (newTextEditorLine '' pos) // blank line
		pos += 1
		paragraph = (list)
	  }
	} else {
	  add paragraph s
	}
  }
  if (not (isEmpty paragraph)) { // add final line
	paraString = (joinStrings paragraph ' ')
	add lines (newTextEditorLine paraString pos)
  }
checkLines this // xxx
  desiredWidth = nil
  redraw this
}

// Drawing

method redraw TextEditor {
  scale = (global 'scale')
  bgColor = (gray 255)
  selectionColor = (color 178 216 250)
  textColor = (gray 0)
  setFont fontName fontSize
  descent = (fontDescent)

  fixLayout this
  bm = (costume morph)
  if (or (isNil bm) ((width bm) != (width morph)) ((width bm) != (width morph))) {
	bm = (newBitmap (width morph) (height morph))
  }
  fill bm bgColor

  x = (15 * scale)
  y = (15 * scale)
  i = 1
  end = (count wrapCache)
  h = (height morph)
  while (and (i <= end) (y < h)) {
	line = (at wrapCache i)
	lineText = (contents line)
	lineStart = (lineStart line)
	lineEnd = (+ lineStart (count lineText) -1)
//	if (not (endsParagraph line)) { lineEnd += -1 }

	// show selection, if visible
	if (not (or (lineEnd < selStart) (lineStart > selEnd))) {
	  left = (x - (5 * scale))
	  right = ((width bm) - ((10 * scale) + (width (morph slider))))
	  if (selStart > lineStart) {
		setFont fontName fontSize
		left = (x + (stringWidth (substring lineText 1 (selStart - lineStart))))
	  }
	  if (selEnd <= lineEnd) {
		setFont fontName fontSize
		right = (x + (stringWidth (substring lineText 1 (selEnd - lineStart))))
	  }
	  fillRect bm selectionColor left (y + descent) (right - left) fontSize
	}

	setFont fontName fontSize
	drawString bm lineText textColor x y
	y += fontSize
	i += 1
  }
print 'displayed' (i - 1) 'lines; wrapcache size:' (count wrapCache)
  setCostume morph bm
}

// Layout

method fixLayout TextEditor {
  bnds = (bounds morph)

  // update slider bounds
  setPosition (morph slider) ((right bnds) - (width (morph slider))) (top bnds)
  setHeight (bounds (morph slider)) (height bnds)
  redraw slider // update slider appearance in case rewrapping takes a while

return // xxx

  // rewrap text, if necessary
  rewrap this

  // update slider after wrapping
  linesInView = (truncate ((height morph) / fontSize))
  if (isEmpty lines) {
	scrollPercent = 0
	percentVisible = 100
  } else {
	srollableLines = (max 1 ((count lines) - 5))
	scrollPercent = (clamp ((100 * firstLine) / srollableLines) 0 100)
	percentVisible = (clamp ((100 * linesInView) / (count lines)) 0 100)
  }
  setSize slider percentVisible
  setValue slider scrollPercent
}

// Scrolling

method setScroll TextEditor n {
  lineCount = (count lines)
  firstLine = (clamp ((n * lineCount) / 100) 1 (max 1 (lineCount - 5)))
  redraw this
}

method swipe TextEditor x y {
  firstLine = (max 1 (firstLine - (y / 3)))
  redraw this
  return true
}

// Selection

method handDownOn TextEditor aHand {
  focusOn aHand this
  selAnchor = (characterIndexForXY this (x aHand) (y aHand))
  handMoveFocus this aHand
  return true
}

method handMoveFocus TextEditor aHand {
  oldStart = selStart
  oldEnd = selEnd
  i = (characterIndexForXY this (x aHand) (y aHand))
  setSelection this selAnchor i
  if (or (selStart != oldStart) (selEnd != oldEnd)) {
	redraw this
  }
}

method characterIndexForXY TextEditor x y {
  // Return the character index for the given global position.

  scale = (global 'scale')
  localXY = (normal morph x y)
  x = (round ((first localXY) + ((normalWidth morph) / 2)))
  y = (round ((last localXY) + ((normalHeight morph) / 2)))
  x = (clamp x 0 (normalWidth morph))
  y = (clamp y 0 (normalHeight morph))
  lineOffset = (truncate ((y - (15 * scale)) / fontSize))
  lineIndex = (clamp ((round firstLine) + lineOffset) 1 (count lines))
  line = (at lines lineIndex)
  s = (contents line)
  for inset (count s) {
	setFont fontName fontSize
	endX = ((15 * scale) + (stringWidth (substring s 1 inset)))
	if (endX > x) { return (+ (lineStart line) inset -1) }
  }
  result = ((lineStart line) + (count s))
  if (not (endsParagraph line)) { result += -1 }
  return result
}

method setSelection TextEditor start end {
  if (isNil end) { end = start }
  selStart = (min start end)
  selEnd = (max start end)
}

// Line wrapping

method rewrap TextEditor {
  scale = (global 'scale')
  leftMargin = (15 * scale)
  rightMargin = ((15 * scale) + (width (morph slider)))
  currentWrapWidth = desiredWidth
  desiredWidth = ((width morph) - (leftMargin + rightMargin))
  if (desiredWidth == currentWrapWidth) { return }
  pos = 0
  newLines = (list)
  para = (list)
  for line lines {
	add para (contents line)
	if (endsParagraph line) {
	  s = (joinStrings para)
	  addAll newLines (splitParagraph this s pos)
	  pos += ((count s) + 1)
	  removeAll para
	  gcIfNeeded
	}
  }
  lines = newLines
}

method fillWrapCache TextEditor startLine {
  if (isNil startLine) { startLine = 1 }
  scale = (global 'scale')
  leftMargin = (15 * scale)
  rightMargin = ((15 * scale) + (width (morph slider)))
  desiredWidth = ((width morph) - (leftMargin + rightMargin))
  minLines = (ceiling ((height morph) / fontSize))
  wrapCache = (list)
  for i (range startLine (count lines)) {
	line = (at lines i)
	addAll wrapCache (splitParagraph this (contents line) (lineStart line))
	if ((count wrapCache) >= minLines) {
print i 'wrapCache lines:' (count wrapCache) 'min:' minLines
	  return // we have enough lines to display
	}
  }
}

method splitParagraph TextEditor s pos {
  result = (list)
  i = 1
  while true {
	i = (findBreakIndex this s i)
	if (i < (count s)) {
	  add result (newTextEditorLine (substring s 1 i) pos)
	  pos += i
	  s = (substring s (i + 1))
	} else {
	  add result (newTextEditorLine s pos)
	  return result
	}
  }
}

method findBreakIndex TextEditor s guess {
  // Return the index i at which to break s such that (substring 1 i) <= desiredWidth.
  // Try to break at a whitespace character, but break in the middle of a word if necessary.
  // Details: Scan forward from guess to first whitespace after the desired width,
  // then scan backward to find a whitespace such such that the entire string up to
  // that break is less than the desired width.

  if (isEmpty s) { return 0 }

  letters = (letters s)
  end = (count letters)
  i = (min guess end)
  w = -1

  while (w < desiredWidth) {
	while (and (i < end) ((at letters i) > ' ')) { i += 1 } // find start of next whitespace
	setFont fontName fontSize
	w = (stringWidth (substring s 1 (i - 1)))
	if (i >= end) {
	  if (w <= desiredWidth) { return end } // entire line fits
	  w = (desiredWidth + 1) // exit this loop
	}
	if (w < desiredWidth) {
	  while (and (i < end) ((at letters i) <= ' ')) { i += 1 } // skip whitespace
	}
  }

  while true {
	while (and (i > 0) ((at letters i) > ' ')) { i += -1 } // find previous whitespace

	if (i == 0) { // no previous whitespace found; fit as many letters as possible (but at least 1)
	  return (breakWord this s)
	}

	possibleEnd = i // includes trailing white space
	while (and (i > 0) ((at letters i) <= ' ')) { i += -1 } // find start of whitespace
	setFont fontName fontSize
	w = (stringWidth (substring s 1 i))
	if (w < desiredWidth) { return possibleEnd }
  }
}

method breakWord TextEditor s {
  end = (count s)
  for i (end - 1) {
	setFont fontName fontSize
	w = (stringWidth (substring s 1 (i + 1)))
	if (w > desiredWidth) { return i }
  }
  return end
}
