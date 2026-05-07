#!/bin/sh
# Имена выходов пишет dual_monitors.sh в ~/.cache/bspwm_polybar_monitors.env
killall -q polybar
while pgrep -x polybar >/dev/null; do
    sleep 0.2
done

ENVFILE="${HOME}/.cache/bspwm_polybar_monitors.env"
if [ -f "$ENVFILE" ]; then
    # shellcheck source=/dev/null
    . "$ENVFILE"
fi

DISPLAY_CFG="${HOME}/.config/bspwm/display.env"
if [ -f "$DISPLAY_CFG" ]; then
    # shellcheck source=/dev/null
    . "$DISPLAY_CFG"
fi

export MONITOR="${MONITOR:-eDP}"
export MONITOR_EXT="${MONITOR_EXT:-}"
export POLYBAR_DPI="${POLYBAR_DPI:-$(awk "BEGIN{printf \"%d\", 144*${BSPWM_UI_SCALE_CFG:-1.00}}")}"

if [ -n "$MONITOR_EXT" ] && xrandr -q | grep -q "^${MONITOR_EXT} connected"; then
    MONITOR_EXT="$MONITOR_EXT" polybar top_external -r >>/tmp/polybar_external.log 2>&1 &
    MONITOR="$MONITOR" polybar top -r >>/tmp/polybar.log 2>&1 &
else
    MONITOR="$MONITOR" polybar top -r >>/tmp/polybar.log 2>&1 &
fi
