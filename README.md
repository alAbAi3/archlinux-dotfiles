# Arch Linux Hyprland Rice

A fully automated, beautiful Hyprland rice setup featuring QuickShell panels, pywal theming, and workspace management.

## Features

- 🎨 **Automatic theming** with pywal - colors extracted from wallpapers
- 🖥️ **Custom taskbar** with workspace indicators, volume, battery, and clock
- 🚀 **App launcher** with fuzzy search
- 🎴 **Wallpaper manager** with swww integration
- 🎹 **5 workspaces** with smooth switching and indicators
- 🎵 **PipeWire audio** with volume controls
- ⚡ **Zero manual configuration** - run bootstrap.sh and you're done!

## Prerequisites

- Fresh Arch Linux installation
- Internet connection
- User account with sudo privileges

## One-Command Installation

```bash
git clone https://github.com/yourusername/archlinux-dotfiles.git
cd archlinux-dotfiles
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

That's it! The script will:
1. ✅ Install yay AUR helper (if not present)
2. ✅ Install all required packages (Hyprland, QuickShell, fonts, etc.)
3. ✅ Install NVIDIA drivers (if NVIDIA GPU detected)
4. ✅ Backup your existing configs
5. ✅ Symlink all dotfiles to correct locations
6. ✅ Initialize pywal theme from your wallpapers
7. ✅ Set up all state files and directories
8. ✅ Enable audio services (PipeWire)
9. ✅ Make all scripts executable

## After Installation

1. **Log out** of your current session
2. Select **"Hyprland"** from your display manager
3. **Log in** and enjoy your rice!

## Keybindings

| Key Combo | Action |
|-----------|--------|
| `Super + Q` | Open terminal (Alacritty) |
| `Super + Space` | Open app launcher |
| `Super + 1-5` | Switch to workspace 1-5 |
| `Super + D` | Next workspace |
| `Super + A` | Previous workspace |
| `Super + Tab` | Wallpaper changer |
| `Super + C` | Close window |
| `Super + M` | Exit Hyprland |
| `Super + E` | File manager |
| `Super + V` | Toggle floating |

## Customization

### Change Theme

```bash
# Apply new theme from wallpaper
wal -i ~/path/to/wallpaper.jpg
apply-theme.sh
```

### Add Wallpapers

Simply add `.jpg` or `.png` files to the `Wallpapers/` directory. They'll appear in the wallpaper changer (`Super + Tab`).

### Modify Keybindings

Edit `~/.config/hypr/hyprland.conf` and restart Hyprland.

## Project Structure

```
archlinux-dotfiles/
├── modules/
│   ├── hypr/              # Hyprland configuration
│   ├── quickshell/        # QuickShell QML components
│   │   ├── taskbar/       # Taskbar widgets
│   │   ├── launcher/      # App launcher
│   │   └── theme/         # Color theme
│   ├── alacritty/         # Terminal config
│   ├── scripts/           # Helper scripts
│   └── shell/             # Bash configuration
├── packages/
│   ├── packages-base.txt  # Official repo packages
│   └── packages-aur.txt   # AUR packages
├── scripts/
│   └── bootstrap.sh       # Main installation script
└── Wallpapers/            # Your wallpapers
```

## Troubleshooting

### Check Logs

```bash
# All rice scripts log here (centralized logging)
tail -f ~/.cache/rice/rice.log

# Hyprland logs
cat ~/.cache/hyprland/hyprland.log

# Run diagnostic script
debug-rice.sh
```

### App launcher not working?

```bash
# Manually restart the command executor
pkill -f taskbar-command-executor
taskbar-command-executor.sh &
```

### No audio?

```bash
# Restart audio services
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Theme not applying?

```bash
# Manually regenerate theme
wal -i ~/Pictures/Wallpapers/yourwallpaper.jpg
apply-theme.sh
```

### Taskbar not showing?

```bash
# Restart QuickShell
pkill quickshell
quickshell &
```

## Architecture

This rice follows a modular architecture with clear separation:

- **QML Components**: Self-contained UI widgets
- **Shell Scripts**: Data providers and command executors
- **State Files**: Simple text files for inter-process communication
- **Environment Variables**: Enable QML file reading and Wayland support

See `ARCHITECTURE.md` for detailed design documentation.

## Contributing

Feel free to open issues or pull requests for improvements!

## License

MIT License - feel free to use and modify as you wish.

## Credits

- Built with [Hyprland](https://hyprland.org/)
- UI powered by [QuickShell](https://outfoxxed.me/quickshell/)
- Colors by [pywal](https://github.com/dylanaraps/pywal)
- Wallpaper daemon: [swww](https://github.com/Horus645/swww)

---

**Enjoy your rice! 🍚**
