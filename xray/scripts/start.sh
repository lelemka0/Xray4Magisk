#!/system/bin/sh

MODDIR=${0%/*}

start_proxy () {
  ${MODDIR}/helper.service start &> /data/xray/run/service.log
}

if [ ! -f /data/xray/manual ] ; then
  start_proxy
  inotifyd ${MODDIR}/xray.inotify ${MODDIR}/.. &>> /data/xray/run/service.log &
fi
