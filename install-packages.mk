SIGNJAR:=prebuilts/sdk/tools/lib/signapk.jar

SELFINSTALL_DIR := $(PRODUCT_OUT)/selfinstall
SELFINSTALL_SIGNED_UPDATEPACKAGE := $(SELFINSTALL_DIR)/cache/update.zip
BOOTLOADER_MESSAGE := $(SELFINSTALL_DIR)/BOOTLOADER_MESSAGE
SELFINSTALL_CACHEIMAGE_SIZE := 256 # MB
SELFINSTALL_CACHE_IMAGE := $(SELFINSTALL_DIR)/cache.ext4

#
# Bootloader
#
bootable/uboot/build/u-boot-orig.bin:
	rm -rf bootable/uboot/sd_fusing/bl1.bin.hardkernel
	rm -rf bootable/uboot/sd_fusing/u-boot.bin
	make -C bootable/uboot ARCH=arm clean
	make -C bootable/uboot ARCH=arm odroidc_rev2_config
	make -C bootable/uboot ARCH=arm

.PHONY: $(PRODUCT_OUT)/bl1.bin.hardkernel
$(PRODUCT_OUT)/bl1.bin.hardkernel:
	cp -a bootable/uboot/sd_fuse/bl1.bin.hardkernel $@

$(PRODUCT_OUT)/u-boot.bin: bootable/uboot/build/u-boot-orig.bin
	cp -a bootable/uboot/sd_fuse/u-boot.bin $@

$(PRODUCT_OUT)/sd_fusing.sh:
	cp -a bootable/uboot/sd_fuse/sd_fusing.sh $@

#
# Update image : update.zip
#
UPDATE_PACKAGE_PATH := $(SELFINSTALL_DIR)/otapackages

$(SELFINSTALL_DIR)/update.unsigned.zip: userdataimage cacheimage rootsystem recoveryimage
	rm -rf $@
	rm -rf $(UPDATE_PACKAGE_PATH)
	mkdir -p $(UPDATE_PACKAGE_PATH)/META-INF/com/google/android
	cp -af $(PRODUCT_OUT)/rootsystem.img $(UPDATE_PACKAGE_PATH)
#	cp -af $(INSTALLED_USERDATAIMAGE_TARGET) $(UPDATE_PACKAGE_PATH)
	cp -af $(INSTALLED_CACHEIMAGE_TARGET) $(UPDATE_PACKAGE_PATH)
	cp -af $(PRODUCT_OUT)/system/bin/updater \
		$(UPDATE_PACKAGE_PATH)/META-INF/com/google/android/update-binary
	cp -af $(TARGET_DEVICE_DIR)/recovery/updater-script \
		$(UPDATE_PACKAGE_PATH)/META-INF/com/google/android/updater-script
	( pushd $(UPDATE_PACKAGE_PATH); \
		zip -r $(CURDIR)/$@ * ; \
	)

$(SELFINSTALL_SIGNED_UPDATEPACKAGE): $(SELFINSTALL_DIR)/update.unsigned.zip
	mkdir -p $(dir $@)
	java -jar $(SIGNJAR) -w \
		$(DEFAULT_KEY_CERT_PAIR).x509.pem \
		$(DEFAULT_KEY_CERT_PAIR).pk8 $< $@

$(BOOTLOADER_MESSAGE):
	mkdir -p $(dir $@)
	dd if=/dev/zero of=$@ bs=16 count=4	# 64 Bytes
	echo "recovery" >> $@
	echo "--locale=en_US" >> $@
	echo "--selfinstall" >> $@
	echo "--update_package=CACHE:update.zip" >> $@

.PHONY: $(SELFINSTALL_DIR)/cache
$(SELFINSTALL_DIR)/cache: $(SELFINSTALL_SIGNED_UPDATEPACKAGE) $(BOOTLOADER_MESSAGE)
	cp -af $(PRODUCT_OUT)/cache/ $(SELFINSTALL_DIR)/

$(SELFINSTALL_DIR)/cache.img: $(SELFINSTALL_DIR)/cache
	$(MAKE_EXT4FS) -s -L cache -a cache \
		-l $(BOARD_CACHEIMAGE_PARTITION_SIZE) $@ $<

$(SELFINSTALL_CACHE_IMAGE): $(SELFINSTALL_DIR)/cache.img
	simg2img $? $@

#
# Android Self-Installation
#
$(PRODUCT_OUT)/selfinstall-$(TARGET_DEVICE).bin: \
	$(INSTALLED_BOOTIMAGE_TARGET) \
	$(INSTALLED_RECOVERYIMAGE_TARGET) \
	$(PRODUCT_OUT)/bl1.bin.hardkernel \
	$(PRODUCT_OUT)/u-boot.bin \
	$(PRODUCT_OUT)/sd_fusing.sh \
	$(SELFINSTALL_CACHE_IMAGE)
	@echo "Creating installable single image file..."
	dd if=$(PRODUCT_OUT)/bl1.bin.hardkernel of=$@ bs=1 count=442
	dd if=$(PRODUCT_OUT)/bl1.bin.hardkernel of=$@ bs=512 skip=1 seek=1
	dd if=$(PRODUCT_OUT)/u-boot.bin of=$@ bs=512 seek=64
	dd if=$(BOOTLOADER_MESSAGE) of=$@ bs=512 seek=1432
	dd if=$(PRODUCT_OUT)/meson8b_odroidc.dtb of=$@ bs=512 seek=1504
	dd if=$(PRODUCT_OUT)/kernel of=$@ bs=512 seek=1632
	dd if=$(INSTALLED_RECOVERYIMAGE_TARGET) of=$@ bs=512 seek=34400
	dd if=$(PRODUCT_OUT)/hardkernel-720.bmp.gz \
		of=$@ bs=512 seek=58976
	dd if=$(SELFINSTALL_CACHE_IMAGE) of=$@ bs=512 seek=65536
	sync
	@echo "Done."

.PHONY: selfinstall
selfinstall: $(PRODUCT_OUT)/selfinstall-$(TARGET_DEVICE).bin
