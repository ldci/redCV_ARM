#!/usr/local/bin/red-view
Red [
	Title:   "Thresholding Operations"
	Author:  "ldci"
	File: 	 %threshold1.red
	Needs:	 'View
]


; required libs
;#include %../../libs/core/rcvCore.red

margins: 3x10
;thresh: 127
;maxValue: 255

loadimage: does [
	tmp: request-file
	if not none? tmp [
		img1: load tmp
		;dst:  copy img1
		canvas/image: img1
	]
]


view win: layout [
	title "BW thresholding Tests"
	;origin margins space margins
	button 65 "Load" [loadimage]
	return
	canvas: base 512x512 dst
]