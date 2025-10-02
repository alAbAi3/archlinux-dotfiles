#!/bin/bash
#
# bootstrap.sh - Phase 0 Skeleton
#
# This script will:
# 1. Install necessary packages from official repos and AUR.
# 2. Symlink dotfiles into the correct locations.
# 3. Install NVIDIA drivers if an NVIDIA GPU is detected.
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
    if ! command -v yay &> /dev/null; then
        echo "  - ERROR: 'yay' is not installed. Please install it first."
        echo "    git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
        return 1
    fi

    if [ -f "$AUR_PACKAGES_FILE" ]; then
        echo "  - Removing potentially conflicting 'quickshell' package..."
        sudo pacman -R --noconfirm quickshell >/dev/null 2>&1 || true
        yay -S --noconfirm --needed - < "$AUR_PACKAGES_FILE"
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


# --- Main Execution ---
main() {
    echo "🚀 Bootstrapping Rice Environment..."
    install_pacman_packages
    install_nvidia_packages_if_needed
    install_aur_packages

    # Explicit check for swww after AUR install
    if ! command -v swww &> /dev/null; then
        echo "  - ERROR: 'swww' not found after AUR install! Please check AUR_PACKAGES_FILE."
        exit 1
    else
        echo "  - 'swww' found."
    fi
    remove_conflicting_files
    set_script_permissions # Ensure scripts are executable before linking
    link_dotfiles

    # Explicit check for ~/.cache/rice after linking
    if [ ! -d "$HOME/.cache/rice" ]; then
        echo "  - ERROR: '~/.cache/rice' directory not created!"
        exit 1
    else
        echo "  - '~/.cache/rice' directory found."
    fi

    echo "✅ Bootstrap complete."
}

main "$@"
