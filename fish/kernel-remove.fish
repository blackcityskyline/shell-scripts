# Функция для удаления ядер
function kernel-remove
    set current (uname -r)

    echo "Удаление ядер"
    echo "============="
    echo ""
    echo "Текущее ядро: "(set_color green)$current(set_color normal)
    echo ""

    # Показать все ядра с номерами
    set -l kernel_list (pacman -Q | grep -E '^linux(-|$)' | grep -v 'headers\|firmware' | sort)

    echo "Выберите ядро для удаления:"
    echo ""

    set i 1
    for kernel in $kernel_list
        set name (echo $kernel | cut -d' ' -f1)

        # Помечаем активное ядро
        if string match -q "*$name*" $current
            echo "  [$i] "$(set_color red)"$kernel ← АКТИВНОЕ! НЕ УДАЛЯЙТЕ!"$(set_color normal)
        else
            echo "  [$i] $kernel"
        end
        set i (math $i + 1)
    end

    echo ""
    echo "  [a] Удалить все неактивные"
    echo "  [q] Выйти"
    echo ""

    read -l -P "Выбор: " choice

    switch $choice
        case "q" "Q"
            echo "Выход."
            return 0
        case "a" "A"
            echo "Удаление всех неактивных ядер..."
            for kernel in $kernel_list
                set name (echo $kernel | cut -d' ' -f1)
                if not string match -q "*$name*" $current
                    echo "  Удаление: $name"
                    sudo pacman -Rns $name $name-headers 2>/dev/null || true
                end
            end
        case '*'
            if test -n "$choice" && string match -qr '^[0-9]+$' $choice
                set selected_index $choice
                if test $selected_index -ge 1 && test $selected_index -le (count $kernel_list)
                    set selected_kernel $kernel_list[$selected_index]
                    set name (echo $selected_kernel | cut -d' ' -f1)

                    # Проверяем что это не активное ядро
                    if string match -q "*$name*" $current
                        echo $(set_color red)"ОШИБКА: Это активное ядро! Нельзя удалять!"$(set_color normal)
                        return 1
                    end

                    read -l -P "Удалить $selected_kernel? (y/N): " confirm
                    if test "$confirm" = "y" -o "$confirm" = "Y"
                        echo "Удаление $name..."
                        sudo pacman -Rns $name $name-headers
                        sudo rm -f /boot/vmlinuz-$name /boot/initramfs-$name*.img 2>/dev/null
                        sudo grub-mkconfig -o /boot/grub/grub.cfg
                        echo "Готово!"
                    else
                        echo "Отмена."
                    end
                else
                    echo "Неверный номер."
                end
            else
                echo "Неверный выбор."
            end
    end
end
