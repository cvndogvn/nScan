#!/bin/bash

subnet="192.168.1"

echo "Ağ taraması yapılıyor..."

declare -A devices
index=1

for i in {1..254}; do
    ip="$subnet.$i"
    ping -c 1 -W 1 $ip &> /dev/null && {
        devices[$index]=$ip
        echo "$index) $ip"
        ((index++))
    }
done

if [ ${#devices[@]} -eq 0 ]; then
    echo "Ağda aktif cihaz bulunamadı."
    exit 1
fi

echo -n "Ping atmak istediğiniz cihazın numarasını girin: "
read choice

if [[ -n "${devices[$choice]}" ]]; then
    echo "${devices[$choice]} adresine ping atılıyor..."
    ping -c 4 "${devices[$choice]}"
else
    echo "Geçersiz seçim."
fi

interface="wlan0"
echo "Monitör modu açılıyor..."
sudo airmon-ng start $interface

echo "Deauth saldırıları izleniyor..."
sudo timeout 30 airodump-ng --write attack_log --output-format csv ${interface}mon &> /dev/null

grep "Deauthentication" attack_log-*.csv &> /dev/null
if [ $? -eq 0 ]; then
    echo "Deauth saldırısı tespit edildi!"
    attacker_mac=$(grep "Deauthentication" attack_log-*.csv | awk -F"," '{print $6}')
    echo "Saldırgan MAC adresi: $attacker_mac"
    sudo iptables -A INPUT -m mac --mac-source $attacker_mac -j DROP
    echo "Saldırgan engellendi."
else
    echo "Deauth saldırısı tespit edilmedi."
fi

echo "Monitör modu kapatılıyor..."
sudo airmon-ng stop ${interface}mon
