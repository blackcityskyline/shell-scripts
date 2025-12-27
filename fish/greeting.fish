#!/usr/bin/env fish

# Цвета
set color_green (tput setaf 2)
set color_yellow (tput setaf 3)
set color_purple (tput setaf 147)
set reset (tput sgr0)

# Переменные для имени и времени
set user (whoami)
set hour (date +"%H")
if test $hour -ge 5 -a $hour -lt 12
    set greeting_word "morning"
else if test $hour -ge 12 -a $hour -lt 17
    set greeting_word "afternoon"
else if test $hour -ge 17 -a $hour -lt 21
    set greeting_word "evening"
else
    set greeting_word "night"
end

set date_str (env LC_TIME=C date '+%b %d, %a' | sed 's/\.  */./g')
set time_str (date '+%H:%M')

# Проверка обновлений с кэшированием на 24 часа
set cache_file "/tmp/update_info_$user"
set cache_age_file "/tmp/update_age_$user"

# Чтение кэшированного значения
set updates 0
set should_check false

if test -f $cache_file -a -f $cache_age_file
    set last_check (cat $cache_age_file 2>/dev/null)
    set current_time (date +%s)

    if test -n "$last_check"
        # Проверка, прошло ли больше 24 часов (86400 секунд)
        if test (math "$current_time - $last_check") -gt 86400
            set should_check true
        end
        set updates (cat $cache_file 2>/dev/null || echo 0)
    else
        set should_check true
        set updates (cat $cache_file 2>/dev/null || echo 0)
    end
else
    set should_check true
end

# Если нужно проверить обновления, запуск в фоне
if test "$should_check" = "true"
    # Запуск фоновой проверки
    sh -c '
        sleep 0.5
        checkupdates 2>/dev/null | wc -l > '$cache_file'
        date +%s > '$cache_age_file'
    ' &
end

# Сообщение о обновлениях
if test $updates -eq 0
    set updates_msg "Fresh as ever —$color_purple no updates $reset"
else
    set updates_msg "A fresh batch for you — $color_green$updates updates available$reset"
end

# Вывод основной информации
echo -e "Welcome, $color_green$user$reset. Good $color_purple$greeting_word$reset. Date: $color_yellow$date_str$reset / The time is $reset$color_green$time_str$reset"

# Вывод сообщения о обновлениях
echo -e "$updates_msg"
