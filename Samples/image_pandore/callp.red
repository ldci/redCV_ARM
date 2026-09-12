#!/usr/local/bin/red-cli
Red [
	Title:   "Pandore test"
	Author:  "ldci"
	File: 	 %callp.red
]

OS: system/platform
print OS
if any [OS = 'macOS OS = 'Linux ] [home: select list-env "HOME"] 
if any [OS = 'MSDOS OS = 'Windows][home: select list-env "USERPROFILE"]
print ["Red Version:" system/version ]
panhome: rejoin [home "/Programmation/pandore/"]
sampleDir: rejoin [panhome "examples/"]
tmpDir: rejoin [sampleDir "tmp/"]
if not exists? to-file tmpDir [make-dir to-file tmpDir]
change-dir to-file panhome
prin "Pandore Version: " 
prog: rejoin [panhome "bin/pversion"]
call/console prog
prin "Image Conversion Test: "
prog: rejoin ["bin/pany2pan " sampleDir "tangram.bmp " tmpDir "tangram.pan"]
call/console prog
call/console "bin/pstatus"
prin "Shows Pandore Image: "
prog: rejoin ["bin/pvisu " tmpDir "tangram.pan"]
call/console prog
call/console "bin/pstatus"
print "Done"

 
