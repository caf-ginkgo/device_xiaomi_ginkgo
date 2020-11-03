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
ART_BUILD_TARGET_NDEBUG := true
ART_BUILD_TARGET_DEBUG := false
ART_BUILD_HOST_NDEBUG := true
ART_BUILD_HOST_DEBUG := false
endif

PRODUCT_DEXPREOPT_SPEED_APPS += \
    Launcher3QuickStep \
    Settings \
    SystemUI

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

BUILD_FINGERPRINT := google/coral/coral:11/RP1A.201105.002/6869500:user/release-keys

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

# NFC
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/nfc/libnfc-nxp_RF.conf:$(TARGET_COPY_OUT_VENDOR)/libnfc-nxp_RF.conf \
    $(LOCAL_PATH)/nfc/libnfc-nxp.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-nxp.conf

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_willow/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_willow/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_willow/android.hardware.nfc.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_willow/com.android.nfc_extras.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_willow/com.nxp.mifare.xml

# IR
PRODUCT_PACKAGES += \
    android.hardware.ir@1.0-impl \
    android.hardware.ir@1.0-service

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml \

# Freeform Multiwindow
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.freeform_window_management.xml

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.3-service.clearkey

PRODUCT_COPY_FILES += \
    prebuilts/vndk/v29/arm64/arch-arm-armv8-a/shared/vndk-core/libprotobuf-cpp-lite.so:vendor/lib/libprotobuf-cpp-lite.so \
    prebuilts/vndk/v29/arm64/arch-arm64-armv8-a/shared/vndk-core/libprotobuf-cpp-lite.so:vendor/lib64/libprotobuf-cpp-lite.so \
    prebuilts/vndk/v29/arm64/arch-arm-armv8-a/shared/vndk-core/libprotobuf-cpp-full.so:vendor/lib/libprotobuf-cpp-full.so \
    prebuilts/vndk/v29/arm64/arch-arm64-armv8-a/shared/vndk-core/libprotobuf-cpp-full.so:vendor/lib64/libprotobuf-cpp-full.so

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
ODM_MANIFEST_WILLOW_FILES := $(LOCAL_PATH)/manifest_willow.xml
ODM_MANIFEST_SKUS += willow

# External exFat tools
PRODUCT_PACKAGES += \
    mkfs.exfat \
    fsck.exfat

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-service.ginkgo

# Telephony: Enable advanced network scanning
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.enableadvancedscan=true

# IMS
PRODUCT_PROPERTY_OVERRIDES += \
    persist.dbg.volte_avail_ovr=1 \
    persist.dbg.vt_avail_ovr=1 \
    persist.dbg.wfc_avail_ovr=1 \
    persist.vendor.ims.disableADBLogs=1 \
    persist.vendor.ims.disableDebugLogs=1 \
    persist.vendor.ims.disableIMSLogs=1 \
    persist.vendor.ims.disableQXDMLogs=1

# Radio power saving
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.add_power_save=1

# Radio data indication
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.data_ltd_sys_ind=1 \
    persist.vendor.radio.force_ltd_sys_ind=1

# Zygote
PRODUCT_PROPERTY_OVERRIDES += \
    persist.device_config.runtime_native.usap_pool_enabled=true

# Display
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.display.disable_rotator_downscale=1

# SF
PRODUCT_PROPERTY_OVERRIDES += \
    debug.hwui.renderer=skiavk \
    debug.sf.disable_backpressure=1 \
    debug.sf.hw=1 \
    debug.sf.latch_unsignaled=1 \
    debug.sf.use_phase_offsets_as_durations=1 \
    debug.sf.late.sf.duration=10500000 \
    debug.sf.late.app.duration=20500000 \
    debug.sf.early.sf.duration=21000000 \
    debug.sf.early.app.duration=16500000 \
    debug.sf.earlyGl.sf.duration=13500000 \
    debug.sf.earlyGl.app.duration=21000000 \
    ro.sf.blurs_are_expensive=1 \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3 \
    ro.surface_flinger.supports_background_blur=1

