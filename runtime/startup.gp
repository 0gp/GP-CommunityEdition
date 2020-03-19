// This GP file is run after the GP library has been loaded.
// By default, it just prints a welcome message defines a
// startup function that is run when GP starts up. You can
// replace the startup function with one that starts your own
// application.


// This loads the additional libraries
print '--- Loading core ...'
loadCore 'Default' // Change to the core subFolder you want
print '--- Core loaded'
print (getCoreName)