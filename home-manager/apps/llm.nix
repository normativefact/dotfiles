{ lib, pkgs, ... }:

let
  # Wrapped DeepSeek Harness with bubblewrap sandboxing enabled by default.
  # Mask common credential paths while keeping the home directory writable.
  mkDsh = latest: pkgs.writeShellScriptBin (if latest then "dsh-latest" else "dsh") ''
    set -euo pipefail

    export PATH="${lib.makeBinPath [ pkgs.nodejs pkgs.pnpm ]}:$PATH"
    ${lib.optionalString latest ''export DSH_HOME="''${DSH_HOME:-$HOME/.dsh-latest}"''}
    DSH_COMMAND=( ${pkgs.nodejs}/bin/npx --yes ${if latest then "@deepseek-ai/dsh@latest" else "--prefer-offline @deepseek-ai/dsh@0.2.1-rc.5"} )

    # Allow bypassing sandbox when explicitly requested
    if [ "''${DSH_NO_SANDBOX:-0}" = "1" ] || [ "''${1:-}" = "--no-sandbox" ]; then
      if [ "''${1:-}" = "--no-sandbox" ]; then
        shift
      fi
      exec "''${DSH_COMMAND[@]}" "$@"
    fi

    # Bubblewrap sandbox arguments
    BWRAP_ARGS=(
      --ro-bind / /
      --dev /dev
      --proc /proc
      --bind /tmp /tmp
      --bind "$HOME" "$HOME"
      --unshare-pid
    )

    # Projects outside the home directory should also be editable.
    case "$PWD" in
      /|/nix/store|/nix/store/*) ;;
      *) if [ -w "$PWD" ]; then BWRAP_ARGS+=(--bind "$PWD" "$PWD"); fi ;;
    esac

    # Mask sensitive directories with empty in-memory tmpfs if they exist
    SENSITIVE_DIRS=(
      "$HOME/.ssh"
      "$HOME/.gnupg"
      "$HOME/.aws"
      "$HOME/.config/gcloud"
      "$HOME/.zen"
      "$HOME/.mozilla"
      "$HOME/.config/google-chrome"
      "$HOME/.config/chromium"
      "$HOME/.config/BraveSoftware"
      "$HOME/.config/gh"
    )

    for dir in "''${SENSITIVE_DIRS[@]}"; do
      if [ -d "$dir" ]; then
        BWRAP_ARGS+=(--tmpfs "$dir")
      fi
    done

    # Mask sensitive credential files if present
    for file in "$HOME/.netrc" "$HOME/.git-credentials" "$HOME/.config/git/credentials"; do
      if [ -f "$file" ]; then
        BWRAP_ARGS+=(--ro-bind /dev/null "$file")
      fi
    done

    # A forwarded agent socket would otherwise provide access to SSH keys.
    unset SSH_AUTH_SOCK

    exec ${pkgs.bubblewrap}/bin/bwrap "''${BWRAP_ARGS[@]}" \
      "''${DSH_COMMAND[@]}" "$@"
  '';
in
{
  home.packages = with pkgs; [
    codex
    antigravity-cli
    bubblewrap
    wl-clipboard
    jq
    nodejs
    pnpm
    (mkDsh false)
    (mkDsh true)
  ];
}
