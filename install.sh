#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

echo "🚀 Starting dotfiles installation..."

stow-cmd="stow -v -t ~ kitty hyprland zotero obsidian nvim waybar edit-config-script zellij bashrc rofi wallpapers"

# Step 1: Ensure we are in the right directory
cd "$HOME/dotfiles"

# Step 2: Use nix-shell to run stow if it's not installed on the base system yet
echo "🔗 Symlinking user configs (Kitty, Hyprland, etc.)..."
if ! command -v stow &> /dev/null; then
    echo "📦 Stow not found natively. Running via nix-shell..."
    nix-shell -p stow --run "$stow-cmd"
else
    $stow-cmd
fi

echo "✅ User configs linked!"

# Step 3: Apply NixOS configuration
echo "❄️  Applying NixOS system configuration..."
read -p "Do you want to apply the NixOS flake now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos
    echo "✅ NixOS rebuild complete!"
fi

echo "🎉 All done! Enjoy your system."
