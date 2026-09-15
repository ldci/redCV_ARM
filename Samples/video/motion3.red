Red [
	Title:   "Test image operators and camera Red VID "
	Author:  "ldci"
	File: 	 %motion.red
	Needs:	 'View
]


{Based on
Collins, R., Lipton, A., Kanade, T., Fijiyoshi, H., Duggins, D., Tsin, Y., Tolliver, D., Enomoto,
N., Hasegawa, O., Burt, P., Wixson, L.: A system for video surveillance and monitoring. Tech.
rep., Carnegie Mellon University, Pittsburg, PA (2000)}

;--with 3 successive images

; required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/math/rcvStats.red	
#include %../../libs/imgproc/rcvImgProc.red


camSize: 1920x1080;1280x720 			;default Apple FaceTime Camera size
iSize: camSize / 4 ;--480x270
margins: 10x10
threshold: 32
cam: none						;--for camera object
camImg: none					;--cam image
prevImg: currImg: nextImg: none ;--successive images
d1: d2: none					;--filter images
r1: r2: none					;--result images

to-text: function [val][form to integer! 0.5 + 128 * any [val 0]]

createImages: does [
    prevImg: make image! iSize
    currImg: make image! iSize
    nextImg: make image! iSize
    d1: make image! iSize
    d2: make image! iSize
    r1: make image! iSize
    r2: make image! iSize
]


processCam: does [
    ; 1. Capture & Resize
    cImg: draw iSize compose [image (to-image cam) 0x0 (iSize)]
    rimg: rcvResizeImage cImg iSize
    
    ; 2. Pré-traitement
    rcv2gray/average rimg nextImg
    rcvGaussianFilter nextImg nextImg 3x3 1.0
    
    ; 3. Détection 3 images
    rcvAbsdiff prevImg currImg d1
    rcvAbsdiff currImg nextImg d2
    rcvAnd d1 d2 r1
    rcv2BWFilter r1 r2 threshold
    
    ; 4. Rotation des buffers
    tmpImg: prevImg
    prevImg: currImg
    currImg: nextImg
    nextImg: tmpImg
    
    ; 5. Affichage
    canvas/image: none
    canvas/draw: reduce ['image r2 0x0 iSize]
]

view win: layout [
		title "Motion Detection"
		origin margins space margins
		text "Motion " 50 middle
		motion: field 70 rate 0:0:1 on-time [
			z: rcvCountNonZero r2
			face/text: form z
		]
		text "Camera Size" middle
		cSize: field 80
		onoff: toggle 85 "Start/Stop" false [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					motion/rate: none
					canvas/image: black
				][
					cam/selected: cam-list/selected
					createImages				;--all images we need for processing
					canvas/image: r2			;--show result
					canvas/rate: 0:0:0.04		;--max 1/25 fps in ms
					motion/rate: 0:0:0.04		;--max 1/25 fps in ms		
					cSize/text: form currImg/size
				]
			]
		;pad 160x0
		btnQuit: button "Quit" 60x24 on-click [
			rcvReleaseImage prevImg
            rcvReleaseImage currImg
            rcvReleaseImage nextImg
            rcvReleaseImage d1
            rcvReleaseImage d2
            rcvReleaseImage r1
            rcvReleaseImage r2
			quit]
		return
		cam: camera iSize
		canvas: base black iSize rate 0:0:1 on-time [processCam]
		return
		text 40 "Select" 
		cam-list: drop-list 270 on-create [face/data: cam/data]
		text "Threshold" 60 middle
		sl1: slider 200x25 [filter/text: to-text sl1/data threshold: to integer! filter/data]
		filter: field 35 "32" 
		do [cam-list/selected: 1 motion/rate: canvas/rate: none sl1/data: 0.32 ]
]
	
	


