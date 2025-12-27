#!/bin/bash

# Обновляем систему
sudo pacman -Syu --noconfirm

# Устанавливаем yay, если его нет
if ! command -v yay &>/dev/null; then
    echo "Yay не найден. Устанавливаю yay..."
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git ~/yay
    (cd ~/yay && makepkg -si --noconfirm)
fi

# Обновляем все пакеты через yay
yay -Syu --noconfirm

# Список пакетов, отсортированный по алфавиту
PACKAGES=(

)

# Установка или обновление пакетов через yay
for pkg in "${PACKAGES[@]}"; do
  yay -S --noconfirm --needed "$pkg"
done
