#!/bin/bash

NORMAL="\e[0m"
BOLD="\e[1m"

RED="\e[31m"
GREEN="\e[32m"

YES="${GREEN}✓${NORMAL}"
NO="${RED}𐄂${NORMAL}"

check_spyware() {
	if grep -qri "aliyun"; then
		ALIYUN=${YES}
	else
		ALIYUN=${NO}
	fi
	if grep -qri "yunos"; then
		YUNOS=${YES}
	else
		YUNOS=${NO}
	fi
	if grep -qri "umeng"; then
		UMENG=${YES}
	else
		UMENG=${NO}
	fi
	if grep -qri "tencent"; then
		TENCENT=${YES}
	else
		TENCENT=${NO}
	fi
	if grep -qri "bytedance"; then
		BYTEDANCE=${YES}
	else
		BYTEDANCE=${NO}
	fi
	if grep -qri "baidu"; then
		BAIDU=${YES}
	else
		BAIDU=${NO}
	fi
	if grep -qri "/proc/cpuinfo"; then
		CPUINFO=${YES}
	else
		CPUINFO=${NO}
	fi
	if grep -qri "/proc/meminfo"; then
		MEMINFO=${YES}
	else
		MEMINFO=${NO}
	fi
	if grep -qri "/proc/%d/mounts"; then
		MNTCHECK=${YES}
	else
		MNTCHECK=${NO}
	fi
	if grep -qri "Magisk"; then
		MAGISKMENTION=${YES}
	else
		MAGISKMENTION=${NO}
	fi
	if grep -qri "IMEI"; then
		IMEIMENTION=${YES}
	else
		IMEIMENTION=${NO}
	fi
}

print_report() {
	clear
	echo -e "${BOLD}${1} Report:${NORMAL}"
	echo -e "Aliyun: ${ALIYUN}"
	echo -e "YunOS: ${YUNOS}"
	echo -e "Umeng: ${UMENG}"
	echo -e "Tencent: ${TENCENT}"
	echo -e "Bytedance: ${BYTEDANCE}"
	echo -e "Baidu: ${BAIDU}"
	echo -e "/proc/cpuinfo access: ${CPUINFO}"
	echo -e "/proc/meminfo access: ${MEMINFO}"
	echo -e "Magisk /proc/%d/mounts check: ${MNTCHECK}"
	echo -e "Magisk mention: ${MAGISKMENTION}"
	echo -e "IMEI mention: ${IMEIMENTION}"
}

if [ -z ${1} ]; then
	echo "Usage: ./csd.sh (APK path)"
else
	echo "Disassembling APK..."
	java -jar apktool.jar d ${1}
	APKFOLDER=${1%.*}
	OLDDIR=$(pwd)
	cd ${APKFOLDER}
	echo "Analyzing APK..."
	check_spyware
	cd ${OLDDIR}
	echo "Cleaning up..."
	rm -rf ${APKFOLDER}
	print_report ${1}
fi
