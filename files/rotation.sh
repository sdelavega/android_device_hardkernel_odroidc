#!/bin/sh

mount -o rw,remount /system
if [ "$1" == "portrait" ]; then # if portrait
    sed -i s/persist.demo.hdmirotation=landscape/persist.demo.hdmirotation=portrait/g /system/build.prop
    if [ "$2" == "90" ]; then # if degree == 90
        sed -i s/ro.sf.hwrotation=0/ro.sf.hwrotation=90/g /system/build.prop
        sed -i s/ro.sf.hwrotation=270/ro.sf.hwrotation=90/g /system/build.prop
    else # else
        sed -i s/ro.sf.hwrotation=0/ro.sf.hwrotation=270/g /system/build.prop
        sed -i s/ro.sf.hwrotation=90/ro.sf.hwrotation=270/g /system/build.prop
    fi
    sed -i s/config.override_forced_orient=false/config.override_forced_orient=true/g /system/build.prop
    setprop config.override_forced_orient true
    setprop persist.demo.hdmirotation portrait
elif [ "$1" == "landscape" ]; then # else landscape
    sed -i s/persist.demo.hdmirotation=portrait/persist.demo.hdmirotation=landscape/g /system/build.prop
    sed -i s/ro.sf.hwrotation=90/ro.sf.hwrotation=0/g /system/build.prop
    sed -i s/ro.sf.hwrotation=270/ro.sf.hwrotation=0/g /system/build.prop
    sed -i s/config.override_forced_orient=true/config.override_forced_orient=false/g /system/build.prop
    setprop config.override_forced_orient false
fi
setprop persist.demo.hdmirotation $1
mount -o ro,remount /system
