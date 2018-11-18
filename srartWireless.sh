#!/bin/bash

if [ $UID -ne 0 ];then
	echo "[!]You must be root"
	exit
fi

killall wpa_supplicant
killall hostapd
ifconfig wlan0 up 
hostapd -B /etc/hostapd/hostapd.conf

