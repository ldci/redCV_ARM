Red [
	Title:   "Red Computer Vision: Core functions"
	Author:  "ldci"
	File: 	 %rcvConvolutionMat.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2026 ldci. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]
;--used libs

;#include %../matrix/rcvMatrix.red ;--for compilation stand alone test


;******************* Matrix Convolution Routines ***************************
;-- rcvGetIntValue and rcvSetIntValue routines are replaced by inline code
;-- no crash if another routine call these routines

{ Convolution on matrices:  Non normalized convolution 
can be used with 8,16 and 32-bit matrices
factor and delta modify convolution result
}

_rcvConvolveMat: routine [
"Classical matrix convolution"
    src  		[vector!]
    dst  		[vector!]
    mSize		[pair!]
    kernel 		[block!] 
    factor 		[float!]
    delta		[float!]
    /local
    	s					[series!]
    	svalue dvalue idx	[byte-ptr!] 
    	kBase kValue		[red-value!]
    	h w x y i j 		[integer!]
    	mx my				[integer!] 
		kWidth kHeight		[integer!]
		unit v vint			[integer!]  
    	weightAcc vc		[float!]
    	f					[red-float!] 
    	p4					[int-ptr!]
][
    ;get mat size will be improved in future
    w: mSize/x
    h: mSize/y
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel  ; get pointer address of the kernel first value
	svalue: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	 ; a byte ptr
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)	
    y: v: 0
    while [y < h] [
    	x: 0
       	while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			;v: rcvGetIntValue as integer! idx unit 
           			v: vector/get-value-int as int-ptr! idx unit
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * as float! v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
        
        vc: weightAcc * factor + delta	
        vint: as integer! vc					 			 
        ;rcvSetIntValue as integer! dvalue as integer! vc unit
        p4: as int-ptr! dvalue
     	p4/value: switch unit [
			1 [vint and FFh or (p4/value and FFFFFF00h)]
			2 [vint and FFFFh or (p4/value and FFFF0000h)]
			4 [vint]
		]
        dvalue: dvalue + unit
        x: x + 1
       ]
       y: y + 1
    ]
]


{ Convolution on matrices:  Normalized convolution 
two-pass : first looks for maxi and mini 
can be used with 8,16 and 32-bit matrices
}

_rcvConvolveNormalizedMat: routine [
"Normalized fast matrix convolution"
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    kernel 	[block!] 
    factor 	[float!]
    delta	[float!]
    /local
    	s					[series!]
    	svalue dvalue idx	[byte-ptr!]
    	kBase kValue		[red-value!]	 
   		h w x y i j mx my 	[integer!] 
		kWidth kHeight 		[integer!]
		unit v vint				[integer!]
		mini maxi scale 	[float!]
    	weightAcc vc vcc	[float!]
		f					[red-float!]
		p4					[int-ptr!]
	
][
    ;get mat size will be improved in future
    w: mSize/x
    h: mSize/y
    ; get Kernel dimension (e.g. 3, 5 ...)
    kWidth: as integer! (sqrt as float! (block/rs-length? kernel))
	kHeight: kWidth
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	svalue: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)	
    y: v: 0
    maxi: -16777215.0
    mini: 16777215.0
    while [y < h][
    	x: 0
       	while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			;v: rcvGetIntValue as integer! idx unit 
           			v: vector/get-value-int as int-ptr! idx unit
           			;if unit = 1 [v: v and FFh] ; for 8-bit image
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * as float! v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
       	vc: (weightAcc * factor) + delta					 			 
    	if vc > maxi [maxi: vc] 
    	if vc <= mini [mini: vc]
        x: x + 1
       ]
       y: y + 1
    ]
    
    scale: 255.0 / (maxi - mini) 
    
    y: v: 0
    while [y < h] [
    	x: 0
       	while [x < w][
    	weightAcc: 0.0
   		j: 0
		kValue: kBase
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx:  (x + (i - (kWidth / 2)) + w ) % w 
        			my:  (y + (j - (kHeight / 2)) + h ) % h 
            		idx: svalue + (((my * w) + mx) * unit)  ; corrected pixel index
           			;v: rcvGetIntValue as integer! idx unit 
           			v: vector/get-value-int as int-ptr! idx unit
           			if unit = 1 [v: v and FFh] ; for 8-bit image
           			;get kernel values OK 
        			f: as red-float! kValue
        			; calculate weighted values
        			weightAcc: weightAcc + (f/value * as float! v)
        			kValue: kBase + (j * kWidth + i + 1)
           			i: i + 1
            	]
            	j: j + 1 
        ]
    
    	vcc: (((weightAcc * factor) + delta) - mini) * scale 
    	vint: as integer! vcc						 			 
        ;rcvSetIntValue as integer! dvalue as integer! vcc unit
        p4: as int-ptr! dvalue
     	p4/value: switch unit [
			1 [vint and FFh or (p4/value and FFFFFF00h)]
			2 [vint and FFFFh or (p4/value and FFFF0000h)]
			4 [vint]
		]
        dvalue: dvalue + unit
        x: x + 1
       ]
       y: y + 1
    ]
]

