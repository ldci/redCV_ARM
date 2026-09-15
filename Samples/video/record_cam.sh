#!/bin/bash
ffmpeg -f avfoundation -framerate 30 -video_size 1280x720 -i "0:2" -c:v mpeg2video -b:v 6000k -r 30 -y "/Users/fjouen/Programmation/Red_ARM/code/RedCV_ARM/Samples/video/Untitled.mpg"
