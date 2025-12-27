# Функция для быстрого переключения ядер

function kernel-switch --argument kernel_name
    if test -z "$kernel_name"
        echo "Использование: kernel-switch <имя_ядра>"
        echo ""
        echo "Примеры:"
        echo "  kernel-switch linux-cachyos"
        echo "  kernel-switch linux-lts"
        echo "  kernel-switch linux-zen"
        echo "  kernel-switch linux-cachyos-lts"
        return 1
    end

    echo "Установка ядра $kernel_name..."

    # Проверить доступность
    if not pacman -Ss $kernel_name >/dev/null 2>&1
        echo "Ошибка: ядро $kernel_name не найдено в репозиториях"
        echo "Проверьте: pacman -Ss $kernel_name"
        return 1
    end

    # Установка
    sudo pacman -S $kernel_name $kernel_name-headers

    # Обновление конфигов
    echo "Обновление initramfs..."
    sudo mkinitcpio -P

    echo "Обновление GRUB..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    echo ""
    echo "Готово! Ядро $kernel_name установлено."
    echo "Для использования перезагрузитесь и выберите его в меню GRUB."
    echo ""
    echo "Текущее ядро: "(uname -r)
    echo "Установленное: $kernel_name"
end
