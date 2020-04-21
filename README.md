# Files
  The purpose of this branch is to make easier the use of custom configuration.
  For the moment configs are .cfg files (zipped files) wich contains 3 files.
    
  
## ```config.json``` :
This one is empty for the moment, but the Editor loads it at startup and the parsed json is saved in a global variable. It could contains anything.
  
## ```palette.gp``` :
This file can be used to change categories of the editor their and colors. 

## ```info.json``` :
Contains info about the config. ```configName``` key should be exactly equal to the name of the .cfg file. ```configVersion``` key has no purpose for the moment.

  
# Things to do
- A GUI (clearly not soon but it would be quite awesome)
