# Copyright (c) 2023 The Android Open Source Project
# Copyright (C) 2023 SebaUbuntu's TWRP device tree generator 4-#
# SPDX-License-Identifier: Apache-2.0
#
# 关于橙狐变量详见 fox_12.1/vendor/recovery/orangefox_build_vars.txt 
echo -e "\x1b[96mAdontoo: 开始加载OrangeFox配置变量...\x1b[m"

#基础环境配置（合并核心变量，避免冲突）

export TW_DEFAULT_LANGUAGE="zh_CN"  # 默认中文语言
export LC_ALL="C"  # 统一字符编码，避免中文乱码
export ALLOW_MISSING_DEPENDENCIES=true  # 允许缺失非核心依赖（兼容部分库缺失场景）
export FOX_AB_DEVICE=1  # 标记为A/B分区设备
export OF_AB_DEVICE_WITH_RECOVERY_PARTITION=1  # A/B设备且存在独立recovery分区
export OF_USE_LZ4_COMPRESSION=1  # 使用LZ4压缩算法
#export FOX_VANILLA_BUILD=1  # 纯净版构建（不含额外预装组件）
#export OF_NO_MIUI_PATCH_WARNING=1  # 禁用MIUI补丁警告
#export OF_DISABLE_MIUI_OTA_BY_DEFAULT=1  # 默认禁用MIUI OTA功能

#设备相关配置（合并兼容设备列表，补充核心参数）

export TARGET_DEVICE_ALT="OP5D0DL1,OPD2413,OP615EL1,RE6018L1,RE602CL1,RE605FL1,OP60EBL1,OP60F5L1,OP6113L1,RE6400L1,SM87XX"
export FOX_VIRTUAL_AB_DEVICE=1  # 标记为虚拟A/B设备
export OF_DYNAMIC_FULL_SIZE=15569256448  # 动态分区总大小（适配VAB设备）
export FOX_VARIANT="OPLUS_PINEAPPLE_TABLET"  # 平板设备变体（保留原有命名逻辑）
#export OF_FORCE_PREBUILT_KERNEL=1  # 强制使用预编译内核
export OF_UNBIND_SDCARD_F2FS=1  # 格式化F2FS时解绑SD卡
export OF_WIPE_METADATA_AFTER_DATAFORMAT=1  # 格式化数据后清除metadata分区
export OF_FORCE_DATA_FORMAT_F2FS=1  # 强制将数据分区格式化为F2FS

#补充分区路径配置

export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/mapper/system"  # 系统分区路径
export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/mapper/vendor"  #  vendor分区路径

#功能开关配置（保留原有+新增核心功能）

export FOX_USE_TAR_BINARY=1  # 启用tar命令支持
export FOX_USE_SED_BINARY=1  # 启用sed命令支持
export FOX_USE_LZ4_BINARY=1  # 启用lz4命令支持
export FOX_USE_ZSTD_BINARY=1  # 启用zstd命令支持
export FOX_USE_DATE_BINARY=1  # 启用date命令支持
export FOX_USE_GREP_BINARY=1  # 启用grep命令支持
export FOX_USE_BUSYBOX_BINARY=1  # 启用busybox工具集
export FOX_USE_XZ_UTILS=1  # 启用xz压缩工具
export FOX_USE_FSCK_EROFS_BINARY=1  # 启用EROFS文件系统检查工具
export FOX_USE_PATCHELF_BINARY=1  # 启用patchelf工具（修复库依赖）

#新增功能变量

export FOX_REPLACE_TOOLBOX_GETPROP=1  # 使用完整版getprop命令
export FOX_USE_BASH_SHELL=1  # 使用bash代替sh和ash
export FOX_ASH_IS_BASH=1  # 关联ash与bash
export FOX_ENABLE_APP_MANAGER=1  # 注释：按需启用橙狐应用管理器（纯净版默认关闭）

#特殊处理配置

