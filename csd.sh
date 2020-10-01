#!/usr/bin/env bash

set -e

if [ -n "${DISABLE_COLOR}" ] || [ -n "${DISABLE_COLOUR}" ]; then
	NORMAL=""
	BOLD=""
	RED=""
	GREEN=""
else
	NORMAL="\e[0m"
	BOLD="\e[1m"
	RED="\e[31m"
	GREEN="\e[32m"
fi

function random_yes() {
	shuf -n 1 -e "Yep!~" "Yup~" "Yes!" "Absolutely!" "Extremely Likely.." "Indeed~"
}

function random_no() {
	shuf -n 1 -e "Nope!" "No~" "Null." "None!" "Nah~"
}

function is_match() {
	if [ -n "${PLAINTEXT}" ]; then
		# shellcheck disable=SC2046
		YES=$(printf "${GREEN}%s${NORMAL}" $(random_yes))
		# shellcheck disable=SC2046
		NO=$(printf "${RED}%s${NORMAL}" $(random_no))
	else
		YES="${GREEN}✓${NORMAL}"
		NO="${RED}𐄂${NORMAL}"
	fi

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
	[ -z "${CLEAR_SCREEN}" ] && clear
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
	exit 1
else
	echo "Disassembling APK..."
	APKFOLDER="$(mktemp -d)"
	java -jar apktool.jar -f -o "${APKFOLDER}" d "${1}"
	pushd "${APKFOLDER}" >/dev/null || exit
	echo "Analyzing APK..."
	check_spyware
	popd >/dev/null|| exit
	echo "Cleaning up..."
	rm -rf "${APKFOLDER}"
	print_report "${1}"
fi
