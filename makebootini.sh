#!/bin/sh

while true
do
    sleep 1
    if [ -e "/sdcard/boot.ini" ]
    then
        break
    else
        cp /system/etc/boot.ini.template /sdcard/boot.ini
    fi
done