# OEM unlock
PRODUCT_PROPERTY_OVERRIDES += \
    ro.oem_unlock_supported=0

# Use 64-bit dex2oat for better dexopt time.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.dex2oat64.enabled=true

# Configure dex2oat
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.boot-dex2oat-cpu-set=0,1,2,3,4,5,6,7 \
    dalvik.vm.boot-dex2oat-threads=8 \
    dalvik.vm.dex2oat-cpu-set=0,1,2,3,4,5,6,7 \
    dalvik.vm.dex2oat-threads=8 \
    dalvik.vm.image-dex2oat-cpu-set=0,1,2,3,4,5,6,7 \
    dalvik.vm.image-dex2oat-threads=8

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

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-impl \
    android.hardware.thermal@1.0-service

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/thermal-engine-normal.conf:$(TARGET_COPY_OUT_VENDOR)/etc/thermal-engine-normal.conf

#PowerHAL
TARGET_USES_NON_LEGACY_POWERHAL := true

# Camera configuration file. Shared by passthrough/binderized camera HAL
PRODUCT_PACKAGES += camera.device@3.2-impl
PRODUCT_PACKAGES += camera.device@1.0-impl
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl
# Enable binderized camera HAL
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service

# Camera properties
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.camera.preview.ubwc=0 \
    persist.vendor.camera.isp.clock.optmz=0 \
    persist.vendor.camera.isp.turbo=1 \
    persist.vendor.camera.imglib.usefdlite=1 \
    persist.vendor.camera.expose.aux=1 \
    persist.vendor.camera.HAL3.enabled=1 \
    persist.vendor.camera.mpo.disabled=1 \
    persist.vendor.camera.manufacturer=Xiaomi \
    persist.vendor.camera.stats.test=0 \
    persist.vendor.camera.awb.sync=2 \
    persist.vendor.camera.af.sync=2 \
    persist.vendor.camera.eis.enable=1 \
    persist.vendor.camera.is_type=4 \
    persist.vendor.camera.is_type_preview=4 \
    persist.vendor.camera.gyro.disable=0 \
    persist.vendor.camera.llnoise=1 \
    persist.vendor.denoise.process.plates=2 \
    persist.vendor.tnr.process.plates=2 \
    persist.vendor.camera.tnr.preview=1 \
    persist.vendor.camera.swtnr.preview=1 \
    persist.vendor.camera.tnr.video=1 \
    persist.vendor.camera.aec.sync=1 \
    persist.vendor.camera.instant.aec=1 \
    persist.vendor.camera.ae.instant.bound=20 \
    persist.vendor.camera.privapp.list=org.codeaurora.snapdragoncam \
    persist.vendor.dualcam.lpm.enable=0 \
    vendor.camera.aux.packagelist=org.codeaurora.snapcam,com.android.camera,com.android.GoogleCameraTigr \
    vendor.camera.hal1.packagelist=com.whatsapp,com.instagram.android,com.facebook.katana,com.snapchat.android \
    vendor.camera.not.cts.apk=1 \
    vendor.camera.not.ctsverify.apk=1

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

# Overlay
PRODUCT_PACKAGES += \
    FrameworksGinkgo \
    SystemUIGinkgo \
    NotchBarKiller \
    NoCutoutOverlay

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
    ro.crypto.volume.filenames_mode=aes-256-cts \
    ro.crypto.allow_encrypt_override=true

# Enable incremental FS feature
PRODUCT_PROPERTY_OVERRIDES += ro.incremental.enable=1

ENABLE_VENDOR_RIL_SERVICE := true

PRODUCT_PACKAGES += cameraconfig.txt

TARGET_USES_MKE2FS := true

#Property to enable memperfd
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.debug.enable.memperfd = true

CAM_BRINGUP_NEW_SP := true

# Target specific Netflix custom property
PRODUCT_PROPERTY_OVERRIDES += \
    ro.netflix.bsp_rev=Q6125-17995-1

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
