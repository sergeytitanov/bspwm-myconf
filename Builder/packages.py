
BASE_PACKAGES = [
    "ffmpegthumbnailer", "tumbler",  # Создает миниатюры в thunar
    "lsd",  # Расширенная версия ls
    "alacritty",  # Эмулятор терминала
    "bat",  # Улучшенная версия cat
    "evince",  # Читалка PDF
    "xdotool",  # Dependency for ~/bin/cursor_tracker.sh
    "mesa", "lib32-mesa", "xf86-video-amdgpu", "vulkan-radeon", "lib32-vulkan-radeon",  # Ryzen iGPU (AMD)
    "nvtop",  # Позволяет посмотреть нагрузку на GPU в режиме терминала
    "npm",  # Зависимость для других компонентов
    "brightnessctl",  # Используется для управления яркостью (bin/brightness)
    "kitty",  # Зависимость nvim для images.lua
    "gvfs", "gvfs-mtp",  # Поддержка MTP протокола, монтирование Android через USB
    "automake", "make", "cmake", "autoconf",  # Автоматическое создание Makefile
    "bluez", "bluez-utils",  # Пакеты для модуля блютуз
    "dunst",  # Демон уведомлений
    "fakeroot",  # Создает фейковое окружение
    "feh",  # Просмотр и работа с изображениями
    "firefox",  # Основной Браузер
    "fish",  # Shell для работы с терминалом
    "thunar-archive-plugin",  # Поддержка архивов в thunar
    "gzip", "p7zip", "unrar", "zip", "unzip", "xarchiver",  # Работа с архивами
    "gedit",  # Редактор текста
    "htop", "btop",  # Системные мониторы
    "thunar",  # Файловый менеджер
    "zathura", "zathura-djvu", "zathura-pdf-mupdf",  # Просмотр PDF, DJVU, EPUB файлов
    "picom",  # Композитор для отрисовки анимаций
    "nitrogen",  # Выбор обоев из графического интерфейса
    "pavucontrol",  # Управление звуком с графического интерфейса
    "redshift",  # Задает теплый цвет монитора в зависимости от времени
    "scrot",  # Консольный софт для скринов
    "fastfetch",  # Вывод информации о системе и железе
    "rofi", "rofi-calc", "rofi-emoji",  # Меню приложений + доп.плагины
    "mat2",  # Очистка метаданных изображения
    "ranger",  # Консольный файловый менеджер
    "calcurse",  # Консольный календарь
    "ttf-jetbrains-mono", "ttf-jetbrains-mono-nerd",  # Базовые шрифты
    "ttf-fira-code", "ttf-iosevka-nerd",  # Базовые шрифты
    "libreoffice",  # Приложения офиса
    "tree",  # Отобразить дерево
    "sudo",  # Выполнение команд с правами root
    "ffmpeg",  # Утилита для работы с медиа
    "polybar",  # Верхняя панель с рабочими столами и управлением системой
    "torbrowser-launcher",  # Лаунчер тора и служба для работы в фоне
    "dpkg",  # Средство для сборки Debian пакетов
    "gcc", "clang",  # Компилятор языка С и пакет для поддержки языка
    "git",  # Система контроля версий
    "gpick",  # Определить цвета. Необходимо для встроенного софта из bin/
    "wget",  # Получить файлы с использованием HTTP/S, FTP
    "pamixer",  # Микшер командной строки Pulseaudio
    "pulseaudio-alsa",  # Управление ALSA
    "ueberzug",  # Используется для отображения превью изображений и прочего медиа-контента
    "xclip",  # Работа с буфером обмена используя терминал
    # "breeze", # TODO: Deprecated
    "openvpn",  # Поддержка протокола OpenVPN
    "reflector",  # Получить последний список зеркал
    # "uthash",  # TODO: Deprecated
    "slop",  # Получить координаты клика мыши
    "nano",  # Консольный редактор текста
    "lxappearance",  # Управления темами, иконками
    "papirus-icon-theme",  # Пак иконок для окружения
    "imagemagick",  # Набор консольных утилит для редактирования изображений / TODO: Зависимость от nvim
    "ncmpcpp", "mpd",  # Клиент для работы с медиа
    "mpc",  # Минималистичный интерфейс командной строки для MPD
    "mpv",  # Просмотр видео
    "alsa-plugins", "alsa-utils",  # Плагины и утилиты для Alsa
    # "alsa-tools",  # TODO: Deprecated
    "network-manager-applet", "networkmanager-openvpn",
    "gparted",  # Работа с носителями в системе
    "amd-ucode",  # Микрокод для процессоров AMD (Ryzen / G14)
    "gnu-netcat",  # Утилиты для работы с сетью
    "usbutils",  # Утилиты для работы с USB-устройствами
    # "python-pyalsa",  # TODO: Deprecated
    "sshfs",  # Монтирование удаленных SSH каталогов локально
    "netctl",  # Сетевой менеджер на основе CLI
    "openssh",  # Набор программ для поддержки SSH
    "shellcheck",  # Инструмент для анализа сценариев оболочки
    "noto-fonts-emoji",  # Для отображения emoji в rofi-menu
    "noto-fonts-cjk",  # Для отображения emoji в rofi-menu
    "gthumb",  # Просмотр и редактирование изображений
    "gnome-disk-utility",  # Просмотр и редактирование дисков
]

DEV_PACKAGES = [
    "obsidian",  # Заметки
    "python",  # Интерпретатор Python
    "python-pip",  # Установка пакетов PyPI
    # Стек ASUS Linux (официально с репозитория [g14]; добавьте его в /etc/pacman.conf до билдера):
    "asusctl",  # CLI и демон для ROG (asus-linux.org)
    "power-profiles-daemon",  # Профили энергопотребления (после установки: systemctl enable --now power-profiles-daemon)
    "rog-control-center",  # GUI для asusctl / ROG
]

AUR_PACKAGES = [
    "lazydocker",  # Удобный интерфейс для управления docker
    "cava",  # Вывод спектра для музыки
    "i3lock-color",  # Используется для блокировки экрана
    "ptpython",  # Выполнение Python кода построчно
    "ttf-symbola",  # Для отображения emoji в rofi-menu
    "hyx",  # Редактирование и просмотр Hex внутри файла
    "arttime-git",  # Консольный таймер и секундомер
    "bluetuith",  # TUI менеджер управления bluetooth
    "rofi-bluetooth-git",  # Управление bluetooth в rofi
    "anki",  # Программа для запоминания материала через карточки
    "light",  # TODO: Нужен для управления яркостью amd (bin/brightness)
]

