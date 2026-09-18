Red [
	Title:   "Matrix tests "
	Author:  "ldci"
	f2ile: 	 %matf2Sobel.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvConvolutionMat.red ;--for mat convolution


isize: 256x256
bitSize: 32

img1: rcvCreateImage isize
img2: rcvCreateImage isize

loadImage: does [
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		mat1: matrix/init 2 bitSize img1/size
        mat2: matrix/init 2 bitSize img1/size
		canvas1/image: img1
		f1/text: form img1/size
		rcvImage2Mat img1 mat1 		;--Convert to a grayscale image and to 1 Channel matrix [0..255]  
		tt: dt [
			rcvSobelMat mat1 mat2		;--fast Sobel convolution on matrix
		]
		rcvMat2Image mat2 img2		;--from matrix to red image
		canvas2/image: img2			;--show image
		rcvReleaseMat mat1			;--free mat1
		rcvReleaseMat mat2			;--free mat2
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "fast Sobel on matrix"
		button "Load" [loadImage
			f2/text: rejoin [form round/to (third tt * 1000) 0.01 " msec"]
		]
		text "Image size" middle
		f1: field 
		text "fast Sobel" middle
		f2: field 
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							Quit
		]
		return
		text 100 "Source" pad 156x0 
		text "fast Sobel"
		return
		canvas1: base isize img1
		canvas2: base isize img2
]
