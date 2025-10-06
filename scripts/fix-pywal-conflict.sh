#!/bin/bash
#
# fix-pywal-conflict.sh
# Quick fix for python-pywal package conflict
#

set -e

echo "🔧 Fixing python-pywal package conflict..."

# Remove all conflicting pywal packages
echo "-> Removing conflicting pywal packages..."
sudo pacman -R --noconfirm python-pywal python-pywal-git python-pywal116 2>/dev/null || true

# Install the correct version from AUR
echo "-> Installing python-pywal16-git from AUR..."
yay -S --noconfirm python-pywal16-git

# Verify installation
if command -v wal &> /dev/null; then
    echo "✅ pywal installed successfully!"
    wal --version
else
    echo "❌ ERROR: pywal still not found after installation"
    exit 1
fi

echo ""
echo "✅ Conflict resolved! You can now run bootstrap.sh again:"
echo "   ./scripts/bootstrap.sh"
