{ lib, config, pkgs, ... }: {
  home.username = "normativefact";
  home.homeDirectory = "/home/normativefact";
  home.stateVersion = "26.05";

nix.gc = {
  automatic = true;
  dates = "weekly";       # Runs a user-level systemd timer
  options = "--delete-older-than 14d";
};

imports = [./apps];
}
