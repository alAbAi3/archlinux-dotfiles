#!/bin/bash
#
# bootstrap.sh - Fully Automated Rice Setup
#
# This script will:
# 1. Install yay AUR helper if not present
# 2. Install necessary packages from official repos and AUR
# 3. Install NVIDIA drivers if an NVIDIA GPU is detected
# 4. Symlink dotfiles into the correct locations
# 5. Initialize pywal theme
# 6. Set up all required state files and directories
# 7. Start all necessary background services
#
# NO MANUAL WORK REQUIRED - Run once and enjoy!
#

set -e # Exit immediately if a command exits with a non-zero status.
set -x # Enable verbose output for debugging

# --- Configuration ---
# Get the directory of the script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")

# List of packages to install from official repositories
PACMAN_PACKAGES_FILE="$PROJECT_ROOT/packages/packages-base.txt"
# List of packages to install from the AUR
AUR_PACKAGES_FILE="$PROJECT_ROOT/packages/packages-aur.txt"
# NVIDIA packages
NVIDIA_PACKAGES="linux-headers nvidia-dkms qt5-wayland qt6-wayland egl-wayland"


# --- Functions ---
install_yay() {
    if command -v yay &> /dev/null; then
        echo "-> yay is already installed."
        return 0
    fi

    echo "-> yay not found. Installing yay..."
    
    # Install base-devel if not present (required for makepkg)
    sudo pacman -S --noconfirm --needed base-devel git
    
    # Clone and build yay
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    
    echo "  - yay installed successfully."
}

install_pacman_packages() {
    echo "-> Installing packages from official repositories..."
    if [ -f "$PACMAN_PACKAGES_FILE" ]; then
        sudo pacman -S --noconfirm --needed - < "$PACMAN_PACKAGES_FILE"
    else
        echo "  - WARN: $PACMAN_PACKAGES_FILE not found. Skipping."
    fi
}

install_nvidia_packages_if_needed() {
    # Check for NVIDIA GPU
    if lspci | grep -E "VGA|3D controller" | grep -iq nvidia; then
        echo "-> NVIDIA GPU detected. Installing NVIDIA packages..."
        sudo pacman -S --noconfirm --needed $NVIDIA_PACKAGES
    else
        echo "-> No NVIDIA GPU detected. Skipping NVIDIA package installation."
    fi
}

install_aur_packages() {
    echo "-> Installing packages from AUR..."

    if [ -f "$AUR_PACKAGES_FILE" ]; then
        echo "  - Removing potentially conflicting 'quickshell' package..."
        sudo pacman -R --noconfirm quickshell >/dev/null 2>&1 || true
        
        # Install packages one by one for better error handling
        while IFS= read -r package; do
            # Skip empty lines and comments
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            
            echo "  - Installing: $package"
            if ! yay -S --noconfirm --needed "$package"; then
                echo "  - WARNING: Failed to install $package, continuing..."
            fi
        done < "$AUR_PACKAGES_FILE"
    else
        echo "  - INFO: $AUR_PACKAGES_FILE not found. Skipping."
    fi
}

remove_conflicting_files() {
    echo "-> Checking for and removing conflicting default configs..."
    # Add any conflicting files or directories here
    CONFLICTS=("$HOME/.config/hypr" "$HOME/.config/quickshell" "$HOME/.config/alacritty" "$HOME/.config/starship" "$HOME/.bashrc" "$HOME/.config/xdg-desktop-portal")

    for conflict in "${CONFLICTS[@]}"; do
        if [ -e "$conflict" ] && [ ! -L "$conflict" ]; then
            echo "  - Deleting conflicting file/directory: $conflict"
            rm -rf "$conflict"
        fi
    done
    echo "  - No conflicts found or conflicts resolved."
}

