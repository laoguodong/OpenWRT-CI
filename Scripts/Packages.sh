#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)  # 第5个参数为自定义名称列表
	local REPO_NAME=${PKG_REPO#*/}

	echo " "

	# 删除本地可能存在的不同名称的软件包
	for NAME in "${PKG_LIST[@]}"; do
		# 查找匹配的目录
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		# 删除找到的目录
		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not fonud directory: $NAME"
		fi
	done

	# 克隆 GitHub 仓库
	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	# 处理克隆的仓库
	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		rm -rf ./$REPO_NAME/
	elif [[ "$PKG_SPECIAL" == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

# 调用示例
# UPDATE_PACKAGE "OpenAppFilter" "destan19/OpenAppFilter" "master" "" "custom_name1 custom_name2"
# UPDATE_PACKAGE "open-app-filter" "destan19/OpenAppFilter" "master" "" "luci-app-appfilter oaf" 这样会把原有的open-app-filter，luci-app-appfilter，oaf相关组件删除，不会出现coremark错误。

# UPDATE_PACKAGE "包名" "项目地址" "项目分支" "pkg/name，可选，pkg为从大杂烩中单独提取包名插件；name为重命名为包名"
UPDATE_PACKAGE "argon" "sbwml/luci-theme-argon" "openwrt-25.12"
UPDATE_PACKAGE "shadcn" "eamonxg/luci-theme-shadcn" "main"
UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master"
UPDATE_PACKAGE "aurora-config" "eamonxg/luci-app-aurora-config" "master"

# iStore 软件中心
UPDATE_PACKAGE "istore" "linkease/istore" "main"
# iStore upstream uses PKG_VERSION=0.1.32-1 with empty PKG_RELEASE; APK rejects hyphenated version.
# Normalize to PKG_VERSION=0.1.32 + PKG_RELEASE=1 for current ImmortalWrt apk packaging.
# Packages.sh is executed from the OpenWrt package/ directory, so search relative to cwd.
ISTORE_STORE_MAKEFILE=$(find . -path '*/luci-app-store/Makefile' -print -quit)
if [ -n "$ISTORE_STORE_MAKEFILE" ]; then
  sed -i "s/^PKG_VERSION:=0\.1\.32-1/PKG_VERSION:=0.1.32/; s/^PKG_RELEASE:=.*/PKG_RELEASE:=1/" "$ISTORE_STORE_MAKEFILE"
  grep -E '^(PKG_VERSION|PKG_RELEASE):=' "$ISTORE_STORE_MAKEFILE"
fi
UPDATE_PACKAGE "dockerman" "lisaac/luci-app-dockerman" "master"
UPDATE_PACKAGE "luci-lib-docker" "kenzok8/small-package" "main" "pkg"
# Dockerman upstream uses PKG_VERSION with a leading "v"; APK rejects version "v0.5.26-r1".
DOCKERMAN_MAKEFILE=$(find . -path '*/luci-app-dockerman/Makefile' -print -quit)
if [ -n "$DOCKERMAN_MAKEFILE" ]; then
  sed -i "s/^PKG_VERSION:=v/PACKAGE_VERSION_SHOULD_NOT_MATCH:=v/" "$DOCKERMAN_MAKEFILE"
  sed -i "s/^PACKAGE_VERSION_SHOULD_NOT_MATCH:=v/PKG_VERSION:=/" "$DOCKERMAN_MAKEFILE"
  grep -E '^(PKG_VERSION|PKG_RELEASE):=' "$DOCKERMAN_MAKEFILE"
fi

# TurboACC / ModemData
UPDATE_PACKAGE "turboacc" "chenmozhijin/turboacc" "luci"
#UPDATE_PACKAGE "luci-app-modemdata" "4IceG/luci-app-modemdata" "main"

# FRP 内网穿透
UPDATE_PACKAGE "frp" "kuoruan/openwrt-frp" "master"
UPDATE_PACKAGE "luci-app-frpc" "kuoruan/luci-app-frpc" "master"
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "master"
UPDATE_PACKAGE "kucat-config" "sirpdboy/luci-app-kucat-config" "master"

#UPDATE_PACKAGE "homeproxy" "VIKINGYFY/homeproxy" "main"
#UPDATE_PACKAGE "momo" "nikkinikki-org/OpenWrt-momo" "main"
#UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main"
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
#UPDATE_PACKAGE "passwall" "Openwrt-Passwall/openwrt-passwall" "main" "pkg"
#UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg"

#UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"

#UPDATE_PACKAGE "athena-led" "unraveloop/JDC-AX6600-Athena-LED-Controller" "main"
UPDATE_PACKAGE "ddns-go" "sirpdboy/luci-app-ddns-go" "main"
UPDATE_PACKAGE "diskman" "sbwml/luci-app-diskman" "main"
UPDATE_PACKAGE "diskmanager" "4IceG/luci-app-mini-diskmanager" "main"
#UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main"
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"
#UPDATE_PACKAGE "netspeedtest" "sirpdboy/netspeedtest" "main" "" "homebox ookla-speedtest"
UPDATE_PACKAGE "netwizard" "sirpdboy/luci-app-netwizard" "main"
UPDATE_PACKAGE "openlist2" "sbwml/luci-app-openlist2" "main"
UPDATE_PACKAGE "partexp" "sirpdboy/luci-app-partexp" "main"

# 对齐旧路由常用管理插件
UPDATE_PACKAGE "cpulimit-ng" "gangbanlau/cpulimit-ng" "master"
# cpulimit-ng upstream unconditionally includes <sys/sysctl.h>; musl/ImmortalWrt may not provide it.
# The sysctl call is only used in the macOS code path, so guard/remove it for Linux builds.
CPULIMIT_NG_C=$(find ./cpulimit-ng -type f -name 'cpulimit.c' -print -quit)
if [ -n "$CPULIMIT_NG_C" ]; then
  sed -i 's|^#include <sys/sysctl.h>|#ifdef __APPLE__
#include <sys/sysctl.h>
#endif|' "$CPULIMIT_NG_C"
  grep -n "sys/sysctl" "$CPULIMIT_NG_C" || true
fi
UPDATE_PACKAGE "rclone" "shidahuilang/openwrt-package" "Lede" "pkg" "rclone-config rclone-ng rclone-webui-react"
UPDATE_PACKAGE "rclone-ng" "shidahuilang/openwrt-package" "Lede" "pkg"
UPDATE_PACKAGE "rclone-webui-react" "shidahuilang/openwrt-package" "Lede" "pkg"
UPDATE_PACKAGE "luci-app-rclone" "shidahuilang/openwrt-package" "Lede" "pkg"
UPDATE_PACKAGE "luci-app-fileassistant" "kenzok8/small-package" "main" "pkg"
UPDATE_PACKAGE "luci-app-rtbwmon" "kenzok8/small-package" "main" "pkg"
# luci-app-rtbwmon has PKG_VERSION=1.1.0-1 + empty release; APK rejects hyphenated version.
RTBWMON_MAKEFILE=$(find . -path '*/luci-app-rtbwmon/Makefile' -print -quit)
if [ -n "$RTBWMON_MAKEFILE" ]; then
  sed -i "s/^PKG_VERSION:=1\.1\.0-1/PKG_VERSION:=1.1.0/; s/^PKG_RELEASE:=.*/PKG_RELEASE:=1/" "$RTBWMON_MAKEFILE"
  grep -E '^(PKG_VERSION|PKG_RELEASE):=' "$RTBWMON_MAKEFILE"
fi
UPDATE_PACKAGE "luci-app-syncdial" "kenzok8/small-package" "main" "pkg"
UPDATE_PACKAGE "luci-app-mwan3helper" "kenzok8/small-package" "main" "pkg"
# pdnsd-alt is not present in current ImmortalWrt feeds; mwan3helper can work without hard depending on it.
MWAN3HELPER_MAKEFILE=$(find . -path '*/luci-app-mwan3helper/Makefile' -print -quit)
if [ -n "$MWAN3HELPER_MAKEFILE" ]; then
  sed -i 's/[[:space:]]*+pdnsd-alt//g' "$MWAN3HELPER_MAKEFILE"
  grep -E '^LUCI_DEPENDS' "$MWAN3HELPER_MAKEFILE" || true
fi
UPDATE_PACKAGE "luci-app-lan-scanner" "adminchenyu/LAN-Scanner" "main" "name"
UPDATE_PACKAGE "luci-app-serverchan" "schen39/luci-app-serverchan" "master"
UPDATE_PACKAGE "luci-app-smartinfo" "shidahuilang/openwrt-package" "Lede" "pkg"
UPDATE_PACKAGE "luci-app-syscontrol" "bobbyunknown/luci-app-syscontrol" "main"
UPDATE_PACKAGE "luci-app-disks-info" "gSpotx2f/luci-app-disks-info" "master"
UPDATE_PACKAGE "luci-app-smbuser" "sbwml/luci-app-smbuser" "main"
UPDATE_PACKAGE "luci-app-wizard" "kiddin9/luci-app-wizard" "main"
#UPDATE_PACKAGE "qbittorrent" "sbwml/luci-app-qbittorrent" "master" "" "qt6base qt6tools rblibtorrent"
#UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main"
UPDATE_PACKAGE "quickfile" "sbwml/luci-app-quickfile" "main"
UPDATE_PACKAGE "timecontrol" "sirpdboy/luci-app-timecontrol" "main"
UPDATE_PACKAGE "viking" "VIKINGYFY/packages" "main" "" "gecoosac luci-app-timewol luci-app-wolplus"
#UPDATE_PACKAGE "vnt" "lmq8267/luci-app-vnt" "main"

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_MARK=${2:-false}
	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

	if [ -z "$PKG_FILES" ]; then
		echo "$PKG_NAME not found!"
		return
	fi

	echo -e "\n$PKG_NAME version update has started!"

	for PKG_FILE in $PKG_FILES; do
		local PKG_REPO=$(grep -Po "PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)" $PKG_FILE)
		local PKG_TAG=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease == $PKG_MARK)) | first | .tag_name")

		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")
		local OLD_URL=$(grep -Po "PKG_SOURCE_URL:=\K.*" "$PKG_FILE")
		local OLD_FILE=$(grep -Po "PKG_SOURCE:=\K.*" "$PKG_FILE")
		local OLD_HASH=$(grep -Po "PKG_HASH:=\K.*" "$PKG_FILE")

		local PKG_URL=$([[ "$OLD_URL" == *"releases"* ]] && echo "${OLD_URL%/}/$OLD_FILE" || echo "${OLD_URL%/}")

		local NEW_VER=$(echo $PKG_TAG | sed -E 's/[^0-9]+/\./g; s/^\.|\.$//g')
		local NEW_URL=$(echo $PKG_URL | sed "s/\$(PKG_VERSION)/$NEW_VER/g; s/\$(PKG_NAME)/$PKG_NAME/g")
		local NEW_HASH=$(curl -sL "$NEW_URL" | sha256sum | cut -d ' ' -f 1)

		echo "old version: $OLD_VER $OLD_HASH"
		echo "new version: $NEW_VER $NEW_HASH"

		if [[ "$NEW_VER" =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
			echo "$PKG_FILE version has been updated!"
		else
			echo "$PKG_FILE version is already the latest!"
		fi
	done
}

#UPDATE_VERSION "软件包名" "测试版，true，可选，默认为否"
UPDATE_VERSION "sing-box"

#引入私有扩展脚本
if [ -f "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh" ]; then
	source "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh"
fi
