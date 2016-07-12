#!/bin/sh

SIZE=`wm size`

ORIENTATION=`getprop persist.demo.hdmirotation`
echo $ORIENTATION
if [ "$ORIENTATION" == "landscape" ]; then
	retval=1
else
	retval=0
fi

if [ "$SIZE" == "Physical size: 640x480" ]; then
	wm density 120
elif [ "$SIZE" == "Physical size: 800x480" ]; then
	if [ "$retval" == 1 ]; then
		wm density 120
	else
		wm density 160
	fi
elif [ "$SIZE" == "Physical size: 720x480" ]; then
	wm density 120
elif [ "$SIZE" == "Physical size: 720x576" ]; then
	if [ "$retval" == 1 ]; then
		wm density 120
	else
		wm density 160
	fi
else
	wm density 160
fi