link_dotfiles() {
    echo "-> Linking configuration files..."

    # Ensure target directories exist
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.cache/rice"
    mkdir -p "$HOME/.cache/swww"
    mkdir -p "$HOME/Pictures/Wallpapers"

    # Link config directories using ln -s for clarity and reliability
    echo "  - Linking hypr config..."
    ln -sf "$PROJECT_ROOT/modules/hypr" "$HOME/.config/hypr"

    echo "  - Linking quickshell config..."
    ln -sf "$PROJECT_ROOT/modules/quickshell" "$HOME/.config/quickshell"

    echo "  - Linking alacritty config..."
    ln -sf "$PROJECT_ROOT/modules/alacritty" "$HOME/.config/alacritty"

    echo "  - Linking starship config..."
    ln -sf "$PROJECT_ROOT/modules/starship" "$HOME/.config/starship"

    echo "  - Linking xdg-desktop-portal config..."
    mkdir -p "$HOME/.config/xdg-desktop-portal"
    ln -sf "$PROJECT_ROOT/modules/xdg-desktop-portal/portals.conf" "$HOME/.config/xdg-desktop-portal/portals.conf"

    echo "  - Linking bashrc..."
    ln -sf "$PROJECT_ROOT/modules/shell/.bashrc" "$HOME/.bashrc"

    echo "  - Linking wallpapers directory..."
    ln -sf "$PROJECT_ROOT/wallpapers" "$HOME/Pictures/Wallpapers"

    # Link all scripts individually to ~/.local/bin for reliability
    echo "  - Linking scripts to ~/.local/bin..."
    for script in "$PROJECT_ROOT/modules/scripts/"*.sh; do
        ln -sf "$script" "$HOME/.local/bin/"
    done

    echo "  - Linking complete."
}

set_script_permissions() {
    echo "-> Making all shell scripts executable..."
    find "$PROJECT_ROOT/modules/scripts" -type f -name "*.sh" -exec chmod +x {} +
    find "$PROJECT_ROOT/scripts" -type f -name "*.sh" -exec chmod +x {} +
    
    echo "  - Permissions set."
}

initialize_state_files() {
    echo "-> Initializing state files..."
    
    # Create cache directories
    mkdir -p "$HOME/.cache/rice"
    mkdir -p "$HOME/.cache/swww"
    mkdir -p "$HOME/.cache/quickshell"
    mkdir -p "$HOME/.cache/wal"
    
    # Initialize workspace state
    echo "1" > "$HOME/.cache/rice/active_workspace.txt"
    echo "  - Created active_workspace.txt"
    
    # Initialize empty command file for taskbar executor
    > "$HOME/.cache/rice/taskbar_commands.txt"
    echo "  - Created taskbar_commands.txt"
    
    # Create log file
    > "$HOME/.cache/rice/rice.log"
    echo "  - Created rice.log"
    
    echo "  - State files initialized."
}

initialize_theme() {
    echo "-> Initializing theme with pywal..."
    
    # Check if pywal is installed
    if ! command -v wal &> /dev/null; then
        echo "  - WARNING: pywal not found. Installing..."
        sudo pacman -S --noconfirm --needed python-pywal
    fi
    
    # Ensure theme directory exists
    mkdir -p "$HOME/.config/quickshell/theme"
    
    # Find a wallpaper to use for initial theme
    WALLPAPER_DIR="$PROJECT_ROOT/Wallpapers"
    if [ -d "$WALLPAPER_DIR" ]; then
        # Find first image file
        FIRST_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)
        
        if [ -n "$FIRST_WALLPAPER" ]; then
            echo "  - Generating theme from: $FIRST_WALLPAPER"
            wal -i "$FIRST_WALLPAPER" -n
            
            # Run the apply-theme script to generate QML colors
            if [ -f "$HOME/.local/bin/apply-theme.sh" ]; then
                bash "$HOME/.local/bin/apply-theme.sh" "$FIRST_WALLPAPER"
                echo "  - Applied theme to QuickShell"
            fi
        else
            echo "  - WARNING: No wallpaper found in $WALLPAPER_DIR"
            echo "  - Using default theme generation"
            wal --theme base16-default -n
            
            # Create a default Colors.qml as fallback
            create_default_colors_qml
        fi
    else
        echo "  - WARNING: Wallpapers directory not found. Using default theme."
        wal --theme base16-default -n
        
        # Create a default Colors.qml as fallback
        create_default_colors_qml
    fi
    
    # Final check - ensure Colors.qml exists
    if [ ! -f "$HOME/.config/quickshell/theme/Colors.qml" ]; then
        echo "  - Creating fallback Colors.qml"
        create_default_colors_qml
    fi
    
    echo "  - Theme initialized."
}

