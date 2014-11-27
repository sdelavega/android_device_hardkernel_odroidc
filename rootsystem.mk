.PHONY: $(PRODUCT_OUT)/rootsystem/fstab.odroidc

$(PRODUCT_OUT)/rootsystem/fstab.odroidc:
	sed -i "`grep -nE '/system.ext4' $@ | cut -d : -f 1` s/ro/rw/" $@

$(PRODUCT_OUT)/rootsystem: $(BUILD_SYSTEMIMAGE)
	echo combine the directories system/ and root/ into rootsystem/.
	cp -arp $(PRODUCT_OUT)/system $(PRODUCT_OUT)/rootsystem
	rm -rf $(PRODUCT_OUT)/rootsystem/init
	rm -rf $(PRODUCT_OUT)/rootsystem/sbin/adbd
	rm -rf $(PRODUCT_OUT)/rootsystem/sbin/healthd
	cp -arp $(PRODUCT_OUT)/root/* $(PRODUCT_OUT)/rootsystem/
	mv $(PRODUCT_OUT)/rootsystem/init $(PRODUCT_OUT)/rootsystem/bin/
	mv $(PRODUCT_OUT)/rootsystem/sbin/adbd $(PRODUCT_OUT)/rootsystem/bin/
	mv $(PRODUCT_OUT)/rootsystem/sbin/healthd $(PRODUCT_OUT)/rootsystem/bin/
	ln -sf /bin/init $(PRODUCT_OUT)/rootsystem/init
	ln -sf /system/bin/adbd $(PRODUCT_OUT)/rootsystem/sbin/adbd
	ln -sf /system/bin/healthd $(PRODUCT_OUT)/rootsystem/sbin/healthd

$(PRODUCT_OUT)/rootsystem.img: $(PRODUCT_OUT)/rootsystem \
	$(PRODUCT_OUT)/rootsystem/fstab.odroidc
	echo Creating Android single root file system.
	$(MAKE_EXT4FS) -s -l $(BOARD_SYSTEMIMAGE_PARTITION_SIZE) -a system $@ $<

rootsystem.img: $(PRODUCT_OUT)/rootsystem.img
