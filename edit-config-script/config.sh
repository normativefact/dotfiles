#!/usr/bin/env bash

# Set preferred editor
EDITOR="${EDITOR:-nvim}"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
# Ensure fzf is installed
if ! command -v fzf &>/dev/null; then
    echo "Error: 'fzf' is required for interactive selection."
    exit 1
fi

# Reusable fzf function with Vim-style (HJKL) keybindings
fzf_menu() {
    local prompt_text="$1"
    fzf \
        --prompt="$prompt_text > " \
        --height=~12 \
        --layout=reverse \
        --border \
        --cycle \
        --bind="ctrl-j:down,ctrl-k:up" \
        --bind="alt-j:down,alt-k:up" \
        --bind="ctrl-l:accept,alt-l:accept" \
        --bind="alt-h:abort"
}

while true; do
    # Main interactive menu
    choice=$(printf "Bashrc\nNeovim\nHyprland\nKitty\nNix\nWaybar\nConfig Editor\nExit" | fzf_menu "Config Category")

    case "$choice" in
        "Bashrc")
            $EDITOR "$HOME/.bashrc"
            break
            ;;
        "Neovim")
		mapfile -t conf_files < <(
            cd ~/.config/nvim && find -L . -type f ! -path '*/.*' | sed 's|^\./||' | sort)
                if [ ${#conf_files[@]} -gt 0 ]; then
                    selected_file=$(printf "%s\n" "${conf_files[@]}" "← Back" | fzf_menu "Neovim")

                    if [ "$selected_file" = "← Back" ] || [ -z "$selected_file" ]; then
                        continue
                    fi
                    $EDITOR "$CFG/nvim/$selected_file"
                    break
                else
                    echo "No configuration files found in $CFG/nvim/"
                    sleep 1
                fi
            break
            ;;
        "Hyprland")
            if [ -d "$HYPR_DIR" ]; then
                # Follow symlinks (-L) and strip leading ./ to list all config files cleanly
                mapfile -t conf_files < <(
                    cd "$HYPR_DIR" && find -L . -type f ! -path '*/.*' | sed 's|^\./||' | sort
                )

                if [ ${#conf_files[@]} -gt 0 ]; then
                    selected_file=$(printf "%s\n" "${conf_files[@]}" "← Back" | fzf_menu "Hyprland Config")

                    # Loop back to main menu if Back or Esc (empty) is pressed
                    if [ "$selected_file" = "← Back" ] || [ -z "$selected_file" ]; then
                        continue
                    fi

                    $EDITOR "$HYPR_DIR/$selected_file"
                    break
                else
                    echo "No configuration files found in $HYPR_DIR"
                    sleep 1
                fi
            else
                mkdir -p "$HYPR_DIR"
                $EDITOR "$HYPR_DIR/hyprland.lua"
                break
            fi
            ;;
        "Kitty")
            $EDITOR "$CFG/kitty/kitty.conf"
            break
            ;;
        "Waybar")
		mapfile -t conf_files < <(
			cd ~/.config/waybar && find -L . -type f ! -path '*/.*' | sed 's|^\./||' | sort
		)
                if [ ${#conf_files[@]} -gt 0 ]; then
                    selected_file=$(printf "%s\n" "${conf_files[@]}" "← Back" | fzf_menu "Waybar")

                    # Loop back to main menu if Back or Esc (empty) is pressed
                    if [ "$selected_file" = "← Back" ] || [ -z "$selected_file" ]; then
                        continue
                    fi
                    $EDITOR "$CFG/waybar/$selected_file"
                    break
                else
                    echo "No configuration files found in $CFG/waybar/"
                    sleep 1
                fi
            break
            ;;
        "Config Editor")
            $EDITOR "${XDG_CONFIG_HOME:-$HOME}/config.sh"
            break
            ;;
        "Nix")
		mapfile -t conf_files < <(
			cd /etc/nixos/ && find -L . -type f ! -path '*/.*' | sed 's|^\./||' | sort
		)
                if [ ${#conf_files[@]} -gt 0 ]; then
                    selected_file=$(printf "%s\n" "${conf_files[@]}" "← Back" | fzf_menu "Waybar")

                    # Loop back to main menu if Back or Esc (empty) is pressed
                    if [ "$selected_file" = "← Back" ] || [ -z "$selected_file" ]; then
                        continue
                    fi
                    sudo $EDITOR /etc/nixos/$selected_file
                    break
                else
                    echo "No configuration files found in /etc/nixos/"
                    sleep 1
		fi
            break
            ;;
        "Exit"|"")
            echo "Exited."
            break
            ;;
    esac
done
