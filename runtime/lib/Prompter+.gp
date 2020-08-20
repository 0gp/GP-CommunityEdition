// Prompter+.gp - request text or yes/no input from the user

// UNFINISHED
// The field currentValueFrame mignt need to be renamed

defineClass Prompter+ morph window textBox textFrame buttons slider answer isDone callback sliderValue currentValueFrame questionFrame

method textBox Prompter+ {return textBox}
method answer Prompter+ {return answer}
method isDone Prompter+ {return isDone}

method initialize Prompter+ label default editRule anAction {
  scale = (global 'scale')
  answer = ''
  isDone = false
  if (isNil label) {label = 'Prompter+'}
  if (isNil default) {default = ''}
  if (isNil editRule) {editRule = 'line'}
  callback = anAction // optional

  window = (window label)
  clr = (clientColor window)
  border = (border window)
  morph = (morph window)
  setHandler morph this

  textBox = (newText default)
  setBorders textBox border border true
  minW = ((width (morph textBox)) + (60 * scale))
  setEditRule textBox editRule
  setGrabRule (morph textBox) 'ignore'
  textFrame = (scrollFrame textBox clr (== editRule 'line'))
  addPart morph (morph textFrame)
  createButtons this
  minW = (clamp minW (scale * 250) (scale * 400))
  setExtent morph minW (scale * 100)
  setMinExtent morph (width morph) (height morph)
}

method initializeForConfirm Prompter+ label question yesLabel noLabel anAction {
  answer = false
  isDone = false
  if (isNil label) {label = 'Confirm'}
  if (isNil question) {question = ''}
  if (isNil yesLabel) {yesLabel = 'Yes'}
  if (isNil noLabel) {noLabel = 'No'}
  callback = anAction // optional

  window = (window (localized label))
  hide (morph (getField window 'resizer'))
  border = (border window)
  morph = (morph window)
  setHandler morph this

  lbl = (getField window 'label')
  questionFrame = (newText (localized question) (fontName lbl) (fontSize lbl) (gray 0) 'center')
  addPart morph (morph questionFrame)
  createButtons this (localized yesLabel) (localized noLabel)

  textWidth = (width (morph questionFrame))
  buttonWidth = (width buttons)
  labelWidth = (width (morph lbl))
  xBtnWidth = (width (morph (getField window 'closeBtn')))
  w = (max textWidth buttonWidth labelWidth)
  setExtent morph (+ w xBtnWidth (4 * border)) (+ (height (morph lbl)) (height (morph questionFrame)) (height (bounds buttons)) (8 * border))
  setMinExtent morph (width morph) (height morph)
}

to prompt+ForNumber title anAction minValue maxValue currentValue question {
  page = (global 'page')
  p = (new 'Prompter+')
  initializeForSlider p title anAction minValue maxValue currentValue question
  setCenter (morph p) (x (hand page)) (y (hand page))
  keepWithin (morph p) (insetBy (bounds (morph page)) 50)
  addPart (morph page) (morph p)
  setField (hand page) 'lastTouchTime' nil
  while (not (isDone p)) { 
  doOneCycle page 
  redraw p
  } // Loop until the prompter is either validated or closed
  destroy (morph p)
  return (answer p)
}

to prompt+ForString label default editRule anAction {
  page = (global 'page')
  p = (new 'Prompter+')
  initialize p label default editRule anAction
  setCenter (morph p) (x (hand page)) (y (hand page))
  keepWithin (morph p) (insetBy (bounds (morph page)) 50)
  addPart (morph page) (morph p)
  setField (hand page) 'lastTouchTime' nil
  while (not (isDone p)) { doOneCycle page } // Loop until the prompter is either validated or closed
  destroy (morph p)
  return (answer p)
}

to prompt+ForConfirm label question yesLabel noLabel anAction {
  page = (global 'page')
  p = (new 'Prompter+')
  initializeForConfirm p label question yesLabel noLabel anAction
  setCenter (morph p) (x (hand page)) (y (hand page))
  keepWithin (morph p) (insetBy (bounds (morph page)) 50)
  addPart (morph page) (morph p)
  setField (hand page) 'lastTouchTime' nil
  while (not (isDone p)) { doOneCycle page } // Loop until the prompter is either validated or closed
  destroy (morph p)
  return (answer p)
}

