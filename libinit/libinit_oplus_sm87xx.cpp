/*
 * Copyright (C) 2022-2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android-base/parseint.h>
#include <android-base/properties.h>
#include <android-base/strings.h>  // 新增：用于Split/Trim
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>
#include <sys/stat.h>  // 新增：用于文件操作
#include <fcntl.h>     // 新增：用于open函数
#include <unistd.h>    // 新增：用于read/close函数

#include <fs_mgr.h>
#include <unordered_map>

using android::base::GetProperty;
using android::base::ParseInt;  // 新增：安全类型转换
using android::base::Split;      // 新增：解析cmdline参数
using android::base::Trim;       // 新增：去除字符串首尾空格

const std::unordered_map<int, std::string> kRegionSuffixMap = {
    {27,    "IN"},
    {55,    "RU"},
    {68,    "EEA"},
    {151,   ""},    // CN
    {161,   "NA"},
    {0,     ""},    // Default
};

struct ModelInfo {
    const char* brand;              // ro.product.brand
    const char* device;             // ro.product.device
    const char* manufacturer;       // ro.product.manufacturer
    const char* model;              // ro.product.model
    const char* base_name;          // ro.product.name  w/o region suffix
    const char* twversion;          // ro.twrp.device_version
    const char* supportSpr;         // vendor.display.enable_spr
};

const std::unordered_map<int, ModelInfo> kModelInfoMap = {
    {23821, {"OnePlus", "OP5D0DL1", "OnePlus", "PJZ110",  "PJZ110",  "OnePlus_13",          "1"}}, // dodge CN
    {24926, {"OnePlus", "OP615EL1", "OnePlus", "OPD2413", "OPD2413", "OnePlus_Pad_2_Pro",   "0"}}, // erhai OnePlus Pad 2 Pro 
    {24600, {"realme",  "RE6018L1", "realme",  "RMX5010", "RMX5010", "Realme_GT_7_Pro",     "0"}}, // RMX5010 CN
    {24620, {"realme",  "RE602CL1", "realme",  "RMX5090", "RMX5090", "Realme_GT_7_Pro_JS",  "0"}}, // RMX5090 CN
    {24670, {"realme",  "RE605FL1", "realme",  "RMX5011", "RMX5011", "Realme_GT_7_Pro",     "0"}}, // RMX5011 IN
    {24671, {"realme",  "RE605FL1", "realme",  "RMX5011", "RMX5011", "Realme_GT_7_Pro",     "0"}}, // RMX5011 EEA/RU
    {24811, {"OnePlus", "OP60EBL1", "OnePlus", "PKR110",  "PKR110",  "OnePlus_ACE_5_Pro",   "0"}}, // hummer CN
    {24821, {"OnePlus", "OP60F5L1", "OnePlus", "PKX110",  "PKX110",  "OnePlus_13_T",        "1"}}, // pagani CN
    {24851, {"OnePlus", "OP6113L1", "OnePlus", "PLQ110",  "PLQ110",  "OnePlus_ACE_6",       "0"}}, // ktm CN
    {25600, {"realme",  "RE6400L1", "realme",  "RMX6699", "RMX6699", "Realme_GT_8",         "0"}}, // RMX6699 CN
    {0,     {"OPLUS",   "SM87XX",   "OPLUS",   "SM87XX",  "SM87XX",  "SM87XX",              "0"}}, // Default
};

/*
 * SetProperty does not allow updating read only properties and as a result
 * does not work for our use case. Write "OverrideProperty" to do practically
 * the same thing as "SetProperty" without this restriction.
 */
void OverrideProperty(const char* name, const char* value) {
    size_t valuelen = strlen(value);

    prop_info* pi = (prop_info*)__system_property_find(name);
    if (pi != nullptr) {
        __system_property_update(pi, value, valuelen);
    } else {
        __system_property_add(name, strlen(name), value, valuelen);
    }
}

void SetupModelProperties(const ModelInfo& info, const std::string& region) {
    std::string name = info.base_name + region;
    struct PropPair {
        const char* key;
        const char* value;
    } props[] = {
        {"ro.product.brand",            info.brand},
        {"ro.product.device",           info.device},
        {"ro.product.manufacturer",     info.manufacturer},
        {"ro.product.model",            info.model},
        {"ro.product.name",             name.c_str()},
        {"vendor.display.enable_spr",   info.supportSpr},
        {"ro.twrp.device_version",      info.twversion},
        {"ro.build.date.utc",           "0"},
    };
    for (const auto& p : props) {
        OverrideProperty(p.key, p.value);
    }
}

// 新增：自定义cmdline参数解析函数（替代废弃的GetKernelCmdline）
std::string ReadCmdlineParam(const std::string& param_name) {
    const char* cmdline_path = "/proc/cmdline";
    char buf[4096] = {0};
    int fd = open(cmdline_path, O_RDONLY);
    if (fd < 0) {
        LOG(WARNING) << "Failed to open " << cmdline_path << ", errno: " << errno;
        return "0";
    }

    ssize_t read_len = read(fd, buf, sizeof(buf) - 1);
    close(fd);
    if (read_len < 0) {
        LOG(WARNING) << "Failed to read " << cmdline_path << ", errno: " << errno;
        return "0";
    }

    // 解析cmdline参数（格式：key=value 或 key）
    std::vector<std::string> params = Split(buf, " ");
    for (const auto& param : params) {
        std::string trimmed = Trim(param);
        if (trimmed.empty()) continue;

        size_t eq_pos = trimmed.find('=');
        if (eq_pos == std::string::npos) {
            // 无值参数，跳过
            continue;
        }

        std::string key = trimmed.substr(0, eq_pos);
        std::string value = trimmed.substr(eq_pos + 1);
        if (key == param_name) {
            return value;
        }
    }

    // 未找到参数，返回默认值
    LOG(WARNING) << "Param " << param_name << " not found in cmdline";
    return "0";
}

void vendor_load_properties() {
    // 替换：用自定义函数 替换：用自定义函数读取oplus_region，替代废弃的GetKernelCmdline
    std::string buf = ReadCmdlineParam("oplus_region");
    int region = 0;
    // 安全转换（避免std::stoi的异常风险）
    if (!ParseInt(buf, &region)) {
        LOG(ERROR) << "Invalid oplus_region value: " << buf << ", using default 0";
        region = 0;
    }

    // 查找区域后缀（保留原有逻辑）
    auto region_suffix_iter = kRegionSuffixMap.find(region);
    if (region_suffix_iter == kRegionSuffixMap.end()) {
        LOG(WARNING) << "Unknown oplus_region: " << region << ", using default";
        region_suffix_iter = kRegionSuffixMap.find(0);
    }

    // 读取prjname（保留原有逻辑，添加安全转换）
    std::string prjname_str = GetProperty("ro.boot.prjname", "0");
    int prjname = 0;
    if (!ParseInt(prjname_str, &prjname)) {
        LOG(ERROR) << "Invalid ro.boot.prjname value: " << prjname_str << ", using default 0";
        prjname = 0;
    }

    // 查找机型信息（保留原有逻辑）
    auto model_info = kModelInfoMap.find(prjname);
    if (model_info == kModelInfoMap.end()) {
        LOG(ERROR) << "Unknown prjname: " << prjname << ", using default";
        model_info = kModelInfoMap.find(0);
    }

    SetupModelProperties(model_info->second, region_suffix_iter->second);
}
