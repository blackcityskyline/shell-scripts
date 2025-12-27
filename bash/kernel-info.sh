#!/bin/bash

function kernel-info {
    local green="\033[32m"
    local yellow="\033[33m"
    local cyan="\033[36m"
    local red="\033[31m"
    local blue="\033[34m"
    local magenta="\033[35m"
    local orange="\033[38;5;208m"
    local reset="\033[0m"

    # Определить дистрибутив
    local distro_name="Arch Linux"
    local distro_id="arch"

    if [[ -f /etc/os-release ]]; then
        distro_name=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"' | xargs)
        distro_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"' | xargs)
    fi

    # Определить поддерживаемые типы ядер
    pacman -Q linux-cachyos 2>/dev/null || pacman -Ss linux-cachyos 2>/dev/null | grep -q '^cachyos/' && local has_cachyos=true || local has_cachyos=false
    grep -q 'chaotic-aur' /etc/pacman.conf 2>/dev/null && local has_chaotic_aur=true || local has_chaotic_aur=false
    grep -q '\[core\]' /etc/pacman.conf 2>/dev/null && local has_arch_repos=true || local has_arch_repos=false

    # Заголовок в зависимости от дистрибутива
    case $distro_id in
        cachyos)
            echo -e "${magenta}🧠 АНАЛИЗ ЯДЕР CACHYOS${reset}"
            local distro_color=$magenta
            ;;
        manjaro)
            echo -e "${green}🧠 АНАЛИЗ ЯДЕР MANJARO${reset}"
            local distro_color=$green
            ;;
        endeavouros)
            echo -e "${blue}🧠 АНАЛИЗ ЯДЕР ENDEAVOUROS${reset}"
            local distro_color=$blue
            ;;
        arcolinux)
            echo -e "${cyan}🧠 АНАЛИЗ ЯДЕР ARCOLINUX${reset}"
            local distro_color=$cyan
            ;;
        *)
            echo -e "${cyan}🧠 АНАЛИЗ ЯДЕР ARCH-BASED СИСТЕМ${reset}"
            local distro_color=$cyan
            ;;
    esac

    echo -e "${distro_color}══════════════════════════════════════════════${reset}"
    echo "Дистрибутив: $distro_name"
    echo ""

    # 1. Текущее ядро
    local current_kernel=$(uname -r)
    echo -e "${yellow}1. Текущее загруженное ядро:${reset}"
    echo -e "   ${cyan}$current_kernel${reset}"

    # Определяем тип ядра (универсально)
    local kernel_type="стандартное"
    local kernel_color=$cyan

    if [[ $current_kernel == *"cachyos"* ]]; then
        if [[ $current_kernel == *"lts"* ]]; then
            kernel_type="CachyOS LTS"
            kernel_color=$magenta
        elif [[ $current_kernel == *"bmq"* ]]; then
            kernel_type="CachyOS BMQ"
            kernel_color=$orange
        else
            kernel_type="CachyOS"
            kernel_color=$magenta
        fi
    elif [[ $current_kernel == *"zen"* ]]; then
        kernel_type="Zen"
        kernel_color=$blue
    elif [[ $current_kernel == *"hardened"* ]]; then
        kernel_type="Hardened"
        kernel_color=$red
    elif [[ $current_kernel == *"lts"* ]]; then
        kernel_type="LTS"
        kernel_color=$cyan
    elif [[ $current_kernel == *"xanmod"* ]]; then
        kernel_type="Xanmod"
        kernel_color=$orange
    elif [[ $current_kernel == *"ck"* ]]; then
        kernel_type="CK"
        kernel_color=$yellow
    elif [[ $current_kernel == *"tkg"* ]]; then
        kernel_type="TKG"
        kernel_color=$green
    elif [[ $current_kernel == *"rt"* ]]; then
        kernel_type="Real-Time"
        kernel_color=$red
    elif [[ $current_kernel == *"libre"* ]]; then
        kernel_type="Libre"
        kernel_color=$green
    fi

    echo -e "   ${kernel_color}• Тип: $kernel_type ядро${reset}"

    local kernel_build=$(uname -v)
    echo -e "   ${blue}• Сборка:${reset} ${kernel_build:0:60}"
    echo ""

    # 2. Установленные ядра (универсальный поиск)
    echo -e "${yellow}2. Установленные ядра:${reset}"

    # Получить ВСЕ ядра из pacman
    local all_kernels=$(pacman -Q | grep -E '^linux(-|$)' | grep -v 'headers\|firmware\|api-headers')

    # Группировать по типам
    local cachyos_kernels=()
    local arch_official_kernels=()
    local aur_kernels=()
    local other_kernels=()

    while read -r line; do
        name=$(echo "$line" | cut -d' ' -f1)
        ver=$(echo "$line" | cut -d' ' -f2)

        # Классификация
        if [[ $name == *"cachyos"* ]]; then
            cachyos_kernels+=("$name $ver")
        elif [[ $name == "linux" ]] || [[ $name == "linux-lts" ]] || \
             [[ $name == "linux-zen" ]] || [[ $name == "linux-hardened" ]]; then
            arch_official_kernels+=("$name $ver")
        elif [[ $name == *"xanmod"* ]] || [[ $name == *"ck"* ]] || \
             [[ $name == *"tkg"* ]] || [[ $name == *"rt"* ]] || \
             [[ $name == *"libre"* ]]; then
            aur_kernels+=("$name $ver")
        else
            other_kernels+=("$name $ver")
        fi
    done <<< "$all_kernels"

    # Вывод по группам
    local has_any_kernels=false

    # CachyOS ядра
    if [[ ${#cachyos_kernels[@]} -gt 0 ]]; then
        has_any_kernels=true
        echo -e "   ${magenta}CachyOS ядра:${reset}"
        for kernel in "${cachyos_kernels[@]}"; do
            name=$(echo "$kernel" | cut -d' ' -f1)
            ver=$(echo "$kernel" | cut -d' ' -f2)

            if [[ $name == *"$current_kernel"* ]]; then
                echo -e "   • ${green}$name $ver${reset} ${cyan}← ТЕКУЩЕЕ${reset}"
            else
                echo -e "   • ${magenta}$name $ver${reset}"
            fi
        done
        echo ""
    fi

    # Официальные Arch ядра
    if [[ ${#arch_official_kernels[@]} -gt 0 ]]; then
        has_any_kernels=true
        echo -e "   ${cyan}Официальные ядра Arch:${reset}"
        for kernel in "${arch_official_kernels[@]}"; do
            name=$(echo "$kernel" | cut -d' ' -f1)
            ver=$(echo "$kernel" | cut -d' ' -f2)

            if [[ $name == *"$current_kernel"* ]]; then
                echo -e "   • ${green}$name $ver${reset} ${cyan}← ТЕКУЩЕЕ${reset}"
            else
                echo -e "   • ${cyan}$name $ver${reset}"
            fi
        done
        echo ""
    fi

    # AUR ядра
    if [[ ${#aur_kernels[@]} -gt 0 ]]; then
        has_any_kernels=true
        echo -e "   ${yellow}AUR ядра:${reset}"
        for kernel in "${aur_kernels[@]}"; do
            name=$(echo "$kernel" | cut -d' ' -f1)
            ver=$(echo "$kernel" | cut -d' ' -f2)

            if [[ $name == *"$current_kernel"* ]]; then
                echo -e "   • ${green}$name $ver${reset} ${cyan}← ТЕКУЩЕЕ${reset}"
            else
                echo -e "   • ${yellow}$name $ver${reset}"
            fi
        done
        echo ""
    fi

    # Прочие ядра
    if [[ ${#other_kernels[@]} -gt 0 ]]; then
        has_any_kernels=true
        echo -e "   ${blue}Прочие ядра:${reset}"
        for kernel in "${other_kernels[@]}"; do
            name=$(echo "$kernel" | cut -d' ' -f1)
            ver=$(echo "$kernel" | cut -d' ' -f2)

            if [[ $name == *"$current_kernel"* ]]; then
                echo -e "   • ${green}$name $ver${reset} ${cyan}← ТЕКУЩЕЕ${reset}"
            else
                echo "   • $name $ver"
            fi
        done
        echo ""
    fi

    if ! $has_any_kernels; then
        echo -e "   ${red}Не найдено установленных ядер!${reset}"
        echo -e "   ${blue}Попробуйте: ${reset}pacman -Q | grep linux"
    fi
    echo ""

    # 3. Файлы в /boot (универсальный поиск)
    echo -e "${yellow}3. Файлы ядер в /boot:${reset}"

    # Поиск файлов ядер разными способами
    local boot_files=""

    # Основные пути
    for path in /boot /boot/efi /boot/EFI /efi /efi/EFI; do
        if [[ -d "$path" ]]; then
            files=$(find "$path" -maxdepth 1 -name "vmlinuz-*" -type f 2>/dev/null)
            if [[ -n "$files" ]]; then
                boot_files+="$files"$'\n'
            fi
        fi
    done

    # Поиск по общему шаблону
    if [[ -z "$boot_files" ]]; then
        boot_files=$(find /boot -name "vmlinuz-*" -type f 2>/dev/null | head -10)
    fi

    # Если ничего не найдено, попробовать ls
    if [[ -z "$boot_files" ]]; then
        boot_files=$(ls /boot/vmlinuz-* 2>/dev/null 2>/dev/null)
    fi

    # Убрать дубликаты и отсортировать
    boot_files=$(echo "$boot_files" | tr ' ' '\n' | sort -u)

    if [[ -n "$boot_files" ]]; then
        while read -r file; do
            [[ -z "$file" ]] && continue
            fname=$(basename "$file")
            if [[ -f "$file" ]]; then
                fsize=$(stat -c%s "$file" 2>/dev/null || echo "0")
                fhuman=$(numfmt --to=iec --suffix=B "$fsize" 2>/dev/null || echo "$fsize байт")

                # Цвет в зависимости от типа
                if [[ $fname == *"cachyos"* ]]; then
                    fcolor=$magenta
                elif [[ $fname == *"zen"* ]]; then
                    fcolor=$blue
                elif [[ $fname == *"lts"* ]]; then
                    fcolor=$cyan
                elif [[ $fname == *"hardened"* ]]; then
                    fcolor=$red
                elif [[ $fname == *"xanmod"* ]] || [[ $fname == *"ck"* ]] || \
                     [[ $fname == *"tkg"* ]]; then
                    fcolor=$yellow
                else
                    fcolor=$green
                fi

                if [[ $fname == *"$current_kernel"* ]]; then
                    echo -e "   • ${fcolor}$fname${reset} ($fhuman) ${green}← ТЕКУЩЕЕ${reset}"
                else
                    echo -e "   • ${fcolor}$fname${reset} ($fhuman)"
                fi
            fi
        done <<< "$boot_files"
    else
        echo -e "   ${yellow}Файлы ядер не найдены в стандартных местах${reset}"
        echo -e "   ${blue}Поиск по всей системе: ${reset}(find / -name \"*vmlinuz*\" 2>/dev/null | wc -l) файлов"
    fi
    echo ""

    # 4. Доступные в репозиториях (умный поиск)
    echo -e "${yellow}4. Доступные ядра в репозиториях:${reset}"

    # Проверяем доступные репозитории
    pacman -Sl core 2>&1 | grep -q "database not found" && local has_arch_repo=false || local has_arch_repo=true
    pacman -Sl extra 2>&1 | grep -q "database not found" && local has_extra_repo=false || local has_extra_repo=true
    pacman -Sl cachyos 2>&1 | grep -q "database not found" && local has_cachyos_repo=false || local has_cachyos_repo=true
    pacman -Sl chaotic-aur 2>&1 | grep -q "database not found" && local has_chaotic_repo=false || local has_chaotic_repo=true

    # Arch репозитории
    if $has_arch_repo || $has_extra_repo; then
        echo -e "   ${cyan}Официальные репозитории Arch:${reset}"
        arch_kernels=$(pacman -Ss ^linux- 2>/dev/null | grep -E '^(core|extra)/' | grep -v 'headers\|docs\|firmware\|tools' | head -5)

        if [[ -n "$arch_kernels" ]]; then
            while read -r kernel; do
                [[ -z "$kernel" ]] && continue
                kname=$(echo "$kernel" | cut -d' ' -f1)
                if pacman -Q "$kname" >/dev/null 2>&1; then
                    kinstalled=$(pacman -Q "$kname" | cut -d' ' -f2)
                    echo -e "   • ${green}$kname $kinstalled${reset} ${cyan}[установлен]${reset}"
                else
                    echo "   • $kernel"
                fi
            done <<< "$arch_kernels"
        else
            echo -e "   ${yellow}Не удалось получить список ядер${reset}"
        fi
        echo ""
    fi

    # CachyOS репозитории
    if $has_cachyos_repo; then
        echo -e "   ${magenta}Репозитории CachyOS:${reset}"
        cachyos_kernels=$(pacman -Ss linux-cachyos 2>/dev/null | grep '^cachyos/' | head -5)

        if [[ -n "$cachyos_kernels" ]]; then
            while read -r kernel; do
                [[ -z "$kernel" ]] && continue
                kname=$(echo "$kernel" | cut -d' ' -f1)
                if pacman -Q "$kname" >/dev/null 2>&1; then
                    kinstalled=$(pacman -Q "$kname" | cut -d' ' -f2)
                    echo -e "   • ${green}$kname $kinstalled${reset} ${cyan}[установлен]${reset}"
                else
                    echo "   • $kernel"
                fi
            done <<< "$cachyos_kernels"
        else
            echo -e "   ${yellow}Ядра CachyOS не найдены${reset}"
        fi
        echo ""
    fi

    # Chaotic-AUR
    if $has_chaotic_repo; then
        echo -e "   ${yellow}Chaotic-AUR (AUR ядра):${reset}"
        echo "   • linux-xanmod (кастомная сборка)"
        echo "   • linux-ck (патчи Con Kolivas)"
        echo "   • linux-tkg (игровая оптимизация)"
        echo "   • linux-rt (реального времени)"
        echo ""
    elif command -v yay >/dev/null || command -v paru >/dev/null; then
        echo -e "   ${yellow}AUR ядра (через yay/paru):${reset}"
        echo "   • linux-xanmod (кастомная сборка)"
        echo "   • linux-ck (патчи Con Kolivas)"
        echo "   • linux-tkg (игровая оптимизация)"
        echo "   • linux-rt (реального времени)"
        echo ""
    fi

    # 5. Системная информация
    echo -e "${yellow}5. Системная информация:${reset}"
    echo "   • Архитектура: $(uname -m)"

    if command -v grub-install >/dev/null; then
        bootloader="GRUB"
    elif [[ -d /boot/loader/entries ]]; then
        bootloader="systemd-boot"
    elif [[ -f /boot/refind_linux.conf ]]; then
        bootloader="rEFInd"
    else
        bootloader="не определен"
    fi
    echo "   • Загрузчик: $bootloader"

    if command -v grub-install >/dev/null; then
        grub_version=$(grub-install --version 2>/dev/null | head -1 | awk '{print $NF}')
        echo "   • Версия GRUB: $grub_version"
    fi

    [[ -d /sys/firmware/efi ]] && echo "   • Тип системы: UEFI" || echo "   • Тип системы: BIOS/Legacy"
    echo "   • Загружено модулей: $(lsmod | wc -l)"

    # Параметры ядра
    if [[ -f /proc/cmdline ]]; then
        cmdline=$(cat /proc/cmdline)
        echo "   • Параметры ядра: ${cmdline:0:60}..."

        # Полезные параметры
        if [[ $cmdline == *"subvol="* ]]; then
            subvol=$(echo "$cmdline" | grep -o 'subvol=[^ ]*')
            echo "   • Файловая система: BTRFS $subvol"
        elif [[ $cmdline == *"root="* ]]; then
            root_dev=$(echo "$cmdline" | grep -o 'root=[^ ]*' | cut -d= -f2)
            echo "   • Корневой раздел: $root_dev"
        fi
    fi
    echo ""

    # 6. Статус системы
    echo -e "${green}📊 СТАТУС СИСТЕМЫ:${reset}"
    echo "   • Время работы: $(uptime -p | cut -d' ' -f2- 2>/dev/null || echo "неизвестно")"

    # Память
    if command -v free >/dev/null; then
        mem_info=$(free -h | grep Mem 2>/dev/null)
        if [[ -n "$mem_info" ]]; then
            used=$(echo "$mem_info" | awk '{print $3}')
            total=$(echo "$mem_info" | awk '{print $2}')
            free=$(echo "$mem_info" | awk '{print $4}')
            echo "   • Память: $used/$total ($free свободно)"
        fi
    fi

    # Диск
    if command -v df >/dev/null; then
        disk_info=$(df -h / | tail -1 2>/dev/null)
        if [[ -n "$disk_info" ]]; then
            used=$(echo "$disk_info" | awk '{print $3}')
            total=$(echo "$disk_info" | awk '{print $2}')
            perc=$(echo "$disk_info" | awk '{print $5}')
            echo "   • Диск (/): $used/$total ($perc)"
        fi
    fi
    echo ""

    # 7. Рекомендации для конкретной системы
    echo -e "${magenta}💡 РЕКОМЕНДАЦИИ:${reset}"

    case $distro_id in
        cachyos)
            if [[ $current_kernel == *"lts"* ]]; then
                echo "   Используется CachyOS LTS (стабильное)."
                echo -e "   Для тестирования нового ядра: ${magenta}sudo pacman -S linux-cachyos${reset}"
            else
                echo "   Используется CachyOS основное (новейшее)."
                echo -e "   Для стабильности: ${magenta}sudo pacman -S linux-cachyos-lts${reset}"
            fi

            if $has_arch_repos; then
                echo -e "   Также доступны Arch ядра: ${cyan}sudo pacman -S linux-zen${reset}"
            fi
            ;;

        manjaro)
            echo "   Manjaro использует собственные ядра."
            echo -e "   Обновить: ${green}sudo pacman -Syu${reset}"
            echo -e "   Установить LTS: ${green}sudo pacman -S linux-lts${reset}"
            ;;

        *)
            # Общие рекомендации для Arch-based
            if [[ $current_kernel == *"cachyos"* ]]; then
                echo "   Используется ядро CachyOS."
                if $has_cachyos_repo; then
                    echo -e "   Обновить: ${magenta}sudo pacman -Syu${reset}"
                fi
                echo -e "   Попробовать Arch ядра: ${cyan}sudo pacman -S linux-zen${reset}"
            else
                echo "   Используется Arch-ядро."
                echo -e "   Обновить: ${cyan}sudo pacman -Syu${reset}"
                if $has_cachyos_repo; then
                    echo -e "   Попробовать CachyOS: ${magenta}sudo pacman -S linux-cachyos${reset}"
                fi
            fi
            ;;
    esac

    echo ""
    echo -e "${blue}⚙️  ОБЩИЕ КОМАНДЫ:${reset}"
    echo "   • Обновить всё: sudo pacman -Syu"
    echo "   • Обновить GRUB: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo "   • Пересобрать initramfs: sudo mkinitcpio -P"
    echo "   • Показать меню GRUB: перезагрузиться, нажать Esc/Shift"
    echo ""

    # Информация о версии скрипта
    echo -e "${yellow}ℹ️  Универсальный скрипт для Arch-based систем${reset}"
    echo "   Поддерживает: Arch, CachyOS, Manjaro, EndeavourOS, ArcoLinux и другие"
}
