ALLOW_MISSING_DEPENDENCIES=true
# Default A/B configuration.
ENABLE_AB := false
# Enable virtual-ab by default
ENABLE_VIRTUAL_AB := false

ifeq ($(ENABLE_VIRTUAL_AB), true)
    $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
endif
SHIPPING_API_LEVEL := 28
# Enable Dynamic partitions only for Q new launch devices.
ifeq (true,$(call math_gt_or_eq,$(SHIPPING_API_LEVEL),29))
  BOARD_DYNAMIC_PARTITION_ENABLE := true
  PRODUCT_SHIPPING_API_LEVEL := $(SHIPPING_API_LEVEL)

  # f2fs utilities
  PRODUCT_PACKAGES += \
   sg_write_buffer \
   f2fs_io \
   check_f2fs

  # Userdata checkpoint
  PRODUCT_PACKAGES += \
   checkpoint_gc

  ifeq ($(ENABLE_AB), true)
    AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true
  endif
else ifeq ($(SHIPPING_API_LEVEL),28)
  BOARD_DYNAMIC_PARTITION_ENABLE := false
  $(call inherit-product, build/make/target/product/product_launched_with_p.mk)
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
endif

# For QSSI builds, we skip building the system image. Instead we build the
# "non-system" images (that we support).
PRODUCT_BUILD_SYSTEM_IMAGE := false
PRODUCT_BUILD_SYSTEM_OTHER_IMAGE := false
PRODUCT_BUILD_VENDOR_IMAGE := true
PRODUCT_BUILD_PRODUCT_IMAGE := false
PRODUCT_BUILD_SYSTEM_EXT_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := false
PRODUCT_BUILD_CACHE_IMAGE := true
PRODUCT_BUILD_USERDATA_IMAGE := true

# Also, since we're going to skip building the system image, we also skip
# building the OTA package. We'll build this at a later step.
TARGET_SKIP_OTA_PACKAGE := true

# Enable AVB 2.0
BOARD_AVB_ENABLE := true

ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
# Enable chain partition for system, to facilitate system-only OTA in Treble.
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
else
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_PACKAGES += fastbootd
ifeq ($(ENABLE_AB), true)
PRODUCT_COPY_FILES += $(LOCAL_PATH)/default/fstab_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.default
PRODUCT_COPY_FILES += $(LOCAL_PATH)/emmc/fstab_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.emmc
else
PRODUCT_COPY_FILES += $(LOCAL_PATH)/default/fstab_non_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.default
PRODUCT_COPY_FILES += $(LOCAL_PATH)/emmc/fstab_non_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.emmc
endif
BOARD_AVB_VBMETA_SYSTEM := system
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
$(call inherit-product, build/make/target/product/gsi_keys.mk)
endif

#privapp-permissions whitelisting
PRODUCT_PROPERTY_OVERRIDES += ro.control_privapp_permissions=log

#target name, shall be used in all makefiles
TRINKET := trinket
TARGET_VENDOR := xiaomi
TARGET_DEFINES_DALVIK_HEAP := true
$(call inherit-product, device/qcom/vendor-common/common64.mk)

#Inherit all dalvik properties for 4GB device
$(call inherit-product, frameworks/native/build/phone-xhdpi-4096-dalvik-heap.mk)

PRODUCT_NAME := ginkgo
PRODUCT_DEVICE := ginkgo
PRODUCT_BRAND := Xiaomi
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := Redmi Note 8

#Initial bringup flags
TARGET_USES_AOSP := false
TARGET_USES_AOSP_FOR_AUDIO := false
TARGET_USES_QCOM_BSP := false

# RRO configuration
TARGET_USES_RRO := true

# Fingerprint
PRODUCT_PACKAGES += \
    FingerprintExtensionService \
    android.hardware.biometrics.fingerprint@2.1-service.ginkgo

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

# Input
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/idc/uinput-fpc.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/uinput-fpc.idc \
    $(LOCAL_PATH)/idc/uinput-goodix.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/uinput-goodix.idc

