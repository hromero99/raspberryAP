#!/bin/bash

dhcpFile="/etc/dhcpcd.conf"
hostapdFile="/etc/hostapd/hostapd.conf"

SSID=$1
PASS=$2
IFACE=$3

if [ $UID -ne 0 ]; then
    echo "[!] You should run this as root"
    exit
fi

if  [ -z $1 ]  || [ -z  $2 ]  || [ -z  $3 ] ;then
	echo "[!] Usage: ./install.sh ssid password interface"
	exit
fi

systemctl stop hostapd
systemctl stop dnsmasq

#Configure static ip for $IFACE
echo "interface $IFACE" >> $dhcpFile
echo "static ip_address=192.168.4.1/24" >>$dhcpFile

#Configure DHCP Server (dnsmasq)

mv  /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

echo "interface=$IFACE" >> /etc/dnsmasq.conf
echo "dhcp-range=192.168.4.2,192.168.4.200,255.255.255.0,24h" >> /etc/dnsmasq.conf

#Configure hostapd

echo "interface=$IFACE" >> $hostapdFile
echo "driver=nl80211">>$hostapdFile
echo "hw_mode=g">> $hostapdFile
echo "channel=7" >> $hostapdFile
echo "wmm_enabled=0">>$hostapdFile
echo "macaddr_acl=0">>$hostapdFile
echo "auth_algs=1">>$hostapdFile
echo "ignore_broadcast_ssid=0">>$hostapdFile
echo "wpa=2">>$hostapdFile
echo "wpa_key_mgmt=WPA-PSK" >> $hostapdFile
echo "wpa_pairwise=TKIP" >> $hostapdFile
echo "rsn_pairwise=CCMP" >>$hostapdFile
echo "ssid=$SSID">>$hostapdFile
echo "wpa_passphrase=$PASS">>$hostapdFile


#Enable forwaring and configure persistent iptables
echo "net.ipv4.ip_forward=1">>/etc/sysctl.conf

iptables -t NAT -A POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
iptables-restore < /etc/iptables.ipv4.nat


