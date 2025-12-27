function kernel
    set current (uname -r)

    # Проверка типа системы
    if string match -q "*cachyos*" $current
        echo "🧠 CACHYOS ЯДРА"
        echo "════════════════"
    else
        echo "🧠 ARCH LINUX ЯДРА"
        echo "══════════════════"
    end

    echo ""
    echo "Текущее: "(set_color green)$current(set_color normal)
    echo ""

    echo "Установленные:"
    pacman -Q | grep '^linux' | grep -v 'headers\|firmware' | while read pkg
        if string match -q "*$current*" $pkg
            echo "  → "$(set_color cyan)$pkg$(set_color normal)
        else
            echo "    $pkg"
        end
    end

    echo ""
    echo "Файлы в /boot:"
    ls -lh /boot/vmlinuz-* 2>/dev/null || echo "  (нет файлов)"

    echo ""
    echo "💡 Команды:"
    echo "  sudo pacman -S linux-cachyos     # CachyOS"
    echo "  sudo pacman -S linux-cachyos-lts # CachyOS LTS"
    echo "  sudo pacman -S linux-lts         # Arch LTS"
    echo "  sudo grub-mkconfig -o /boot/grub/grub.cfg"
end
