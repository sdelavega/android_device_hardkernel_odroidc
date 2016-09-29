#!/bin/sh

sleep 3
SIZE="Error type 2"

function get_orientation()
{
	ORIENTATION=`getprop persist.demo.hdmirotation`
	echo $ORIENTATION
	if [ "$ORIENTATION" == "landscape" ]; then
		retval=1
	else
		retval=0
	fi
}

while true
do
	case $SIZE in
		Error*)
			echo "wm not ready"
			SIZE=`wm size`
			if [ "$SIZE" == "" ]; then
				SIZE="Error type 2"
			fi
			sleep 0.2
			get_orientation
		;;
		Physical*)
			if [ "$SIZE" == "Physical size: 640x480" ]; then
				wm density 120
				break
			elif [ "$SIZE" == "Physical size: 800x480" ]; then
				if [ "$retval" == 1 ]; then
					wm density 120
				else
					wm density 160
				fi
				break
			elif [ "$SIZE" == "Physical size: 720x480" ]; then
				wm density 120
				break
			elif [ "$SIZE" == "Physical size: 720x576" ]; then
				if [ "$retval" == 1 ]; then
					wm density 120
				else
					wm density 160
				fi
				break;
			else
				wm density 160
				break;
			fi
	esac
done
