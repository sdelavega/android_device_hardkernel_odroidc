#ifneq ($(TARGET_AMLOGIC_KERNEL),)


# for 1G DDR board, replace u-boot-1G.bin to u-boot.bin
KERNEL_DEVICETREE := meson8b_odroidc
KERNEL_DEFCONFIG := odroidc_defconfig

KERNEL_ROOTDIR := kernel
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_CONFIG := $(KERNEL_OUT)/.config
KERNEL_MODULES_INSTALL := system
KERNEL_MODULES_OUT := $(TARGET_OUT)/lib/modules
TARGET_PREBUILT_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage
BOARD_MKBOOTIMG_ARGS := --second $(KERNEL_OUT)/arch/arm/boot/dts/$(KERNEL_DEVICETREE).dtb
TARGET_AMLOGIC_INT_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage
TARGET_AMLOGIC_INT_RECOVERY_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage_recovery
MALI_OUT := $(TARGET_OUT_INTERMEDIATES)/hardware/arm/gpu/mali
UMP_OUT  := $(TARGET_OUT_INTERMEDIATES)/hardware/arm/gpu/ump
WIFI_OUT  := $(TARGET_OUT_INTERMEDIATES)/hardware/wifi
BACKPORTS_PATH := hardware/backports

PREFIX_CROSS_COMPILE=arm-linux-gnueabihf-
#arm-none-linux-gnueabi-

define cp-modules
mkdir -p $(PRODUCT_OUT)/root/boot
mkdir -p $(TARGET_OUT)/lib

#cp $(UMP_OUT)/ump.ko $(PRODUCT_OUT)/root/boot/
cp $(MALI_OUT)/mali.ko $(PRODUCT_OUT)/root/boot/
cp $(KERNEL_OUT)/arch/arm/boot/dts/$(KERNEL_DEVICETREE).dtb $(PRODUCT_OUT)/$(KERNEL_DEVICETREE).dtb
endef

define mv-modules
mdpath=`find $(KERNEL_MODULES_OUT) -type f -name modules.dep`;\
       if [ "$$mdpath" != "" ];then\
       mpath=`dirname $$mdpath`;\
       ko=`find $$mpath/kernel $$mpath/hardware $(BACKPORTS_PATH) -type f -name *.ko`;\
       for i in $$ko; do mv $$i $(KERNEL_MODULES_OUT)/; done;\
       fi
endef

define clean-module-folder
mdpath=`find $(KERNEL_MODULES_OUT) -type f -name modules.dep`;\
       if [ "$$mdpath" != "" ];then\
       mpath=`dirname $$mdpath`; rm -rf $$mpath;\
       fi
endef

$(KERNEL_OUT):
	mkdir -p $(KERNEL_OUT)

$(KERNEL_CONFIG): $(KERNEL_OUT)
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(KERNEL_DEFCONFIG)

$(TARGET_PREBUILT_KERNEL): $(KERNEL_OUT) $(KERNEL_CONFIG)
	@echo " make uImage"
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) uImage
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) modules
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) INSTALL_MOD_PATH=../../$(KERNEL_MODULES_INSTALL) INSTALL_MOD_STRIP=1 ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) modules_install
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) dtbs
	$(MAKE) -C $(BACKPORTS_PATH) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) KLIB_BUILD=../../$(KERNEL_OUT) defconfig-odroidc
	$(MAKE) -C $(BACKPORTS_PATH) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) KLIB_BUILD=../../$(KERNEL_OUT)
	$(cp-modules)
	$(mv-modules)
	$(clean-module-folder)

kerneltags: $(KERNEL_OUT)
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) tags

kernelconfig: $(KERNEL_OUT) $(KERNEL_CONFIG)
	env KCONFIG_NOTIMESTAMP=true \
	     $(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) menuconfig

savekernelconfig: $(KERNEL_OUT) $(KERNEL_CONFIG)
	env KCONFIG_NOTIMESTAMP=true \
	     $(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) savedefconfig
	cp $(KERNEL_OUT)/defconfig $(KERNEL_ROOTDIR)/customer/configs/$(KERNEL_DEFCONFIG)


#endif
