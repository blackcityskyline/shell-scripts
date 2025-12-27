#!/bin/bash

function kernel {
    current=$(uname -r)

    # Проверка типа системы
    if [[ "$current" == *"cachyos"* ]]; then
        echo "🧠 CACHYOS ЯДРА"
        echo "════════════════"
    else
        echo "🧠 ARCH LINUX ЯДРА"
        echo "══════════════════"
    fi

    echo ""
    echo -e "Текущее: \033[32m$current\033[0m"
    echo ""

    echo "Установленные:"
    pacman -Q | grep '^linux' | grep -v 'headers\|firmware' | while read pkg; do
        if [[ "$pkg" == *"$current"* ]]; then
            echo -e "  → \033[36m$pkg\033[0m"
        else
            echo "    $pkg"
        fi
    done

    echo ""
    echo "Файлы в /boot:"
    ls -lh /boot/vmlinuz-* 2>/dev/null || echo "  (нет файлов)"

    echo ""
    echo "💡 Команды:"
    echo "  sudo pacman -S linux-cachyos     # CachyOS"
    echo "  sudo pacman -S linux-cachyos-lts # CachyOS LTS"
    echo "  sudo pacman -S linux-lts         # Arch LTS"
    echo "  sudo grub-mkconfig -o /boot/grub/grub.cfg"
}
