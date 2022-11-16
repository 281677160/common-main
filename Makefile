#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iproute2
PKG_VERSION:=5.15.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/utils/net/iproute2
PKG_HASH:=38e3e4a5f9a7f5575c015027a10df097c149111eeb739993128e5b2b35b291ff
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=iptables
PKG_LICENSE:=GPL-2.0
PKG_CPE_ID:=cpe:/a:iproute2_project:iproute2

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/iproute2/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2
  SUBMENU:=Routing and Redirection
  MAINTAINER:=Russell Senior <russell@personaltelco.net>
endef

define Package/ip-tiny
$(call Package/iproute2/Default)
  TITLE:=Routing control utility (minimal)
  VARIANT:=iptiny
  DEFAULT_VARIANT:=1
  PROVIDES:=ip
  ALTERNATIVES:=200:/sbin/ip:/usr/libexec/ip-tiny
  DEPENDS:=+libnl-tiny +(PACKAGE_devlink||PACKAGE_rdma):libmnl
endef

define Package/ip-full
$(call Package/iproute2/Default)
  TITLE:=Routing control utility (full)
  VARIANT:=ipfull
  PROVIDES:=ip
  ALTERNATIVES:=300:/sbin/ip:/usr/libexec/ip-full
  DEPENDS:=+libnl-tiny +libbpf +(PACKAGE_devlink||PACKAGE_rdma):libmnl
endef

define Package/tc-tiny
$(call Package/iproute2/Default)
  TITLE:=Traffic control utility (minimal)
  VARIANT:=tctiny
  DEFAULT_VARIANT:=1
  PROVIDES:=tc
  ALTERNATIVES:=200:/sbin/tc:/usr/libexec/tc-tiny
  DEPENDS:=+kmod-sched-core +libxtables +tc-mod-iptables +(PACKAGE_devlink||PACKAGE_rdma):libmnl
endef

define Package/tc-full
$(call Package/iproute2/Default)
  TITLE:=Traffic control utility (full)
  VARIANT:=tcfull
  PROVIDES:=tc
  ALTERNATIVES:=300:/sbin/tc:/usr/libexec/tc-full
  DEPENDS:=+kmod-sched-core +libxtables +tc-mod-iptables +libbpf +(PACKAGE_devlink||PACKAGE_rdma):libmnl
endef

define Package/tc-mod-iptables
$(call Package/iproute2/Default)
  TITLE:=Traffic control module - iptables action
  DEPENDS:=+libxtables
endef

define Package/genl
$(call Package/iproute2/Default)
  TITLE:=General netlink utility frontend
  DEPENDS:=+libnl-tiny +(PACKAGE_devlink||PACKAGE_rdma):libmnl +PACKAGE_ip-full:libcap
endef

define Package/ip-bridge
$(call Package/iproute2/Default)
  TITLE:=Bridge configuration utility from iproute2
  DEPENDS:=+libnl-tiny +(PACKAGE_devlink||PACKAGE_rdma):libmnl +PACKAGE_ip-full:libcap
endef

define Package/ss
$(call Package/iproute2/Default)
  TITLE:=Socket statistics utility
  DEPENDS:=+libnl-tiny +(PACKAGE_devlink||PACKAGE_rdma):libmnl +PACKAGE_ip-full:libcap +kmod-netlink-diag
endef

define Package/nstat
$(call Package/iproute2/Default)
  TITLE:=Network statistics utility
  DEPENDS:=+libnl-tiny +(PACKAGE_devlink||PACKAGE_rdma):libmnl +PACKAGE_ip-full:libcap
endef

define Package/devlink
$(call Package/iproute2/Default)
  TITLE:=Network devlink utility
  DEPENDS:=+libmnl +PACKAGE_ip-full:libcap
endef

define Package/rdma
$(call Package/iproute2/Default)
  TITLE:=Network rdma utility
  DEPENDS:=+libmnl +PACKAGE_ip-full:libcap
endef

ifeq ($(BUILD_VARIANT),iptiny)
  IP_CONFIG_TINY:=y
  LIBBPF_FORCE:=off
endif

