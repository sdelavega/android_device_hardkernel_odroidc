SIGNJAR:=prebuilts/sdk/tools/lib/signapk.jar

#
# Bootloader
#
bootable/uboot/build/u-boot-orig.bin:
	make -C bootable/uboot odroidc_config
	make -C bootable/uboot

.PHONY: $(PRODUCT_OUT)/bl1.bin.hardkernel
$(PRODUCT_OUT)/bl1.bin.hardkernel:
	cp -a bootable/uboot/sd_fuse/bl1.bin.hardkernel $@

$(PRODUCT_OUT)/u-boot.bin: bootable/uboot/build/u-boot-orig.bin
	cp -a bootable/uboot/sd_fuse/u-boot.bin $@

#
# Update image : update.zip
#
UPDATE_PACKAGE_PATH=$(PRODUCT_OUT)/otapackages

.PHONY: $(PRODUCT_OUT)/.update-orig.zip
$(PRODUCT_OUT)/.update-orig.zip: userdataimage cacheimage rootsystem recoveryimage
	rm -rf $@
	rm -rf $(UPDATE_PACKAGE_PATH)
	mkdir -p $(UPDATE_PACKAGE_PATH)/META-INF/com/google/android
	cp -a $(PRODUCT_OUT)/rootsystem.img $(UPDATE_PACKAGE_PATH)
	cp -a $(INSTALLED_USERDATAIMAGE_TARGET) $(UPDATE_PACKAGE_PATH)
	cp -a $(INSTALLED_CACHEIMAGE_TARGET) $(UPDATE_PACKAGE_PATH)
	cp -a $(TARGET_PRODUCT_DIR)/recovery/system $(UPDATE_PACKAGE_PATH)
	cp -a $(PRODUCT_OUT)/system/bin/updater \
		$(UPDATE_PACKAGE_PATH)/META-INF/com/google/android/update-binary
	cp -a $(TARGET_PRODUCT_DIR)/recovery/updater-script \
		$(UPDATE_PACKAGE_PATH)/META-INF/com/google/android/updater-script
	( pushd $(UPDATE_PACKAGE_PATH); \
		zip -r $(CURDIR)/$@ * ; \
	)

RECOVERY_MESSAGE_FILE := $(PRODUCT_OUT)/.recovery.message.txt

$(PRODUCT_OUT)/update.zip: $(PRODUCT_OUT)/.update-orig.zip
	java -jar $(SIGNJAR) -w \
		$(DEFAULT_KEY_CERT_PAIR).x509.pem \
		$(DEFAULT_KEY_CERT_PAIR).pk8 $< $@
	dd if=/dev/zero of=$(RECOVERY_MESSAGE_FILE) bs=4 count=16	# 64 Bytes
	echo "recovery" >>$(RECOVERY_MESSAGE_FILE)
	echo "--locale=en_US" >> $(RECOVERY_MESSAGE_FILE)
	echo "--selfinstall" >> $(RECOVERY_MESSAGE_FILE)
	echo "--update_package=CACHE:update.zip" >> $(RECOVERY_MESSAGE_FILE)

.PHONY: update.zip
update.zip: $(PRODUCT_OUT)/update.zip

.PHONY: $(PRODUCT_OUT)/obj/installpackage
$(PRODUCT_OUT)/obj/installpackage: $(PRODUCT_OUT)/update.zip
	rm -rf $@
	mkdir -p $@
	cp -a $(PRODUCT_OUT)/cache/* $(PRODUCT_OUT)/obj/installpackage/
	cp -a $< $(PRODUCT_OUT)/obj/installpackage/

$(PRODUCT_OUT)/installpackage.img: $(PRODUCT_OUT)/obj/installpackage
	$(MAKE_EXT4FS) -s -l $(BOARD_CACHEIMAGE_PARTITION_SIZE) -a cache $@ $<

.PHONY: installpackage.img
installpackage.img: $(PRODUCT_OUT)/installpackage.img

#
# Installation Android Image file
#
$(PRODUCT_OUT)/selfinstall-$(TARGET_DEVICE).bin: \
	$(INSTALLED_BOOTIMAGE_TARGET) \
	$(INSTALLED_RECOVERYIMAGE_TARGET) \
	$(PRODUCT_OUT)/bl1.bin.hardkernel \
	$(PRODUCT_OUT)/u-boot.bin \
	$(PRODUCT_OUT)/installpackage.img
	@echo "Creating installable single image file..."
	dd if=$(PRODUCT_OUT)/bl1.bin.hardkernel of=$@ bs=1 count=442
	dd if=$(PRODUCT_OUT)/bl1.bin.hardkernel of=$@ bs=512 skip=1 seek=1
	dd if=$(PRODUCT_OUT)/u-boot.bin of=$@ bs=512 seek=64
	dd if=$(RECOVERY_MESSAGE_FILE) of=$@ bs=512 seek=1016
	dd if=$(PRODUCT_OUT)/meson8b_odroidc.dtb of=$@ bs=512 seek=1088
	dd if=$(PRODUCT_OUT)/kernel of=$@ bs=512 seek=1216
	dd if=$(INSTALLED_RECOVERYIMAGE_TARGET) of=$@ bs=512 seek=17600
	dd if=$(PRODUCT_OUT)/hardkernel-720.bmp of=$@ bs=512 seek=33984
	dd if=$(PRODUCT_OUT)/installpackage.img of=$@ bs=512 seek=49152
	sync
	@echo "Done."

.PHONY: selfinstall
selfinstall: $(PRODUCT_OUT)/selfinstall-$(TARGET_DEVICE).bin
