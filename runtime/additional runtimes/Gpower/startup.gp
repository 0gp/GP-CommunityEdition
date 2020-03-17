// This GP file is run after the GP library has been loaded.
// By default, it just prints a welcome message and a few lines
// of help, then runs "startScripting", which starts up the GUI.
// However, you can replace that code with GP commands to start
// up your own application.

print
print 'Welcome to GP!'
print
print 'This the GP terminal window, used for bootstrapping GP. The GP user'
print 'interface (UI) runs in its own window, but if the UI loop encounters'
print 'an error it cannot handle, it stops and this window takes over.'
print
print 'You can type ctrl-C in this terminal window to manually halt the UI.'
print
print 'When the UI is stopped, you can run commands in this terminal window, such as:'
print '  exit - quit GP'
print '  help - print a list of primitive operations built into GP'
print '  print (3 + 4) - print the result of an expression'
print '  inspect (list 1 2 3) - inspect an object'
print '  go - restart the user interface'

to startup {
  setGlobal 'app' false
  setGlobal 'vectorTrails' false
  print 'Settings loaded'
  loadSettings
  openProjectEditor true true
}
