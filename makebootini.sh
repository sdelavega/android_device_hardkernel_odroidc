#!/bin/sh
if [ -f "/storage/sdcard0/boot.ini" ]
then
    break
else
    cp /system/etc/boot.ini.template /storage/sdcard0/boot.ini
fi
