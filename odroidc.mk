# Copyright (C) 2011 Amlogic Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This file is the build configuration for a full Android
# build for MX reference board. This cleanly combines a set of
# device-specific aspects (drivers) with a device-agnostic
# product configuration (apps).
#


# Inherit from those products. Most specific first.
$(call inherit-product-if-exists, vendor/google/products/gms.mk)
$(call inherit-product, device/hardkernel/odroidc/device.mk)
#$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Replace definitions used by tablet in mid_amlogic.mk above
# Overrides
PRODUCT_BRAND := ODROID
PRODUCT_DEVICE := odroidc
PRODUCT_NAME := odroidc
PRODUCT_CHARACTERISTICS := odroidc

include frameworks/native/build/mbox-1024-dalvik-heap.mk

# Discard inherited values and use our own instead.
PRODUCT_MANUFACTURER := HardKernel Co., Ltd.
PRODUCT_MODEL := ODROIDC
# PRODUCT_CHARACTERISTICS := tablet,nosdcard

# for security boot
#TARGET_USE_SECURITY_MODE :=true

#framebuffer use 3 buffers
TARGET_USE_TRIPLE_FB_BUFFERS := true

BOARD_USES_AML_SENSOR_HAL := true

#########################################################################
#
#                                                Audio
#
#########################################################################

#possible options: 1 tiny 2 legacy
BOARD_ALSA_AUDIO := tiny
BOARD_AUDIO_CODEC := amlpmu3
BOARD_USE_USB_AUDIO := true

ifneq ($(strip $(wildcard $(LOCAL_PATH)/mixer_paths.xml)),)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/mixer_paths.xml:system/etc/mixer_paths.xml
endif

include device/hardkernel/common/audio.mk

ifeq ($(BOARD_ALSA_AUDIO),legacy)
PRODUCT_PROPERTY_OVERRIDES += \
    alsa.mixer.capture.master=Digital \
    alsa.mixer.capture.headset=Digital \
    alsa.mixer.capture.earpiece=Digital
endif

#########################################################################
#
#                                                USB
#
#########################################################################

BOARD_USES_USB_PM := true

#########################################################################
#
#                                                WiFi
#
#########################################################################
WIFI_DRIVER             := rtl8192cu
BOARD_WIFI_VENDOR       := realtek
BOARD_WLAN_DEVICE       := rtl8192cu
WIFI_DRIVER_MODULE_PATH := /system/lib/modules/8192cu.ko
WIFI_DRIVER_MODULE_NAME := 8192cu
WIFI_DRIVER_FW_PATH_STA := none
WIFI_DRIVER_MODULE_ARG  := "ifname=wlan0 if2name=p2p0"

WIFI_DRIVER_MODULE_NAME2            := rt2800usb
WIFI_DRIVER_MODULE_PATH2            := /system/lib/modules/rt2800usb.ko

WPA_SUPPLICANT_VERSION           := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
CONFIG_DRIVER_WEXT               := y
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_nl80211
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_nl80211

WIFI_FIRMWARE_LOADER      := ""
WIFI_DRIVER_FW_PATH_STA   := ""
WIFI_DRIVER_FW_PATH_AP    := ""
WIFI_DRIVER_FW_PATH_P2P   := ""
WIFI_DRIVER_FW_PATH_PARAM := ""

PRODUCT_PROPERTY_OVERRIDES += \
        wifi.interface=wlan0 \

# Change this to match target country
# 11 North America; 14 Japan; 13 rest of world
PRODUCT_DEFAULT_WIFI_CHANNELS := 13

PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \

PRODUCT_PACKAGES += \
        wpa_supplicant.conf \
        wpa_supplicant_overlay.conf \
        p2p_supplicant_overlay.conf

#########################################################################
#
#                                                GPS
#
#########################################################################

GPS_MODULE :=
include device/hardkernel/common/gps.mk



#########################################################################
#
#                                                Init.rc
#
#########################################################################

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/init.odroidc.rc:root/init.odroidc.rc \
	$(LOCAL_PATH)/init.odroidc.usb.rc:root/init.odroidc.usb.rc \
	$(LOCAL_PATH)/ueventd.odroidc.rc:root/ueventd.odroidc.rc \
	$(LOCAL_PATH)/fstab.odroidc:root/fstab.odroidc

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/init.odroidc.board.rc:root/init.odroidc.board.rc \
	$(LOCAL_PATH)/init.odroidc.wifi.rc:root/init.odroidc.wifi.rc

