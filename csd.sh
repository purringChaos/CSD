#!/usr/bin/env bash

NORMAL="\e[0m"
BOLD="\e[1m"

RED="\e[31m"
GREEN="\e[32m"

YES="${GREEN}✓${NORMAL}"
NO="${RED}𐄂${NORMAL}"

function is_match() {
	if rg -uuuqi "$1"; then
		echo "${YES}"
	else
		echo "${NO}"
	fi
}


function check_spyware() {
	ALIYUN=$(is_match "aliyun")
	YUNOS=$(is_match "yunos")
	UMENG=$(is_match "umeng")
	TENCENT=$(is_match "tencent")
	BYTEDANCE=$(is_match "bytedance")
	BAIDU=$(is_match "baidu")
	CPUINFO=$(is_match "/proc/cpuinfo")
	MEMINFO=$(is_match "/proc/meminfo")
	MNTCHECK=$(is_match "/proc/%d/mounts")
	MAGISKMENTION=$(is_match "magisk")
	IMEIMENTION=$(is_match "imei")
}

function print_report() {
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

if [ -z "${1}" ]; then
	echo "Usage: ./csd.sh (APK path)"
else
	echo "Disassembling APK..."
	java -jar apktool.jar d "${1}"
	APKFOLDER="${1%.*}"
	pushd "${APKFOLDER}" || exit
	echo "Analyzing APK..."
	check_spyware
	popd || exit
	echo "Cleaning up..."
	rm -rf "${APKFOLDER}"
	print_report "${1}"
fi