; Fast Sobel Detector on Matrix
; Computes the x component of the gradient vector
; at a given point in a matrix.
; returns gradient in the x direction

_xSMGradient: routine [
	p		[integer!]
	mSize	[pair!]
	x		[integer!]
	y		[integer!]
	return:	[integer!]
	/local
		h w idx sum v	[integer!]
][
	w: mSize/x
    h: mSize/y
    if x < 1 [x: w - 1]
    if y < 1 [y: h - 1]
    if x >= (w - 1) [x: 1]
	if y >= (h - 1) [y: 1]
    sum: 0
    idx: p + (y - 1 * w) + (x - 1) 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum + v
    idx: p + (y * w) + (x - 1) 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum + (v * 2)
    idx: p + (y + 1 * w) + (x - 1) 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum + v
    idx: p + (y - 1 * w) + (x + 1) 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum - v
    idx: p + (y  * w) + (x + 1)
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1 
    sum: sum - (v * 2)
    idx: p + (y + 1 * w) + (x + 1) 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum - v
    sum 
]


;Computes the x component of the gradient vector
; at a given point in a matrix.
;returns gradient in the y direction

_ySMGradient: routine [
	p		[integer!]
	mSize	[pair!]
	x		[integer!]
	y		[integer!]
	return:	[integer!]
	/local
		h w idx sum v [integer!]
][
	w: mSize/x
    h: mSize/y
    if x < 1 [x: w - 1]
    if y < 1 [y: h - 1]
    if x >= (w - 1) [x: 1]
	if y >= (h - 1) [y: 1]
    sum: 0
    idx: p + (y - 1 * w) + (x - 1)
    ;v: rcvGetIntValue idx 1 
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum + v
    idx: p + (y - 1 * w) + x 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum + (v * 2)
    idx: p + (y - 1 * w) + (x + 1) 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum + v
    idx: p + (y + 1 * w) + (x - 1) 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum - v
    idx: p + (y + 1 * w) + x 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum - (v * 2)
    idx: p + (y + 1 * w) + (x + 1) 
    ;v: rcvGetIntValue idx 1
    v: vector/get-value-int as int-ptr! idx 1
    sum: sum - v
    sum
]


_rcvSobelMat: routine [
    "Fast Sobel on Matrix"
    src     [vector!]
    dst     [vector!]
    mSize   [pair!]
    /local
        svalue dvalue idx   [int-ptr!]
        h w cx cy x y       [integer!]
        gx gy sum v         [integer!]
][
    svalue: as int-ptr! vector/rs-head src
    dvalue: as int-ptr! vector/rs-head dst
    
    w: mSize/x
    h: mSize/y

    cy: 0
    while [cy < h] [
        cx: 0
        while [cx < w] [
            x: cx 
            y: cy
            
            ; --- Gestion des bords (wrap-around) ---
            if x < 1 [x: w - 1]
            if y < 1 [y: h - 1]
            if x >= (w - 1) [x: 1]
            if y >= (h - 1) [y: 1]
            
            ; --- Calcul X Gradient (gx) ---
            sum: 0
            
            idx: svalue + (((y - 1) * w) + (x - 1))
            sum: sum + idx/value
            
            idx: svalue + ((y * w) + (x - 1))
            sum: sum + (idx/value * 2)
            
            idx: svalue + (((y + 1) * w) + (x - 1))
            sum: sum + idx/value
            
            idx: svalue + (((y - 1) * w) + (x + 1))
            sum: sum - idx/value
            
            idx: svalue + ((y * w) + (x + 1))
            sum: sum - (idx/value * 2)
            
            idx: svalue + (((y + 1) * w) + (x + 1))
            sum: sum - idx/value
            gx: sum
            
            ; --- Calcul Y Gradient (gy) ---
            sum: 0
            
            idx: svalue + (((y - 1) * w) + (x - 1))
            sum: sum + idx/value
            
            idx: svalue + (((y - 1) * w) + x)
            sum: sum + (idx/value * 2)
            
            idx: svalue + (((y - 1) * w) + (x + 1))
            sum: sum + idx/value
            
            idx: svalue + (((y + 1) * w) + (x - 1))
            sum: sum - idx/value
            
            idx: svalue + (((y + 1) * w) + x)
            sum: sum - (idx/value * 2)
            
            idx: svalue + (((y + 1) * w) + (x + 1))
            sum: sum - idx/value
            gy: sum
            
            ; --- Résultat final ---
            ;v: abs gx + abs gy 
            ; --- Résultat final ---
			gx: either gx < 0 [0 - gx][gx]
			gy: either gy < 0 [0 - gy][gy]
			v: gx + gy
            
            dvalue/value: v
            dvalue: dvalue + 1
            
            cx: cx + 1
        ]
        cy: cy + 1
    ]
]

