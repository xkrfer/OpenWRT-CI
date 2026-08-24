#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

#移除luci-app-attendedsysupgrade
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/mediatek/filogic/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#每个构建变体只启用一种透明代理，避免三套代理及其依赖互相干扰
case "${WRT_VARIANT:-default}" in
	nikki)
		echo "CONFIG_PACKAGE_luci-app-nikki=y" >> ./.config
		;;
	homeproxy)
		echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
		;;
	dae)
		echo "CONFIG_PACKAGE_luci-app-daed=y" >> ./.config
		# dae 依赖 eBPF CO-RE；沿用历史成功构建验证过的内核 BTF 方案
		echo "CONFIG_DEVEL=y" >> ./.config
		echo "CONFIG_KERNEL_DEBUG_INFO=y" >> ./.config
		echo "CONFIG_KERNEL_DEBUG_INFO_REDUCED=n" >> ./.config
		echo "CONFIG_KERNEL_DEBUG_INFO_BTF=y" >> ./.config
		echo "CONFIG_KERNEL_CGROUPS=y" >> ./.config
		echo "CONFIG_KERNEL_CGROUP_BPF=y" >> ./.config
		echo "CONFIG_KERNEL_BPF_EVENTS=y" >> ./.config
		echo "CONFIG_BPF_TOOLCHAIN_HOST=y" >> ./.config
		echo "CONFIG_KERNEL_XDP_SOCKETS=y" >> ./.config
		echo "CONFIG_PACKAGE_kmod-xdp-sockets-diag=y" >> ./.config
		echo "CONFIG_DAED_USE_KERNEL_BTF=y" >> ./.config
		;;
	default)
		;;
	*)
		echo "Unsupported firmware variant: $WRT_VARIANT" >&2
		exit 1
		;;
esac

#引入私有扩展配置
if [ -f "$GITHUB_WORKSPACE/Config/PRIVATE.txt" ]; then
	echo "Applying private configurations from PRIVATE.txt..."
	cat $GITHUB_WORKSPACE/Config/PRIVATE.txt >> ./.config
fi

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi
