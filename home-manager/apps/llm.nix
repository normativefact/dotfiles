{ pkgs, ... }:

{
  home.packages = with pkgs; [
    codex
    bubblewrap
    wl-clipboard
    jq
  ];
}
