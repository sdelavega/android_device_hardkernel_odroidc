SIGNJAR:=prebuilts/sdk/tools/lib/signapk.jar
KEY_PEM:=bootable/recovery/testdata/testkey.x509.pem
KEY_PK8:=bootable/recovery/testdata/testkey.pk8

#
# updatepackage-$(TARGET_DEVICE).zip
# updatepackage-$(TARGET_DEVICE)-signed.zip
#
PKGDIR=$(PRODUCT_OUT)/updatepackage

$(PRODUCT_OUT)/updatepackage.zip: $(PRODUCT_OUT)/kernel rootsystem
	rm -rf $@
	rm -rf $(PKGDIR)
	mkdir -p $(PKGDIR)/META-INF/com/google/android
	cp -a $(PRODUCT_OUT)/kernel $(PKGDIR)
	cp -a $(PRODUCT_OUT)/meson8b_odroidc.dtb $(PKGDIR)
	cp -a $(PRODUCT_OUT)/u-boot.bin $(PKGDIR)
	cp -a $(PRODUCT_OUT)/rootsystem.img $(PKGDIR)
	cp -a $(TARGET_PRODUCT_DIR)/recovery/system $(PKGDIR)
	cp -a $(PRODUCT_OUT)/system/bin/updater \
		$(PKGDIR)/META-INF/com/google/android/update-binary
	cp -a $(TARGET_PRODUCT_DIR)/recovery/updater-script.updatepackage \
		$(PKGDIR)/META-INF/com/google/android/updater-script
	( pushd $(PKGDIR); \
		zip -r $(CURDIR)/$@ * ; \
	)

$(PRODUCT_OUT)/updatepackage-$(TARGET_DEVICE)-signed.zip: \
	$(PRODUCT_OUT)/updatepackage.zip
	java -jar $(SIGNJAR) -w $(KEY_PEM) $(KEY_PK8) $< $@

.PHONY: updatepackage
updatepackage: $(PRODUCT_OUT)/updatepackage-$(TARGET_DEVICE)-signed.zip
