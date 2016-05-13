#!/bin/sh

while true
do
    sleep 1
    if [ -f "/storage/sdcard0/boot.ini" ]
    then
        break
    else
        cp /system/etc/boot.ini.template /storage/sdcard0/boot.ini
    fi
done
