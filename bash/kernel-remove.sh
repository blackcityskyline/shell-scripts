#!/bin/bash

# Функция для удаления ядер
function kernel-remove {
    current=$(uname -r)

    echo "Удаление ядер"
    echo "============="
    echo ""
    echo -e "Текущее ядро: \033[32m$current\033[0m"
    echo ""

    # Показать все ядра с номерами
    kernel_list=$(pacman -Q | grep -E '^linux(-|$)' | grep -v 'headers\|firmware' | sort)

    echo "Выберите ядро для удаления:"
    echo ""

    i=1
    while read -r kernel; do
        [[ -z "$kernel" ]] && continue

        name=$(echo "$kernel" | cut -d' ' -f1)

        # Помечаем активное ядро
        if [[ "$current" == *"$name"* ]]; then
            echo -e "  [$i] \033[31m$kernel ← АКТИВНОЕ! НЕ УДАЛЯЙТЕ!\033[0m"
        else
            echo "  [$i] $kernel"
        fi
        ((i++))
    done <<< "$kernel_list"

    echo ""
    echo "  [a] Удалить все неактивные"
    echo "  [q] Выйти"
    echo ""

    read -p "Выбор: " choice

    case "$choice" in
        "q"|"Q")
            echo "Выход."
            return 0
            ;;
        "a"|"A")
            echo "Удаление всех неактивных ядер..."
            while read -r kernel; do
                [[ -z "$kernel" ]] && continue

                name=$(echo "$kernel" | cut -d' ' -f1)

                if [[ "$current" != *"$name"* ]]; then
                    echo "  Удаление: $name"
                    # Попробуем удалить с зависимостями
                    sudo pacman -Rns "$name" "$name-headers" 2>/dev/null || true
                fi
            done <<< "$kernel_list"
            ;;
        *)
            if [[ -n "$choice" ]] && [[ "$choice" =~ ^[0-9]+$ ]]; then
                selected_index=$choice
                # Подсчитаем количество строк
                kernel_count=$(echo "$kernel_list" | wc -l)

                if [[ $selected_index -ge 1 ]] && [[ $selected_index -le $kernel_count ]]; then
                    # Получаем выбранное ядро по индексу
                    selected_kernel=$(echo "$kernel_list" | sed -n "${selected_index}p")
                    name=$(echo "$selected_kernel" | cut -d' ' -f1)

                    # Проверяем что это не активное ядро
                    if [[ "$current" == *"$name"* ]]; then
                        echo -e "\033[31mОШИБКА: Это активное ядро! Нельзя удалять!\033[0m"
                        return 1
                    fi

                    read -p "Удалить $selected_kernel? (y/N): " confirm
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        echo "Удаление $name..."
                        sudo pacman -Rns "$name" "$name-headers"
                        sudo rm -f /boot/vmlinuz-"$name" /boot/initramfs-"$name"*.img 2>/dev/null
                        sudo grub-mkconfig -o /boot/grub/grub.cfg
                        echo "Готово!"
                    else
                        echo "Отмена."
                    fi
                else
                    echo "Неверный номер."
                fi
            else
                echo "Неверный выбор."
            fi
            ;;
    esac
}
