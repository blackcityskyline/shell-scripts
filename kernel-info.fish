function kernel-info --description "Универсальная информация о ядрах Arch-based систем"
    # Цвета
    set -l green (set_color green)
    set -l yellow (set_color yellow)
    set -l cyan (set_color cyan)
    set -l red (set_color red)
    set -l blue (set_color blue)
    set -l magenta (set_color magenta)
    set -l orange (set_color bryellow)
    set -l reset (set_color normal)

    # Определить дистрибутив
    set distro_name "Arch Linux"
    set distro_id "arch"

    if test -f /etc/os-release
        set os_release (cat /etc/os-release)
        set distro_name (echo $os_release | grep '^NAME=' | cut -d= -f2 | tr -d '"' | string trim)
        set distro_id (echo $os_release | grep '^ID=' | cut -d= -f2 | tr -d '"' | string trim)
    end

    # Определить поддерживаемые типы ядер
    set has_cachyos (pacman -Q linux-cachyos 2>/dev/null || pacman -Ss linux-cachyos 2>/dev/null | grep -q '^cachyos/')
    set has_chaotic_aur (grep -q 'chaotic-aur' /etc/pacman.conf 2>/dev/null)
    set has_arch_repos (grep -q '\[core\]' /etc/pacman.conf 2>/dev/null)

    # Заголовок в зависимости от дистрибутива
    switch $distro_id
        case cachyos
            echo $magenta"🧠 АНАЛИЗ ЯДЕР CACHYOS"$reset
            set distro_color $magenta
        case manjaro
            echo $green"🧠 АНАЛИЗ ЯДЕР MANJARO"$reset
            set distro_color $green
        case endeavouros
            echo $blue"🧠 АНАЛИЗ ЯДЕР ENDEAVOUROS"$reset
            set distro_color $blue
        case arcolinux
            echo $cyan"🧠 АНАЛИЗ ЯДЕР ARCOLINUX"$reset
            set distro_color $cyan
        case '*'
            echo $cyan"🧠 АНАЛИЗ ЯДЕР ARCH-BASED СИСТЕМ"$reset
            set distro_color $cyan
    end

    echo $distro_color"══════════════════════════════════════════════"$reset
    echo "Дистрибутив: $distro_name"
    echo ""

    # 1. Текущее ядро
    set current_kernel (uname -r)
    echo $yellow"1. Текущее загруженное ядро:"$reset
    echo "   "$cyan$current_kernel$reset

    # Определяем тип ядра (универсально)
    set kernel_type "стандартное"
    set kernel_color $cyan

    if string match -q "*cachyos*" $current_kernel
        if string match -q "*lts*" $current_kernel
            set kernel_type "CachyOS LTS"
            set kernel_color $magenta
        else if string match -q "*bmq*" $current_kernel
            set kernel_type "CachyOS BMQ"
            set kernel_color $orange
        else
            set kernel_type "CachyOS"
            set kernel_color $magenta
        end
    else if string match -q "*zen*" $current_kernel
        set kernel_type "Zen"
        set kernel_color $blue
    else if string match -q "*hardened*" $current_kernel
        set kernel_type "Hardened"
        set kernel_color $red
    else if string match -q "*lts*" $current_kernel
        set kernel_type "LTS"
        set kernel_color $cyan
    else if string match -q "*xanmod*" $current_kernel
        set kernel_type "Xanmod"
        set kernel_color $orange
    else if string match -q "*ck*" $current_kernel
        set kernel_type "CK"
        set kernel_color $yellow
    else if string match -q "*tkg*" $current_kernel
        set kernel_type "TKG"
        set kernel_color $green
    else if string match -q "*rt*" $current_kernel
        set kernel_type "Real-Time"
        set kernel_color $red
    else if string match -q "*libre*" $current_kernel
        set kernel_type "Libre"
        set kernel_color $green
    end

    echo "   "$kernel_color"• Тип: $kernel_type ядро"$reset

    set kernel_build (uname -v)
    echo "   "$blue"• Сборка:"$reset" "(string sub -l 60 $kernel_build)
    echo ""

    # 2. Установленные ядра (универсальный поиск)
    echo $yellow"2. Установленные ядра:"$reset

    # Получить ВСЕ ядра из pacman
    set all_kernels (pacman -Q | grep -E '^linux(-|\$)' | grep -v 'headers\|firmware\|api-headers')

    # Группировать по типам
    set -l cachyos_kernels
    set -l arch_official_kernels
    set -l aur_kernels
    set -l other_kernels

    for kernel in $all_kernels
        set name (echo $kernel | cut -d' ' -f1)
        set ver (echo $kernel | cut -d' ' -f2)

        # Классификация
        if string match -q "*cachyos*" $name
            set cachyos_kernels $cachyos_kernels "$name $ver"
        else if string match -q "linux\$" $name || string match -q "linux-lts\$" $name || \
               string match -q "linux-zen\$" $name || string match -q "linux-hardened\$" $name
            set arch_official_kernels $arch_official_kernels "$name $ver"
        else if string match -q "*xanmod*" $name || string match -q "*ck*" $name || \
               string match -q "*tkg*" $name || string match -q "*rt*" $name || \
               string match -q "*libre*" $name
            set aur_kernels $aur_kernels "$name $ver"
        else
            set other_kernels $other_kernels "$name $ver"
        end
    end

    # Вывод по группам
    set has_any_kernels false

    # CachyOS ядра
    if test -n "$cachyos_kernels"
        set has_any_kernels true
        echo "   "$magenta"CachyOS ядра:"$reset
        for kernel in $cachyos_kernels
            set name (echo $kernel | cut -d' ' -f1)
            set ver (echo $kernel | cut -d' ' -f2)

            if string match -q "*$current_kernel*" $name
                echo "   • "$green$name $ver$reset" "$cyan"← ТЕКУЩЕЕ"$reset
            else
                echo "   • "$magenta$name $ver$reset
            end
        end
        echo ""
    end

    # Официальные Arch ядра
    if test -n "$arch_official_kernels"
        set has_any_kernels true
        echo "   "$cyan"Официальные ядра Arch:"$reset
        for kernel in $arch_official_kernels
            set name (echo $kernel | cut -d' ' -f1)
            set ver (echo $kernel | cut -d' ' -f2)

            if string match -q "*$current_kernel*" $name
                echo "   • "$green$name $ver$reset" "$cyan"← ТЕКУЩЕЕ"$reset
            else
                echo "   • "$cyan$name $ver$reset
            end
        end
        echo ""
    end

    # AUR ядра
    if test -n "$aur_kernels"
        set has_any_kernels true
        echo "   "$yellow"AUR ядра:"$reset
        for kernel in $aur_kernels
            set name (echo $kernel | cut -d' ' -f1)
            set ver (echo $kernel | cut -d' ' -f2)

            if string match -q "*$current_kernel*" $name
                echo "   • "$green$name $ver$reset" "$cyan"← ТЕКУЩЕЕ"$reset
            else
                echo "   • "$yellow$name $ver$reset
            end
        end
        echo ""
    end

    # Прочие ядра
    if test -n "$other_kernels"
        set has_any_kernels true
        echo "   "$blue"Прочие ядра:"$reset
        for kernel in $other_kernels
            set name (echo $kernel | cut -d' ' -f1)
            set ver (echo $kernel | cut -d' ' -f2)

            if string match -q "*$current_kernel*" $name
                echo "   • "$green$name $ver$reset" "$cyan"← ТЕКУЩЕЕ"$reset
            else
                echo "   • $name $ver"
            end
        end
        echo ""
    end

    if not $has_any_kernels
        echo "   "$red"Не найдено установленных ядер!"$reset
        echo "   "$blue"Попробуйте: "$reset"pacman -Q | grep linux"
    end
    echo ""

    # 3. Файлы в /boot (универсальный поиск)
    echo $yellow"3. Файлы ядер в /boot:"$reset

    # Поиск файлов ядер разными способами
    set boot_files ""

    # Основные пути
    for path in /boot /boot/efi /boot/EFI /efi /efi/EFI
        if test -d $path
            set files (find $path -maxdepth 1 -name "vmlinuz-*" -type f 2>/dev/null)
            if test -n "$files"
                set boot_files $boot_files $files
            end
        end
    end

    # Поиск по общему шаблону
    if test -z "$boot_files"
        set boot_files (find /boot -name "vmlinuz-*" -type f 2>/dev/null | head -10)
    end

    # Если ничего не найдено, попробовать ls
    if test -z "$boot_files"
        set boot_files (ls /boot/vmlinuz-* 2>/dev/null)
    end

    # Убрать дубликаты и отсортировать
    set boot_files (echo $boot_files | tr ' ' '\n' | sort -u)

    if test -n "$boot_files"
        for file in $boot_files
            set fname (basename $file)
            if test -f $file
                set fsize (stat -c%s "$file" 2>/dev/null || echo "0")
                set fhuman (numfmt --to=iec --suffix=B $fsize 2>/dev/null || echo "$fsize байт")

                # Цвет в зависимости от типа
                if string match -q "*cachyos*" $fname
                    set fcolor $magenta
                else if string match -q "*zen*" $fname
                    set fcolor $blue
                else if string match -q "*lts*" $fname
                    set fcolor $cyan
                else if string match -q "*hardened*" $fname
                    set fcolor $red
                else if string match -q "*xanmod*" $fname || string match -q "*ck*" $fname || \
                       string match -q "*tkg*" $fname
                    set fcolor $yellow
                else
                    set fcolor $green
                end

                if string match -q "*$current_kernel*" $fname
                    echo "   • "$fcolor$fname$reset" ("$fhuman") "$green"← ТЕКУЩЕЕ"$reset
                else
                    echo "   • "$fcolor$fname$reset" ("$fhuman")"
                end
            end
        end
    else
        echo "   "$yellow"Файлы ядер не найдены в стандартных местах"$reset
        echo "   "$blue"Поиск по всей системе: "$reset"(find / -name \"*vmlinuz*\" 2>/dev/null | wc -l) файлов"
    end
    echo ""

    # 4. Доступные в репозиториях (умный поиск)
    echo $yellow"4. Доступные ядра в репозиториях:"$reset

    # Проверяем доступные репозитории
    set has_arch_repo (pacman -Sl core 2>&1 | grep -q "database not found" && echo false || echo true)
    set has_extra_repo (pacman -Sl extra 2>&1 | grep -q "database not found" && echo false || echo true)
    set has_cachyos_repo (pacman -Sl cachyos 2>&1 | grep -q "database not found" && echo false || echo true)
    set has_chaotic_repo (pacman -Sl chaotic-aur 2>&1 | grep -q "database not found" && echo false || echo true)

    # Arch репозитории
    if $has_arch_repo || $has_extra_repo
        echo "   "$cyan"Официальные репозитории Arch:"$reset
        set arch_kernels (pacman -Ss ^linux- 2>/dev/null | grep -E '^(core|extra)/' | grep -v 'headers\|docs\|firmware\|tools' | head -5)

        if test -n "$arch_kernels"
            for kernel in $arch_kernels
                set kname (echo $kernel | cut -d' ' -f1)
                if pacman -Q $kname >/dev/null 2>&1
                    set kinstalled (pacman -Q $kname | cut -d' ' -f2)
                    echo "   • "$green$kname $kinstalled$reset" "$cyan"[установлен]"$reset
                else
                    echo "   • $kernel"
                end
            end
        else
            echo "   "$yellow"Не удалось получить список ядер"$reset
        end
        echo ""
    end

    # CachyOS репозитории
    if $has_cachyos_repo
        echo "   "$magenta"Репозитории CachyOS:"$reset
        set cachyos_kernels (pacman -Ss linux-cachyos 2>/dev/null | grep '^cachyos/' | head -5)

        if test -n "$cachyos_kernels"
            for kernel in $cachyos_kernels
                set kname (echo $kernel | cut -d' ' -f1)
                if pacman -Q $kname >/dev/null 2>&1
                    set kinstalled (pacman -Q $kname | cut -d' ' -f2)
                    echo "   • "$green$kname $kinstalled$reset" "$cyan"[установлен]"$reset
                else
                    echo "   • $kernel"
                end
            end
        else
            echo "   "$yellow"Ядра CachyOS не найдены"$reset
        end
        echo ""
    end

    # Chaotic-AUR
    if $has_chaotic_repo
        echo "   "$yellow"Chaotic-AUR (AUR ядра):"$reset
        echo "   • linux-xanmod (кастомная сборка)"
        echo "   • linux-ck (патчи Con Kolivas)"
        echo "   • linux-tkg (игровая оптимизация)"
        echo "   • linux-rt (реального времени)"
        echo ""
    else if command -v yay >/dev/null || command -v paru >/dev/null
        echo "   "$yellow"AUR ядра (через yay/paru):"$reset
        echo "   • linux-xanmod (кастомная сборка)"
        echo "   • linux-ck (патчи Con Kolivas)"
        echo "   • linux-tkg (игровая оптимизация)"
        echo "   • linux-rt (реального времени)"
        echo ""
    end

    # 5. Системная информация
    echo $yellow"5. Системная информация:"$reset
    echo "   • Архитектура: "(uname -m)
    echo "   • Загрузчик: "(command -v grub-install >/dev/null && echo "GRUB" || \
                           test -d /boot/loader/entries && echo "systemd-boot" || \
                           test -f /boot/refind_linux.conf && echo "rEFInd" || \
                           echo "не определен")

    if command -v grub-install >/dev/null
        set grub_version (grub-install --version 2>/dev/null | head -1 | awk '{print $NF}')
        echo "   • Версия GRUB: $grub_version"
    end

    echo "   • Тип системы: "(test -d /sys/firmware/efi && echo "UEFI" || echo "BIOS/Legacy")
    echo "   • Загружено модулей: "(lsmod | wc -l)

    # Параметры ядра
    if test -f /proc/cmdline
        set cmdline (cat /proc/cmdline)
        echo "   • Параметры ядра: "(string sub -l 60 $cmdline)"..."

        # Полезные параметры
        if string match -q "*subvol=*" $cmdline
            set subvol (echo $cmdline | grep -o 'subvol=[^ ]*')
            echo "   • Файловая система: BTRFS $subvol"
        else if string match -q "*root=*" $cmdline
            set root_dev (echo $cmdline | grep -o 'root=[^ ]*' | cut -d= -f2)
            echo "   • Корневой раздел: $root_dev"
        end
    end
    echo ""

    # 6. Статус системы
    echo $green"📊 СТАТУС СИСТЕМЫ:"$reset
    echo "   • Время работы: "(uptime -p | cut -d' ' -f2- || echo "неизвестно")

    # Память
    if command -v free >/dev/null
        set mem_info (free -h | grep Mem 2>/dev/null)
        if test -n "$mem_info"
            echo "   • Память: "(echo $mem_info | awk '{print $3 "/" $2 " (" $4 " свободно)"}')
        end
    end

    # Диск
    if command -v df >/dev/null
        set disk_info (df -h / | tail -1 2>/dev/null)
        if test -n "$disk_info"
            echo "   • Диск (/): "(echo $disk_info | awk '{print $3 "/" $2 " (" $5 ")"}')
        end
    end
    echo ""

    # 7. Рекомендации для конкретной системы
    echo $magenta"💡 РЕКОМЕНДАЦИИ:"$reset

    switch $distro_id
        case cachyos
            if string match -q "*lts*" $current_kernel
                echo "   Используется CachyOS LTS (стабильное)."
                echo "   Для тестирования нового ядра: "$magenta"sudo pacman -S linux-cachyos"$reset
            else
                echo "   Используется CachyOS основное (новейшее)."
                echo "   Для стабильности: "$magenta"sudo pacman -S linux-cachyos-lts"$reset
            end

            if $has_arch_repo
                echo "   Также доступны Arch ядра: "$cyan"sudo pacman -S linux-zen"$reset
            end

        case manjaro
            echo "   Manjaro использует собственные ядра."
            echo "   Обновить: "$green"sudo pacman -Syu"$reset
            echo "   Установить LTS: "$green"sudo pacman -S linux-lts"$reset

        case '*'
            # Общие рекомендации для Arch-based
            if string match -q "*cachyos*" $current_kernel
                echo "   Используется ядро CachyOS."
                if $has_cachyos_repo
                    echo "   Обновить: "$magenta"sudo pacman -Syu"$reset
                end
                echo "   Попробовать Arch ядра: "$cyan"sudo pacman -S linux-zen"$reset
            else
                echo "   Используется Arch-ядро."
                echo "   Обновить: "$cyan"sudo pacman -Syu"$reset
                if $has_cachyos_repo
                    echo "   Попробовать CachyOS: "$magenta"sudo pacman -S linux-cachyos"$reset
                end
            end
    end

    echo ""
    echo $blue"⚙️  ОБЩИЕ КОМАНДЫ:"$reset
    echo "   • Обновить всё: sudo pacman -Syu"
    echo "   • Обновить GRUB: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo "   • Пересобрать initramfs: sudo mkinitcpio -P"
    echo "   • Показать меню GRUB: перезагрузиться, нажать Esc/Shift"
    echo ""

    # Информация о версии скрипта
    echo $yellow"ℹ️  Универсальный скрипт для Arch-based систем"$reset
    echo "   Поддерживает: Arch, CachyOS, Manjaro, EndeavourOS, ArcoLinux и другие"
end
