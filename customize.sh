#!/sbin/sh
#####################
# helper Customization
#####################
SKIPUNZIP=1

# prepare helper execute environment
ui_print "- Prepare helper execute environment."
mkdir -p /data/xray
mkdir -p /data/xray/run
mkdir -p /data/xray/bin
mkdir -p /data/xray/confs
mkdir -p $MODPATH/scripts

download_helper_zip="/data/xray/run/helper.zip"
custom="/sdcard/Download/helper.zip"

if [ -f "${custom}" ]; then
  cp "${custom}" "${download_helper_zip}"
  ui_print "Info: Custom helper found, starting installer"
  latest_helper_version=custom
else
  case "${ARCH}" in
    arm)
      version="helper-linux-arm32-v7a.zip"
      ;;
    arm64)
      version="helper-linux-arm64-v8a.zip"
      ;;
    x86)
      version="helper-linux-32.zip"
      ;;
    x64)
      version="helper-linux-64.zip"
      ;;
  esac
  if [ -f /sdcard/Download/"${version}" ]; then
    cp /sdcard/Download/"${version}" "${download_helper_zip}"
    ui_print "Info: helper already downloaded, starting installer"
    latest_helper_version=custom
  else
    # download latest helper core from official link
    ui_print "- Connect official helper download link."
    if [ $BOOTMODE ! = true ] ; then
      abort "Error: Please install in Magisk Manager"
    fi
    official_helper_link="https://github.com/CerteKim/Xray-Helper/releases"
    latest_helper_version=`curl -k -s https://api.github.com/repos/CerteKim/Xray-Helper/releases | grep -m 1 "tag_name" | grep -o "v[0-9.]*"`
    if [ "${latest_helper_version}" = "" ] ; then
      ui_print "Error: Connect official helper download link failed." 
      ui_print "Tips: You can download helper core manually,"
      ui_print "      and put it in /sdcard/Download"
      abort
    fi
    ui_print "- Download latest helper core ${latest_helper_version}-${ARCH}"
    curl "${official_helper_link}/download/${latest_helper_version}/${version}" -k -L -o "${download_helper_zip}" >&2
    if [ "$?" != "0" ] ; then
      ui_print "Error: Download helper core failed."
      ui_print "Tips: You can download helper core manually,"
      ui_print "      and put it in /sdcard/Download"
      abort
    fi
  fi
fi

# install helper execute file
ui_print "- Install helper core $ARCH execute files"
unzip -j -o "${download_helper_zip}" "geoip.dat" -d /data/xray >&2
unzip -j -o "${download_helper_zip}" "geosite.dat" -d /data/xray >&2
unzip -j -o "${download_helper_zip}" "helper" -d /data/xray/bin >&2
unzip -j -o "${ZIPFILE}" 'helper/scripts/*' -d $MODPATH/scripts >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
rm "${download_helper_zip}"
# copy helper data and config
ui_print "- Copy helper config and data files"
[ -f /data/xray/config.json ] || \
unzip -j -o "${ZIPFILE}" "helper/etc/config.json" -d /data/xray >&2
[ -f /data/xray/confs/proxy.json ] || \
unzip -j -o "${ZIPFILE}" "helper/etc/confs/*" -d /data/xray/confs >&2
[ -f /data/xray/appid.list] || \
echo ALL > /data/xray/appid.list
# generate module.prop
ui_print "- Generate module.prop"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=helper" > $MODPATH/module.prop
echo "name=Xray4Magisk2" >> $MODPATH/module.prop
echo -n "version=Module v2.0.0, Core " >> $MODPATH/module.prop
echo ${latest_helper_version} >> $MODPATH/module.prop
echo "versionCode=20210211" >> $MODPATH/module.prop
echo "author=CerteKim" >> $MODPATH/module.prop
echo "description=helper core with service scripts for Android" >> $MODPATH/module.prop

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm  $MODPATH/service.sh    0  0  0755
set_perm  $MODPATH/uninstall.sh    0  0  0755
set_perm  $MODPATH/scripts/start.sh    0  0  0755
set_perm  $MODPATH/scripts/helper.inotify    0  0  0755
set_perm  $MODPATH/scripts/helper.service    0  0  0755
set_perm  $MODPATH/scripts/helper.tproxy     0  0  0755
set_perm  /data/xray                0  0  0755

######################
#                    #
#   Xray Installer   #
#                    #
######################
download_xray_zip="/data/xray/run/xray-core.zip"
custom="/sdcard/Download/Xray-core.zip"

if [ -f "${custom}" ]; then
  cp "${custom}" "${download_xray_zip}"
  ui_print "Info: Custom Xray-core found, starting installer"
  latest_xray_version=custom
else
  case "${ARCH}" in
    arm)
      version="Xray-linux-arm32-v7a.zip"
      ;;
    arm64)
      version="Xray-android-arm64-v8a.zip"
      ;;
    x86)
      version="Xray-linux-32.zip"
      ;;
    x64)
      version="Xray-linux-64.zip"
      ;;
  esac
  if [ -f /sdcard/Download/"${version}" ]; then
    cp /sdcard/Download/"${version}" "${download_xray_zip}"
    ui_print "Info: Xray-core already downloaded, starting installer"
    latest_xray_version=custom
  else
    # download latest xray core from official link
    ui_print "- Connect official xray download link."
    if [ $BOOTMODE ! = true ] ; then
      abort "Error: Please install in Magisk Manager"
    fi
    official_xray_link="https://github.com/XTLS/Xray-core/releases"
    latest_xray_version=`curl -k -s https://api.github.com/repos/XTLS/Xray-core/releases | grep -m 1 "tag_name" | grep -o "v[0-9.]*"`
    if [ "${latest_xray_version}" = "" ] ; then
      ui_print "Error: Connect official xray download link failed." 
      ui_print "Tips: You can download xray core manually,"
      ui_print "      and put it in /sdcard/Download"
      abort
    fi
    ui_print "- Download latest xray core ${latest_xray_version}-${ARCH}"
    curl "${official_xray_link}/download/${latest_xray_version}/${version}" -k -L -o "${download_xray_zip}" >&2
    if [ "$?" != "0" ] ; then
      ui_print "Error: Download xray core failed."
      ui_print "Tips: You can download xray core manually,"
      ui_print "      and put it in /sdcard/Download"
      abort
    fi
  fi
fi

# install xray execute file
ui_print "- Install xray core $ARCH execute files"
unzip -j -o "${download_xray_zip}" "geoip.dat" -d /data/xray >&2
unzip -j -o "${download_xray_zip}" "geosite.dat" -d /data/xray >&2
unzip -j -o "${download_xray_zip}" "xray" -d /data/xray/bin >&2