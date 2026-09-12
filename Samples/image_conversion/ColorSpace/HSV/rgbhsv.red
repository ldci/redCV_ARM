#!/usr/local/bin/red-cli
Red [
	Author:  "ldci"
	File: %rgbhsv.red
]

;--Convertor RGB <> HSV
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
	;either r < g [mini: r] [mini: g] if b < mini [mini: b]
	;either r > g [maxi: r] [maxi: g] if b > maxi [maxi: b]
	
	mini: either all [r <= g r <= b] [r] [either g <= b [g] [b]]
    maxi: either all [r >= g r >= b] [r] [either g >= b [g] [b]]
	delta: maxi - mini
	;--Compute Hue 
	either delta = 0 [h: 0][
		case [
			maxi = r [h: (60 * ((g - b) / delta) + 360) % 360]
			maxi = g [h: (60 * ((b - r) / delta) + 120) % 360]
			maxi = b [h: (60 * ((r - g) / delta) + 240) % 360]
		]
	]
	;--Compute Saturation
	either maxi = 0 [s: 0][s: delta / maxi]
	;--Compute Value
	v: maxi	
	reduce [h s v]
]

;--With  H [0..359], S [0..1] and V [0..1] (float values)
hsvToRgb: function [
	h		[number!]
	s		[number!]
	v		[number!]
	return: [block!]
][
	c: v * s
	x: c *  (1 - absolute ((h / 60) %  2) - 1)
	m: v - c
	if all [h >=   0 h <  60][rr: c gg: x bb: 0]
	if all [h >=  60 h < 120][rr: x gg: c bb: 0]
	if all [h >= 120 h < 180][rr: 0 gg: c bb: x]
	if all [h >= 180 h < 240][rr: 0 gg: x bb: c]
	if all [h >= 240 h < 300][rr: x gg: 0 bb: c]
	if all [h >= 300 h < 360][rr: c gg: 0 bb: x]
	r: to integer! round (rr + m * 255)
	g: to integer! round (gg + m * 255)
	b: to integer! round (bb + m * 255)
	reduce [r g b]
]
