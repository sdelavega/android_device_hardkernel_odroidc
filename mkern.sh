#!/bin/bash -ex

# Run from top of kitkat source

ROOTFS=$1
#ROOTFS="../lpdk/out/target/product/odroidc/ramdisk.img"

if [ "$ROOTFS" == "" -o ! -f "$ROOTFS" ]; then
    echo "Usage: $0 <ramdisk.img>"
    exit 1
fi

KERNEL_OUT=out/target/product/odroidc/obj/KERNEL_OBJ
mkdir -p $KERNEL_OUT

if [ ! -f $KERNEL_OUT/.config ]; then
    make -C common O=../$KERNEL_OUT odroidc_defconfig
fi
make -C common O=../$KERNEL_OUT uImage -j6
make -C common O=../$KERNEL_OUT modules -j6

make -C common O=../$KERNEL_OUT meson8b_odroidc.dtd
make -C common O=../$KERNEL_OUT meson8b_odroidc.dtb


common/mkbootimg --kernel common/../$KERNEL_OUT/arch/arm/boot/uImage \
    --ramdisk ${ROOTFS} \
    --second common/../$KERNEL_OUT/arch/arm/boot/dts/amlogic/meson8b_odroidc.dtb \
    --output ./boot.img
ls -l ./boot.img
echo "boot.img done"
