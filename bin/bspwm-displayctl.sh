#!/bin/sh

CFG="${HOME}/.config/bspwm/display.env"
mkdir -p "$(dirname "$CFG")"

# Значения по умолчанию
BSPWM_EXTERNAL_ROTATE_CFG="normal"
BSPWM_EXTERNAL_POSITION_CFG="left"
BSPWM_UI_SCALE_CFG="1.00"
BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.00"

[ -f "$CFG" ] && . "$CFG"

scale_next_up() {
    case "$BSPWM_UI_SCALE_CFG" in
        0.80) BSPWM_UI_SCALE_CFG="0.85" ;;
        0.85) BSPWM_UI_SCALE_CFG="0.90" ;;
        0.90) BSPWM_UI_SCALE_CFG="0.95" ;;
        0.95) BSPWM_UI_SCALE_CFG="1.00" ;;
        1.00) BSPWM_UI_SCALE_CFG="1.05" ;;
        1.05) BSPWM_UI_SCALE_CFG="1.10" ;;
        1.10) BSPWM_UI_SCALE_CFG="1.15" ;;
        *) BSPWM_UI_SCALE_CFG="1.00" ;;
    esac
}

scale_next_down() {
    case "$BSPWM_UI_SCALE_CFG" in
        1.15) BSPWM_UI_SCALE_CFG="1.10" ;;
        1.10) BSPWM_UI_SCALE_CFG="1.05" ;;
        1.05) BSPWM_UI_SCALE_CFG="1.00" ;;
        1.00) BSPWM_UI_SCALE_CFG="0.95" ;;
        0.95) BSPWM_UI_SCALE_CFG="0.90" ;;
        0.90) BSPWM_UI_SCALE_CFG="0.85" ;;
        0.85) BSPWM_UI_SCALE_CFG="0.80" ;;
        *) BSPWM_UI_SCALE_CFG="1.00" ;;
    esac
}

global_scale_next_up() {
    case "$BSPWM_EXTERNAL_GLOBAL_SCALE_CFG" in
        0.80) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="0.85" ;;
        0.85) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="0.90" ;;
        0.90) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="0.95" ;;
        0.95) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.00" ;;
        1.00) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.05" ;;
        1.05) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.10" ;;
        1.10) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.15" ;;
        *) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.00" ;;
    esac
}

global_scale_next_down() {
    case "$BSPWM_EXTERNAL_GLOBAL_SCALE_CFG" in
        1.15) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.10" ;;
        1.10) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.05" ;;
        1.05) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.00" ;;
        1.00) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="0.95" ;;
        0.95) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="0.90" ;;
        0.90) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="0.85" ;;
        0.85) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="0.80" ;;
        *) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.00" ;;
    esac
}

case "${1:-}" in
    side-left) BSPWM_EXTERNAL_POSITION_CFG="left" ;;
    side-right) BSPWM_EXTERNAL_POSITION_CFG="right" ;;
    rotate-left) BSPWM_EXTERNAL_ROTATE_CFG="left" ;;
    rotate-right) BSPWM_EXTERNAL_ROTATE_CFG="right" ;;
    rotate-normal) BSPWM_EXTERNAL_ROTATE_CFG="normal" ;;
    rotate-inverted) BSPWM_EXTERNAL_ROTATE_CFG="inverted" ;;
    scale-up|ui-scale-up) scale_next_up ;;
    scale-down|ui-scale-down) scale_next_down ;;
    scale-reset|ui-scale-reset) BSPWM_UI_SCALE_CFG="1.00" ;;
    global-scale-up) global_scale_next_up ;;
    global-scale-down) global_scale_next_down ;;
    global-scale-reset) BSPWM_EXTERNAL_GLOBAL_SCALE_CFG="1.00" ;;
    "")
        ;;
    *)
        echo "Usage: $0 [side-left|side-right|rotate-left|rotate-right|rotate-normal|rotate-inverted|ui-scale-up|ui-scale-down|ui-scale-reset|global-scale-up|global-scale-down|global-scale-reset]"
        exit 1
        ;;
esac

cat >"$CFG" <<EOF
BSPWM_EXTERNAL_ROTATE_CFG=${BSPWM_EXTERNAL_ROTATE_CFG}
BSPWM_EXTERNAL_POSITION_CFG=${BSPWM_EXTERNAL_POSITION_CFG}
BSPWM_UI_SCALE_CFG=${BSPWM_UI_SCALE_CFG}
BSPWM_EXTERNAL_GLOBAL_SCALE_CFG=${BSPWM_EXTERNAL_GLOBAL_SCALE_CFG}
EOF

export BSPWM_EXTERNAL_ROTATE="${BSPWM_EXTERNAL_ROTATE_CFG}"
export BSPWM_EXTERNAL_POSITION="${BSPWM_EXTERNAL_POSITION_CFG}"
export BSPWM_UI_SCALE="${BSPWM_UI_SCALE_CFG}"
export BSPWM_EXTERNAL_GLOBAL_SCALE="${BSPWM_EXTERNAL_GLOBAL_SCALE_CFG}"

# UI scaling: без смены разрешения, только размер интерфейса (DPI/курсор/polybar)
POLYBAR_DPI="$(awk "BEGIN{printf \"%d\", 144*${BSPWM_UI_SCALE_CFG}}")"
XFT_DPI="$(awk "BEGIN{printf \"%d\", 96*${BSPWM_UI_SCALE_CFG}}")"
XCURSOR_SIZE="$(awk "BEGIN{printf \"%d\", 24*${BSPWM_UI_SCALE_CFG}}")"
export POLYBAR_DPI
export XCURSOR_SIZE
xrdb -merge <<EOF
Xft.dpi: ${XFT_DPI}
Xcursor.size: ${XCURSOR_SIZE}
EOF

sh "${HOME}/.config/bspwm/dual_monitors.sh"
sh "${HOME}/.config/polybar/launch.sh"

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Display layout" "Side: ${BSPWM_EXTERNAL_POSITION_CFG}, rotate: ${BSPWM_EXTERNAL_ROTATE_CFG}, UI: ${BSPWM_UI_SCALE_CFG}, Global: ${BSPWM_EXTERNAL_GLOBAL_SCALE_CFG}" -t 1700
fi
