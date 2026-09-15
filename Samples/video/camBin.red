Red [
	Title:   "Test camera Red VID "
	Author:  "ldci"
	File: 	 %camBin.red
	Needs:	 'View
]
; required libs
#include %../../libs/core/rcvCore.red

camSize: 1920x1080; 1280x720 			;default Apple FaceTime Camera size 1920x1080
iSize: camSize / 4
margins: 10x10
cam: none ; for camera
src: rcvCreateImage camSize
dst: rcvCreateImage camSize
threshold: 127

view win: layout [
		title "Red Binary Camera"
		origin margins space margins
		text "Image size" middle cSize: field 100
		pad 300x0
		sl1: slider 255x25 [filter/text: form to-integer sl1/data * 255  
						threshold: to integer! filter/data  
						do-events/no-wait]
		filter: field 40 
		pad 80x0 
		btnQuit: button "Quit" 60x24 on-click [quit]
		return
		cam: camera iSize	;--Red cam object
		canvas: base iSize black on-time [ 
					;cImg: cam/image		;--specific to macOS
					cImg: copy to-image cam	;--for all
					;src: rcvResizeImage cImg iSize
					rcvThreshold/binary cImg dst threshold 255
					canvas/image: dst
					;canvas/image: draw iSize compose [image (dst) 0x0 iSize]
					;cam/image: none ;--required when using cam/image
					tf/text: form now/time/precise
					;canvas/text: tf/text
				] font-color red font-size 12
		return
		text 60 "Camera" middle 
		cam-list: drop-list 250 on-create [
				face/data: cam/data
		]
		onoff: toggle 85  "Start/Stop" false [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: none
					canvas/text: ""
				][
					cam/selected: cam-list/selected
					canvas/rate:  0:0:0.04;  max 1/25 fps in ms
				]
		]
		pad 60x0 tf: field 220
		do [cam-list/selected: 1 canvas/rate: none 
			canvas/para: make para! [align: 'right v-align: 'bottom]
			sl1/data: 0.5
			filter/text: form threshold cSize/text: form camSize
		]
]