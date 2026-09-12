#!/usr/local/bin/red-cli
Red [
	Author:  "ldci"
	File: %rgbhsv2.red
]

;--https://gist.github.com/mjackson/5311256

;--Convertor RGB <> HSV
min3: function [
	a		[number!]
	b 		[number!]
	c		[number!]
	return: [number!]
][
	either a < b [mini: a] [mini: b]
	if c < mini [mini: c]
	mini
]

max3: function [
	a		[number!]
	b 		[number!]
	c		[number!]
	return: [number!]
][
	either a > b [maxi: a] [maxi: b]
	if c > maxi [maxi: c]
	maxi
]

;https://www.rapidtables.com/convert/color/rgb-to-hsv.html
;--better from a python sample
;--The RGB values are divided by 255 to change the range from 0..255 to 0..1
rgbToHsv: function [
	r 		[integer!]
	g 		[integer!]
	b 		[integer!]
	return: [block!]
][
	r: r / 255
	g: g / 255
	b: b / 255
	either r < g [mini: r] [mini: g] if b < mini [mini: b]
	either r > g [maxi: r] [maxi: g] if b > maxi [maxi: b]
	h: s: v: maxi
	delta: maxi - mini
	either maxi = 0 [s: 0][s: delta / maxi]
	;--Compute Hue 
	either maxi = mini [h: 0][
		case [
			maxi = r [ either g < b [d: 6][d: 0]
			h: (g - b) / delta + d]
			maxi = g [h: (b - r) / delta + 2]
			maxi = b [h: (r - g) / delta + 4]
		]
	]
	h: h / 6
	reduce [h s v]
]

;--With  H [0..1], S [0..1] and V [0..1] (float values)
hsvToRgb: function [
	h		[number!]
	s		[number!]
	v		[number!]
][
	i: round/floor h * 6
	f: (h * 6) - i
	p: v * (1 - s)
	q: v * (1 - f * s)
	t: v * (1 - (1 - f) * s)
	x: i % 6
	case [
		x = 0 [r: v g: t b: p]
    	x = 1 [r: q g: v b: p]
    	x = 2 [r: p g: v b: t]
    	x = 3 [r: p g: q b: v]
    	x = 4 [r: t g: p b: v]
    	x = 5 [r: v g: p b: q]
	]
	r: to integer! r * 255
	g: to integer! g * 255
	b: to integer! b * 255
	to-tuple reduce [r g b]
]

print ["RGB Values:" 200 128 16]
print ["RGB2HSV:" blk: rgbToHsv 200 128 16] 			;--37 0.92 0.784
print ["HSV2RGB:" hsvToRgb blk/1 blk/2 blk/3] 	;--200 128 16
print ""
print ["RGB Values:" 200 0 16]
print ["RGB2HSV:" blk: rgbToHsv 200 0 16]	
print ["HSV2RGB:" hsvToRgb blk/1 blk/2 blk/3] 	;--200 128 16

