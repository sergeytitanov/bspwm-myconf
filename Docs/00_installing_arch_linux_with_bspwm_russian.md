# Установка Arch Linux + BSPWM (Zproger) на ASUS ROG Zephyrus G14

Данный файл — актуальная последовательность шагов для **ноутбука ASUS ROG Zephyrus G14** (ориентир: модели с **AMD Ryzen** и **NVIDIA GeForce RTX**), **dual-boot с уже установленной Windows**, **отдельный EFI-раздел для Arch**, **LUKS без LVM**, **Btrfs с подтомами**, загрузчик **GRUB + os-prober** (в одном меню: Arch, fallback, Windows Boot Manager).

Оригинальное видео Zproger по разметке и BSPWM можно смотреть для общей картины: [YouTube](https://youtu.be/9zewiGf7j-A). **Командам из этого файла отдавайте приоритет** — схема диска и загрузчик здесь другие (не systemd-boot, не LVM).

Если у вас редкая конфигурация G14 на **Intel** без дискретной NVIDIA — пропустите шаги с `linux-g14`/репозиторием ASUS там, где указано, замените `amd-ucode` на `intel-ucode`, пакеты NVIDIA/CUDA не ставьте.

---

## 0. Железо и софт в двух словах

| Компонент | Типично на G14 |
|-----------|----------------|
| CPU | AMD Ryzen (микрокод: `amd-ucode`) |
| iGPU | AMD Radeon (Mesa) |
| dGPU | NVIDIA RTX (для `linux-g14`: **DKMS**, `nvidia-open-dkms` или `nvidia-dkms`) |
| Звук / BT | PipeWire, `bluez` |
| Специфика ноутбука | Репозиторий [ASUS Linux](https://asus-linux.org/): `asusctl`, `rog-control-center`, ядро **`linux-g14`** |
| CUDA (разработка) | Пакеты `cuda`, опционально `cudnn` — после настройки NVIDIA и перезагрузки на рабочем драйвере |

---

## 1. Подготовка Windows

В PowerShell **от администратора**:

```powershell
powercfg /h off
```

Отключает гибернацию и уменьшает проблемы с Fast Startup.

Проверка BitLocker:

```powershell
manage-bde -status
```

Если шифрование включено — **сохраните ключ восстановления**. После смены загрузчика Windows может запросить его.

---

## 2. BIOS / UEFI

Рекомендуемые настройки на время установки:

- **Secure Boot**: Disabled (позже можно настроить под свою цепочку доверия; LUKS, DKMS, стороннее ядро проще без него на первом проходе).
- **Fast Boot**: Disabled.
- **Режим загрузки**: UEFI.
- **GPU**: Hybrid / Standard (как в прошивке ASUS).

---

## 3. Загрузка с Arch ISO

Проверка UEFI:

```bash
ls /sys/firmware/efi/efivars
```

### Wi‑Fi (`iwd`)

```bash
iwctl
# device list
# station wlan0 scan
# station wlan0 get-networks
# station wlan0 connect "SSID"
# exit
ping archlinux.org
```

Синхронизация времени:

```bash
timedatectl set-ntp true
```

Крупный шрифт в консоли (по желанию):

```bash
pacman -Sy terminus-font
setfont ter-u32b.psf.gz
```

---

## 4. Схема диска (пример)

**Диск:** например `/dev/nvme0n1`, часть занята Windows, в свободной области — Arch.

**Windows уже есть:**

- Windows EFI (не форматировать)
- разделы Microsoft / `C:` и т.д.

**Arch (пример):**

- **Arch EFI** ~1 ГиБ, FAT32 — только под загрузчик Arch (GRUB).
- **Arch root** — остаток, **LUKS**, внутри **Btrfs** с подтомами `@`, `@home`, `@log`, `@cache`, `@snapshots`.

**Пример имён узлов (у вас номера разделов будут свои):**

| Назначение   | Пример узла      |
|-------------|------------------|
| Windows EFI | `/dev/nvme0n1p1` |
| Arch EFI    | `/dev/nvme0n1p6` |
| LUKS        | `/dev/nvme0n1p7` |

Всегда проверяйте:

```bash
lsblk -f
parted /dev/nvme0n1 print free
```

Найдите **свободное место** под Arch и отдельно определите **VFAT EFI с Windows** (часто `PARTLABEL="EFI system partition"` и путь `EFI/Microsoft/Boot/bootmgfw.efi`).

---

## 5. Создание разделов Arch

Только в **свободной** области (например `cfdisk /dev/nvme0n1`):

1. Раздел **1 ГиБ**, тип **EFI System** → будущий `/boot` Arch.
2. Раздел **весь остаток**, тип **Linux filesystem** → будущий LUKS.

Запись таблицы, затем:

```bash
lsblk -f
```

---

## 6. Форматирование только Arch EFI

```bash
mkfs.fat -F32 /dev/nvme0n1p6
```

**Не** форматируйте раздел EFI Windows.

---

## 7. LUKS на разделе Linux

```bash
cryptsetup luksFormat /dev/nvme0n1p7
# ввести YES заглавными

cryptsetup open /dev/nvme0n1p7 cryptroot
lsblk
```

Ожидается цепочка `nvme0n1p7` → `cryptroot`.

---

## 8. Btrfs и подтома

```bash
mkfs.btrfs -f /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@snapshots

umount /mnt
```

Монтирование (подставьте свой mapper-имя, здесь `cryptroot`):

```bash
mount -o noatime,compress=zstd,ssd,space_cache=v2,subvol=@ /dev/mapper/cryptroot /mnt

mkdir -p /mnt/{boot,home,var/log,var/cache,.snapshots}

mount -o noatime,compress=zstd,ssd,space_cache=v2,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd,ssd,space_cache=v2,subvol=@log /dev/mapper/cryptroot /mnt/var/log
mount -o noatime,compress=zstd,ssd,space_cache=v2,subvol=@cache /dev/mapper/cryptroot /mnt/var/cache
mount -o noatime,compress=zstd,ssd,space_cache=v2,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

mount /dev/nvme0n1p6 /mnt/boot
```

---

## 9. Установка базовой системы (`pacstrap`)

Пример набора (ядро **stock** `linux` — для первой загрузки; **`linux-g14`** поставим из chroot/после установки репозитория):

```bash
pacstrap -K /mnt \
  base base-devel \
  linux linux-headers linux-firmware amd-ucode \
  btrfs-progs cryptsetup \
  grub efibootmgr os-prober dosfstools mtools ntfs-3g \
  networkmanager iwd \
  nano micro vim git wget curl \
  sudo zsh \
  pipewire pipewire-pulse wireplumber \
  bluez bluez-utils \
  man-db man-pages texinfo
```

Для редкой Intel-версии G14 замените `amd-ucode` на `intel-ucode`.

---

## 10. Fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

Проверьте строки для `/`, `/home`, `/var/log`, `/var/cache`, `/.snapshots`, `/boot`.

---

## 11. Chroot и базовая настройка

```bash
arch-chroot /mnt
```

Часовой пояс (подставьте свой регион):

```bash
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
```

Локали:

```bash
micro /etc/locale.gen
# раскомментировать: en_US.UTF-8 UTF-8 и ru_RU.UTF-8 UTF-8

locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

Имя хоста и `hosts`:

```bash
echo "g14-arch" > /etc/hostname
micro /etc/hosts
```

Пример `/etc/hosts`:

```
127.0.0.1	localhost
::1		localhost
127.0.1.1	g14-arch.localdomain	g14-arch
```

Пользователь (замените `sergey` на свой логин):

```bash
passwd
useradd -m -G wheel,users,video,audio,input,storage,power -s /bin/zsh sergey
passwd sergey
EDITOR=micro visudo
# раскомментировать: %wheel ALL=(ALL:ALL) ALL
```

---

## 12. mkinitcpio (LUKS, без LVM)

```bash
micro /etc/mkinitcpio.conf
```

В строке **HOOKS** важен порядок: **`keyboard` до `encrypt`**, есть **`encrypt`**, **нет `lvm2`**:

```
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

```bash
mkinitcpio -P
```

---

## 13. GRUB: ядро командной строки и os-prober

UUID **физического** раздела с LUKS (не mapper):

```bash
blkid /dev/nvme0n1p7
```

```bash
micro /etc/default/grub
```

Пример (подставьте свой UUID из строки `TYPE="crypto_LUKS"`):

```
GRUB_CMDLINE_LINUX="cryptdevice=UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@"
GRUB_DISABLE_OS_PROBER=false
```

Установка GRUB в **EFI Arch** (у вас смонтирован в `/boot`):

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch-GRUB --recheck
```

### Windows в меню GRUB

По [ArchWiki (GRUB)](https://wiki.archlinux.org/title/GRUB): для обнаружения Windows в UEFI нужно, чтобы был смонтирован EFI-раздел с `bootmgfw.efi`.

Из chroot (пример: Windows EFI = `p1`):

```bash
mkdir -p /win-efi
mount /dev/nvme0n1p1 /win-efi
ls /win-efi/EFI/Microsoft/Boot/bootmgfw.efi
os-prober
grub-mkconfig -o /boot/grub/grub.cfg
```

В выводе ожидаются строки вроде `Found Windows Boot Manager on ...`.

---

## 14. Сервисы перед первой перезагрузкой

```bash
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
```

Выход, размонтирование, закрытие LUKS:

```bash
exit
umount -R /mnt/win-efi 2>/dev/null
umount -R /mnt
cryptsetup close cryptroot
reboot
```

В меню UEFI выберите загрузочную запись **Arch-GRUB**. В GRUB проверьте **Windows**, затем **Arch**.

После входа в установленный Arch — Wi‑Fi, например `nmtui`, затем:

```bash
sudo pacman -Syu
```

---

## 15. Репозиторий ASUS Linux (`linux-g14`, `asusctl`)

Ключ и репозиторий (актуальная процедура — [asus-linux.org](https://asus-linux.org/)):

```bash
sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
```

Если ключ не качается с сервера:

```bash
wget "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8b15a6b0e9a3fa35" -O g14.sec
sudo pacman-key -a g14.sec
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
```

В конец `/etc/pacman.conf`:

```
[g14]
Server = https://arch.asus-linux.org
```

```bash
sudo pacman -Syu
sudo pacman -S asusctl power-profiles-daemon rog-control-center
sudo systemctl enable --now power-profiles-daemon.service
```

**Не** включайте `asusd` вручную — он поднимается через udev, как описано у ASUS Linux.

Ядро:

```bash
sudo pacman -S linux-g14 linux-g14-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg
reboot
```

Проверка:

```bash
uname -r
# в строке должно быть что-то вроде ...-g14...
```

Дальше в меню GRUB выбирайте пункт с **linux-g14** как основной для повседневной работы на G14.

---

## 16. NVIDIA (RTX) под `linux-g14`

Обычно используют **DKMS**-вариант драйвера:

```bash
sudo pacman -S --needed \
  nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime \
  vulkan-icd-loader lib32-vulkan-icd-loader mesa-utils
```

Сервисы сна / питания:

```bash
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service
sudo systemctl enable --now nvidia-powerd.service
```

```bash
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
reboot
```

Проверка:

```bash
nvidia-smi
prime-run glxinfo | grep "OpenGL renderer"
```

Если `nvidia-open-dkms` ведёт себя нестабильно:

```bash
sudo pacman -R nvidia-open-dkms
sudo pacman -S nvidia-dkms
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
reboot
```

**Важно:** не ставьте одновременно с этим конфликтующие стеки энергосбережения вроде **TLP** / **auto-cpufreq** без понимания рисков — для G14 разумная база: **asusctl + power-profiles-daemon**.

---

## 17. CUDA и инструменты для GPU-разработки

Ставить **после** того, как `nvidia-smi` стабильно работает на выбранном драйвере.

Минимально для разработки под NVIDIA на Arch (ветка `extra`):

```bash
sudo pacman -S --needed cuda cuda-tools
```

Опционально (нейросети, большие фреймворки):

```bash
sudo pacman -S --needed cudnn nccl
```

Проверка компилятора NVIDIA:

```bash
nvcc --version
```

Размер пакета `cuda` большой; при нехватке места смотрите [ArchWiki CUDA](https://wiki.archlinux.org/title/CUDA).

---

## 18. Установка BSPWM и dotfiles Zproger

База для X11 и билдера (часть пакетов билдер доустановит сам — см. `Builder/packages.py`):

```bash
sudo pacman -S xorg bspwm sxhkd xorg-xinit xterm git python3
```

Полезно сразу для ноутбука и HiDPI (часть может пересечься с билдером):

```bash
sudo pacman -S --needed \
  xorg-xrandr xorg-xsetroot xorg-xinput \
  picom polybar rofi dunst \
  kitty \
  thunar gvfs tumbler file-roller \
  firefox \
  nitrogen feh \
  brightnessctl pamixer playerctl pavucontrol \
  flameshot \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  ttf-jetbrains-mono-nerd ttf-font-awesome \
  unzip unrar zip
```

Клон репозитория (свой URL форка, если используете форк):

```bash
cd ~
git clone https://github.com/Zproger/bspwm-dotfiles.git
cd bspwm-dotfiles
```

Перед `install.py` откройте `Builder/packages.py`: не трогайте `BASE_PACKAGES` без необходимости. Для Ryzen G14 в `BASE_PACKAGES` уже указаны **`amd-ucode`** и драйверы **AMD** (amdgpu / vulkan-radeon). **`DEV_PACKAGES`** содержит только Obsidian, Python и пакеты **ASUS Linux** (`asusctl`, `power-profiles-daemon`, `rog-control-center`) — их ставит `pacman` из репозитория **`[g14]`**, поэтому блок `[g14]` в `/etc/pacman.conf` и ключ `pacman-key` нужно настроить **до** запуска пункта с dev-зависимостями. После установки dev-пакетов выполните: `sudo systemctl enable --now power-profiles-daemon.service`.

```bash
python3 Builder/install.py
```

После установки:

```bash
chmod +x ~/.config/bspwm/bspwmrc
```

### `~/.xinitrc`

```bash
micro ~/.xinitrc
```

```sh
#!/bin/sh
xrdb -merge ~/.Xresources 2>/dev/null
xrandr --dpi 144
exec bspwm
```

```bash
chmod +x ~/.xinitrc
startx
```

Если мешает стандартный `/etc/X11/xinit/xinitrc`, используйте свой `~/.xinitrc` как показано выше (или `startx ~/.xinitrc`).

---

## 19. HiDPI (QHD / 3K), touchpad, раскладка, мультимедиа-клавиши

### `~/.Xresources` (пример 2560×1600)

```
Xft.dpi: 144
Xft.autohint: 0
Xft.lcdfilter: lcddefault
Xft.hintstyle: hintslight
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
```

Для **2880×1800** часто пробуют `Xft.dpi: 168` или `192`.

В `~/.config/bspwm/bspwmrc` в начале (подставьте вывод `xrandr | grep connected`, часто `eDP-1`):

```sh
xrdb -merge ~/.Xresources
xrandr --dpi 144
xrandr --output eDP-1 --primary --rate 120
```

Для панели **165 Hz** замените `--rate 165`; на батарее можно снижать до `60`.

### Touchpad (`libinput`)

```bash
sudo mkdir -p /etc/X11/xorg.conf.d
sudo micro /etc/X11/xorg.conf.d/30-touchpad.conf
```

```
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "ClickMethod" "clickfinger"
    Option "AccelSpeed" "0.3"
EndSection
```

### Раскладка RU/EN

В `bspwmrc`:

```sh
setxkbmap -layout us,ru -option grp:alt_shift_toggle
```

### Клавиши в `~/.config/sxhkd/sxhkdrc`

Примеры:

```
XF86MonBrightnessUp
    brightnessctl set +5%

XF86MonBrightnessDown
    brightnessctl set 5%-

XF86AudioRaiseVolume
    pamixer -i 5

XF86AudioLowerVolume
    pamixer -d 5

XF86AudioMute
    pamixer -t

XF86AudioMicMute
    pamixer --default-source -t

XF86AudioPlay
    playerctl play-pause

XF86AudioNext
    playerctl next

XF86AudioPrev
    playerctl previous

Print
    flameshot gui

super + F7
    rog-control-center
```

```bash
pkill -USR1 -x sxhkd
```

### Polybar / Rofi / Kitty под DPI

В конфиге polybar: `dpi = 144`, высота и шрифты под экран. В `~/.config/rofi/config.rasi`: увеличенный `font`. В `~/.config/kitty/kitty.conf`: `font_family` и `font_size`.

---

## 20. Лимит заряда 80 % (по возможности)

```bash
asusctl --help | grep -i charge
asusctl -c 80
```

Или через sysfs, если доступно:

```bash
ls /sys/class/power_supply/BAT*/charge_control_end_threshold
```

Постоянная запись через `tmpfiles.d` — см. документацию `systemd-tmpfiles` и ваш индекс батареи (`BAT0` / `BAT1`).

---

## 21. Если Windows не появилась в GRUB

```bash
sudo pacman -S os-prober ntfs-3g
sudo mkdir -p /mnt/windows-efi
sudo mount /dev/nvme0n1p1 /mnt/windows-efi
ls /mnt/windows-efi/EFI/Microsoft/Boot/bootmgfw.efi
```

В `/etc/default/grub`: `GRUB_DISABLE_OS_PROBER=false`.

```bash
sudo os-prober
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Ручной `menuentry` в `/etc/grub.d/40_custom` — крайний случай; см. ArchWiki GRUB.

---

## 22. После обновлений ядра / NVIDIA / GRUB

При смене ядра, DKMS или `/etc/default/grub`:

```bash
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 23. Краткий чеклист

1. Windows: `powercfg /h off`, BitLocker key.
2. BIOS: Secure Boot off, UEFI, Hybrid GPU.
3. Arch ISO, сеть, время.
4. В свободной области: Arch EFI 1 ГиБ + раздел под LUKS.
5. `mkfs.fat` только на Arch EFI; LUKS + open `cryptroot`; Btrfs + подтома; монтирование.
6. `pacstrap` с `grub`, `efibootmgr`, `os-prober`, `cryptsetup`, `btrfs-progs`, `amd-ucode`.
7. `mkinitcpio`: `encrypt`, без `lvm2`.
8. `/etc/default/grub`: `cryptdevice=...`, `rootflags=subvol=@`, `GRUB_DISABLE_OS_PROBER=false`.
9. `grub-install` на Arch EFI → смонтировать Windows EFI → `os-prober` → `grub-mkconfig`.
10. Первый вход → репозиторий ASUS → `asusctl`, `linux-g14` → перезагрузка.
11. NVIDIA DKMS + сервисы → при необходимости CUDA/cudnn.
12. Xorg + BSPWM + `Builder/install.py`, HiDPI и sxhkd.

Удачной установки.