# Keylayouts
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/keylayout/uinput-fpc.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/uinput-fpc.kl \
    $(LOCAL_PATH)/keylayout/uinput-goodix.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/uinput-goodix.kl

# IR
PRODUCT_PACKAGES += \
    android.hardware.ir@1.0-impl \
    android.hardware.ir@1.0-service

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml \

TARGET_KERNEL_VERSION := 4.14
# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard

BOARD_FRP_PARTITION_NAME := frp

#Android EGL implementation
PRODUCT_PACKAGES += libGLES_android

-include $(QCPATH)/common/config/qtic-config.mk


PRODUCT_BOOT_JARS += tcmiface
PRODUCT_BOOT_JARS += telephony-ext
PRODUCT_PACKAGES += telephony-ext

TARGET_ENABLE_QC_AV_ENHANCEMENTS := true

TARGET_DISABLE_QTI_VPP := true


PRODUCT_PACKAGES += android.hardware.media.omx@1.0-impl

# Audio configuration file
-include $(TOPDIR)vendor/qcom/opensource/audio-hal/primary-hal/configs/trinket/trinket.mk

#Audio DLKM
AUDIO_DLKM := audio_apr.ko
AUDIO_DLKM += audio_wglink.ko
AUDIO_DLKM += audio_q6_pdr.ko
AUDIO_DLKM += audio_q6_notifier.ko
AUDIO_DLKM += audio_adsp_loader.ko
AUDIO_DLKM += audio_q6.ko
AUDIO_DLKM += audio_usf.ko
AUDIO_DLKM += audio_pinctrl_wcd.ko
AUDIO_DLKM += audio_swr.ko
AUDIO_DLKM += audio_wcd_core.ko
AUDIO_DLKM += audio_swr_ctrl.ko
AUDIO_DLKM += audio_wsa881x.ko
AUDIO_DLKM += audio_platform.ko
AUDIO_DLKM += audio_hdmi.ko
AUDIO_DLKM += audio_stub.ko
AUDIO_DLKM += audio_wcd9xxx.ko
AUDIO_DLKM += audio_mbhc.ko
AUDIO_DLKM += audio_wcd_spi.ko
AUDIO_DLKM += audio_native.ko
AUDIO_DLKM += audio_machine_trinket.ko
AUDIO_DLKM += audio_wcd_cpe.ko
AUDIO_DLKM += audio_cpe_lsm.ko
AUDIO_DLKM += audio_wcd9335.ko
AUDIO_DLKM += audio_wcd934x.ko
AUDIO_DLKM += audio_wcd937x.ko
AUDIO_DLKM += audio_wcd937x_slave.ko
AUDIO_DLKM += audio_bolero_cdc.ko
AUDIO_DLKM += audio_wsa_macro.ko
AUDIO_DLKM += audio_va_macro.ko
AUDIO_DLKM += audio_rx_macro.ko
AUDIO_DLKM += audio_tx_macro.ko
AUDIO_DLKM += audio_max98937.ko

PRODUCT_PACKAGES += $(AUDIO_DLKM)

PRODUCT_PACKAGES += fs_config_files

ifeq ($(ENABLE_AB), true)
#A/B related packages
PRODUCT_PACKAGES += update_engine \
    update_engine_client \
    update_verifier \
    android.hardware.boot@1.1-impl-qti \
    android.hardware.boot@1.1-impl-qti.recovery \
    android.hardware.boot@1.1-service

#Boot control HAL test app
PRODUCT_PACKAGES_DEBUG += bootctl

PRODUCT_PACKAGES += \
  update_engine_sideload
endif

DEVICE_MANIFEST_FILE := $(LOCAL_PATH)/manifest.xml
DEVICE_MATRIX_FILE := device/qcom/common/compatibility_matrix.xml
DEVICE_FRAMEWORK_MANIFEST_FILE := $(LOCAL_PATH)/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml

# Telephony: Enable advanced network scanning
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.enableadvancedscan=true

# Radio power saving
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.add_power_save=1

