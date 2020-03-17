// useful global functions

// constants

to pi { return 3.14159265358979323846 }
to e { return 2.71828182845904523536 }

to maxInt { return 1073741823 }
to minInt { return -1073741824 }

to 'true' { return true }
to 'false' { return false }
to 'nil' { return nil }

// negation and decrease

to negate n { return (0 - n) }

// equality (in terms of ==)

to '!=' a b { return (not (a == b)) }

// comparision (in terms of < and ==)
// note: adding these slows down number comparison

// to '<=' a b { return (or (a < b) (a == b)) }
// to '>' a b { return (and (not (a < b)) (not (a == b))) }
// to '>=' a b { return (not (a < b))}



// misc operations

to half n {
  // Return half the argument truncated.

  return (truncate (n / 2))
}

to interpolate n1 n2 fraction {
  // Return the number that is fraction of the way from n1 to n2.
  // fraction should be in the range [0..1].

  return (n1 + (fraction * (n2 - n1)))
}

// angles and vectors

to toRadians n { return ((n * (pi)) / 180) }
to toDegrees n { return ((n * 180) / (pi)) }

to distanceFromTo x1 y1 x2 y2 {
  dx = (x2 - x1)
  dy = (y2 - y1)
  return (sqrt ((dx * dx) + (dy * dy)))
}

to directionFromTo x1 y1 x2 y2 {
  dx = (x2 - x1)
  dy = (y2 - y1)
  return (atan dy dx)
}

// logarithms

to logBase n base {
  if (isNil base) { base = 10 }
  if (n <= 0) { error 'You cannot take the logarithm of a number less than or equal to zero' }
  if (base <= 0) { error 'The logarithm base must be greater than zero' }
  return ((ln n) / (ln base))
}

to raise base n {
  if (-1 == base) { // special case
	if (and (n == (truncate n)) (n > 0)) {
	  if (0 == (n % 2)) {
		return 1
	  } else {
	    return -1
	  }
	}
  }
  if (base <= 0) { error 'The first argument of raise (the base) must be greater than zero' }
  return (exp (n * (ln base)))
}

// hexadecimal numbers

to hex s {
  // Convert the given hexadecimal string to an integer.

  if ((substring s 1 2) == '0x') {
    s = (substring s 3)
  }
  n = 0
  letters = (letters s)
  for i (count letters) {
    digit = (hexDigitValue (at letters i))
	if (digit < 0) { error 'bad hex digit' }
	n = ((16 * n) + digit)
  }
  return n
}

to hexDigitValue ch {
  if (and ('0' <= ch) (ch <= '9')) {
    return ((byteAt ch 1) - (byteAt '0' 1))
  }
  if (and ('A' <= ch) (ch <= 'F')) {
    return (10 + ((byteAt ch 1) - (byteAt 'A' 1)))
  }
  if (and ('a' <= ch) (ch <= 'f')) {
    return (10 + ((byteAt ch 1) - (byteAt 'a' 1)))
  }
  return -1
}

// binary numbers

to binary s {
  // Convert the given binary string to an integer.

  result = 0
  for digit (letters s) {
	if ('0' == digit) {
	  result = (result << 1)
	} ('1' == digit) {
	  result = ((result << 1) + 1)
	} true {
	  error 'binary numbers can only contain "0" or "1"'
	}
  }
  return result
}
