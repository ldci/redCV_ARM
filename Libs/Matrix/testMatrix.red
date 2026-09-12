Red[
]


#system [
    rcv-get-int: func [p [byte-ptr!] unit [integer!] return: [integer!]][
        vector/get-value-int as int-ptr! p unit
    ]
]

;********************** NEW MATRIX OBJECT **************************

#include %matrix-as-obj/matrix-obj.red
#include %matrix-as-obj/routines-obj.red

bi: [1 2 3 4 5 6 7 8 9]
m1: matrix/create 2 16 3x3 bi

matrix/show m1

rcvGetMatType: routine [
"Returns matrix type (integer or float)"
	mObj  	[object!]
	return: [integer!]
	/local
	vec 	[red-vector!]
	unit	[integer!] 
	type	[integer!]
] [
	vec: mat/get-data mObj
	switch vec/type [
		TYPE_CHAR 		[type: 1]
		TYPE_INTEGER 	[type: 2]
		TYPE_FLOAT		[type: 3]
	]
	type
]

rcvGetMatUnit: routine [
"Returns matrice unit"
	mObj  	[object!] ;--replace [vector!]
	return: [integer!]
] [
	mat/get-unit mObj
]

rcvGetMatData: routine [
"Returns matrice data"
	mObj  	[object!] ;--replace [vector!]
	return: [vector!]
][
	mat/get-data mObj
]

rcvGetIntValue: routine [
"Get integer matrix value"
	p		[integer!] ; address of mat element 
	unit	[integer!] ; size of integer 8 16 32 [1 2 4]
	return:	[integer!]
] [
	vector/get-value-int as int-ptr! p unit
]

rcvGetInt2D: routine [
    "Get integer matrix value"
    mObj        [object!]
    x           [integer!]  ; x coordinate      
    y           [integer!]  ; y coordinate
    return:     [integer!]
    /local
    vec         [red-vector!]
    width       [integer!]  ; matrix width
    mvalue      [byte-ptr!]
    unit        [integer!]
    idx         [integer!]
][
    vec: mat/get-data mObj         
    unit: mat/get-unit mObj         
    width: mat/get-cols mObj        
    mvalue: vector/rs-head vec      
    
    ; Correction de la priorité : (y - 1) * width
    idx: (y - 1) * width + x        ;-- red 1-based index
    idx: (idx - 1) * unit           ;-- red/S 0-based offset in bytes
    
    ; On inline le code de rcvGetIntValue
    vector/get-value-int as int-ptr! (mvalue + idx) unit
]

rcvSetInt2D: routine [
    "Set integer matrix value"
    mObj        [object!]
    x           [integer!]
    y           [integer!]
    val         [integer!]
    /local
    vec         [red-vector!]
    width       [integer!]
    mvalue      [byte-ptr!]      ;-- Très important : byte-ptr! pour l'arithmétique de pointeur
    unit        [integer!]
    idx         [integer!]
    p4          [int-ptr!]
][
    vec: mat/get-data mObj
    unit: mat/get-unit mObj
    width: mat/get-cols mObj
    mvalue: vector/rs-head vec
    
    idx: (y - 1) * width + x       ;-- Parenthèses obligatoires pour (y - 1)
    idx: (idx - 1) * unit          ;-- Parenthèses obligatoires pour (idx - 1)
    
    p4: as int-ptr! (mvalue + idx) ;-- On caste l'adresse exacte en int-ptr!
    
    p4/value: switch unit [
        1 [val and FFh or (p4/value and FFFFFF00h)]
        2 [val and FFFFh or (p4/value and FFFF0000h)]
        4 [val]
    ]
]



;--get value at given row and col
_getAt: func [
	mx		[object! vector!]
	row		[integer!] 
	col		[integer!]
	/only
		cols [integer!]
][
	either all [only vector? mx] 
		[pick mx (row - 1) * cols + col]
		[pick mx/data row - 1 * mx/cols + col]
]

;--set value at given row and col
_setAt: func [
	mx		[object! vector!]
	row		[integer!] 
	col		[integer!]
	value 	[scalar!]
	/only
	cols [integer!]
	][
		either all [only vector? mx] [
			poke mx (row - 1) * cols + col value
		][
			poke mx/data (row - 1) * mx/cols + col value
	]
]


print ["Mat type " rcvGetMatType m1]
print ["Mat unit " rcvGetMatUnit m1]
print ["Mat data " rcvGetMatData m1]
print ["val 3x3 " v: _getAt m1 3 3]
print ["val 3x3 " rcvGetInt2D m1 3 3]
_setAt m1 2 2 0
matrix/show m1
rcvSetInt2D m1 1 1 0
matrix/show m1
