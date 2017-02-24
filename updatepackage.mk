SIGNJAR:=prebuilts/sdk/tools/lib/signapk.jar

#
# updatepackage-$(TARGET_DEVICE).zip
# updatepackage-$(TARGET_DEVICE)-signed.zip
#
PKGDIR=$(PRODUCT_OUT)/updatepackage

$(PRODUCT_OUT)/updatepackage.zip: $(PRODUCT_OUT)/kernel rootsystem recovery
	rm -rf $@
	rm -rf $(PKGDIR)
	mkdir -p $(PKGDIR)/META-INF/com/google/android
	cp -a $(PRODUCT_OUT)/kernel $(PKGDIR)
	cp -a $(PRODUCT_OUT)/meson8b_odroidc.dtb $(PKGDIR)
	cp -a $(PRODUCT_OUT)/u-boot.bin $(PKGDIR)
	cp -a $(PRODUCT_OUT)/rootsystem $(PKGDIR)
	cp -a $(PRODUCT_OUT)/recovery.img $(PKGDIR)
	cp -a $(PRODUCT_OUT)/system/bin/updater \
		$(PKGDIR)/META-INF/com/google/android/update-binary
	cp -a $(TARGET_PRODUCT_DIR)/recovery/updater-script.updatepackage \
		$(PKGDIR)/META-INF/com/google/android/updater-script
	( pushd $(PKGDIR); \
		zip -r $(CURDIR)/$@ * ; \
	)

$(PRODUCT_OUT)/updatepackage-$(TARGET_DEVICE)-signed.zip: \
	$(PRODUCT_OUT)/updatepackage.zip
	java -jar $(SIGNJAR) -w \
		$(DEFAULT_KEY_CERT_PAIR).x509.pem \
		$(DEFAULT_KEY_CERT_PAIR).pk8 $< $@

.PHONY: updatepackage
updatepackage: $(PRODUCT_OUT)/updatepackage-$(TARGET_DEVICE)-signed.zip
