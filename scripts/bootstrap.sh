#!/bin/bash
#
# bootstrap.sh - Phase 0 Skeleton
#
# This script will:
# 1. Install necessary packages from official repos and AUR.
# 2. Symlink dotfiles into the correct locations using `stow`.
# 3. Install NVIDIA drivers if an NVIDIA GPU is detected.
#

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
# Get the directory of the script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")

# List of packages to install from official repositories
PACMAN_PACKAGES_FILE="$PROJECT_ROOT/packages/packages-base.txt"
# List of packages to install from the AUR
AUR_PACKAGES_FILE="$PROJECT_ROOT/packages/packages-aur.txt"
# Stow modules to link
STOW_MODULES="hypr quickshell scripts"
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
    CONFLICTS=("$HOME/.config/hypr" "$HOME/.config/quickshell")

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

    # Link config directories using ln -s for clarity and reliability
    echo "  - Linking hypr config..."
    ln -sf "$PROJECT_ROOT/modules/hypr" "$HOME/.config/hypr"

    echo "  - Linking quickshell config..."
    ln -sf "$PROJECT_ROOT/modules/quickshell" "$HOME/.config/quickshell"

    echo "  - Linking wallpapers directory..."
    ln -sf "$PROJECT_ROOT/wallpapers" "$HOME/wallpapers"

    # Stow is still good for populating a bin directory
    echo "  - Stowing scripts to ~/.local/bin..."
    if ! command -v stow &> /dev/null; then
        echo "  - ERROR: 'stow' is not installed. Please install it with 'sudo pacman -S stow'."
        return 1
    fi
    pushd "$PROJECT_ROOT/modules" > /dev/null
    stow -v --restow --target="$HOME/.local/bin" scripts
    popd > /dev/null

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
    remove_conflicting_files
    set_script_permissions # Ensure scripts are executable before linking
    link_dotfiles
    echo "✅ Bootstrap complete."
}

main "$@"