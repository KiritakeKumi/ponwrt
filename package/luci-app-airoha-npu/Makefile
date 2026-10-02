# This is free software, licensed under the Apache License, Version 2.0 .

include $(TOPDIR)/rules.mk

PKG_VERSION:=1.0.1
PKG_RELEASE:=2

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

LUCI_TITLE:=LuCI Airoha SoC Status (NPU, CPU, Frame Engine)
LUCI_MAINTAINER:=Ryan Chen <rchen14b@gmail.com>
LUCI_URL:=https://github.com/rchen14b/luci-app-airoha-npu
LUCI_DESCRIPTION:=Status page for Airoha EN7581 and AN7583 SoCs: NPU state and \
	reserved memory, the Frame Engine port counters and PSE queues, the PPE \
	flow offload table, plus CPU frequency, governor and direct PLL overclock. \
	The Frame Engine section and the overclock control read and write registers \
	through the busybox devmem applet (CONFIG_BUSYBOX_CONFIG_DEVMEM), which is \
	not enabled in a default build; without it the rest of the page still works. \
	The PPE table needs CONFIG_KERNEL_DEBUG_FS and the WiFi queue view needs the \
	mt76 debugfs nodes.
LUCI_DEPENDS:=+luci-base @TARGET_airoha

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