;median filter 

_sortMKernel: function [knl][sort knl]

_rcvMatrixMedianFilter: routine [
"Median Filter for matrices"
    src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    kWidth 	[integer!]
    kHeight	[integer!] 
    kernel 	[vector!]
    /local
    	s					[series!]
    	svalue dvalue idx 	[byte-ptr!]
    	kBase kValue 		[byte-ptr!]
   		ptr 				[int-ptr!]
    	h w x y i j			[integer!]
    	edgex edgey pos n 	[integer!]
    	mx my unit			[integer!]
    	p4					[int-ptr!]
][
    ;get mat size will be improved in future
    w: mSize/x
    h: mSize/y
    edgex: kWidth / 2
    edgey: kHeight / 2
	kBase: vector/rs-head kernel ; get pointer address of the kernel first value
	svalue: vector/rs-head src   ; get pointer address of the source matrix first value
	dvalue: vector/rs-head dst	 ; a byte ptr
	;vector/rs-clear dst 		 ; clears destination matrix
	s: GET_BUFFER(src)
	unit: GET_UNIT(s)
	ptr: as int-ptr! kBase
    n: vector/rs-length? kernel
    pos: n / 2
    y: 0
    while [y < h] [
    	x: 0
        while [x < w][
   		j: 0
		vector/rs-clear kernel
		while [j < kHeight][
            	i: 0
            	while [i < kWidth][
            		; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
            		mx: (x + i - edgex + w) % w
    				my: (y + j - edgey + h) % h 
    				idx: svalue + (((my * w) + mx) * unit)
       				vector/rs-append-int kernel as integer! idx/value
           			i: i + 1
            	]
            	j: j + 1 
        ]
        #call [_sortMKernel kernel]
        ;rcvSetIntValue as integer! dvalue ptr/pos unit
        p4: as int-ptr! dvalue
        p4/value: switch unit [
        	1 [ptr/pos and FFh or (p4/value and FFFFFF00h)]
        	2 [ptr/pos and FFFFh or (p4/value and FFFF0000h)]
        	4 [ptr/pos]
    	]
        dvalue: dvalue + unit
        x: x + 1
       ]
    y: y + 1
    ]
]

;******************** functions **************************

rcvConvolveMat: function [
"Classical matrix convolution"
	mxS			[object!] 
	mxD			[object!]
	kernel 		[block!] 
    factor 		[float!]
    delta		[float!]
][
	
	;--type 2: integer matrices
	if all [mxS/type = 2 mxD/type = 2 matrix/_matSizeEQ? mxS mxD][
		mSize: as-pair  mxS/cols mxS/rows
		_rcvConvolveMat mxS/data mxD/data mSize kernel factor delta
	]
]

rcvConvolveNormalizedMat: function [
"Classical matrix convolution"
	mxS			[object!] 
	mxD			[object!] 
	kernel 		[block!] 
    factor 		[float!]
    delta		[float!]
	return:		[object!]
	/local
	_mx			[object!]
	mSize		[pair!]
][
	;--type 2: integer matrices
	if all [mxS/type = 2 mxD/type = 2 matrix/_matSizeEQ? mxS mxD][
		mSize: as-pair  mxS/cols mxS/rows
		_rcvConvolveNormalizedMat mxS/data mxD/data mSize kernel factor delta
	]
]

rcvSobelMat: function [
"Fast Sobel on Matrix"
	mxS			[object!] 
	mxD			[object!]
	/local mSize [pair!] 
][
	;--type 2: integer matrices
	if all [mxS/type = 2 mxD/type = 2 matrix/_matSizeEQ? mxS mxD][
		mSize: as-pair  mxS/cols mxS/rows
		_rcvSobelMat mxS/data mxD/data mSize
	]
]

rcvMatrixMedianFilter: function [
"Median Filter for matrices"
	mxS			[object!]
	mxD			[object!]
	kWidth 		[integer!];--kernel rows
    kHeight		[integer!];--kernel columns 
    kernel 		[vector!] ;--for convolution
    /local mSize [pair!]
][
	;--type 2: integer matrices
	if all [mxS/type = 2 mxD/type = 2 matrix/_matSizeEQ? mxS mxD][
		mSize: as-pair  mx/cols mx/rows
		_rcvMatrixMedianFilter mxS/data _mxD/data mSize kWidth kHeight kernel
	]
]









