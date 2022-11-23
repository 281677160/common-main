#!/bin/sh

#====================================================
#	Author:	281677160
#	Dscription: openwrt onekey Management
#	github: https://github.com/281677160/build-actions
#====================================================

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[1;36m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
GX=" ${Red}[恭喜]${Font}"
ERROR="${Red}[ERROR]${Font}"

function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOR() {
  echo -e "${Red} $1 ${Font}"
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
}
function ECHOBG() {
  echo
  echo -e "${GreenBG} $1 ${Font}"
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOG() {
  echo -e "${Green} $1 ${Font}"
  echo
}
function print_ok() {
  echo
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
function print_gg() {
  echo
  echo -e "${GX}${Green} $1 ${Font}"
  echo
}

function information_acquisition() {
source /bin/openwrt_info
Kernel=$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+" /usr/lib/opkg/info/kernel.control)
[ ! -d "${Download_Path}" ] && mkdir -p ${Download_Path} || rm -rf "${Download_Path}"/*
opkg list | awk '{print $1}' > ${Download_Path}/Installed_PKG_List
PKG_List="${Download_Path}/Installed_PKG_List"

curl --connect-timeout 5 "baidu.com" > "/dev/null" 2>&1 || wangluo='1'
if [[ "${wangluo}" == "1" ]]; then
  curl --connect-timeout 5 "google.com" > "/dev/null" 2>&1 || wangluo='2'
fi
if [[ "${wangluo}" == "1" ]] && [[ "${wangluo}" == "2" ]]; then
  echo "您可能没进行联网,请检查网络,或您的网络不能连接百度?"
  exit 1
else
  echo "网络连接正常"
fi

Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "${Google_Check}" == 301 ]; then
  echo "正在检测和下载云端API"
  DOWNLOAD=https://ghproxy.com/${Release_download}
  wget -q --show-progress https://ghproxy.com/${Github_API2} -O ${API_PATH}
else
  echo "正在检测和下载云端API"
  DOWNLOAD=${Release_download}
  wget -q --show-progress ${Github_API1} -O ${API_PATH}
fi
if [[ $? -ne 0 ]];then
  echo "获取API数据失败,Github地址不正确，或此地址没云端存在，或您的仓库为私库!"
  exit 1
else
  echo "云端API下载完成,开始获取固件信息"
fi

case "${TARGET_BOARD}" in
x86)
  [ -d '/sys/firmware/efi' ] && {
    BOOT_Type=uefi
  } || {
    BOOT_Type=legacy
  }
;;
*)
  BOOT_Type=sysupgrade
esac


CLOUD_Firmware_1="$(egrep -o "18.06-Lede-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_2="$(egrep -o "17.01-Lienol-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_3="$(egrep -o "19.07-Lienol-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_4="$(egrep -o "21.02-Lienol-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_5="$(egrep -o "master-Lienol-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_6="$(egrep -o "18.06-Immortalwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_7="$(egrep -o "18.06-K54-Immortalwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_8="$(egrep -o "21.02-Immortalwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_9="$(egrep -o "master-Immortalwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_10="$(egrep -o "19.07-Official-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_11="$(egrep -o "21.02-Official-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_12="$(egrep -o "22.03-Official-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_13="$(egrep -o "master-Official-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_14="$(egrep -o "21.02-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_15="$(egrep -o "22.03-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_16="$(egrep -o "master-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_17="$(egrep -o "ap-x-wrt-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_18="$(egrep -o "fix-arm-trusted-firmware-mediatek-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_19="$(egrep -o "fix-busybox-nslookup-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_20="$(egrep -o "fix-hostapd-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_21="$(egrep -o "fix-kdump-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_22="$(egrep -o "fix-lzma-openwrt-magic-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_23="$(egrep -o "fix-mac-address-increment-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_24="$(egrep -o "fix-missing-symbol-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_25="$(egrep -o "fix-mmap-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_26="$(egrep -o "fix-mt7663-firmware-sta-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_27="$(egrep -o "fix-nand_do_platform_check-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_28="$(egrep -o "fix-nand_upgrade_ubinized-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_29="$(egrep -o "fix-okli-loader-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_30="$(egrep -o "fix-uboot-mediatek-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_31="$(egrep -o "fix-uboot-mediatek-erase-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_32="$(egrep -o "fix-umdns-filter-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_33="$(egrep -o "ipvlan-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_34="$(egrep -o "mt7621-gsw150-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_35="$(egrep -o "mtk_ppe-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_36="$(egrep -o "p910nd-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_37="$(egrep -o "pr-dnsmasq-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_38="$(egrep -o "pr-fix-nand_do_platform_check-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_39="$(egrep -o "pr-ipq40xx-rt-ac42u-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_40="$(egrep -o "pr-rm-ax6000-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_41="$(egrep -o "switch_ports_status-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"
CLOUD_Firmware_42="$(egrep -o "switch-Xwrt-${DEFAULT_Device}-[0-9]+-${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${API_PATH} | awk 'END {print}')"

echo "
${CLOUD_Firmware_1}
${CLOUD_Firmware_2}
${CLOUD_Firmware_3}
${CLOUD_Firmware_4}
${CLOUD_Firmware_5}
${CLOUD_Firmware_6}
${CLOUD_Firmware_7}
${CLOUD_Firmware_8}
${CLOUD_Firmware_9}
${CLOUD_Firmware_10}
${CLOUD_Firmware_11}
${CLOUD_Firmware_12}
${CLOUD_Firmware_13}
${CLOUD_Firmware_14}
${CLOUD_Firmware_15}
${CLOUD_Firmware_16}
${CLOUD_Firmware_17}
${CLOUD_Firmware_18}
${CLOUD_Firmware_19}
${CLOUD_Firmware_20}
${CLOUD_Firmware_21}
${CLOUD_Firmware_22}
${CLOUD_Firmware_23}
${CLOUD_Firmware_24}
${CLOUD_Firmware_25}
${CLOUD_Firmware_26}
${CLOUD_Firmware_27}
${CLOUD_Firmware_28}
${CLOUD_Firmware_29}
${CLOUD_Firmware_30}
${CLOUD_Firmware_31}
${CLOUD_Firmware_32}
${CLOUD_Firmware_33}
${CLOUD_Firmware_34}
${CLOUD_Firmware_35}
${CLOUD_Firmware_36}
${CLOUD_Firmware_37}
${CLOUD_Firmware_38}
${CLOUD_Firmware_39}
${CLOUD_Firmware_40}
${CLOUD_Firmware_41}
${CLOUD_Firmware_42}
" >> /tmp/feedsdefault

sed -i '/^$/d' /tmp/feedsdefault
cat "/tmp/feedsdefault" |awk '$0=NR" "$0' > /tmp/GITHUB_ENN
sed -i '/^$/d' /tmp/GITHUB_ENN
XYZDSZ="$(cat /tmp/GITHUB_ENN | awk 'END {print}' |awk '{print $(1)}')"
}

function firmware_upgrade() {
TMP_Available=$(df -m | grep "/tmp" | awk '{print $4}' | awk 'NR==1' | awk -F. '{print $1}')
let X=$(grep -n "${CLOUD_Firmware}" ${API_PATH} | tail -1 | cut -d : -f 1)-4
let CLOUD_Firmware_Size=$(sed -n "${X}p" ${API_PATH} | egrep -o "[0-9]+" | awk '{print ($1)/1048576}' | awk -F. '{print $1}')+1
if [[ "${TMP_Available}" -lt "${CLOUD_Firmware_Size}" ]]; then
  echo "[$(date "+%Y年%m月%d日%H时%M分%S秒") 固件tmp空间值[${TMP_Available}M],云端固件体积[${CLOUD_Firmware_Size}M],空间不足，不能下载]"
  exit 1
else
  echo "${TMP_Available}  ${CLOUD_Firmware_Size}"
fi

cd "${Download_Path}"
echo "[$(date "+%Y年%m月%d日%H时%M分%S秒") 正在下载云端固件,请耐心等待..]"
wget -q --show-progress "${DOWNLOAD}/${CLOUD_Firmware}" -O ${CLOUD_Firmware}
if [[ $? -ne 0 ]];then
  curl -# -L -O "${DOWNLOAD}/${CLOUD_Firmware}"
fi
if [[ $? -ne 0 ]];then
  echo "[$(date "+%Y年%m月%d日%H时%M分%S秒") 下载云端固件失败,请检查网络再尝试或手动安装固件]"
  exit 1
else
  echo "[$(date "+%Y年%m月%d日%H时%M分%S秒") 下载云端固件成功!]"
fi

export LOCAL_MD5=$(md5sum ${CLOUD_Firmware} | cut -c1-3)
export LOCAL_256=$(sha256sum ${CLOUD_Firmware} | cut -c1-3)
export MD5_256=$(echo ${CLOUD_Firmware} | egrep -o "[a-zA-Z0-9]+${Firmware_SFX}" | sed -r "s/(.*)${Firmware_SFX}/\1/")
export CLOUD_MD5="$(echo "${MD5_256}" | cut -c1-3)"
export CLOUD_256="$(echo "${MD5_256}" | cut -c 4-)"
if [[ ! "${LOCAL_MD5}" == "${CLOUD_MD5}" ]]; then
  echo "[$(date "+%Y年%m月%d日%H时%M分%S秒") MD5对比失败,固件可能在下载时损坏,请检查网络后重试!]"
  exit 1
fi
if [[ ! "${LOCAL_256}" == "${CLOUD_256}" ]]; then
  echo "[$(date "+%Y年%m月%d日%H时%M分%S秒") SHA256对比失败,固件可能在下载时损坏,请检查网络后重试!]"
  exit 1
fi

cd "${Download_Path}"
echo "[$(date "+%Y年%m月%d日%H时%M分%S秒") 正在执行更新,更新期间请不要断开电源或重启设备 ...]"
chmod 777 "${CLOUD_Firmware}"
[[ "$(cat ${PKG_List})" =~ "gzip" ]] && opkg remove gzip > /dev/null 2>&1
sleep 2
if [[ -f "/etc/deletefile" ]]; then
  chmod 775 "/etc/deletefile"
  source /etc/deletefile
fi
rm -rf /etc/config/luci
echo "*/5 * * * * sh /etc/networkdetection > /dev/null 2>&1" >> /etc/crontabs/root
rm -rf /mnt/*upback.tar.gz && sysupgrade -b /mnt/upback.tar.gz
if [[ `ls -1 /mnt | grep -c "upback.tar.gz"` -eq '1' ]]; then
  Upgrade_Options='sysupgrade -f /mnt/upback.tar.gz'
  echo "${Upgrade_Options}"
else
  Upgrade_Options='sysupgrade -q'
  echo "${Upgrade_Options}"
fi
echo "[$(date "+%Y年%m月%d日%H时%M分%S秒") 升级固件中，请勿断开路由器电源，END]"
${Upgrade_Options} ${CLOUD_Firmware}
}
  
function Bendi_xuanzhe() {
  cat "/tmp/feedsdefault" |awk '$0=NR"、"$0'|awk '{print "  " $0}'
  clear
  echo
  echo
  echo -e "${Blue}  请输入您要升级的固件，选择前面对应的数值(1~N),输入[0或n]则为退出程序${Font}"
  echo
  export YUMINGIP="  请输入数字(1~N)"
  while :; do
  YMXZ=""
  read -p "${YUMINGIP}：" YMXZ
  if [[ "${YMXZ}" == "0" ]] || [[ "${YMXZ}" == "N" ]] || [[ "${YMXZ}" == "n" ]]; then
    CUrrenty="N"
  elif [[ "${YMXZ}" -le "${XYZDSZ}" ]]; then
    CUrrenty="Y"
  else
    CUrrenty=""
  fi
  case $CUrrenty in
  Y)
    CLOUD_Firmware="$(grep "${YMXZ}" /tmp/GITHUB_ENN |awk '{print $(2)}')"
    ECHOY " 您选择了 ${CLOUD_Firmware} 固件,10秒后将进行不保留配置升级固件操作"
    rm -rf /tmp/GITHUB_ENN
    sleep 12
    firmware_upgrade
  break
  ;;
  N)
    rm -rf GITHUB_ENN
    echo
    exit 0
  break
  ;;
  *)
    export YUMINGIP="  敬告,请输入正确数值"
  ;;
  esac
  done
}

function menu() {
  clear
  echo
  echo
  echo -e " 1${Red}.${Font}${Green}获取云端固件信息${Font}"
  echo
  echo -e " 2${Red}.${Font}${Green}退出${Font}"
  echo
  echo
  XUANZop="请输入数字"
  echo
  while :; do
  read -p " ${XUANZop}：" menu_num
  case $menu_num in
  1)
    information_acquisition
    Bendi_xuanzhe
  break
  ;;
  2)
    echo
    exit 0
  break
  ;;
  *)
    XUANZop="请输入正确的数字编号!"
  ;;
  esac
  done
}


menu