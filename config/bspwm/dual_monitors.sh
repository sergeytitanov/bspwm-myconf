#!/bin/sh
# Внутренний: eDP*. Внешний: DP-*/HDMI*/DisplayPort-* (в т.ч. USB‑C).
#
# Поворот внешнего (как в xrandr, не «градусы экрана» буквально):
#   normal    — 0°
#   right     — по часовой 90° (частый «портрет»)
#   left      — против часовой 90° (= 270° по часовой)
#   inverted  — 180°
# Задать: export BSPWM_EXTERNAL_ROTATE=right   (в ~/.profile, bspwmrc или перед startx)
#
# Сторона внешнего относительно ноутбука:
#   BSPWM_EXTERNAL_POSITION=left  (по умолчанию) или right

POLYBAR_MON_ENV="${HOME}/.cache/bspwm_polybar_monitors.env"
DISPLAY_CFG="${HOME}/.config/bspwm/display.env"

# Приоритет: переменные окружения > сохраненный конфиг > дефолты
[ -f "$DISPLAY_CFG" ] && . "$DISPLAY_CFG"
EXT_ROT="${BSPWM_EXTERNAL_ROTATE:-${BSPWM_EXTERNAL_ROTATE_CFG:-normal}}"
EXT_SIDE="${BSPWM_EXTERNAL_POSITION:-${BSPWM_EXTERNAL_POSITION_CFG:-left}}"
EXT_GLOBAL_SCALE="${BSPWM_EXTERNAL_GLOBAL_SCALE:-${BSPWM_EXTERNAL_GLOBAL_SCALE_CFG:-1.00}}"
EXT_WINDOW_GAP="${BSPWM_EXTERNAL_WINDOW_GAP:-0}"
EXT_BORDER_WIDTH="${BSPWM_EXTERNAL_BORDER_WIDTH:-0}"

pick_internal() {
    for n in eDP eDP-1 eDP-2; do
        if xrandr -q | grep -q "^${n} connected"; then
            echo "$n"
            return
        fi
    done
    echo "eDP"
}

pick_external() {
    for n in \
        DP-1 DP-2 DP-1-0 DP-1-1 DP-1-2 DP-1-3 DP-1-4 \
        DisplayPort-0 DisplayPort-1 DisplayPort-2 DisplayPort-1-0 DisplayPort-2-0 \
        HDMI-1-1 HDMI-A-1-0 HDMI-1 HDMI-1-0 HDMI-2; do
        if xrandr -q | grep -q "^${n} connected"; then
            echo "$n"
            return
        fi
    done
    echo ""
}

INTERNAL_MONITOR="$(pick_internal)"
EXTERNAL_MONITOR="$(pick_external)"

mkdir -p "${HOME}/.cache"
# По умолчанию только внутренний (polybar читает при старте)
{
    echo "export MONITOR=${INTERNAL_MONITOR}"
    echo "export MONITOR_EXT="
} >"$POLYBAR_MON_ENV"

export MONITOR="${INTERNAL_MONITOR}"
export MONITOR_EXT="${EXTERNAL_MONITOR:-}"

if [ -n "$EXTERNAL_MONITOR" ] && xrandr -q | grep -q "${EXTERNAL_MONITOR} connected"; then
    bspc monitor "$INTERNAL_MONITOR" -d 1 2 3 4 5
    bspc monitor "$EXTERNAL_MONITOR" -d 6 7 8 9
    bspc wm -O "$INTERNAL_MONITOR" "$EXTERNAL_MONITOR"
else
    bspc monitor "$INTERNAL_MONITOR" -d 1 2 3 4 5
fi

if [ -n "$EXTERNAL_MONITOR" ] && xrandr -q | grep -q "${EXTERNAL_MONITOR} connected"; then
    # Сначала внутренний (опорная точка), затем внешний — геометрия без конфликта --pos и --left-of
    xrandr --output "$INTERNAL_MONITOR" --auto --rotate normal 2>/dev/null
    if [ "$EXT_SIDE" = "right" ]; then
        xrandr --output "$EXTERNAL_MONITOR" --auto --rotate "$EXT_ROT" --scale "${EXT_GLOBAL_SCALE}x${EXT_GLOBAL_SCALE}" --right-of "$INTERNAL_MONITOR" 2>/dev/null
    else
        xrandr --output "$EXTERNAL_MONITOR" --auto --rotate "$EXT_ROT" --scale "${EXT_GLOBAL_SCALE}x${EXT_GLOBAL_SCALE}" --left-of "$INTERNAL_MONITOR" 2>/dev/null
    fi
    xrandr --output "$INTERNAL_MONITOR" --primary 2>/dev/null

    {
        echo "export MONITOR=${INTERNAL_MONITOR}"
        echo "export MONITOR_EXT=${EXTERNAL_MONITOR}"
    } >"$POLYBAR_MON_ENV"
    bspc wm -O "$INTERNAL_MONITOR" "$EXTERNAL_MONITOR"

    # На внешнем мониторе без щелей вокруг окон.
    bspc config -m "$EXTERNAL_MONITOR" window_gap "$EXT_WINDOW_GAP"
    bspc config -m "$EXTERNAL_MONITOR" border_width "$EXT_BORDER_WIDTH"
else
    for out in \
        DP-1 DP-2 DP-1-0 DP-1-1 DP-1-2 DP-1-3 DP-1-4 \
        DisplayPort-0 DisplayPort-1 DisplayPort-2 DisplayPort-1-0 DisplayPort-2-0 \
        HDMI-1-1 HDMI-A-1-0 HDMI-1 HDMI-1-0 HDMI-2; do
        xrandr --output "$out" --off 2>/dev/null
    done
    xrandr --output "$INTERNAL_MONITOR" --primary --auto --rotate normal 2>/dev/null
    if [ "$(bspc query -D -m "${INTERNAL_MONITOR}" | wc -l)" -ne 5 ]; then
        bspc monitor "$INTERNAL_MONITOR" -d 1 2 3 4 5
    fi
fi