ifeq ($(BUILD_VARIANT),ipfull)
  HAVE_ELF:=y
  LIBBPF_FORCE:=on
endif

ifeq ($(BUILD_VARIANT),tctiny)
  LIBBPF_FORCE:=off
  SHARED_LIBS:=y
endif

ifeq ($(BUILD_VARIANT),tcfull)
  HAVE_ELF:=y
  LIBBPF_FORCE:=on
  SHARED_LIBS:=y
endif

ifdef CONFIG_PACKAGE_devlink
  HAVE_MNL:=y
endif

ifdef CONFIG_PACKAGE_rdma
  HAVE_MNL:=y
endif

define Build/Configure
	echo "static const char SNAPSHOT[] = \"$(PKG_VERSION)-$(PKG_RELEASE)-openwrt\";" \
		> $(PKG_BUILD_DIR)/include/SNAPSHOT.h
endef

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections -Wl,--as-needed
TARGET_CPPFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny

MAKE_FLAGS += \
	KERNEL_INCLUDE="$(LINUX_DIR)/user_headers/include" \
	SHARED_LIBS=$(SHARED_LIBS) \
	IP_CONFIG_TINY=$(IP_CONFIG_TINY) \
	BUILD_VARIANT=$(BUILD_VARIANT) \
	LIBBPF_FORCE=$(LIBBPF_FORCE) \
	HAVE_ELF=$(HAVE_ELF) \
	HAVE_MNL=$(HAVE_MNL) \
	HAVE_CAP=$(HAVE_CAP) \
	IPT_LIB_DIR=/usr/lib/iptables \
	XT_LIB_DIR=/usr/lib/iptables \
	FPIC="$(FPIC)" \
	$(if $(findstring c,$(OPENWRT_VERBOSE)),V=1,V='')

define Build/Compile
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) $(MAKE_FLAGS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/iproute2
	$(CP) $(PKG_BUILD_DIR)/include/bpf_elf.h $(1)/usr/include/iproute2
	$(CP) $(PKG_BUILD_DIR)/include/{libgenl,libnetlink}.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/libnetlink.a $(1)/usr/lib/
	# Hack for qos-gargoyle
	$(INSTALL_DIR) $(1)/usr/lib/iproute2/{tc,lib,include}
	$(CP) $(PKG_BUILD_DIR)/{tc,include,lib} $(1)/usr/lib/iproute2
	# Hack end
endef

define Package/ip-tiny/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ip/ip $(1)/usr/libexec/ip-tiny
endef

define Package/ip-full/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ip/ip $(1)/usr/libexec/ip-full
endef

define Package/tc-tiny/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tc/tc $(1)/usr/libexec/tc-tiny
endef

define Package/tc-full/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tc/tc $(1)/usr/libexec/tc-full
endef

define Package/tc-mod-iptables/install
	$(INSTALL_DIR) $(1)/usr/lib/tc
	$(CP) $(PKG_BUILD_DIR)/tc/m_xt.so $(1)/usr/lib/tc
endef

define Package/genl/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/genl/genl $(1)/usr/sbin/
endef

define Package/ip-bridge/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bridge/bridge $(1)/usr/sbin/
endef

define Package/ss/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/misc/ss $(1)/usr/sbin/
endef

define Package/nstat/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/misc/nstat $(1)/usr/sbin/
endef

define Package/devlink/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/devlink/devlink $(1)/usr/sbin/
endef

define Package/rdma/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rdma/rdma $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,ip-tiny))
$(eval $(call BuildPackage,ip-full))
# build tc-mod-iptables before its dependents, to avoid
# spurious rebuilds when building multiple variants.
$(eval $(call BuildPackage,tc-mod-iptables))
$(eval $(call BuildPackage,tc-tiny))
$(eval $(call BuildPackage,tc-full))
$(eval $(call BuildPackage,genl))
$(eval $(call BuildPackage,ip-bridge))
$(eval $(call BuildPackage,ss))
$(eval $(call BuildPackage,nstat))
$(eval $(call BuildPackage,devlink))
$(eval $(call BuildPackage,rdma))
