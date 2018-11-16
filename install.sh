#!/bin/bash

dhcpFile="/etc/dhcpcd.conf"
hostapdFile="/etc/hostapd/hostapd.conf"

SSID="testingAP"
PASS="Password"

if [ $UID -ne 0 ]; then
    echo "[!] You should run this as root"
    exit
fi

sudo apt-get update && sudo apt-get -y upgrade

sudo apt-get -y install hostapd dnsmasq

#Install software
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

#Configure static ip for wlan0

echo "interface wlan0" >> $dhcpFile
echo "static ip_address=192.168.0.10/24" >>$dhcpFile
echo "denyinterfaces eth0">>$dhcpfile
echo "denyinterfaces wlan0">>$dhcpFile

#Configure DHCP Server (dnsmasq)

cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

echo "interface=wlan0" >> /etc/dnsmasq.conf
echo "dhcp-range=192.168.0.11,192.168.0.30" >> /etc/dnsmasq.conf

#Configure hostapd

echo "interface=wlan0" >> $hostapdFile
echo "bridge=br0" >> $hostapdFile
echo "hw_mode=g">> $hostapdFile
echo"channel=7" >> $hostapdFile
echo "wmm_enabble=0">>$hostapdFile
echo "macaddr_acl=0">>$hostapdFile
echo "auth_algs=1">>$hostapdFile
echo "ignore_broadcast_ssid=0">>$hostapdFile
echo "wpa=2">>$hostapdFile
echo "wpa_key_mgmt=WPA-PSK" >> $hostapdFile
echo "wpa_pairwise=TKIP" >> $hotapdFile
echo "rsn_pairwise=CCMP" >>$hostapdFile
echo "ssid=$SSID">>$hostapdFile
echo "wpa_passphrase=$PASS">>$hostapdFile

echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> /etc/default/hostapd

echo "net.ipv4.ip_forward=1">>/etc/sysctl.conf

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
iptables-restore < /etc/iptables.ipv4.nat

#Enable internet connection

sudo apt-get -y install bridge-utils
sudo brctl addbr br0
sudo brctl addif br0 eth0

echo "auto bro0">>/etc/network/interfaces
echo "iface bro0 inet manual">>/etc/network/interfaces
echo "bridge_ports eth0 wlano">>/etc/network/interfaces
