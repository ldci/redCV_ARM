Red [
	Title:   "Red Computer Vision: Integral Image"
	Author:  "ldci"
	File: 	 %rcvIntegral.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 ldci. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;--used library
;#include %../../libs/matrix/rcvMatrix.red ; for stand alone test
; ****************integral image routines ************************
rcvIntegralImg: routine [
"Direct integral image"
   	src  	[image!]
    dst1  	[object!]
    dst2	[object!]
    /local
    	vec1 vec2			[red-vector!]
    	pixel pIndexS		[int-ptr!]
    	d1value d2value		[byte-ptr!]
    	idxD1 idxD2			[byte-ptr!]
    	unit x y w h		[integer!]
    	pIndexD val val2	[integer!]
    	ssum sqsum 			[integer!]
    	handle1				[ptr-value!]
    	r g b rgb	 		[integer!]
    	rgbf				[float!]
    	p4          		[int-ptr!]
][
	handle1/value: as int-ptr! 0
    pixel: image/acquire-buffer src as ptr-ptr! :handle1 
    unit: mat/get-unit dst1
    vec1: mat/get-data dst1
    vec2: mat/get-data dst2
	d1value: vector/rs-head vec1	
	d2value: vector/rs-head vec2
    idxD1: d1value
    idxD2: d2value
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    while [x < w] [
    	y: 0
    	ssum: 0
    	sqsum: 0
    	val: 0
    	val2: 0
       	while [y < h][
       		pIndexS: pixel + (x + (y * w))
       		r: pIndexS/value and 00FF0000h >> 16 
        	g: pIndexS/value and FF00h >> 8 
        	b: pIndexS/value and FFh 
        	rgbf: (0.2989 * as float! r) + (0.587 * as float! g) + (0.114 * as float! b) 
       		val: (as integer! rgbf) >> 0
       		ssum: ssum + val                             
       		sqsum: sqsum + (val * val)
       		pIndexD: (x + (y * w)) * unit 
       		d1value: idxD1 + pIndexD
       		d2value: idxD2 + pIndexD 
       		if x = 0 [
       			p4: as int-ptr! d1Value 
       			p4/value: switch unit [
        			1 [ssum and FFh or (p4/value and FFFFFF00h)]
        			2 [ssum and FFFFh or (p4/value and FFFF0000h)]
        			4 [ssum]
    			]
    			p4: as int-ptr! d2Value 
       			p4/value: switch unit [
        			1 [sqsum and FFh or (p4/value and FFFFFF00h)]
        			2 [sqsum and FFFFh or (p4/value and FFFF0000h)]
        			4 [sqsum]
    			]
      			
       		] 
       		if x > 0 [
				;sum
				d1value: d1value - unit
				val: vector/get-value-int as int-ptr! d1value unit
				d1value: d1value + unit
				val2: ssum + val
				p4: as int-ptr! d1Value 
       			p4/value: switch unit [
        			1 [val2 and FFh or (p4/value and FFFFFF00h)]
        			2 [val2 and FFFFh or (p4/value and FFFF0000h)]
        			4 [val2]
        		]
        			
				; square sum
				d2value: d2value - unit
				val: vector/get-value-int as int-ptr! d2value unit
				d2value: d2value + unit
				val2: sqsum + val
				p4: as int-ptr! d2Value 
       			p4/value: switch unit [
        			1 [val2 and FFh or (p4/value and FFFFFF00h)]
        			2 [val2 and FFFFh or (p4/value and FFFF0000h)]
        			4 [val2]
        		]
       		]
       		y: y + 1
       	]
    	x: x + 1   	
    ]
    image/release-buffer src handle1/value no
]

; uses float vector to avoid math overflow with integer
rcvIntegralFloatImg: routine [
"Direct  integral on image "
    src  			[image!]
    dst1  			[object!]
    dst2 			[object!]
    /local
    	vec1 vec2				[red-vector!]
        pix1 					[int-ptr!]
        pixD1 pixD2 idxD1 idxD2	[byte-ptr!]
        handle1 				[ptr-value!]
        unit					[integer!]
        h w x y					[integer!]
        pIndexD	pindex2	val		[integer!] 
        ssum sqsum t tq 		[float!]
        r g b rgb	 			[integer!]
        rgbf					[float!]
        p           			[byte-ptr!]
        pt64					[float-ptr!]
        pt32					[float32-ptr!]
][
    handle1/value: as int-ptr! 0
    pix1:  image/acquire-buffer src as ptr-ptr! :handle1 
    vec1: mat/get-data dst1
    vec2: mat/get-data dst2
    pixD1: vector/rs-head vec1
    pixD2: vector/rs-head vec2
    idxD1: pixD1
    idxD2: pixD2
    pIndexD: 0
    unit: mat/get-unit dst1
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	ssum: 0.0
    	sqsum: 0.0
    	x: 0
    	;loop over the number of columns
       	while [x < w][
       		pIndexD: ((y * w) + x) * unit 
       		; grayscale luminance
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh      
			rgbf: (0.2989 * as float! r) + (0.587 * as float! g) + (0.114 * as float! b) 
        	rgb: (as integer! rgbf) >> 0
       		;sum of the current row
       		ssum: ssum + as float! rgb
       		sqsum: sqsum + as float! (rgb * rgb)
       		t: ssum
       		tq: sqsum
       		if y <> 0 [
       			pIndexD: (((y - 1) * w) + x) * unit
       			;sum
				pixD1: idxD1 + pIndexD 
				t: t + vector/get-value-float pixD1 unit
       			; square sum
       			pixD2: idxD2 + pIndexD 
       			tq: tq + vector/get-value-float pixD2 unit
       			
			]
        	pIndexD: ((y * w) + x) * unit
        	pixD1: idxD1 + pIndexD 
        	p: pixD1
        	either unit = 8 [
        		pt64: as float-ptr! p
        		pt64/value: t
    		][
        		pt32: as float32-ptr! p
        		pt32/value: as float32! t
    		]
        	pixD2: idxD2 + pIndexD 
        	p: pixD2
        	either unit = 8 [
        		pt64: as float-ptr! p
        		pt64/value: tq
    		][
        		pt32: as float32-ptr! p
        		pt32/value: as float32! tq
    		]
        	pix1: pix1 + 1
        	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handle1/value no
]



;*********************** Integral Matrices *************************
; integer Matrices 
rcvIntegralMat: routine [
"Direct integral image on matrix"
   	src  	[object!]
    dst1  	[object!]
    dst2	[object!]
    /local
    	vecS vec1 vec2			[red-vector!]
    	svalue d1value d2value 	[byte-ptr!]
    	idx1 idxD1 idxD2		[byte-ptr!]
    	unit w h x y			[integer!]
    	pIndexD val val2 		[integer!]
    	ssum sqsum				[integer!]
    	p4          			[int-ptr!]
][
	w: mat/get-cols src
	h: mat/get-rows src
	unit: mat/get-unit src
	vecS: mat/get-data src
	vec1: mat/get-data dst1
    vec2: mat/get-data dst2
    svalue: vector/rs-head vecS  
	d1value: vector/rs-head vec1	
	d2value: vector/rs-head vec2
	idx1:  svalue
    idxD1: d1value
    idxD2: d2value
    x: 0
    while [x < w] [
    	y: 0
    	ssum: 0
    	sqsum: 0
    	val: 0
    	val2: 0
       	while [y < h][
       		pIndexD: (x + (y * w)) * unit 
       		svalue: idx1 + pIndexD
       		d1value: idxD1 + pIndexD
       		d2value: idxD2 + pIndexD 
       		val: vector/get-value-int as int-ptr! svalue unit 
       		ssum: ssum + val                             
       		sqsum: sqsum + (val * val)
       		if x = 0 [
       			p4: as int-ptr! d1Value
       			p4/value: switch unit [
        			1 [ssum and FFh or (p4/value and FFFFFF00h)]
        			2 [ssum and FFFFh or (p4/value and FFFF0000h)]
        			4 [ssum]
    			]
    			
    			p4: as int-ptr! d2Value
       			p4/value: switch unit [
        			1 [sqsum and FFh or (p4/value and FFFFFF00h)]
        			2 [sqsum and FFFFh or (p4/value and FFFF0000h)]
        			4 [sqsum]
    			]
    			
       		]
       		if x > 0[
       			;sum
				d1value: d1value - unit
				val: vector/get-value-int as int-ptr! d1value unit
				d1value: d1value + unit
				val2: ssum + val
				p4: as int-ptr! d1Value
				p4/value: switch unit [
        			1 [val2 and FFh or (p4/value and FFFFFF00h)]
        			2 [val2 and FFFFh or (p4/value and FFFF0000h)]
        			4 [val2]
    			]
				; square sum
				d2value: d2value - unit
				val: vector/get-value-int as int-ptr! d2value unit
				d2value: d2value + unit
				val2: sqsum + val
				p4: as int-ptr! d2Value
				p4/value: switch unit [
        			1 [val2 and FFh or (p4/value and FFFFFF00h)]
        			2 [val2 and FFFFh or (p4/value and FFFF0000h)]
        			4 [val2]
    			]
       		]
       		y: y + 1
       	]
    x: x + 1   	
    ]
]

rcvProcessIntegralMat: routine [
"Gets boxes in integral image"
	mx 		[object!]
	boxW 	[integer!]
	boxH 	[integer!]
	thresh	[integer!]
	points  [block!]
	/local
	x		[integer!] 
	y		[integer!]
	scal0	[integer!] 
	scal1	[integer!] 
	scal2	[integer!] 
	scal3	[integer!]
	val		[integer!]
	s		[c-string!]
][
	s: "box"
	y: boxH + 1
	while [y < mat/get-rows mx] [
		x: boxW + 1
		while [x < mat/get-cols mx] [
			scal0: rcvGetInt2D mx x y
			scal1: rcvGetInt2D mx x - boxW y - boxH
			scal2: rcvGetInt2D mx x (y - boxH) 
			scal3: rcvGetInt2D mx x - boxW y
			val: (scal0 + scal1 - scal2 - scal3)
			val: val / (boxW * boxH)
			if val <= thresh [
				word/load-in s points				  		; draw dialect word
				pair/make-in points (x - boxW) (y - boxH) 	; top left
				pair/make-in points x y					  	; bottom right
			]
			x: x + 1
		]
		y: y + 1
	]
]


;********************** Integral Images  Functions **************************


rcvIntegral: function [
"Calculates integral images"
	src 	[image! object!] 
	ssum 	[object!] 
	sqsum 	[object!] 
][
	t: type? src
	if t = image!  [rcvIntegralImg src ssum sqsum]
	if t = object! [rcvIntegralMat src ssum sqsum]
]


rcvProcessIntegralImage: function [
"Gets boxes in integral image"
	src 	[image! object!] 
	boxW [	integer!] 
	boxH 	[integer!] 
	thresh	[integer!] 
	points 	[block!]
][
	t: type? src
	if t = object! [rcvProcessIntegralMat src boxW boxH thresh points] 
	if t = image! [
		mx: matrix/init 2 32 as-pair src/size/x src/size/y
		rcvImage2Mat src mx ; in libs/matrix/rcvMatrix.red
		rcvProcessIntegralMat mx boxW boxH thresh points
	]
]






