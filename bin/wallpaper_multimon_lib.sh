#!/bin/sh
# Обои на каждый монитор отдельно: feh --bg-fill --xinerama-index N
# Число индексов = число выходов со статусом «connected» (поле 2 в xrandr), а не только строка Monitors:.

wallpaper_count_monitors() {
    n="$(xrandr -q 2>/dev/null | awk '$2 == "connected" { c++ } END { print c + 0 }')"
    [ -z "$n" ] || [ "$n" -lt 1 ] && n=1
    echo "$n"
}

wallpaper_list_images_sorted() {
    find "${1:-$HOME/Images}" -maxdepth 1 -type f \( \
        -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.webp' -o -iname '*.gif' \
    \) 2>/dev/null | LC_ALL=C sort
}

# 1-based индекс (46 = сорок шестой файл по сортировке)
wallpaper_nth_from_dir() {
    dir="${1:-$HOME/Images}"
    nth="${2:-46}"
    list="$(wallpaper_list_images_sorted "$dir")"
    [ -z "$list" ] && return 1
    total="$(printf '%s\n' "$list" | wc -l)"
    [ "$nth" -gt "$total" ] && nth=$total
    [ "$nth" -lt 1 ] && nth=1
    img="$(printf '%s\n' "$list" | sed -n "${nth}p")"
    [ -n "$img" ] && wallpaper_apply_file "$img"
}

wallpaper_apply_file() {
    img="$1"
    [ -f "$img" ] || return 1

    n="$(wallpaper_count_monitors)"
    [ "$n" -lt 1 ] && n=1

    # Для нескольких мониторов передаем изображение одним вызовом feh.
    # Это корректнее для смешанных/повернутых раскладок (например вертикальный DP).
    set -- feh --no-fehbg --bg-fill
    i=0
    while [ "$i" -lt "$n" ]; do
        set -- "$@" "$img"
        i=$((i + 1))
    done
    "$@"
}

wallpaper_random_from_dir() {
    dir="${1:-$HOME/Images}"
    img="$(wallpaper_list_images_sorted "$dir" | shuf -n 1)"
    [ -n "$img" ] && wallpaper_apply_file "$img"
}
