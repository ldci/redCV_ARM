Red [
	Title:   "Thresholding Operations"
	Author:  "ldci"
	File: 	 %threshold1.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red

margins: 3x10
thresh: 127
maxValue: 255

loadimage: does [
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		canvas/image: dst
	]
]
; ***************** Test Program ****************************
view win: layout [
		title "BW thresholding Tests"
		origin margins space margins
		button 65 "Load" [loadimage]
		button 65 "Source" 		[rcvCopyImage img1 dst]
		button 60 "Binary" 		[rcvThreshold/binary img1 dst thresh maxValue]
		button 80 "Binary Inv" 	[rcvThreshold/binaryInv img1 dst thresh maxValue]
		button 80 "Truncate" 	[rcvThreshold/trunc img1 dst thresh maxValue]
		button 50 "To 0" 		[rcvThreshold/toZero img1 dst thresh maxValue]
		button 75 "To 0 Inv" 	[rcvThreshold/toZeroInv img1 dst thresh maxValue]
		button 50 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		pad 35x0
		text "Threshold" middle
		p1: field [if error? try [thresh: to integer! p1/data] [thresh: 127]]
		text "Max Value" middle
		p2: field [if error? try [maxValue: to integer! p2/data] [maxValue: 255]]
		return
		pad 35x0
		canvas: base 512x512	
		do [p1/data: thresh p2/data: maxValue]
]
