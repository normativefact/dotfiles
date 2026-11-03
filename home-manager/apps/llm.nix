{ pkgs, ... }:

{
  home.packages = with pkgs; [
    codex
    antigravity-cli
    bubblewrap
    wl-clipboard
    jq
  ];
}
