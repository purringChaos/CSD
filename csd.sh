#!/usr/bin/env bash
set -e

MALWARE_FOUND_LIST="$(mktemp)"

DEFAULT_JOBS="$(nproc)"
JOBS=${JOBS:-${DEFAULT_JOBS}}

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

	if rg -qi "${1}" "${MALWARE_FOUND_LIST}"; then
		echo "${YES}"
	else
		echo "${NO}"
	fi
}

function check_for_match() {
	if rg -uuuqi "${1}"; then
		echo "${1}" >> "${MALWARE_FOUND_LIST}"
	fi
}

function search_job() {
	if [ "${JOBS}" -le 1 ]; then
		check_for_match "${1}"
		return
	fi

	jobcount=$(jobs -p | wc -l)
	while [ "${jobcount}" -ge "${JOBS}" ]; do
		sleep 1
		jobcount=$(jobs -p | wc -l)
	done
	check_for_match "${1}" &
}

function check_spyware() {
	search_job "aliyun"
	search_job "yunos"
	search_job "umeng"
	search_job "tencent"
	search_job "bytedance"
	search_job "baidu"
	search_job "/proc/cpuinfo"
	search_job "/proc/meminfo"
	search_job "/proc/%d/mounts"
	search_job "magisk"
	search_job "imei"

	wait

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
	if [ ! -d "${1}" ]; then
		APKFOLDER="$(mktemp -d)"
		java -jar apktool.jar -f -o "${APKFOLDER}" d "${1}"
	else 
		APKFOLDER="${1}"
	fi
	pushd "${APKFOLDER}" >/dev/null || exit
	echo "Analyzing APK..."
	check_spyware
	popd >/dev/null|| exit
	if [ ! -d "${1}" ]; then
		echo "Cleaning up..."
		rm -rf "${APKFOLDER}"
	fi
	print_report "${1}"
	rm -f "${MALWARE_FOUND_LIST}"
fi