{ inputs, pkgs, ... }:

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

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    xwayland.enable = true;
    # NixOS owns the compositor. Reuse its portal without Home Manager's
    # compositor override, which the upstream portal no longer accepts.
    package = null;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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
