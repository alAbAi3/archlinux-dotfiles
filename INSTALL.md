# Installation Guide

## Quick Install (Recommended)

Run this single command on your Arch Linux system:

```bash
git clone https://github.com/yourusername/archlinux-dotfiles.git ~/archlinux-dotfiles && cd ~/archlinux-dotfiles && chmod +x scripts/bootstrap.sh && ./scripts/bootstrap.sh
```

Then log out, select "Hyprland" from your login screen, and log back in.

## What the Bootstrap Script Does

The `bootstrap.sh` script is **fully automated** and handles everything:

### 1. Package Installation
- Automatically installs `yay` AUR helper if not present
- Installs all packages from `packages/packages-base.txt` (official repos)
- Installs all packages from `packages/packages-aur.txt` (AUR)
- Detects NVIDIA GPU and installs drivers automatically
- Installs required fonts (DejaVu, Liberation, Noto, FiraCode Nerd)

### 2. Configuration Setup
- Creates backup of existing configs at `~/.config_backup_TIMESTAMP/`
- Removes conflicting files
- Creates symlinks:
  - `~/.config/hypr` → `modules/hypr`
  - `~/.config/quickshell` → `modules/quickshell`
  - `~/.config/alacritty` → `modules/alacritty`
  - `~/.config/starship` → `modules/starship`
  - `~/.bashrc` → `modules/shell/.bashrc`
  - `~/.local/bin/*` → all scripts from `modules/scripts/`

### 3. Environment Initialization
- Creates all cache directories:
  - `~/.cache/rice/`
  - `~/.cache/swww/`
  - `~/.cache/quickshell/`
  - `~/.cache/wal/`
- Initializes state files:
  - `active_workspace.txt` (workspace tracking)
  - `taskbar_commands.txt` (button click commands)
  - `rice.log` (main log file)

### 4. Theme Setup
- Generates initial pywal color scheme from first wallpaper
- Creates `Colors.qml` for QuickShell theming
- Configures Alacritty terminal colors
- Sets initial wallpaper with swww

### 5. Service Management
- Enables and starts PipeWire audio services
- Rebuilds font cache
- Makes all scripts executable
- Verifies critical packages installed correctly

## Manual Installation (Not Recommended)

If you need to install manually:

### Step 1: Install Base Packages
```bash
sudo pacman -S --needed - < packages/packages-base.txt
```

### Step 2: Install yay
```bash
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
```

### Step 3: Install AUR Packages
```bash
yay -S --needed - < packages/packages-aur.txt
```

### Step 4: Link Configs
```bash
mkdir -p ~/.config ~/.local/bin
ln -sf ~/archlinux-dotfiles/modules/hypr ~/.config/hypr
ln -sf ~/archlinux-dotfiles/modules/quickshell ~/.config/quickshell
ln -sf ~/archlinux-dotfiles/modules/alacritty ~/.config/alacritty
ln -sf ~/archlinux-dotfiles/modules/starship ~/.config/starship
ln -sf ~/archlinux-dotfiles/modules/shell/.bashrc ~/.bashrc

# Link all scripts
for script in ~/archlinux-dotfiles/modules/scripts/*.sh; do
    ln -sf "$script" ~/.local/bin/
done
```

### Step 5: Initialize Environment
```bash
mkdir -p ~/.cache/rice ~/.cache/swww ~/.cache/quickshell ~/.cache/wal
echo "1" > ~/.cache/rice/active_workspace.txt
touch ~/.cache/rice/taskbar_commands.txt
touch ~/.cache/rice/rice.log
```

### Step 6: Set Up Theme
```bash
wal -i ~/archlinux-dotfiles/Wallpapers/<your-wallpaper>.jpg
bash ~/.local/bin/apply-theme.sh
```

### Step 7: Enable Services
```bash
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber
```

## Verifying Installation

After installation, check that everything is set up:

```bash
# Check symlinks
ls -la ~/.config/hypr
ls -la ~/.config/quickshell

# Check scripts
ls -la ~/.local/bin/*.sh

# Check state files
ls -la ~/.cache/rice/

# Check if packages are installed
which hyprland quickshell swww wal alacritty

# Check audio
systemctl --user status pipewire
```

## Troubleshooting Installation

### "Permission denied" errors
```bash
chmod +x scripts/bootstrap.sh
chmod +x modules/scripts/*.sh
```

### "Package not found" errors
```bash
# Update package databases
sudo pacman -Syu
yay -Syu
```

### "yay: command not found"
The bootstrap script will install yay automatically. If it fails:
```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
```

### Symlinks not working
```bash
# Remove old configs first
rm -rf ~/.config/hypr ~/.config/quickshell ~/.config/alacritty
# Then re-run bootstrap or create symlinks manually
```

## Post-Installation

Once installed:

1. **Log out** of your current session
2. At the login screen, select **Hyprland** as your session
3. **Log in**
4. Press `Super + Space` to test the app launcher
5. Press `Super + Q` to open a terminal
6. Check `~/.cache/rice/rice.log` for any errors

Enjoy your rice! 🍚
