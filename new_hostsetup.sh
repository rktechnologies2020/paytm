#!/bin/bash

nc='\033[0m'
rb='\033[31;1m'
gb='\033[32;1m'
clear
HADOOP_HOME=/usr/local/hadoop

# Check Host Name and IP Address given as parameters
if [ "$1" == "" ]; then
	echo "Usage: bash setup.sh <hostname>";
	exit 1;
fi

# Check Adapter 2 has been enabled or not
if [ ! -f /sys/class/net/enp0s8/address ]; then 
	echo "Adapter 2 has been not enabled. Please shutdown the VM and enable the same.";
	exit 1;
fi

IP=""
IP=`cat /etc/hosts | grep $(printf '\t')$1$ | head -1 | cut -d "	" -f1`
if [ "$IP" == "" ]; then
	echo -e "${rb}Hostname not found in /etc/hosts. Please add the same !!!\n${nc}";
	exit 1;
fi

echo -e "Host setup has been started     ${gb}[OK]${nc}"

# Change ifcfg-enp0s8
mac=`cat /sys/class/net/enp0s8/address`
if [ ! -f /etc/sysconfig/network-scripts/ifcfg-enp0s8 ]; then cp /etc/sysconfig/network-scripts/ifcfg-enp0s3 /etc/sysconfig/network-scripts/ifcfg-enp0s8; fi
truncate -s 0 /etc/sysconfig/network-scripts/ifcfg-enp0s8

echo -e "Assigned IP Address:            ${rb}"$IP"${nc}"
echo TYPE=Ethernet >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo BOOTPROTO=none >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo NAME=enp0s8 >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo UUID=12cde791-dd47-4398-839b-703f7ca0e877 >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo DEVICE=enp0s8 >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo ONBOOT=yes >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo NM_CONTROLLED=yes >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
#echo HWADDR=$mac >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo IPADDR=$IP >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
echo GATEWAY=192.168.56.1 >> /etc/sysconfig/network-scripts/ifcfg-enp0s8; 
echo NETMASK=255.255.255.0 >> /etc/sysconfig/network-scripts/ifcfg-enp0s8
sed -i '/^$/d' /etc/sysconfig/network-scripts/ifcfg-enp0s8

# Change Hostname
hname=`echo $1 | cut -d "." -f1`
sed -i '/^HOST/d' /etc/sysconfig/network
echo HOSTNAME=$hname.hadoop.com >> /etc/sysconfig/network
sed -i '/^$/d' /etc/sysconfig/network
hostnamectl set-hostname $hname.hadoop.com --static

echo -n "Restarting the network...       "
systemctl restart network
echo -e "${gb}[OK]${nc}"
echo -e "Host setup has been completed   ${gb}[OK]${nc}"