create_default_colors_qml() {
    cat > "$HOME/.config/quickshell/theme/Colors.qml" << 'EOF'
// Default Colors.qml - Generated by bootstrap
pragma Singleton

import QtQuick

QtObject {
    // Special Colors
    property color background: "#1e1e2e"
    property color foreground: "#cdd6f4"
    property color cursor: "#f5e0dc"

    // Normal Colors (Catppuccin Mocha inspired)
    property color color0: "#45475a"
    property color color1: "#f38ba8"
    property color color2: "#a6e3a1"
    property color color3: "#f9e2af"
    property color color4: "#89b4fa"
    property color color5: "#f5c2e7"
    property color color6: "#94e2d5"
    property color color7: "#bac2de"

    // Bright Colors
    property color color8: "#585b70"
    property color color9: "#f38ba8"
    property color color10: "#a6e3a1"
    property color color11: "#f9e2af"
    property color color12: "#89b4fa"
    property color color13: "#f5c2e7"
    property color color14: "#94e2d5"
    property color color15: "#a6adc8"
}
EOF
}

verify_services() {
    echo "-> Verifying critical services..."
    
    # Check if pipewire is running (needed for audio)
    if ! pgrep -x pipewire > /dev/null; then
        echo "  - Starting pipewire..."
        systemctl --user enable pipewire pipewire-pulse wireplumber
        systemctl --user start pipewire pipewire-pulse wireplumber
    else
        echo "  - pipewire is running."
    fi
    
    echo "  - Services verified."
}

setup_fonts() {
    echo "-> Verifying fonts..."
    
    # Ensure core fonts are installed
    REQUIRED_FONTS="ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji"
    sudo pacman -S --noconfirm --needed $REQUIRED_FONTS
    
    # Rebuild font cache
    fc-cache -fv
    
    echo "  - Fonts verified and cache rebuilt."
}

create_backup() {
    echo "-> Creating backup of existing configs..."
    
    BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    
    BACKUP_ITEMS=(
        "$HOME/.config/hypr"
        "$HOME/.config/quickshell"
        "$HOME/.config/alacritty"
        "$HOME/.bashrc"
    )
    
    for item in "${BACKUP_ITEMS[@]}"; do
        if [ -e "$item" ] && [ ! -L "$item" ]; then
            mkdir -p "$BACKUP_DIR"
            echo "  - Backing up: $item"
            cp -r "$item" "$BACKUP_DIR/"
        fi
    done
    
    if [ -d "$BACKUP_DIR" ]; then
        echo "  - Backup created at: $BACKUP_DIR"
    else
        echo "  - No backup needed (no conflicting configs found)."
    fi
}

print_final_instructions() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "✅ RICE INSTALLATION COMPLETE!"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Next steps:"
    echo "  1. Log out of your current session"
    echo "  2. Select 'Hyprland' from your display manager"
    echo "  3. Log in and enjoy your new rice!"
    echo ""
    echo "Keybindings:"
    echo "  Super + Q          - Open terminal"
    echo "  Super + Space      - Open app launcher"
    echo "  Super + 1-5        - Switch workspaces"
    echo "  Super + D          - Next workspace"
    echo "  Super + A          - Previous workspace"
    echo "  Super + Tab        - Wallpaper changer"
    echo "  Super + C          - Close window"
    echo "  Super + M          - Exit Hyprland"
    echo ""
    echo "Troubleshooting:"
    echo "  - Check logs: ~/.cache/rice/rice.log"
    echo "  - Command executor: ~/.cache/rice/command-executor.log"
    echo "  - Hyprland logs: ~/.cache/hyprland/hyprland.log"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ""
}


# --- Main Execution ---
main() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "🚀 STARTING AUTOMATED RICE INSTALLATION"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Step 1: Install yay first
    install_yay
    
    # Step 2: Install packages
    install_pacman_packages
    install_nvidia_packages_if_needed
    install_aur_packages
    setup_fonts
    
    # Step 3: Verify critical packages
    if ! command -v swww &> /dev/null; then
        echo "  - ERROR: 'swww' not found after AUR install! Please check AUR_PACKAGES_FILE."
        exit 1
    fi
    
    if ! command -v quickshell &> /dev/null; then
        echo "  - ERROR: 'quickshell' not found! Please check AUR_PACKAGES_FILE."
        exit 1
    fi
    
    # Step 4: Backup and setup configs
    create_backup
    remove_conflicting_files
    set_script_permissions
    link_dotfiles
    
    # Step 5: Initialize environment
    initialize_state_files
    initialize_theme
    verify_services
    
    # Step 6: Final verification
    if [ ! -d "$HOME/.cache/rice" ]; then
        echo "  - ERROR: '~/.cache/rice' directory not created!"
        exit 1
    fi
    
    if [ ! -f "$HOME/.config/quickshell/theme/Colors.qml" ]; then
        echo "  - WARNING: Theme not properly initialized. You may need to run apply-theme.sh manually."
    fi
    
    # Success!
    print_final_instructions
}

main "$@"