export OF_TWRP_COMPATIBILITY_MODE=1  # 启用TWRP兼容模式
export OF_NO_RELOAD_AFTER_DECRYPTION=1  # 解密后不重新加载进程
export OF_NO_TREBLE_COMPATIBILITY_CHECK=1  # 禁用Treble兼容性检查
export FOX_DELETE_AROMAFM=1  # 删除AromaFM文件管理器（部分设备不兼容）
export OF_ENABLE_LPTOOLS=1  # 启用逻辑分区工具
export OF_ENABLE_ALL_PARTITION_TOOLS=1  # 启用所有分区管理工具
export OF_ENABLE_FS_COMPRESSION=1  # 启用文件系统压缩
export OF_DISPLAY_FORMAT_FILESYSTEMS_DEBUG_INFO=1  # 显示文件系统调试信息
export FOX_ALLOW_EARLY_SETTINGS_LOAD=1  # 支持早期加载设置
export FOX_SETTINGS_ROOT_DIRECTORY=/persist  # 设置配置文件存储路径
export OF_USE_DMCTL=1  # 启用设备映射控制工具
export OF_USE_AIDL_BOOT_CONTROL=1  # 启用AIDL模式的boot控制
export FOX_RESET_SETTINGS=disabled  # 安装后不恢复默认设置
export OF_IGNORE_LOGICAL_MOUNT_ERRORS=1  # 逻辑分区挂载错误仅日志显示
export FOX_USE_UPDATED_MAGISKBOOT=1  # 使用新版magiskboot工具
export OF_SUPPORT_VBMETA_AVB2_PATCHING=1  # 支持修补vbmeta禁用avb2.0

#数据解密核心配置

export FOX_ENABLE_DATA_DECRYPTION=true  # 启用数据解密功能
export FOX_FBE_DECRYPTION=true  # 明确指定FBE加密类型

#硬件功能设定（原有+新增适配）

export OF_USE_GREEN_LED=0  # 关闭绿色LED指示灯
export OF_FLASHLIGHT_ENABLE=0  #关闭闪光灯功能
export OF_ALLOW_DISABLE_NAVBAR=1  # 平板支持禁用导航栏（适配大屏操作）

#界面与时区配置（13.2英寸平板专属调整）

# 1. 明确横屏分辨率（宽=2800，高=2000，必须 W>H 才会触发横屏）
export OF_SCREEN_W=2800  # 平板横向宽度
export OF_SCREEN_H=2000  # 平板纵向高度
# 2. 横屏状态栏适配（避免元素拥挤）
export OF_STATUS_H=160  # 横屏状态栏高度（比竖屏略高，适配宽屏）
export OF_STATUS_INDENT_LEFT=80  # 状态栏左侧缩进（横屏需加大，避免图标贴边）
export OF_STATUS_INDENT_RIGHT=80  
# 3. 启用橙狐横屏模式（部分版本需显式开启）
export FOX_USE_LANDSCAPE_MODE=1  # 强制启用横屏界面（关键变量）
# 4. 触摸坐标适配（若触摸错位添加，平板通常无需，预留）
# export OF_TOUCHSCREEN_ROTATION=0  # 0=正常横屏，270=旋转适配（根据实际触摸调整）
export OF_HIDE_NOTCH=0  # 平板通常无刘海，禁用隐藏（有刘海则保持1）
export OF_DEFAULT_TIMEZONE="TAIST-8;TAIDT"  # 设置默认时区为北京时间
export OF_OPTIONS_LIST_NUM=9  # 平板大屏：增加选项列表数量（适配显示空间）
export OF_DEFAULT_KEYMASTER_VERSION=4.0  # 指定默认keymaster版本

#刷机属性调整（新增适配平板存储需求）

export FOX_BUGGED_AOSP_ARB_WORKAROUND="1546300800"  # 规避部分ROM防回滚检测（2019-01-01）
export OF_QUICK_BACKUP_LIST="/boot;/data;/system;/vendor;"  # 平板新增系统/ vendor快速备份（适配存储需求）
export FOX_ENABLE_KERNELSU_SUPPORT=1 #ksu支持
export FOX_ENABLE_KERNELSU_NEXT_SUPPORT=1 #ksunext支持
export FOX_ENABLE_SUKISU_SUPPORT=1 #sukisu支持（修复原配置空格问题）

#特殊处理与工具配置

export FOX_MAINTAINER_PATCH_VERSION=$(date +%y%m%d)  # 维护者补丁版本（按日期生成）
export OF_MAINTAINER="Nanya"  # 维护者名称
export FOX_MOVE_MAGISK_INSTALLER_TO_RAMDISK=1  # 将Magisk安装包移至ramdisk
#export OF_SKIP_FBE_DECRYPTION_SDKVERSION=32  # Android 12L及以上跳过FBE解密（避免卡LOGO）

#启动画面修改（保持原有配置，注释冗余重复项）

F=$(find "device" -maxdepth 2 -name "sm86xx")
\cp -fp bootable/recovery/gui/theme/landscape_hdpi/splash.xml "$F"/recovery/root/twres/splash.xml
sed -i 's/value="#D34E38"/value="#000000"/g' "$F"/recovery/root/twres/splash.xml  # 替换橙色为黑色
sed -i 's/value="#FF8038"/value="#000000"/g' "$F"/recovery/root/twres/splash.xml  # 替换浅橙色为黑色

echo -e "\x1b[96mAdontoo: 所有OrangeFox配置变量加载完毕！\x1b[m"
