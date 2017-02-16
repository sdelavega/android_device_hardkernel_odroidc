#!/bin/sh

for x in $(lsusb); do
	echo $x
	if [ "$x" == "16b4:0703" ]; then

		result=`getprop wlan.driver.status`

		if [ "$result" == "ok" ]; then
			svc wifi disable
		fi

		echo 4 > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio4/direction
		sleep 1
		echo 0 > /sys/class/gpio/gpio4/value
		sleep 1
		echo 1 > /sys/class/gpio/gpio4/value
		echo 4 > /sys/class/gpio/unexport

		if [ "$result" == "ok" ]; then
			sleep 3
			svc wifi enable
		fi

	fi
done
