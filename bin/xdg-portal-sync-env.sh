#!/bin/sh
# Проброс DISPLAY (и при наличии WAYLAND_DISPLAY) в systemd --user и D-Bus,
# чтобы xdg-desktop-portal-gtk мог показывать нативные диалоги выбора папки.

[ -n "${DISPLAY:-}" ] || exit 0

export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-bspwm}"

systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP 2>/dev/null
dbus-update-activation-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

systemctl --user restart xdg-desktop-portal-gtk.service xdg-desktop-portal.service 2>/dev/null
