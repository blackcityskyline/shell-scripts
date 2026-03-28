function cheats --description "Show terminal cheat sheet"
    set -l category (string lower (echo $argv[1] | string trim))

    # Цвета
    set -l red (set_color red)
    set -l green (set_color green)
    set -l yellow (set_color yellow)
    set -l blue (set_color blue)
    set -l magenta (set_color magenta)
    set -l cyan (set_color cyan)
    set -l white (set_color white)
    set -l bold (set_color -o)
    set -l reset (set_color normal)

    if test -z "$category"
        # Основной экран
        echo "$bold📖 Terminal Cheat Sheets$reset"
        echo "$cyan================================$reset"
        echo ""
        echo "$boldИспользование:$reset cheats [категория]"
        echo ""
        echo "$boldКатегории:$reset"
        echo "  $green basic$reset     - Основные комбинации"
        echo "  $green nav$reset       - Навигация"
        echo "  $green edit$reset      - Редактирование"
        echo "  $green history$reset   - История команд"
        echo "  $green process$reset   - Управление процессами"
        echo "  $green kitty$reset     - Специфичные для Kitty"
        echo "  $green fish$reset      - Специфичные для Fish"
        echo "  $green git$reset       - Git команды"
        echo "  $green all$reset       - Показать всё"
        echo ""
        echo "$yellowПример:$reset cheats nav"
        echo "$yellowБыстрый доступ:$reset alias c=cheats"

    else if test "$category" = basic -o "$category" = all
        echo "$bold🟢 ОСНОВНЫЕ КОМБИНАЦИИ$reset"
        echo "$cyan--------------------------------$reset"
        echo "$green Ctrl+C$reset     - Прервать процесс"
        echo "$green Ctrl+D$reset     - Выход/EOF (в Fish: настроен)"
        echo "$green Ctrl+Z$reset     - Приостановить процесс"
        echo "$green Ctrl+L$reset     - Очистить экран"
        echo "$green Ctrl+S$reset     - Приостановить вывод"
        echo "$green Ctrl+Q$reset     - Возобновить вывод"
        echo "$green Tab$reset        - Автодополнение"
        echo "$green Ctrl+R$reset     - Поиск в истории"
        echo ""

    else if test "$category" = nav -o "$category" = all
        echo "$bold🟡 НАВИГАЦИЯ$reset"
        echo "$cyan--------------------------------$reset"
        echo "$green Ctrl+A$reset     - В начало строки$yellow (работает)$reset"
        echo "$green Ctrl+E$reset     - В конец строки$yellow (работает)$reset"
        echo "$green Alt+← / Ctrl+←$reset  - На слово назад"
        echo "$green Alt+→ / Ctrl+→$reset  - На слово вперёд"
        echo "$green Ctrl+F$reset     - Символ вперёд"
        echo "$green Ctrl+B$reset     - Символ назад"
        echo "$green Ctrl+XX$reset    - Bash: переключение позиции"
        echo ""

    else if test "$category" = edit -o "$category" = all
        echo "$bold🔴 РЕДАКТИРОВАНИЕ$reset"
        echo "$cyan--------------------------------$reset"
        echo "$green Ctrl+W$reset     - Удалить слово назад$yellow (работает)$reset"
        echo "$green Alt+D$reset      - Удалить слово вперёд"
        echo "$green Ctrl+U$reset     - Удалить до начала строки$yellow (работает)$reset"
        echo "$green Ctrl+K$reset     - Удалить до конца строки$yellow (работает)$reset"
        echo "$green Ctrl+Backspace$reset - Удалить слово назад$yellow (в Kitty)$reset"
        echo "$green Ctrl+Delete$reset    - Удалить слово вперёд$yellow (в Kitty)$reset"
        echo "$green Alt+Backspace$reset  - Удалить слово назад"
        echo "$green Ctrl+H$reset     - Удалить символ назад (как Backspace)"
        echo "$green Ctrl+Y$reset     - Вставить последнее удалённое (yank)"
        echo "$green Ctrl+/$reset     - Отменить"
        echo ""

    else if test "$category" = history -o "$category" = all
        echo "$bold🟣 ИСТОРИЯ КОМАНД$reset"
        echo "$cyan--------------------------------$reset"
        echo "$green ↑ / ↓$reset      - Предыдущая/следующая команда"
        echo "$green Ctrl+P$reset     - Предыдущая команда (как ↑)"
        echo "$green Ctrl+N$reset     - Следующая команда (как ↓)"
        echo "$green Ctrl+R$reset     - Обратный поиск в истории"
        echo "$green Ctrl+S$reset     - Прямой поиск в истории (если включено)"
        echo "$green Alt+.$reset      - Bash: последний аргумент"
        echo "$green Alt+_$reset      - Fish: последний аргумент$yellow (настроено)$reset"
        echo "$green !!$reset         - Повторить последнюю команду"
        echo "$green !*$reset         - Все аргументы последней команды"
        echo "$green !$resetn         - Команда под номером n"
        echo ""

    else if test "$category" = process -o "$category" = all
        echo "$bold🔵 УПРАВЛЕНИЕ ПРОЦЕССАМИ$reset"
        echo "$cyan--------------------------------$reset"
        echo "$green Ctrl+C$reset     - SIGINT (прервать)$yellow (работает)$reset"
        echo "$green Ctrl+Z$reset     - SIGTSTP (приостановить)"
        echo "$green Ctrl+\$reset     - SIGQUIT (завершить с дампом)"
        echo "$green bg$reset         - Запустить процесс в фоне"
        echo "$green fg$reset         - Вернуть процесс на передний план"
        echo "$green jobs$reset       - Показать фоновые процессы"
        echo "$green kill %1$reset    - Убить процесс №1"
        echo ""

    else if test "$category" = kitty -o "$category" = all
        echo "$bold🐱 KITTY СПЕЦИФИЧНЫЕ$reset"
        echo "$cyan--------------------------------$reset"
        echo "$green Ctrl+Shift+Enter$reset - Новое окно"
        echo "$green Ctrl+Shift+N$reset     - Новая вкладка"
        echo "$green Ctrl+Shift+W$reset     - Закрыть окно"
        echo "$green Ctrl+Shift+Q$reset     - Закрыть вкладку"
        echo "$green Ctrl+Shift+→/←$reset   - Переключение окон"
        echo "$green Ctrl+Shift+[/]$reset   - Переключение вкладок"
        echo "$green Ctrl+Shift+C$reset     - Копировать"
        echo "$green Ctrl+Shift+V$reset     - Вставить"
        echo "$green Ctrl++$reset           - Увеличить шрифт"
        echo "$green Ctrl+-$reset           - Уменьшить шрифт"
        echo "$green Ctrl+0$reset           - Сбросить размер шрифта"
        echo ""

    else if test "$category" = fish -o "$category" = all
        echo "$bold🐟 FISH SHELL СПЕЦИФИЧНЫЕ$reset"
        echo "$cyan--------------------------------$reset"
        echo "$green Alt+L$reset      - Слово в lowercase$yellow (настроено)$reset"
        echo "$green Alt+U$reset      - Слово в uppercase$yellow (настроено)$reset"
        echo "$green Alt+C$reset      - Capitalize слово$yellow (настроено)$reset"
        echo "$green Alt+*$reset      - Выбрать все автодополнения"
        echo "$green Alt+Enter$reset  - Принять первое автодополнение"
        echo "$green Ctrl+Space$reset - Показать все автодополнения"
        echo "$green fish_config$reset- Открыть веб-конфиг Fish"
        echo ""

    else if test "$category" = git -o "$category" = all
        echo "$bold💾 GIT КОМАНДЫ$reset"
        echo "$cyan--------------------------------$reset"
        echo "$green gs$reset         - git status"
        echo "$green ga$reset         - git add"
        echo "$green gc$reset         - git commit"
        echo "$green gcm$reset        - git commit -m"
        echo "$green gp$reset         - git push"
        echo "$green gl$reset         - git pull"
        echo "$green gco$reset        - git checkout"
        echo "$green gb$reset         - git branch"
        echo "$green gd$reset         - git diff"
        echo "$green gst$reset        - git stash"
        echo "$green gr$reset         - git remote -v"
        echo "$green glog$reset       - git log --oneline --graph"
        echo ""

    else
        echo "$red❌ Неизвестная категория: $category$reset"
        echo "Доступные категории: basic, nav, edit, history, process, kitty, fish, git, all"
    end
end