#Healthd packages
PRODUCT_PACKAGES += \
    libhealthd.msm

#ANT+ stack
PRODUCT_PACKAGES += \
    AntHalService \
    libantradio \
    antradio_app \
    libvolumelistener

PRODUCT_PACKAGES += \
    android.hardware.broadcastradio@1.0-impl

PRODUCT_HOST_PACKAGES += \
    brillo_update_payload \
    configstore_xmlparser

# MSM IRQ Balancer configuration file
PRODUCT_COPY_FILES += $(LOCAL_PATH)/msm_irqbalance.conf:$(TARGET_COPY_OUT_VENDOR)/etc/msm_irqbalance.conf

# Powerhint configuration file
PRODUCT_COPY_FILES += $(LOCAL_PATH)/powerhint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.xml

#PowerHAL
TARGET_USES_NON_LEGACY_POWERHAL := true

# Camera configuration file. Shared by passthrough/binderized camera HAL
PRODUCT_PACKAGES += camera.device@3.2-impl
PRODUCT_PACKAGES += camera.device@1.0-impl
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl
# Enable binderized camera HAL
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service

# MIDI feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

# USB default HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

#PASR HAL and APP
PRODUCT_PACKAGES += \
    vendor.qti.power.pasrmanager@1.0-service \
    vendor.qti.power.pasrmanager@1.0-impl \
    pasrservice

#Property to enable/disable PASR
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.power.pasr.enabled=true

# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/$(PRODUCT_NAME)/$(KERNEL_MODULES_INSTALL)/lib/modules

#FEATURE_OPENGLES_EXTENSION_PACK support string config file
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml

# system prop for opengles version
#
# 196608 is decimal for 0x30000 to report version 3
# 196609 is decimal for 0x30001 to report version 3.1
# 196610 is decimal for 0x30002 to report version 3.2
PRODUCT_PROPERTY_OVERRIDES  += \
    ro.opengles.version=196610

#Property for setting the max timeout of autosuspend
PRODUCT_PROPERTY_OVERRIDES += sys.autosuspend.timeout=500000

#system prop for Bluetooth SOC type
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.qcom.bluetooth.soc=cherokee

#Property to enable IO cgroups
PRODUCT_PROPERTY_OVERRIDES += ro.vendor.iocgrp.config=1

#Enable full treble flag
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true

# Enable flag to support slow devices
TARGET_PRESIL_SLOW_BOARD := true

DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
-include device/qcom/wlan/trinket/wlan.mk

# dm-verity definitions
ifneq ($(BOARD_AVB_ENABLE), true)
 PRODUCT_SUPPORTS_VERITY := true
endif

# Enable vndk-sp Librarie
PRODUCT_PACKAGES += vndk_package

PRODUCT_PACKAGES += init.qti.dcvs.sh

PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE:=true
TARGET_MOUNT_POINTS_SYMLINKS := false

PRODUCT_PROPERTY_OVERRIDES += \
ro.crypto.volume.filenames_mode = "aes-256-cts" \
ro.crypto.allow_encrypt_override = true \
ro.crypto.dm_default_key.options_format.version = 2

# Enable incremental FS feature
PRODUCT_PROPERTY_OVERRIDES += ro.incremental.enable=1

ENABLE_VENDOR_RIL_SERVICE := true

PRODUCT_PACKAGES += cameraconfig.txt

TARGET_USES_MKE2FS := true

#Property to enable memperfd
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.debug.enable.memperfd = true

CAM_BRINGUP_NEW_SP := true

#Enable Light AIDL HAL
PRODUCT_PACKAGES += android.hardware.lights-service.qti

# Ginkgo Blobs
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/blobs/vendor/,$(TARGET_COPY_OUT_VENDOR))

###################################################################################
# This is the End of target.mk file.
# Now, Pickup other split product.mk files:
###################################################################################
# TODO: Relocate the system product.mk files pickup into qssi lunch, once it is up.
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/*.mk)
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/vendor/*.mk)
###################################################################################
