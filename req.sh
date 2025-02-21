#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Bu scripti çalıştırmak için root yetkileri gereklidir."
    exit 1
fi

echo "Gerekli paketler yükleniyor..."

detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "Bilinmeyen paket yöneticisi! Manuel yükleme gerekli."
        exit 1
    fi
}

pkg_manager=$(detect_package_manager)

case "$pkg_manager" in
    apt)
        apt update && apt install -y aircrack-ng iptables
        ;;
    dnf)
        dnf install -y aircrack-ng iptables
        ;;
    pacman)
        pacman -Sy --noconfirm aircrack-ng iptables
        ;;
esac

echo "Gerekli tüm paketler yüklendi. Şimdi ana scripti çalıştırabilirsiniz."