method initializeForSlider Prompter+ title anAction minValue maxValue currentValue question {
  if (isNil title) {title = 'Number?'}
  if (isNil minValue) { minValue = 0 }
  if (isNil maxValue) { maxValue = 100 }
  if (isNil currentValue) { currentValue = 50 }

  answer = currentValue
  isDone = false
  callback = anAction // optional

  window = (window title)
  hide (morph (getField window 'resizer'))
  border = (border window)
  morph = (morph window)
  setHandler morph this
  
  qFrameHeight = 0
  lbl = (getField window 'label')
  questionFrame = (newText (localized question) (fontName lbl) (fontSize lbl) (gray 0) 'center')
  if (notNil question) {
    addPart morph (morph questionFrame)
    qFrameHeight = (height (morph questionFrame))
  }

  scale = (global 'scale')
  slider = (slider 'horizontal' (150 * scale) callback (10 * scale) minValue maxValue currentValue)
  currentValueFrame = (newText currentValue 'Arial' (11 * scale) (gray 0) 'center')
  w = ( (max (width (morph slider)) (width (morph questionFrame)) ) + (20 * scale))
  setPosition (morph questionFrame) (w / 2) 30 // Might not be the best solution
  setPosition (morph slider) (20 * scale) (+ (40 * scale) qFrameHeight)
  setPosition (morph currentValueFrame) (w / 2) (+ (50 * scale) qFrameHeight)
  addPart morph (morph slider)
  addPart morph (morph currentValueFrame)
  createButtons this 'ok' 'cancel'
  setExtent morph (w + (4 * border)) (+ (height (morph slider)) (height (bounds buttons)) (height (morph currentValueFrame)) qFrameHeight (60 * scale))
  setMinExtent morph (width morph) (height morph)
}

method createButtons Prompter+ okLabel cancelLabel {
  if (isNil okLabel) {okLabel = 'OK'}
  if (isNil cancelLabel) {cancelLabel = 'Cancel'}
  buttons = (newMorph)
  okButton = (pushButton okLabel (gray 130) (action 'accept' this))
  addPart buttons (morph okButton)
  cancelButton = (pushButton cancelLabel (gray 130) (action 'cancel' this))
  addPart buttons (morph cancelButton)
  setPosition (morph cancelButton) (+ (right (morph okButton)) (border window)) (top (morph okButton))
  setBounds buttons (fullBounds buttons)
  addPart morph buttons
}

method redraw Prompter+ {
  if (notNil slider) { setText (my 'currentValueFrame') (value (my 'slider')) } 
  redraw window
  redrawShadow window
  drawInside this
  fixLayout this
}

method drawInside Prompter+ {
  scale = (global 'scale')
  cornerRadius = (4 * scale)
  fillColor = (gray 220)
  inset = (5 * scale)
  topInset = (24 * scale)
  w = ((width morph) - (2 * inset))
  h = ((height morph) - (topInset + inset))
  pen = (newVectorPen (costumeData morph) morph)
  fillRoundedRect pen (rect inset topInset w h) cornerRadius fillColor
}

method fixLayout Prompter+ {
  fixLayout window
  clientArea = (clientArea window)
  border = (border window)
  buttonHeight = (height (bounds buttons))

  if (notNil slider) { // Slider dialog
    setXCenter (morph questionFrame) (hCenter clientArea) // Might not be the best solution
	setXCenter (morph slider) (hCenter clientArea)
	setXCenter (morph currentValueFrame) (hCenter clientArea)
  } (isNil textBox) { // confirmation dialog
    setTop (morph questionFrame) ((top clientArea) + (2 * border))
    setXCenter (morph questionFrame) (hCenter clientArea)
  } else { // prompter dialog
    if (== 'line' (editRule textBox)) {
      textHeight = (height (extent textBox))
      vPadding = (((height clientArea) - (+ textHeight buttonHeight border)) / 2)
    } (== 'editable' (editRule textBox)) {
      textHeight = ((height clientArea) - (+ buttonHeight (border * 2)))
      vPadding = border
    }
    hPadding = (3 * border)
    setPosition (morph textFrame) ((left clientArea) + hPadding) ((top clientArea) + vPadding)
    setExtent (morph textFrame) ((width clientArea) - (2 * hPadding)) textHeight
  }
  setXCenter buttons (hCenter clientArea)
  setBottom buttons ((bottom clientArea) - border)
}

method accept Prompter+ {
  if (notNil slider) {
    answer = (value slider)
  } (isNil textBox) { // confirmation dialog
    answer = true
  } else {
    stopEditing textBox
    answer = (text textBox)
  }
  destroy morph
  if (notNil callback) {
    call callback answer
  }
}

method cancel Prompter+ {
  if (notNil textBox) {stopEditing textBox}
  if (and (notNil slider) (notNil callback) (notNil answer)) {
    call callback answer // restore the original value
  }
  destroy morph
}

method destroyedMorph Prompter+ {isDone = true}
method accepted Prompter+ {accept this}
method cancelled Prompter+ {cancel this}
