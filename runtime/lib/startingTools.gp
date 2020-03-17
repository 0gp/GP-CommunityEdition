// Those functions need to be loaded by the VM to make possible loading additional runtime folders after
// loading the VM


to loadRuntime runtimeName {
  relativePath = (joinStringArray (array 'runtime/additional runtimes/' runtimeName))
  additionalLibFolder = (joinStringArray (array relativePath '/lib'))
  fList = (listFiles additionalLibFolder)
  for f fList { 
    
    lib = (readFile (joinStringArray (array additionalLibFolder '/' f ))) // Read .gp file from library folder
	loadModuleFromString (topLevelModule) lib // Load module from file
    print (joinStringArray (array f ' loaded !'))
  }
  print (joinStringArray (array '--- ' (toString (count fList)) ' libraries loaded from ''' additionalLibFolder ''''))
  loadModuleFromString (topLevelModule) (readFile (joinStringArray (array relativePath '/startup.gp'))) // Load the startup function from the additional runtime
  print '--- startup.gp loaded'
  
  
}



// --- Integer.gp ---

method floor Integer { return this }


// --- math.gp ---
// min, max, and sum

to max args... {
  // Return the maximum argument. Must have at least one argument.
  // If the first argument is an array or list, return its maximum element.

  if (and ((argCount) == 1) (isAnyClass (arg 1) 'Array' 'List')) {
	return (callWith 'max' (toArray (arg 1)))
  }
  count = (argCount)
  if (count == 0) { return nil }
  result = (arg 1)
  for i count {
    n = (arg i)
    if (n > result) { result = n }
  }
  return result
}

to min args... {
  // Return the minimum argument. Must have at least one argument.
  // If the first argument is an array or list, return its minimum element.

  if (and ((argCount) == 1) (isAnyClass (arg 1) 'Array' 'List')) {
	return (callWith 'min' (toArray (arg 1)))
  }
  count = (argCount)
  if (count == 0) { return nil }
  result = (arg 1)
  for i count {
    n = (arg i)
    if (n < result) { result = n }
  }
  return result
}

to sum list {
  result = 0.0
  for n list { result += n }
  return result
}

// clamp and range

to clamp n min max {
  // Return the closest value to n in the given range.
  if (n < min) { n = min }
  if (n > max) { n = max }
  return n
}

to range start stop delta {
  comment '
	Return an array of integers over the given range (inclusive of start and stop).'

  if (isNil delta) { delta = 1 }
  if (isNil stop) {
    stop = start
	start = 1
  }
  if (delta == 0) { error 'Delta cannot be zero' }
  delta = (abs delta)
  result = (list start)
  if (start < stop) {
	steps = (floor ((stop - start) / delta))
	for i steps {
	  add result (start + (i * delta))
	}
  } else {
	steps = (floor ((start - stop) / delta))
	for i steps {
	  add result (start - (i * delta))
	}
  }
  return (toArray result)
}

to isBetween n start stop {
  // Return true if n is between start and stop, inclusive.

  return (and (start <= n) (n <= stop))
}


// --- tools.gp ---

to print args... {
  result = (list)
  for i (argCount) {
    add result (toString (arg i))
    if (i != (argCount)) {add result ' '}
  }
  log (joinStringArray (toArray result))
}

// tests

to isAnyClass obj classNames... {
  // Return true if obj is an instance of one of the given classes.

  for i ((argCount) - 1) {
    if (isClass obj (arg (i + 1))) { return true }
  }
  return false
}

to isNumber obj {
  if (isClass obj 'Integer') { return true }
  if (isClass obj 'Float') { return true }
  if (isClass obj 'LargeInteger') { return true }
  return false
}

to isOneOf obj items... {
  // Return true if obj is equal to any of the remaining arguments.

  for i ((argCount) - 1) {
    if (obj == (arg (i + 1))) { return true }
  }
  return false
}


// --- Array.gp ---

method toList Array {
  return (new 'List' 1 (count this) (copyArray this) )
}

method copy Array {
  return (copyArray this)
}

method copyWith Array newEl {
  result = (copyArray this ((count this) + 1))
  atPut result (count result) newEl
  return result
}

method copyWithout Array omitEl {
  // Return a copy of this array without any instances of omitEl.
  result = (list)
  for el this {
    if (omitEl != el) { add result el }
  }
  return (toArray result)
}

method first Array { return (at this 1) }
method last Array { return (at this (count this)) }


