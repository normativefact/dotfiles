{ pkgs, ... }:

{
  imports = [
    ./autostart.nix
    ./binds.nix
    ./input.nix
    ./looknfeel.nix
    ./monitors.nix
    ./rules.nix
  ];

  programs.hyprlock.enable = true;
  # security.pam.services.hyprlock = {};

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Required companion tools
  home.packages = with pkgs; [
    brightnessctl
    cliphist
    grim
    libnotify
    playerctl
    satty
    slurp
    swaybg
    waybar
    wl-clipboard
  ];
}