#########################################################################
#
#                                                languages
#
#########################################################################

# For all locales, $(call inherit-product, build/target/product/languages_full.mk)
PRODUCT_LOCALES := en_US fr_FR it_IT es_ES de_DE nl_NL cs_CZ pl_PL ja_JP zh_TW zh_CN ru_RU \
   ko_KR nb_NO es_US da_DK el_GR tr_TR pt_PT pt_BR rm_CH sv_SE bg_BG ca_ES en_GB fi_FI hi_IN \
   hr_HR hu_HU in_ID iw_IL lt_LT lv_LV ro_RO sk_SK sl_SI sr_RS uk_UA vi_VN tl_PH ar_EG fa_IR \
   th_TH sw_TZ ms_MY af_ZA zu_ZA am_ET hi_IN


#########################################################################
#
#                                                Software features
#
#########################################################################

BUILD_WITH_AMLOGIC_PLAYER := true
BUILD_WITH_APP_OPTIMIZATION := true
#BUILD_WITH_MARLIN := true
BUILD_WITH_EREADER := false
BUILD_WITH_MIRACAST := false
#BUILD_WITH_XIAOCONG := true
BUILD_WITH_THIRDPART_APK := false
BUILD_WITH_BOOT_PLAYER:= true
BUILD_AMVIDEO_CAPTURE_TEST:=false
ifeq ($(wildcard vendor/google/products/gms.mk),)
# facelock enable, board should have front camera
BUILD_WITH_FACE_UNLOCK := true
endif

include device/hardkernel/common/software.mk

#########################################################################
#
#                                                Misc
#
#########################################################################


# The OpenGL ES API level that is natively supported by this device.
# This is a 16.16 fixed point number
PRODUCT_PROPERTY_OVERRIDES += \
	ro.opengles.version=131072


PRODUCT_PACKAGES += \
        OdroidUpdater \
        Utility \
	VideoPlayer \
	SubTitle \
	remotecfg \
	RC_Server \
	Discovery.apk \
	IpRemote.apk \
	PromptUser \
	libasound \
	alsalib-alsaconf \
	alsalib-pcmdefaultconf \
	alsalib-cardsaliasesconf \
	libamstreaming \
	bootplayer

# Libs
PRODUCT_PACKAGES += \
	com.android.future.usb.accessory

# Device specific system feature description
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/Third_party_apk_camera.xml:system/etc/Third_party_apk_camera.xml \
	frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
	frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml


PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/alarm_blacklist.txt:/system/etc/alarm_blacklist.txt \
	$(LOCAL_PATH)/alarm_whitelist.txt:/system/etc/alarm_whitelist.txt \
	$(LOCAL_PATH)/remote.conf:system/etc/remote.conf \
	$(LOCAL_PATH)/default_shortcut.cfg:system/etc/default_shortcut.cfg


PRODUCT_COPY_FILES += \
	device/hardkernel/common/res/screen_saver/dlna.jpg:system/media/screensaver/images/dlna.jpg \
	device/hardkernel/common/res/screen_saver/miracast.jpg:system/media/screensaver/images/miracast.jpg \
	device/hardkernel/common/res/screen_saver/phone_remote.jpg:system/media/screensaver/images/phone_remote.jpg

#low memory killer
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/lowmemorykiller.txt:/system/etc/lowmemorykiller.txt

# App optimization
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/liboptimization.so:system/lib/liboptimization.so \
	$(LOCAL_PATH)/config:system/etc/config  \
    $(LOCAL_PATH)/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/res_pack/hardkernel-720.bmp:$(PRODUCT_OUT)/hardkernel-720.bmp

# U-boot Env Tools
PRODUCT_PACKAGES += \
        fw_printenv \
        fw_setenv

PRODUCT_COPY_FILES += \
        $(LOCAL_PATH)/fw_env/fw_env.config:root/etc/fw_env.config

# inherit from the non-open-source side, if present
$(call inherit-product-if-exists, device/hardkernel/proprietary/proprietary.mk)
$(call inherit-product-if-exists, vendor/hardkernel/odroidc/device-vendor.mk)
