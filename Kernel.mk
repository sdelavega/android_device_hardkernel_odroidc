#ifneq ($(TARGET_AMLOGIC_KERNEL),)


# for 1G DDR board, replace u-boot-1G.bin to u-boot.bin
KERNEL_DEVICETREE := meson8b_odroidc

ifeq ($(TARGET_USE_SECUREOS),true)
KERNEL_DEFCONFIG := meson8b_tee_defconfig      # FIXME: What is for ODROID-C secure kernel?
else
KERNEL_DEFCONFIG := odroidc_defconfig
endif

KERNET_ROOTDIR := kernel
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_CONFIG := $(KERNEL_OUT)/.config
TARGET_PREBUILT_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage
BOARD_MKBOOTIMG_ARGS := --second $(KERNEL_OUT)/arch/arm/boot/dts/amlogic/$(KERNEL_DEVICETREE).dtb
TARGET_AMLOGIC_INT_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage
TARGET_AMLOGIC_INT_RECOVERY_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage_recovery
MALI_OUT := $(TARGET_OUT_INTERMEDIATES)/hardware/arm/gpu/mali
UMP_OUT  := $(TARGET_OUT_INTERMEDIATES)/hardware/arm/gpu/ump
WIFI_OUT  := $(TARGET_OUT_INTERMEDIATES)/hardware/wifi
MODULES_OUT_DIR := $(TARGET_PRODUCT_DIR)/drivers

PREFIX_CROSS_COMPILE=arm-linux-gnueabihf-
#arm-none-linux-gnueabi-

define cp-modules
mkdir -p $(PRODUCT_OUT)/root/boot
mkdir -p $(TARGET_OUT)/lib
mkdir -p $(MODULES_OUT_DIR)

#cp $(UMP_OUT)/ump.ko $(PRODUCT_OUT)/root/boot/
cp $(MALI_OUT)/mali.ko $(PRODUCT_OUT)/root/boot/
cp $(KERNET_ROOTDIR)/arch/arm/boot/dts/amlogic/$(KERNEL_DEVICETREE).dtd $(PRODUCT_OUT)/meson_target.dtd
cp $(KERNEL_OUT)/arch/arm/boot/meson.dtd $(PRODUCT_OUT)/meson.dtd
cp $(KERNEL_OUT)/arch/arm/boot/dts/amlogic/$(KERNEL_DEVICETREE).dtb $(PRODUCT_OUT)/meson.dtb
find $(KERNEL_OUT) -name "*.ko" | xargs -i cp {} $(MODULES_OUT_DIR)
endef

$(KERNEL_OUT):
	mkdir -p $(KERNEL_OUT)

$(KERNEL_CONFIG): $(KERNEL_OUT)
	$(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(KERNEL_DEFCONFIG)


$(TARGET_PREBUILT_KERNEL): $(KERNEL_OUT) $(KERNEL_CONFIG)
	@echo " make uImage"
	$(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) uImage
	$(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) modules
	$(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(KERNEL_DEVICETREE).dtd
	$(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(KERNEL_DEVICETREE).dtb
	$(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) dtd
	$(cp-modules)

kerneltags: $(KERNEL_OUT)
	$(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) tags

kernelconfig: $(KERNEL_OUT) $(KERNEL_CONFIG)
	env KCONFIG_NOTIMESTAMP=true \
	     $(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) menuconfig

savekernelconfig: $(KERNEL_OUT) $(KERNEL_CONFIG)
	env KCONFIG_NOTIMESTAMP=true \
	     $(MAKE) -C $(KERNET_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) savedefconfig
	cp $(KERNEL_OUT)/defconfig $(KERNET_ROOTDIR)/customer/configs/$(KERNEL_DEFCONFIG)


#endif
