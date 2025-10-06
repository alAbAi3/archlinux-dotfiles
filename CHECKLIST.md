# Post-Installation Checklist

Use this checklist after running `bootstrap.sh` to verify everything works correctly.

## ✅ Pre-Hyprland Checks (Before Logging In)

Run these from a TTY or existing session:

- [ ] Bootstrap script completed without errors
- [ ] `~/.config/hypr` symlink exists: `ls -la ~/.config/hypr`
- [ ] `~/.config/quickshell` symlink exists: `ls -la ~/.config/quickshell`
- [ ] Scripts are in PATH: `ls -la ~/.local/bin/*.sh`
- [ ] Cache directory exists: `ls -la ~/.cache/rice/`
- [ ] Colors.qml exists: `cat ~/.config/quickshell/theme/Colors.qml`
- [ ] Packages installed: `which hyprland quickshell swww wal alacritty`
- [ ] Audio services enabled: `systemctl --user status pipewire`

## ✅ First Login Checks

After logging into Hyprland for the first time:

### Visual Elements
- [ ] Wallpaper is displayed (not black screen)
- [ ] Taskbar visible at top of screen
- [ ] Clock shows current time in taskbar
- [ ] 5 workspace circles visible in taskbar
- [ ] Settings gear icon visible in taskbar
- [ ] Volume icon visible in taskbar
- [ ] Battery icon visible in taskbar (if laptop)

### Keyboard Shortcuts
- [ ] `Super + Q` - Terminal opens (Alacritty)
- [ ] `Super + Space` - App launcher appears
- [ ] `Super + 1` - Switches to workspace 1
- [ ] `Super + 2` - Switches to workspace 2
- [ ] `Super + 3` - Switches to workspace 3
- [ ] `Super + 4` - Switches to workspace 4
- [ ] `Super + 5` - Switches to workspace 5
- [ ] `Super + D` - Cycles to next workspace
- [ ] `Super + A` - Cycles to previous workspace
- [ ] `Super + C` - Closes active window
- [ ] `Super + Tab` - Wallpaper changer opens

### Interactive Elements
- [ ] Click workspace circle - switches workspace
- [ ] Click settings icon - app launcher opens
- [ ] Click app in launcher - app starts
- [ ] Search in launcher - filters apps correctly
- [ ] Press Enter in launcher - launches first app
- [ ] Press Escape in launcher - closes launcher

### Audio
- [ ] Volume icon shows current volume level
- [ ] Volume changes when using media keys
- [ ] Can play audio in any application
- [ ] Microphone works (test in Discord/etc)

### Window Management
- [ ] Windows tile automatically
- [ ] Can drag windows with `Super + Left Click`
- [ ] Can resize windows with `Super + Right Click`
- [ ] `Super + V` toggles floating mode
- [ ] Windows open on current workspace (not random ones)

## ✅ Theme System Checks

- [ ] Terminal colors match wallpaper theme
- [ ] Taskbar colors match wallpaper theme
- [ ] Launcher colors match wallpaper theme
- [ ] Can change theme: `apply-theme.sh ~/Pictures/someimage.jpg`
- [ ] New theme applies to all components

## 🐛 Debugging Commands

If something doesn't work, check these logs:

```bash
# Main QuickShell log
cat ~/.cache/rice/rice.log

# Command executor log (for button clicks)
cat ~/.cache/rice/command-executor.log

# Hyprland log
cat ~/.cache/hyprland/hyprland.log

# Check running processes
ps aux | grep -E "quickshell|swww|pipewire|command-executor|update-volume"

# Check workspace state
cat ~/.cache/rice/active_workspace.txt

# Check volume state
cat /tmp/rice_volume.txt
```

## 🔧 Common Fixes

### App Launcher Not Opening
```bash
pkill -f taskbar-command-executor
taskbar-command-executor.sh &
```

### Taskbar Not Showing
```bash
pkill quickshell
quickshell >> ~/.cache/rice/rice.log 2>&1 &
```

### No Audio
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Volume Widget Shows 0%
```bash
pkill -f update-volume
update-volume.sh &
```

### Workspace Indicators Not Updating
```bash
echo "1" > ~/.cache/rice/active_workspace.txt
# Then switch workspaces with Super + 1-5
```

### Theme Not Applying
```bash
wal -i ~/Pictures/Wallpapers/yourwallpaper.jpg
apply-theme.sh
pkill quickshell
quickshell &
```

## 📝 Expected File Structure

Your home directory should look like this after installation:

```
~/.config/
├── hypr/ -> ~/archlinux-dotfiles/modules/hypr/
├── quickshell/ -> ~/archlinux-dotfiles/modules/quickshell/
│   └── theme/
│       └── Colors.qml (generated file)
├── alacritty/ -> ~/archlinux-dotfiles/modules/alacritty/
└── starship/ -> ~/archlinux-dotfiles/modules/starship/

~/.local/bin/
├── apply-theme.sh -> ~/archlinux-dotfiles/modules/scripts/apply-theme.sh
├── taskbar-command-executor.sh -> ~/archlinux-dotfiles/modules/scripts/taskbar-command-executor.sh
├── toggle-launcher.sh -> ~/archlinux-dotfiles/modules/scripts/toggle-launcher.sh
├── update-volume.sh -> ~/archlinux-dotfiles/modules/scripts/update-volume.sh
└── ... (other scripts)

~/.cache/rice/
├── active_workspace.txt
├── taskbar_commands.txt
├── rice.log
└── command-executor.log
```

## ✅ Installation Complete!

If all items are checked, congratulations! Your rice is fully functional. Enjoy! 🍚

If issues persist, check the troubleshooting section in README.md or open an issue on GitHub.
