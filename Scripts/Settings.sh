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

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
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
	#修改WIFI地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE


#注入 MOSS 自定义根文件：NSS 使用率脚本、LuCI 状态页、apk+iStore 兼容修复等
if [ -d "$GITHUB_WORKSPACE/Files/root" ]; then
	mkdir -p ./package/base-files/files
	cp -a "$GITHUB_WORKSPACE/Files/root/." ./package/base-files/files/
	find ./package/base-files/files/etc/uci-defaults ./package/base-files/files/usr/bin -type f 2>/dev/null -exec chmod 0755 {} +
fi

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#引入私有扩展配置
if [ -f "$GITHUB_WORKSPACE/Config/PRIVATE.txt" ]; then
	echo "Applying private configurations from PRIVATE.txt..."
	cat $GITHUB_WORKSPACE/Config/PRIVATE.txt >> ./.config
fi

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

#无WIFI配置标志
if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
	echo "WRT_WIFI=wifi-no" >> $GITHUB_ENV
fi

#高通平台调整
DTS_PATH="./target/linux/qualcommax/dts/"
if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
	#启用 NSS/ECM 硬件加速相关 feed（不要关闭 nss_packages / sqm_scripts_nss）
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_5=y" >> ./.config
	#其他调整
	echo "CONFIG_PACKAGE_kmod-usb-serial-qualcomm=y" >> ./.config

	#自定义 NN6000 v2 机型显示名称：LuCI/系统信息显示为 LZD-HOME，编译目标仍保持 link_nn6000-v2
	NN6000_V2_DTS="$DTS_PATH/ipq6000-nn6000-v2.dts"
	NN6000_IPQ60XX_MK="./target/linux/qualcommax/image/ipq60xx.mk"
	if [ -f "$NN6000_V2_DTS" ]; then
		sed -i 's/model = "Link NN6000 v2";/model = "LZD-HOME";/' "$NN6000_V2_DTS"
	fi
	if [ -f "$NN6000_IPQ60XX_MK" ]; then
		sed -i '/define Device\/link_nn6000-common/,/endef/s/DEVICE_VENDOR := Link/DEVICE_VENDOR := LZD/' "$NN6000_IPQ60XX_MK"
		sed -i '/define Device\/link_nn6000-v2/,/endef/s/DEVICE_MODEL := NN6000 v2/DEVICE_MODEL := HOME/' "$NN6000_IPQ60XX_MK"
		sed -i '/define Device\/link_nn6000-v2/,/endef/s/DEVICE_VARIANT := v2/DEVICE_VARIANT :=/' "$NN6000_IPQ60XX_MK"
	fi

	#无WIFI配置调整Q6大小
	if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
		echo "qualcommax set up nowifi successfully!"
	fi
fi
