#!/usr/local/bin/red-view
Red [
    Title:   "Red camera and ffmpeg (macOS only)"
    Author:  "ldci"
    File:     %recordCam.red
    Needs:    View
]

camSize: 1280x720
videoSize: form camSize
iSize: camSize / 2
cam: none
fileName: "Untitled.mpg"
vDevice: 0
aDevice: 2          ;-- Micro iMac (pas 0 = Teams Audio)
frameRate: 30
count: 0
t1: now/time
isFile: false
margins: 5x5

my-alert: func [msg [string!]][
    view/flags [
        title "Alert"
        text msg
        button "OK" [unview]
    ][modal popup]
]

;--Create video file
createVideo: does [
    tmp: request-file/save/filter [
        "Format mpg"  "*.mpg"
        "Format mp4"  "*.mp4"
        "Format mov"  "*.mov"
    ]
    if tmp [
        fileName: form tmp
        win/text: fileName
        isFile: true
    ]
]

;--Get video properties
getVideoInfo: does [
    img: to-image cam
    cSize/text: form img/size
    img: none
    frate/text: form frameRate
]

;--Create ffmpeg shell script
generateCommands: does [
    write %record_cam.sh rejoin [
        {#!/bin/bash} newline
        {ffmpeg -f avfoundation -framerate } frameRate
        { -video_size } videoSize
        { -i "} vDevice ":" aDevice {"}
        { -c:v mpeg2video -b:v 6000k -r } frameRate
        { -y "} fileName {"} newline
    ]
    call "chmod +x record_cam.sh"
]

getVideoSize: does [
    attempt [round/to ((size? to-file fileName) / 1000000.0) 0.01]
]

;*************************** Main ******************************
view win: layout [
    title "Red camera recording with ffmpeg"
    origin margins space margins

    text 50 bold "Output"
    drop-down 85 data ["1280x720" "640x480"]
        select 1
        on-change [videoSize: face/data/(face/selected)]

    sl: slider 100x25 [
        frameRate: 1 + to-integer (sl/data * 29)
        ffps/text: rejoin [frameRate " fps"]
    ]
    ffps: field 45

    button "Create Video" on-click [createVideo]

    b1: button 50 "Start" on-click [
        either isFile [
            either cam/selected [
                call "killall ffmpeg"
                cam/selected: none
                tF/rate: sF/rate: none
                count: 0
                b1/text: "Start"
                sF/text: rejoin [getVideoSize " Mo"]
                isFile: false
            ][
                generateCommands
                ;probe read %record_cam.sh        ;--debug: vois le script
                call "./record_cam.sh"           ;--lance le script
                cam/selected: 1
                if count = 0 [getVideoInfo]
                count: count + 1
                b1/text: "Stop"
                t1: now/time
                tF/rate: sF/rate: 0:0:1
            ]
        ][
            my-alert "Create video first!"
        ]
    ]

    button "Quit" 50 on-click [call "killall ffmpeg" quit]

    return
    cam: camera iSize black

    return
    camList: drop-list 230
        on-create [face/data: cam/data]
        on-change [vDevice: camList/selected - 1]
    text 40 bold "Size"
    cSize: field 70
    text 30 bold "FPS"
    frate: field 30
    tF: field 60 on-time [face/text: form now/time - t1]
    sF: field 110 right on-time [
        face/text: rejoin [getVideoSize " Mo"]
        recycle
    ]

    do [
        camList/selected: 1
        vDevice: 0
        tF/rate: none
        sl/data: 100%
        frameRate: 30
        ffps/text: rejoin [frameRate " fps"]
    ]
]