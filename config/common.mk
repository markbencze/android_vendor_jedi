PRODUCT_BRAND ?= jedi

SUPERUSER_EMBEDDED := true
SUPERUSER_PACKAGE_PREFIX := com.android.settings.cyanogenmod.superuser

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/jedi/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/jedi/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/jedi/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

ifdef JEDI_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=jedinightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=jedi
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/jedi/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/jedi/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/jedi/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/jedi/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# JEDI-specific init file
PRODUCT_COPY_FILES += \
    vendor/jedi/prebuilt/common/etc/init.local.rc:root/init.jedi.rc

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/jedi/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/jedi/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is JEDI!
PRODUCT_COPY_FILES += \
    vendor/jedi/config/permissions/com.jedi.android.xml:system/etc/permissions/com.jedi.android.xml

# T-Mobile theme engine
include vendor/jedi/config/themes_common.mk

# Required JEDI packages
PRODUCT_PACKAGES += \
    Development \
    LatinIME \
    BluetoothExt

# Optional JEDI packages
PRODUCT_PACKAGES += \
    VoicePlus \
    Basic \
    libemoji

# Custom JEDI packages
PRODUCT_PACKAGES += \
    libcyanogen-dsp \
    audio_effects.conf \
    JEDIWallpapers \
    Apollo \
    CMFileManager \
    LockClock 

# JEDI Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in JEDI
PRODUCT_PACKAGES += \
    libsepol \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)

PRODUCT_PACKAGES += \
    procmem \
    procrank \
    Superuser \
    su

PRODUCT_COPY_FILES +=  \
    vendor/jedi/proprietary/Nova.apk:system/app/Nova.apk \
    vendor/jedi/proprietary/lib/armeabi/libgif.so:system/lib/libgif.so\
    vendor/jedi/proprietary/CameraNext.apk:system/app/CameraNext.apk \
    vendor/jedi/proprietary/GalleryNext.apk:system/app/GalleryNext.apk \
    vendor/jedi/proprietary/AudioFX.apk:system/app/priv-app/AudioFX.apk \
    vendor/jedi/proprietary/CMKeyguard.apk:system/priv-app/CMKeyguard.apk \
    vendor/jedi/proprietary/Screencast.apk:system/priv-app/Screencast.apk \

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1
else

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

endif

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/jedi/overlay/common

PRODUCT_VERSION_MAJOR = 1
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = 0-RC0

# Set JEDI_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef JEDI_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "JEDI_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^JEDI_||g')
        JEDI_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(JEDI_BUILDTYPE)),)
    JEDI_BUILDTYPE := UNOFFICIAL
endif

ifdef JEDI_BUILDTYPE
    ifneq ($(JEDI_BUILDTYPE), SNAPSHOT)
        ifdef JEDI_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            JEDI_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from JEDI_EXTRAVERSION
            JEDI_EXTRAVERSION := $(shell echo $(JEDI_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to JEDI_EXTRAVERSION
            JEDI_EXTRAVERSION := -$(JEDI_EXTRAVERSION)
        endif
    else
        ifndef JEDI_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            JEDI_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from JEDI_EXTRAVERSION
            JEDI_EXTRAVERSION := $(shell echo $(JEDI_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to JEDI_EXTRAVERSION
            JEDI_EXTRAVERSION := -$(JEDI_EXTRAVERSION)
        endif
    endif
else
    # If JEDI_BUILDTYPE is not defined, set to UNOFFICIAL
    JEDI_BUILDTYPE := 
    JEDI_EXTRAVERSION :=
endif

ifeq ($(JEDI_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        JEDI_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(JEDI_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        JEDI_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(JEDI_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            JEDI_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(JEDI_BUILD)
        else
            JEDI_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(JEDI_BUILD)
        endif
    endif
else
    ifeq ($(PRODUCT_VERSION_MINOR),0)
        JEDI_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(JEDI_BUILDTYPE)$(JEDI_EXTRAVERSION)-$(JEDI_BUILD)
    else
        JEDI_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(JEDI_BUILDTYPE)$(JEDI_EXTRAVERSION)-$(JEDI_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.jedi.version=$(JEDI_VERSION) \
  ro.modversion=$(JEDI_VERSION) \

-include vendor/jedi-priv/keys/keys.mk

JEDI_DISPLAY_VERSION := $(JEDI_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(JEDI_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(JEDI_EXTRAVERSION),)
        # Remove leading dash from JEDI_EXTRAVERSION
        JEDI_EXTRAVERSION := $(shell echo $(JEDI_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(JEDI_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    JEDI_DISPLAY_VERSION=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

PRODUCT_PROPERTY_OVERRIDES += \
  ro.jedi.display.version=$(JEDI_DISPLAY_VERSION)

# disable multithreaded dextop for RELEASE and SNAPSHOT builds
ifneq ($(filter RELEASE SNAPSHOT,$(JEDI_BUILDTYPE)),)
PRODUCT_PROPERTY_OVERRIDES += \
  persist.sys.dalvik.multithread=false
endif

-include $(WORKSPACE)/build_env/image-auto-bits.mk
