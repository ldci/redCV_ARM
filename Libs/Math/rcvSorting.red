Red [
]

_sortPixels: func [bl][sort bl]
_sortreversePixels: func [bl ][sort/reverse bl]

rcvSortImagebyX: routine [
"Sorts image columns"
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [ptr-value!]
    handleD [ptr-value!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1/value: as int-ptr! 0
    handleD/value: as int-ptr! 0
    pix1: image/acquire-buffer src1 as ptr-ptr! :handle1
    pixD: image/acquire-buffer dst as ptr-ptr! :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    y: 0
    while [y < h] [
    	x: 0 
    	vector/rs-clear b
    	while [x < w] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		x: x + 1
    	]
    	either flag [#call [_sortreversePixels  b]] 
    				[#call [_sortPixels b]]
    	ptr: as int-ptr! vBase
    	x: 0
		while [x < w] [
			idx: pixD + (y * w) + x
			n: x + 1			; ptr/0 returns vector size
			idx/value: ptr/n
			x: x + 1
		]
    	y: y + 1
    ]
    image/release-buffer src1 handle1/value no
	image/release-buffer dst handleD/value yes
]

rcvSortImagebyY: routine [
"Sorts image lines"
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [ptr-value!]
    handleD [ptr-value!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1/value: as int-ptr! 0
    handleD/value: as int-ptr! 0
    pix1: image/acquire-buffer src1 as  ptr-ptr! :handle1
    pixD: image/acquire-buffer dst  as ptr-ptr! :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    x: 0
    while [x < w] [
    	y: 0 
    	vector/rs-clear b
    	while [y < h] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		y: y + 1
    	]
    	either flag [#call [_sortreversePixels  b]] 
    				[#call [_sortPixels b]]
    	ptr: as int-ptr! vBase
    	y: 0
		while [y < h] [
			idx: pixD + (y * w) + x
			n: y + 1		; ptr/0 returns vector size
			idx/value: ptr/n 
			y: y + 1
		]
    	x: x + 1
    ]
    image/release-buffer src1 handle1/value no
	image/release-buffer dst handleD/value yes
]


rcvSortImagebyY: routine [
"Sorts image lines"
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [ptr-value!]
    handleD [ptr-value!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1/value: as int-ptr! 0
    handleD/value: as int-ptr! 0
    pix1: image/acquire-buffer src1 as  ptr-ptr! :handle1
    pixD: image/acquire-buffer dst  as ptr-ptr! :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    x: 0
    while [x < w] [
    	y: 0 
    	vector/rs-clear b
    	while [y < h] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		y: y + 1
    	]
    	either flag [#call [_sortreversePixels  b]] 
    				[#call [_sortPixels b]]
    	ptr: as int-ptr! vBase
    	y: 0
		while [y < h] [
			idx: pixD + (y * w) + x
			n: y + 1		; ptr/0 returns vector size
			idx/value: ptr/n 
			y: y + 1
		]
    	x: x + 1
    ]
    image/release-buffer src1 handle1/value no
	image/release-buffer dst handleD/value yes
]

rcvSortImage: function [
"Ascending image sorting"
	source 	[image!] 
	dst 	[image!]
][
	dst/rgb: copy sort source/rgb 
]

rcvXSortImage: function [
"Image sorting by line"
	src 	[image!] 
	dst		[image!] 
	flag 	[logic!] ; reverse order
][
	b: make vector! src/size/x
	rcvSortImagebyX src dst b flag
]

rcvYSortImage: function [
"Image sorting by column"
	src 	[image!] 
	dst		[image!] 
	flag 	[logic!] ; reverse order
][
	b: make vector! src/size/y
	rcvSortImagebyY src dst b flag
]



