#!/bin/bash
#
# bootstrap.sh - Phase 0 Skeleton
#
# This script will:
# 1. Install necessary packages from official repos and AUR.
# 2. Symlink dotfiles into the correct locations using `stow`.
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

# --- Functions ---
install_pacman_packages() {
    echo "-> Installing packages from official repositories..."
    if [ -f "$PACMAN_PACKAGES_FILE" ]; then
        sudo pacman -S --noconfirm --needed - < "$PACMAN_PACKAGES_FILE"
    else
        echo "  - WARN: $PACMAN_PACKAGES_FILE not found. Skipping."
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

stow_dotfiles() {
    echo "-> Symlinking dotfiles using stow..."
    if ! command -v stow &> /dev/null; then
        echo "  - ERROR: 'stow' is not installed. Please install it with 'sudo pacman -S stow'."
        return 1
    fi

    # The -t flag sets the target directory
    # We stow from the 'modules' directory into the user's home directory
    # The target for hyprland is ~/.config/hypr, for quickshell it's ~/.config/quickshell
    # Stow needs the directory structure inside modules to match the target structure relative to ~
    # e.g. modules/hypr/.config/hypr/hyprland.conf -> ~/.config/hypr/hyprland.conf
    # Let's adjust the structure or the stow command.
    # A better approach is to have modules/hypr/.config/hypr and then stow from modules.
    # For now, let's assume the user will create the correct structure or we use a more complex stow command.
    # Let's stick to the simple stow command and assume the structure is modules/hypr/.config/hypr etc.
    # The user's plan implies `stow` from `modules/*` into `~/.config`.
    # This means the structure should be `modules/hypr/hyprland.conf` and it will link to `~/.config/hypr/hyprland.conf` if we are in `~/.config` and run `stow ../modules/hypr`
    # The user's layout is `modules/hypr/`. Let's assume stow is run from the project root.
    # `stow -d modules -t ~/.config hypr quickshell` would require `modules/hypr` to contain `.config/hypr` which is not what the user specified.
    # The simplest interpretation is that the `hypr` folder itself should be linked into `~/.config`.
    # `stow --target=$HOME/.config -d modules hypr quickshell`

    echo "   Stowing modules: $STOW_MODULES"
    pushd "$PROJECT_ROOT/modules" > /dev/null
    # Stow each module into its own subdirectory within ~/.config
    for module in $STOW_MODULES; do
        echo "   - Stowing $module..."
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
    install_aur_packages
    stow_dotfiles
    echo "✅ Bootstrap complete."
}

main "$@"
