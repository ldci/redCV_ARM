#!/usr/local/bin/red-view
Red [
	Title:   "Rotate image"
	Author:  "ldci"
	File: 	 %imageSkew2.red
	Needs:	 View
]
;--version without routines. Just Red
margins: 10x10
iSize: 	512x512
img1: 	make image! iSize

x: 0
y: 0

drawBlk: []
canvas: none
loadImage: does [
	canvas/image: none
	tmp: request-file
	unless none? tmp [
		canvas/draw: none
		img1: load tmp
		drawBlk: compose [skew (x) (y) image (img1)]
		canvas/draw: drawBlk
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Skew Image"
		origin margins space margins
		button 60 "Load"	[loadImage]
		button 60 "Quit"	[Quit]
		return
		text 30 "x" middle
		sl1: slider 230x25		[
								x: face/data * 180.0 
								sx/text: form to integer! x
								drawBlk/2: x 
							 ]
		sx: field 30 "0"
		text "Degrees" middle
		
		return 
		text 30 "y" middle
		sl2: slider 230x25		[
								y: face/data * 180.0 
								sy/text: form to integer! y
							 	drawBlk/3: y
							 ]
		sy: field 30 "0"
		text "Degrees"
		
		return 
		canvas: base iSize black draw drawBlk	
		do [sl1/data: sl2/data: 0.0]
]
