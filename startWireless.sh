#!/bin/bash

killProcess () {

    ps aux | grep $1 &>/dev/null
    while [ $? -eq 0 ];do
        killall $1
    done 
}


if [ $UID -ne 0 ];then
	echo "[!]You must be root"
	exit
fi

killProcess wpa_supplicant
killProcess hostapd
killProcess dhclient
ifconfig wlan0 up 
hostapd -B /etc/hostapd/hostapd.conf

