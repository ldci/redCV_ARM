Red [
]
_rcvSobelMat: routine [
    "Fast Sobel on Matrix"
    src     [vector!]
    dst     [vector!]
    mSize   [pair!]
    /local
        svalue dvalue       [int-ptr!]  ; Pointeurs sur entiers, parfait pour le pas de 4 octets
        idx                 [int-ptr!]
        h w cx cy x y       [integer!]
        gx gy sum v         [integer!]
        xGrad yGrad         [subroutine!]
        p					[int-ptr!]
][
    ; Accès direct et propre au buffer du vecteur (pas besoin de GET_BUFFER)
    svalue: as int-ptr! src/offset
    dvalue: as int-ptr! dst/offset
    
    w: mSize/x
    h: mSize/y

    ; --- Subroutines ---
    xGrad: [
        if x < 1 [x: w - 1]
        if y < 1 [y: h - 1]
        if x >= (w - 1) [x: 1]
        if y >= (h - 1) [y: 1]
        
        sum: 0
        
        ; L'avantage de int-ptr! : le + 1 avance de 4 octets tout seul !
        idx: svalue + (((y - 1) * w) + (x - 1))
        sum: sum + idx/value
        
        idx: svalue + ((y * w) + (x - 1))
        sum: sum + (idx/value * 2)
        
        idx: svalue + (((y + 1) * w) + (x - 1))
        sum: sum + idx/value
        
        ; --- Partie droite (négatifs) ---
        idx: svalue + (((y - 1) * w) + (x + 1))
        sum: sum - idx/value
        
        idx: svalue + ((y * w) + (x + 1))
        sum: sum - (idx/value * 2)
        
        idx: svalue + (((y + 1) * w) + (x + 1))
        sum: sum - idx/value
        
        gx: sum
    ]
    
    yGrad: [
        if x < 1 [x: w - 1]
        if y < 1 [y: h - 1]
        if x >= (w - 1) [x: 1]
        if y >= (h - 1) [y: 1]
        p: svalue
        sum: 0
        sum: sum + v
    	idx: p + (y - 1 * w) + x 
    	v: vector/get-value-int as int-ptr! idx 1
    	sum: sum + (v * 2)
    	idx: p + (y - 1 * w) + (x + 1) 
    	v: vector/get-value-int as int-ptr! idx 1
    	sum: sum + v
    	idx: p + (y + 1 * w) + (x - 1) 
    	v: vector/get-value-int as int-ptr! idx 1
    	sum: sum - v
    	idx: p + (y + 1 * w) + x 
    	v: vector/get-value-int as int-ptr! idx 1
    	sum: sum - (v * 2)
    	idx: p + (y + 1 * w) + (x + 1) 
    	v: vector/get-value-int as int-ptr! idx 1
    	sum: sum - v
    	sum
        gy: sum
    ]

    ; --- Boucle principale ---
    cy: 0
    while [cy < h] [
        cx: 0
        while [cx < w] [
            x: cx y: cy
            xGrad
            
            x: cx y: cy
            yGrad
            
            ; Combinaison (à adapter si tu veux sqrt, etc.)
            v: abs gx + abs gy 
            
            ; Écriture directe dans le buffer de destination
            dvalue/value: v
            dvalue: dvalue + 1
            
            cx: cx + 1
        ]
        cy: cy + 1
    ]
]