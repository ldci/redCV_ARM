#!/usr/local/bin/red-cli
Red [
	Author:  "ldci"
	File: %rgbcmyk.red
]

;--Convertor RGB <> CMYK
;--input range 0..255
;-output range 0..1
rgbToCmyk: function [
	r 		[integer!]
	g 		[integer!]
	b 		[integer!]
	return: [block!]
][
	r: r / 255
	g: g / 255
	b: b / 255
	either r > g [maxi: r] [maxi: g] if b > maxi [maxi: b]
	k: 1.0 - maxi							;--;The black key (K) 
	either k = 1.0 [d: k] [d: (1.0 - k)]	;--Avoid / 0 error
	c: (1.0 - r - k) / d					;--The cyan color (C)
	m: (1.0 - g - k) / d					;--The magenta color (M)
	y: (1.0 - b - k) / d					;--The yellow color (Y)
	reduce [c m y k]
]

cmykToRgb: function [
	c 		[float!]
	m 		[float!]
	y 		[float!]
	k		[float!]
	return: [block!]
][
	r: to integer! (255 * (1 - c) * (1 - k))
	g: to integer! (255 * (1 - m) * (1 - k))
	b: to integer! (255 * (1 - y) * (1 - k))
	reduce [r g b]
]


