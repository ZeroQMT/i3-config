# 🪟 i3-config — Hướng dẫn cài đặt từ A–Z

> Dotfiles của **ZeroQMT** — bộ cấu hình đầy đủ cho môi trường desktop tiling trên Linux, bao gồm i3wm, ghostty, st, tmux, neovim, zsh và picom.

---

## 📋 Mục lục

1. [Tổng quan](#tổng-quan)
2. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
3. [Cài đặt các gói phụ thuộc](#cài-đặt-các-gói-phụ-thuộc)
4. [Clone repo và triển khai dotfiles](#clone-repo-và-triển-khai-dotfiles)
5. [Cấu hình i3wm](#cấu-hình-i3wm)
6. [Cấu hình Ghostty (terminal chính)](#cấu-hình-ghostty-terminal-chính)
7. [Cấu hình st (terminal phụ)](#cấu-hình-st-terminal-phụ)
8. [Cấu hình Tmux](#cấu-hình-tmux)
9. [Cấu hình Zsh](#cấu-hình-zsh)
10. [Cấu hình Neovim](#cấu-hình-neovim)
11. [Cấu hình Picom (compositor)](#cấu-hình-picom-compositor)
12. [Cấu hình Font](#cấu-hình-font)
13. [Wallpaper & Scripts](#wallpaper--scripts)
14. [Bảng phím tắt i3](#bảng-phím-tắt-i3)
15. [Bảng phím tắt Tmux](#bảng-phím-tắt-tmux)
16. [Bảng phím tắt Neovim](#bảng-phím-tắt-neovim)
17. [Troubleshooting](#troubleshooting)

---

## Tổng quan

Repo này chứa bộ dotfiles hoàn chỉnh cho một desktop Linux tiling:

| Thư mục | Mô tả |
|---------|-------|
| `i3/` | Cấu hình i3 window manager |
| `ghostty/` | Ghostty terminal emulator |
| `st/` | st (simple terminal) — source + patch |
| `tmux/` | Tmux multiplexer |
| `zsh/` | Zsh shell với prompt tùy chỉnh |
| `vimpack/` | Neovim config (Lua) |
| `picom/` | Picom compositor (shadow, opacity) |
| `fontconfig/` | Font fallback system-wide |
| `Scripts/` | Shell scripts hỗ trợ (wallpaper, screenshot, status) |
| `Wall/` | Bộ sưu tập wallpaper |
| `book/` | Tài liệu tham khảo về bảo mật / Python |

**Stack công nghệ:**
- Window manager: **i3wm** với gaps
- Status bar: **bumblebee-status** (theme iceberg)
- Terminal chính: **Ghostty** (font BlexMono Nerd Font)
- Terminal phụ: **st** (biên dịch từ source)
- Shell: **Zsh** + zoxide + fzf + eza
- Multiplexer: **Tmux** (prefix: `Ctrl+A`)
- Editor: **Neovim** (config Lua)
- Launcher: **Rofi**
- Compositor: **Picom**
- Wallpaper: **feh**
- Screenshot: **maim** + **xclip**
- Input method: **fcitx5**

---

## Yêu cầu hệ thống

- Distro Linux có X11 (Arch Linux, Debian, Ubuntu, Manjaro, v.v.)
- Display server: **X11** (không phải Wayland)
- Đã đăng nhập và có thể chạy terminal

---

## Cài đặt các gói phụ thuộc

### Arch Linux / Manjaro

```bash
sudo pacman -S \
  i3-wm i3status i3lock \
  rofi feh picom dunst \
  maim xclip xdotool \
  ghostty \
  tmux zsh \
  neovim \
  fcitx5 fcitx5-gtk fcitx5-qt \
  dex xss-lock network-manager-applet \
  pulseaudio-utils \
  terminus-font \
  eza bat fzf zoxide \
  zsh-syntax-highlighting zsh-autosuggestions
```

Cài **bumblebee-status** (status bar):

```bash
pip install bumblebee-status
# hoặc
yay -S bumblebee-status
```

Cài font **BlexMono Nerd Font** (dùng trong Ghostty):

```bash
yay -S ttf-blex-nerd-font
# hoặc tải từ: https://www.nerdfonts.com/font-downloads
```

### Debian / Ubuntu

```bash
sudo apt install \
  i3 rofi feh picom dunst \
  maim xclip xdotool \
  tmux zsh neovim \
  fcitx5 \
  dex xss-lock network-manager-gnome \
  pulseaudio-utils \
  xfonts-terminus \
  bat fzf

# eza (thay thế ls)
sudo apt install eza || cargo install eza

# zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# zsh plugins
sudo apt install zsh-syntax-highlighting zsh-autosuggestions
```

> **Ghostty trên Debian/Ubuntu:** Ghostty chưa có trong repo chính thức. Tải từ https://ghostty.org hoặc dùng `st` làm terminal thay thế.

---

## Clone repo và triển khai dotfiles

```bash
# Clone về home
git clone https://github.com/ZeroQMT/i3-config.git ~/i3-config
cd ~/i3-config
```

### Triển khai từng phần

#### i3

```bash
mkdir -p ~/.config/i3
cp i3/config ~/.config/i3/config
```

> **Lưu ý quan trọng:** File config có hardcode đường dẫn `/home/qmt/`. Bạn **phải** đổi thành username của mình:

```bash
sed -i 's|/home/qmt|/home/YOUR_USERNAME|g' ~/.config/i3/config
```

#### Ghostty

```bash
mkdir -p ~/.config/ghostty
cp -r ghostty/ghostty/* ~/.config/ghostty/
```

#### Tmux

```bash
mkdir -p ~/.config/tmux/scripts
cp tmux/.tmux.conf ~/.config/tmux/tmux.conf
# hoặc đặt ở home:
cp tmux/.tmux.conf ~/.tmux.conf

# Copy scripts hỗ trợ
cp Scripts/scripts/* ~/.config/tmux/scripts/
chmod +x ~/.config/tmux/scripts/*.sh
```

#### Zsh

```bash
cp zsh/.zshrc ~/.zshrc
```

Sau đó đặt Zsh làm shell mặc định:

```bash
chsh -s $(which zsh)
```

Đăng xuất và đăng nhập lại để Zsh có hiệu lực.

#### Neovim

```bash
mkdir -p ~/.config/nvim
cp vimpack/init.lua ~/.config/nvim/init.lua
```

#### Picom

```bash
mkdir -p ~/.config/picom
cp picom/picom.conf ~/.config/picom/picom.conf
```

#### Font config

```bash
mkdir -p ~/.config/fontconfig
cp fontconfig/fonts.conf ~/.config/fontconfig/fonts.conf
fc-cache -fv
```

#### Scripts

```bash
mkdir -p ~/Scripts
cp Scripts/random_wallpaper.sh ~/Scripts/
cp Scripts/screenshot.sh ~/Scripts/
chmod +x ~/Scripts/*.sh
```

#### Wallpaper

```bash
cp -r Wall ~/Wall
```

---

## Cấu hình i3wm

File chính: `~/.config/i3/config`

### Những điểm quan trọng cần biết

**Mod key:** `Super` (phím Windows)

**Gaps:**
```
gaps inner 10   # khoảng cách giữa các cửa sổ: 10px
gaps outer 10   # khoảng cách với cạnh màn hình: 10px
```

**Font:** `Terminus 12` — font mặc định cho title bar.

**Startup tự động:**
- `dex` — chạy các file `.desktop` khi khởi động
- `xss-lock` + `i3lock` — khóa màn hình khi sleep
- `nm-applet` — system tray cho NetworkManager
- `feh` — đặt wallpaper mặc định (`Wall/core/anime_girl_on_blue_background.png`)
- `fcitx5` — input method (gõ tiếng Việt/Nhật/v.v.)
- `lookapp` — app tra cứu nhanh (floating)

**Status bar:** `bumblebee-status` với các module: cpu, memory, battery, time, volume. Theme **iceberg**.

**Màu sắc:** Palette Dracula (tím/xanh).

### Tùy chỉnh sau khi cài

Nếu không cần `fcitx5`, comment hoặc xóa dòng:
```
exec --no-startup-id fcitx5 -d
```

Nếu không có `lookapp`, comment dòng:
```
exec --no-startup-id lookapp
for_window [class="lookapp"] floating enable, border none
```

Nếu muốn bật picom (compositor), bỏ comment dòng:
```
#exec_always picom --config ~/.config/picom.conf
```

---

## Cấu hình Ghostty (terminal chính)

File: `~/.config/ghostty/config.ghostty`

| Cài đặt | Giá trị |
|---------|---------|
| Font | BlexMono Nerd Font Mono, size 16 |
| Background | `#11111B` (Catppuccin Mocha) |
| Opacity | 0.98 (gần như đục) |
| Theme | Kanagawa Wave |
| Shader | cursor animation (`shaders/cursor.glsl`) |
| Titlebar | Ẩn hoàn toàn |

Để thay đổi font size, sửa:
```
font-size = 16
```

Để thay đổi theme, sửa:
```
theme = "Kanagawa Wave"
```
Các theme có sẵn trong `~/.config/ghostty/themes/`: `rosepine`, `rosepine-custom`, `tokyonight`.

---

## Cấu hình st (terminal phụ)

`st` (simple terminal) được đặt sẵn source trong thư mục `st/`. Phải **biên dịch** mới dùng được.

### Cài dependencies build

```bash
# Arch
sudo pacman -S base-devel libxft harfbuzz

# Debian/Ubuntu
sudo apt install build-essential libxft-dev libharfbuzz-dev
```

### Biên dịch và cài

```bash
cd ~/i3-config/st
sudo make clean install
```

Binary `st` sẽ được cài vào `/usr/local/bin/st`.

Để tùy chỉnh màu sắc, font... sửa file `config.h` trước khi `make`.

---

## Cấu hình Tmux

File: `~/.config/tmux/tmux.conf` (hoặc `~/.tmux.conf`)

### Điểm khác biệt so với mặc định

| Cài đặt | Giá trị |
|---------|---------|
| Prefix | `Ctrl+A` (thay vì `Ctrl+B`) |
| Index window | Bắt đầu từ 1 (không phải 0) |
| Navigation pane | Vim-style (h/j/k/l) |
| Copy mode | Vi-keys |
| Split ngang | `prefix + v` |
| Split dọc | `prefix + s` |
| Status bar | Bên dưới, hiển thị session + music + weather + todo |

### Scripts kèm theo

| Script | Chức năng |
|--------|-----------|
| `status.sh` | Hiển thị nhạc đang phát, thời tiết (cache), todo |
| `info-popup.sh` | Popup thông tin hệ thống (`prefix + i`) |
| `music-timer.sh` | Chọn và phát nhạc qua popup |
| `music-status.sh` | Trạng thái bài nhạc |
| `weather-cache.sh` | Cache dữ liệu thời tiết |
| `todo-parse.sh` | Parse file todo hiển thị trên status bar |

### Khởi động Tmux

```bash
tmux        # session mới
tmux a      # attach session cũ
```

---

## Cấu hình Zsh

File: `~/.zshrc`

### Prompt

Prompt có 2 dòng, hiển thị:
- Username trong box màu tím nhạt
- Thư mục hiện tại
- Nhánh Git hiện tại (nếu đang trong git repo)

### Alias quan trọng

| Alias | Lệnh thực |
|-------|-----------|
| `ls` | `eza --long --icons --color` |
| `vim` | `nvim` |
| `bat` | `bat --theme="Solarized (dark)"` |
| `tmux` | `tmux -u` (unicode mode) |
| `cl` | `clear` |
| `py` | `python3` |
| `serve` | `python -m http.server` (web server nhanh) |
| `ktm` | `tmux kill-server` |
| `g` | `git init` |
| `gcm` | `git commit -m` |
| `gadd` | `git add .` |
| `gpush` | `git push -u origin main` |
| `zsh` | `source ~/.zshrc` (reload config) |
| `chill` | `rmpc` (music player) |
| `tree` | `tree -L 3 -a -I '.git'` |

### Function đặc biệt

`se` — Tìm và mở file bằng fzf + bat preview:

```bash
se   # gõ lệnh này, một bảng fuzzy search hiện ra
     # dùng Ctrl+D / Ctrl+U để cuộn preview
     # Enter để mở file bằng nvim
```

### Plugins Zsh cần cài

```bash
# Arch
sudo pacman -S zsh-syntax-highlighting zsh-autosuggestions

# Debian/Ubuntu
sudo apt install zsh-syntax-highlighting zsh-autosuggestions
```

Nếu plugins ở đường dẫn khác, sửa cuối file `.zshrc`:
```bash
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
```

### Tools cần cài để .zshrc hoạt động đầy đủ

```bash
# zoxide (cd thông minh)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# fzf (fuzzy finder)
sudo pacman -S fzf   # Arch
sudo apt install fzf # Debian

# eza (ls đẹp hơn)
sudo pacman -S eza
# hoặc: cargo install eza
```

---

## Cấu hình Neovim

File: `~/.config/nvim/init.lua`

### Cài đặt mặc định

| Tùy chọn | Giá trị |
|----------|---------|
| Line numbers | Tuyệt đối + tương đối |
| Tab size | 4 spaces |
| Scroll offset | 10 dòng |
| Clipboard | Chia sẻ với hệ thống |
| Undo file | Lưu undo history vĩnh viễn (`~/.vim/undodir`) |
| Color column | 98 (giới hạn Black formatter) |
| Fold | Dùng treesitter |

### Keymaps Neovim (Leader = Space)

| Phím | Chức năng |
|------|-----------|
| `<Space>c` | Xóa highlight search |
| `n / N` | Next/Prev result (căn giữa màn hình) |
| `Ctrl+D/U` | Scroll nửa trang (căn giữa) |
| `Ctrl+H/J/K/L` | Di chuyển giữa các split |
| `Alt+J/K` | Di chuyển dòng lên/xuống |
| `< >` (visual) | Indent giữ nguyên selection |
| `<Space>d` | Xem diagnostics dòng hiện tại |
| `<Space>nd` | Lỗi tiếp theo |
| `<Space>pd` | Lỗi trước đó |
| `<Space>rm` | Toggle render markdown |

---

## Cấu hình Picom (compositor)

File: `~/.config/picom/picom.conf`

Picom được **tắt mặc định** trong i3 config (dòng bị comment). Để bật:

```bash
# Trong ~/.config/i3/config, bỏ comment:
exec_always picom --config ~/.config/picom.conf
```

Cấu hình hiện tại dùng backend `xrender` với shadow nhẹ (radius 8). Để bật blur và hiệu ứng góc bo:

```
backend = "glx";
corner-radius = 8;
blur:
{
  method = "dual_kawase";
  strength = 2;
};
blur-background = true;
```

---

## Cấu hình Font

File: `~/.config/fontconfig/fonts.conf`

Cấu hình fallback font cho toàn hệ thống:

| Loại | Font ưu tiên |
|------|-------------|
| Serif | Libertinus Serif → Noto Serif |
| Sans-serif | Libertinus Sans → Noto Sans |
| Monospace | FiraCode Nerd Font → Noto Sans |
| Emoji | Noto Color Emoji → Joy Pixels |

Để áp dụng:
```bash
fc-cache -fv
```

---

## Wallpaper & Scripts

### Wallpaper mặc định

i3 tự động đặt wallpaper khi khởi động:
```
exec_always feh --bg-fill $HOME/Wall/core/anime_girl_on_blue_background.png
```

Bạn có thể đổi đường dẫn này thành bất kỳ ảnh nào.

### Đổi wallpaper ngẫu nhiên

Phím tắt: `Super + Shift + W`

Script `~/Scripts/random_wallpaper.sh` sẽ chọn ngẫu nhiên một ảnh trong `~/Wall/core/`.

Để thêm ảnh vào pool:
```bash
cp your_image.jpg ~/Wall/core/
```

Để thay đổi thư mục pool, sửa trong script:
```bash
WALLPAPER_DIR="$HOME/Wall/core/"
```

### Screenshot

| Phím tắt | Chức năng |
|----------|-----------|
| `Print` | Chụp toàn màn hình |
| `Shift + Print` | Chụp vùng chọn (click & drag) |
| `Ctrl + Print` | Chụp cửa sổ đang focus |

Ảnh được lưu vào `~/Pictures/Screenshots/` và tự copy vào clipboard.

**Dependencies:**
```bash
sudo pacman -S maim xclip xdotool libnotify
# hoặc
sudo apt install maim xclip xdotool libnotify-bin
```

---

## Bảng phím tắt i3

> `$mod` = phím **Super** (Windows key)

### Cơ bản

| Phím tắt | Chức năng |
|----------|-----------|
| `$mod + Enter` | Mở Ghostty terminal |
| `$mod + Shift + Enter` | Mở st terminal |
| `$mod + Q` | Đóng cửa sổ đang focus |
| `$mod + D` | Mở Rofi launcher |
| `$mod + Shift + C` | Reload i3 config |
| `$mod + Shift + R` | Restart i3 |
| `$mod + Shift + E` | Thoát i3 |

### Di chuyển focus

| Phím tắt | Chức năng |
|----------|-----------|
| `$mod + J` hoặc `←` | Focus sang trái |
| `$mod + K` hoặc `↓` | Focus xuống |
| `$mod + L` hoặc `↑` | Focus lên |
| `$mod + ;` hoặc `→` | Focus sang phải |
| `$mod + A` | Focus container cha |

### Di chuyển cửa sổ

| Phím tắt | Chức năng |
|----------|-----------|
| `$mod + Shift + J/←` | Di chuyển cửa sổ sang trái |
| `$mod + Shift + K/↓` | Di chuyển cửa sổ xuống |
| `$mod + Shift + L/↑` | Di chuyển cửa sổ lên |
| `$mod + Shift + ;/→` | Di chuyển cửa sổ sang phải |

### Layout

| Phím tắt | Chức năng |
|----------|-----------|
| `$mod + H` | Split ngang |
| `$mod + V` | Split dọc |
| `$mod + F` | Toàn màn hình |
| `$mod + S` | Layout stack |
| `$mod + W` | Layout tabbed |
| `$mod + E` | Layout split (toggle) |
| `$mod + Shift + Space` | Toggle floating |
| `$mod + Space` | Chuyển focus floating/tiling |

### Workspace

| Phím tắt | Chức năng |
|----------|-----------|
| `$mod + 1-0` | Chuyển sang workspace 1–10 |
| `$mod + Shift + 1-0` | Di chuyển cửa sổ sang workspace 1–10 |

### Resize

| Phím tắt | Chức năng |
|----------|-----------|
| `$mod + R` | Vào resize mode |
| `J/←` (trong resize) | Thu nhỏ chiều rộng |
| `; /→` (trong resize) | Mở rộng chiều rộng |
| `K/↓` (trong resize) | Mở rộng chiều cao |
| `L/↑` (trong resize) | Thu nhỏ chiều cao |
| `Enter/Escape` | Thoát resize mode |

### Tiện ích

| Phím tắt | Chức năng |
|----------|-----------|
| `$mod + Shift + W` | Đổi wallpaper ngẫu nhiên |
| `Print` | Chụp toàn màn hình |
| `Shift + Print` | Chụp vùng chọn |
| `Ctrl + Print` | Chụp cửa sổ |
| `XF86AudioRaiseVolume` | Tăng âm lượng 10% |
| `XF86AudioLowerVolume` | Giảm âm lượng 10% |
| `XF86AudioMute` | Tắt/bật âm |
| `XF86AudioMicMute` | Tắt/bật mic |

---

## Bảng phím tắt Tmux

> Prefix = `Ctrl + A`

### Session / Window

| Phím tắt | Chức năng |
|----------|-----------|
| `Prefix + c` | Window mới (cùng thư mục) |
| `Prefix + C` | Window mới (từ home) |
| `Prefix + ←/→` | Hoán đổi vị trí window |
| `Prefix + i` | Popup thông tin hệ thống |
| `Prefix + m` | Popup music picker |

### Pane

| Phím tắt | Chức năng |
|----------|-----------|
| `Prefix + v` | Split dọc (vertical) |
| `Prefix + s` | Split ngang (horizontal) |
| `Prefix + h/j/k/l` | Di chuyển giữa pane |

### Copy mode (Vi-style)

| Phím tắt | Chức năng |
|----------|-----------|
| `Prefix + [` | Vào copy mode |
| `v` | Bắt đầu chọn |
| `V` | Chọn cả dòng |
| `Ctrl+V` | Chọn block |
| `y` | Copy selection |
| `q/Escape` | Thoát copy mode |

### Nested session

| Phím tắt | Chức năng |
|----------|-----------|
| `F12` | Toggle OFF mode (cho nested tmux) |

---

## Bảng phím tắt Neovim

> Leader = `Space`

| Phím tắt | Chức năng |
|----------|-----------|
| `Space + c` | Xóa highlight |
| `Ctrl+H/J/K/L` | Di chuyển split |
| `Alt+J/K` | Di chuyển dòng |
| `Space+d` | Diagnostics |
| `Space+nd` | Lỗi tiếp theo |
| `Space+pd` | Lỗi trước |
| `Space+rm` | Toggle markdown render |

---

## Troubleshooting

### i3 không khởi động / crash

```bash
# Kiểm tra lỗi config
i3 -C ~/.config/i3/config

# Xem log
journalctl -xe | grep i3
```

### bumblebee-status không hiển thị

```bash
# Kiểm tra cài đặt
which bumblebee-status
# Nếu không tìm thấy:
pip install bumblebee-status --user
```

### Ghostty không chạy

Thử dùng st làm terminal mặc định, sửa trong i3 config:
```
bindsym $mod+Return exec st
```

### Zsh plugins không tải

Kiểm tra đường dẫn thực tế trên hệ thống:
```bash
find /usr -name "zsh-syntax-highlighting.zsh" 2>/dev/null
find /usr -name "zsh-autosuggestions.zsh" 2>/dev/null
```
Sửa tương ứng trong `~/.zshrc`.

### Screenshot không hoạt động

```bash
sudo pacman -S maim xclip xdotool libnotify
# Tạo thư mục lưu ảnh:
mkdir -p ~/Pictures/Screenshots
```

### fcitx5 không gõ được tiếng Việt

Thêm vào `~/.profile` hoặc `~/.xprofile`:
```bash
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
fcitx5 -d &
```

### Font bị thiếu / icon không hiển thị

```bash
# Cài Nerd Fonts
yay -S ttf-nerd-fonts-symbols nerd-fonts-complete
# hoặc tải manual từ https://www.nerdfonts.com

# Rebuild font cache
fc-cache -fv
```

### Wallpaper không đổi với `$mod+Shift+W`

```bash
# Kiểm tra thư mục có ảnh chưa
ls ~/Wall/core/

# Chạy thử script
~/Scripts/random_wallpaper.sh
```

---

## Cấu trúc thư mục sau khi deploy

```
~
├── .config/
│   ├── i3/config
│   ├── ghostty/
│   │   ├── config.ghostty
│   │   ├── shaders/cursor.glsl
│   │   └── themes/
│   ├── tmux/
│   │   ├── tmux.conf
│   │   └── scripts/
│   ├── nvim/init.lua
│   ├── picom/picom.conf
│   └── fontconfig/fonts.conf
├── .zshrc
├── Scripts/
│   ├── random_wallpaper.sh
│   └── screenshot.sh
└── Wall/
    ├── core/          ← pool ảnh ngẫu nhiên
    ├── wallpaper/
    ├── wallpp/
    └── walls/
```

---

*README này được tạo dựa trên phân tích toàn bộ source code tại [ZeroQMT/i3-config](https://github.com/ZeroQMT/i3-config).*
