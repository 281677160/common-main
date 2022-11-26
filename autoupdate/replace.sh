#!/bin/bash

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
Input_Option=$1

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
clear
echo
ECHOY " 开始执行资料读取,读取完毕显示选择固件界面"

source /etc/openwrt_update

A="$(wget -V |grep 'GNU Wget' |egrep -o "[0-9]+\.[0-9]+\.[0-9]+")"
B="1.16.1"
if [[ `awk -v num1=${A} -v num2=${B} 'BEGIN{print(num1>num2)?"0":"1"}'` -eq '0' ]]; then
  WGETGNU="wget -q --show-progress"
else
  WGETGNU="wget -q"
fi

Kernel=$(grep 'Version' /usr/lib/opkg/info/kernel.control |egrep -o "[0-9]+\.[0-9]+\.[0-9]+")
[ ! -d "${Download_Path}" ] && mkdir -p ${Download_Path} || rm -rf "${Download_Path}"/*
opkg list | awk '{print $1}' > ${Download_Path}/Installed_PKG_List
PKG_List="${Download_Path}/Installed_PKG_List"
GUJIAN_liebiaoone="${Download_Path}/gujianliebiaoone"
GUJIAN_liebiaotwo="${Download_Path}/gujianliebiaotwo"

ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 检测您网络是否联网]"
sleep 2
curl --connect-timeout 10 "baidu.com" > "/dev/null" 2>&1 || wangluo='1'
if [[ "${wangluo}" == "1" ]]; then
  curl --connect-timeout 10 "google.com" > "/dev/null" 2>&1 || wangluo='2'
fi
if [[ "${wangluo}" == "1" ]] && [[ "${wangluo}" == "2" ]]; then
  ECHOR "[$(date "+%Y年%m月%d日%H时%M分%S秒") 您可能没进行联网,请检查网络?"
  exit 1
else
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 网络联网正常]"
  sleep 2
fi

ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 检测网络类型]"
Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "${Google_Check}" == 301 ]; then
  DOWNLOAD=https://ghproxy.com/${Release_download}
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 您的网络需要使用代理下载固件,网速或许有影响]"
  sleep 2
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 获取云端API]"
  sleep 2
  echo
  ${WGETGNU} ${Github_API2} -O ${API_PATH}
else
  DOWNLOAD=${Release_download}
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 您的网络可畅游全世界!]"
  sleep 2
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 获取云端API]"
  echo
  ${WGETGNU} ${Github_API1} -O ${API_PATH}
fi
if [[ -f "/tmp/Downloads/zzz_api" ]] && [[ ! -s "/tmp/Downloads/zzz_api" ]]; then
  ECHOR "[$(date "+%Y年%m月%d日%H时%M分%S秒") 获取数据失败,Github地址不正确,或此地址没云端存在,或您的仓库为私库,或网络抽风了再试试看!]"
  exit 1
else
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 云端API下载完成,开始获取固件信息]"
  sleep 2
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

cat > "${GUJIAN_liebiaoone}" <<-EOF
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
EOF
sed -i '/^$/d' "${GUJIAN_liebiaoone}"
local_firmw="${LUCI_EDITION}-${SOURCE}"
kk=$(grep "${local_firmw}" "${GUJIAN_liebiaoone}")
sed -i "/${kk}/d" "${GUJIAN_liebiaoone}"
sed -i "1i${kk}" "${GUJIAN_liebiaoone}"
sed -i s/[[:space:]]//g "${GUJIAN_liebiaoone}"
cat "${GUJIAN_liebiaoone}" |awk '$0=NR" "$0' > ${GUJIAN_liebiaotwo}
XYZDSZ="$(cat "${GUJIAN_liebiaotwo}" | awk 'END {print}' |awk '{print $(1)}')"
}

function firmware_upgrade() {
cloud_firmw=$(echo "${CLOUD_Firmware}" |head -n 5|cut -d '-' -f 1-2)

TMP_Available=$(df -m | grep "/tmp" | awk '{print $4}' | awk 'NR==1' | awk -F. '{print $1}')
let X=$(grep -n "${CLOUD_Firmware}" ${API_PATH} | tail -1 | cut -d : -f 1)-4
let CLOUD_Firmware_Size=$(sed -n "${X}p" ${API_PATH} | egrep -o "[0-9]+" | awk '{print ($1)/1048576}' | awk -F. '{print $1}')+1
if [[ "${TMP_Available}" -lt "${CLOUD_Firmware_Size}" ]]; then
  ECHOR "[$(date "+%Y年%m月%d日%H时%M分%S秒") 固件tmp空间值[${TMP_Available}M],云端固件体积[${CLOUD_Firmware_Size}M],空间不足，不能下载]"
  exit 1
else
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 固件tmp空间值[${TMP_Available}M],云端固件体积[${CLOUD_Firmware_Size}M],下载固件空间充足]"
  sleep 2
fi

if [[ "${local_firmw}" == "${cloud_firmw}" ]]; then
  echo
  ECHOYY "您选择的固件为您现在所用的固件为同一个作者同一个LUCI版本,"
  echo
  ECHOYY "可以选择保留配置或不保留配置升级"
  echo
  while :; do
  read -p " [输入[Y/y]为保留配置，输入[N/n]为不保留配置]： " Bendi_Wsl
  case ${Bendi_Wsl} in
  [Yy])
    Upgrade_Options='sysupgrade -f /mnt/upback.tar.gz'
    upgrade_tions="1"
    tongzhi="保留配置"
  break
  ;;
  [Nn])
    Upgrade_Options='sysupgrade -F -n'
    tongzhi="不保留配置"
  break
  ;;
  *)
    ECHOYY "请输入正确选[Y/n]"
  break
  ;;
  esac
  done
else
   Upgrade_Options='sysupgrade -F -n'
   tongzhi="不保留配置"
fi


cd "${Download_Path}"
ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 正在下载云端固件,请耐心等待..]"
echo
${WGETGNU} "${DOWNLOAD}/${CLOUD_Firmware}" -O ${CLOUD_Firmware}
if [[ $? -ne 0 ]];then
  curl -# -L -O "${DOWNLOAD}/${CLOUD_Firmware}"
fi
if [[ $? -ne 0 ]];then
  ECHOR "[$(date "+%Y年%m月%d日%H时%M分%S秒") 下载云端固件失败,请检查网络再尝试或手动安装固件]"
  exit 1
else
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") 下载云端固件成功!]"
  sleep 2
fi

export LOCAL_MD5=$(md5sum ${CLOUD_Firmware} | cut -c1-3)
export LOCAL_256=$(sha256sum ${CLOUD_Firmware} | cut -c1-3)
export MD5_256=$(echo ${CLOUD_Firmware} | egrep -o "[a-zA-Z0-9]+${Firmware_SFX}" | sed -r "s/(.*)${Firmware_SFX}/\1/")
export CLOUD_MD5="$(echo "${MD5_256}" | cut -c1-3)"
export CLOUD_256="$(echo "${MD5_256}" | cut -c 4-)"
if [[ ! "${LOCAL_MD5}" == "${CLOUD_MD5}" ]]; then
  ECHOR "[$(date "+%Y年%m月%d日%H时%M分%S秒") MD5对比失败,固件可能在下载时损坏,请检查网络后重试!]"
  exit 1
else
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") MD5对比成功!]"
  sleep 2
fi
if [[ ! "${LOCAL_256}" == "${CLOUD_256}" ]]; then
  ECHOR "[$(date "+%Y年%m月%d日%H时%M分%S秒") SHA256对比失败,固件可能在下载时损坏,请检查网络后重试!]"
  exit 1
else
  ECHOB "[$(date "+%Y年%m月%d日%H时%M分%S秒") SHA256对比成功!]"
  sleep 2
fi

cd "${Download_Path}"
ECHOB "[倒计10秒后,执行[${tongzhi}]更新,更新期间请不要断开电源或重启设备 ...]"
seconds=10
while [ $seconds -gt 0 ];do
  echo -n $seconds
  sleep 1
  seconds=$(($seconds - 1))
  echo -ne "\r	\r"
done
chmod 777 "${CLOUD_Firmware}"
[[ "$(cat ${PKG_List})" =~ "gzip" ]] && opkg remove gzip > /dev/null 2>&1
sleep 2
if [[ "${upgrade_tions}" == "1" ]]; then
  if [[ -f "/etc/deletefile" ]]; then
    chmod +x "/etc/deletefile"
    source /etc/deletefile
  fi
  rm -rf /etc/config/luci
  echo "*/5 * * * * sh /etc/networkdetection > /dev/null 2>&1" >> /etc/crontabs/root
  rm -rf /mnt/*upback.tar.gz && sysupgrade -b /mnt/upback.tar.gz
  if [[ `ls -1 /mnt | grep -c "upback.tar.gz"` -eq '1' ]]; then
    ${Upgrade_Options} ${CLOUD_Firmware}
  else
    ${Upgrade_Options} ${CLOUD_Firmware}
  fi
else
  ${Upgrade_Options} ${CLOUD_Firmware}
fi
}
  
function Bendi_xuanzhe() {
  clear
  echo
  echo
  ECHOYY " 当前使用固件：${SOURCE} / ${LUCI_EDITION} / ${Kernel}"
  ECHOYY " 当前固件格式：${BOOT_Type}${Firmware_SFX}"
  ECHOYY " 当前设备型号：${DEFAULT_Device}"
  echo
  echo
  ECHOR " 以下为可选升级固件："
  ECHOG " ******************************************************************"  
  cat "${GUJIAN_liebiaoone}" |awk '$0=NR"、"$0'|awk '{print "  " $0}'
  echo
  ECHOG " ******************************************************************" 
  echo
  ECHOB " 请输入您要升级固件名称前面对应的数值(1~X),输入[0或N]则为退出程序"
  echo
  ECHOG " 有多选时,第一个为您现在所用固件的同类型，可进行选择保留配置或者不保留配置升级"
  ECHOG " 其他的固件因为作者或者LUCI不同型号，都不保留配置升级"
  export YUMINGIP="  请输入数字(1~N)"
  while :; do
  YMXZ=""
  read -p "${YUMINGIP}：" YMXZ
  if [[ "${YMXZ}" == "0" ]] || [[ "${YMXZ}" == "N" ]] || [[ "${YMXZ}" == "n" ]]; then
    CUrrenty="N"
  elif [[ -z "${YMXZ}" ]]; then
    CUrrenty="x"
  elif [[ "${YMXZ}" -le "${XYZDSZ}" ]]; then
    CUrrenty="Y"
    YMXZ=${YMXZ}
  else
    CUrrenty="x"
  fi
  case $CUrrenty in
  Y)
    CLOUD_Firmware=$(cat ${GUJIAN_liebiaoone} |awk ''NR==${YMXZ}'')
    echo
    ECHOG " 您选择了[${CLOUD_Firmware}]固件"
    sleep 2
    firmware_upgrade
  break
  ;;
  N)
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

if [[ -z "${Input_Option}" ]]; then
  menu
else
  case ${Input_Option} in
  -u)
    information_acquisition
    Bendi_xuanzhe
  ;;
  esac
fi