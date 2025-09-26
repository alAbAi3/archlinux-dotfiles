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
STOW_MODULES="hypr quickshell"
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
        yay -S --noconfirm --needed - < "$AUR_PACKAGES_FILE"
    else
        echo "  - INFO: $AUR_PACKAGES_FILE not found. Skipping."
    fi
}

remove_conflicting_files() {
    echo "-> Checking for and removing conflicting default config files..."
    CONFLICTING_FILE="$HOME/.config/hypr/hyprland.conf"
    if [ -f "$CONFLICTING_FILE" ] && [ ! -L "$CONFLICTING_FILE" ]; then
        echo "  - Deleting conflicting file: $CONFLICTING_FILE"
        rm "$CONFLICTING_FILE"
    else
        echo "  - No conflicts found."
    fi
}

stow_dotfiles() {
    echo "-> Symlinking dotfiles using stow..."
    if ! command -v stow &> /dev/null; then
        echo "  - ERROR: 'stow' is not installed. Please install it with 'sudo pacman -S stow'."
        return 1
    fi

    echo "   Stowing modules: $STOW_MODULES"
    pushd "$PROJECT_ROOT/modules" > /dev/null
    # Stow each module into its own subdirectory within ~/.config
    for module in $STOW_MODULES; do
        echo "   - Stowing $module..."
        # Ensure the target directory exists before stowing
        mkdir -p "$HOME/.config/$module"
        # The target is now $HOME/.config/<module_name>
        # This ensures files from 'hypr' go into '.config/hypr', etc.
        stow -v --restow --target="$HOME/.config/$module" "$module"
    done
    popd > /dev/null

    echo "  - Stow complete."
}


# --- Main Execution ---
main() {
    echo "🚀 Bootstrapping Rice Environment..."
    install_pacman_packages
    install_nvidia_packages_if_needed
    install_aur_packages
    remove_conflicting_files
    stow_dotfiles
    echo "✅ Bootstrap complete."
}

main "$@"
