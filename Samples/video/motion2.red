Red [
	Title:   "Test image operators and camera Red VID "
	Author:  "ldci"
	File: 	 %motion2.red
	Needs:	 'View
]

;--must be compiled with -r option

;--version avec 2 images successives
{Based on
Collins, R., Lipton, A., Kanade, T., Fijiyoshi, H., Duggins, D., Tsin, Y., Tolliver, D., Enomoto,
N., Hasegawa, O., Burt, P., Wixson, L.: A system for video surveillance and monitoring. Tech.
rep., Carnegie Mellon University, Pittsburg, PA (2000)}


; required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/math/rcvStats.red	
#include %../../libs/imgproc/rcvImgProc.red


camSize: 1920x1080; 1280x720 			;default Apple FaceTime Camera size
iSize: camSize / 4
margins: 10x10
threshold: 32
cam: none						;--for camera object
camImg: none					;--cam image
prevImg: currImg: nextImg: none ;--successive images
d1: d2: none					;--filter images
r1: r2: none					;--result images

to-text: function [val][form to integer! 0.5 + 128 * any [val 0]]

createImages: does [
	prevImg: make image! reduce [camSize black]
	currImg: rcvCreateImage camSize 
	;prevImg: rcvCreateImage camSize 
	nextImg: rcvCreateImage camSize
	d1: rcvCreateImage camSize
	d2: rcvCreateImage camSize
	r1: rcvCreateImage camSize
	r2: rcvCreateImage camSize
]


_processCam: does [
    ; 1. Capture la frame à taille native
    camImg: to-image cam
    
    ; 2. On laisse le canvas faire le redimensionnement à l'affichage
    ;    Pas de draw, pas de rcvResizeImage
    rcv2gray/average camImg currImg
    rcvGaussianFilter currImg currImg 3x3 1.0
    rcvAbsdiff prevImg currImg d1
    rcv2BWFilter d1 r2 threshold
    rcvCopyImage currImg prevImg
    canvas/image: r2
]
processCam: does [
    ; 1. Capture via draw (GPU = fini le tearing)
    cImg: draw iSize compose [image (to-image cam) 0x0 (iSize)]
    
    ; 2. Force la taille logique pour RedCV (corrige le pb des 4 images)
    rimg: rcvResizeImage cImg iSize
    
    ; 3. Traitement
    rcv2gray/average rimg currImg
    rcvGaussianFilter currImg currImg 3x3 1.0
    rcvAbsdiff prevImg currImg d1
    rcv2BWFilter d1 r2 threshold
    rcvCopyImage currImg prevImg
    
    ; 4. Affichage via draw pour un scaling Retina propre
    canvas/image: none
    canvas/draw: reduce ['image r2 0x0 canvas/size]
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
					;camImg: copy to-image cam		;--read cam
					;camImg: draw iSize compose [image (to-image cam) 0x0 (iSize)]
					
					createImages				;--all images we need for processing
					canvas/image: r2			;--show result
					canvas/rate: 0:0:0.04		;--max 1/25 fps in ms
					motion/rate: 0:0:0.04		;--max 1/25 fps in ms		
					cSize/text: form currImg/size
				]
			]
		pad 460x0
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
		text 40 "Select" middle
		cam-list: drop-list 270 on-create [face/data: cam/data]
		text "Threshold" 60 middle
		sl1: slider 200x25 [filter/text: to-text sl1/data threshold: to integer! filter/data]
		filter: field 35 "32" 
		do [cam-list/selected: 1 motion/rate: canvas/rate: none sl1/data: 0.32 ]
]
	
	


