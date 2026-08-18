# Formatting stdin.
# Use --help to see all command line options.
# use --quiet to suppress this and other messages.
{
config, lib, pkgs, inputs, ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Jerusalem";

  nixpkgs.config.allowUnfree = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
  services = {
    displayManager = {ly.enable = true;};
  };

  services.input-remapper.enable = true;

  users.users.normativefact = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      tree-sitter
      git
      neovim
      foot
      rofi
      thunar
      swaybg
      waybar

      gcc
      lua-language-server
      alejandra
      nil
      adwaita-icon-theme
      gnome-themes-extra
      nitch
      wl-clipboard
      yazi
      kitty
      psmisc

      obsidian
      zathura
      poppler
      zotero
      ripgrep
      fd
      anki-bin
      stow

      swaynotificationcenter
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    fzf
    (zathura.override {
      plugins = [zathuraPkgs.zathura_pdf_poppler];
    })
    input-remapper
    zellij
    satty
    grim
    gnumake
    slurp
    helix
    espanso-wayland
    evtest
    keyd
    piper
    cliphist
    wl-clipboard
    hyprpolkitagent
  ];

services.espanso = {
  enable = true;
  package = pkgs.espanso-wayland;
};


  xdg.mime.defaultApplications = {
    "text/html" = "zen.desktop";
    "text/xml" = "zen.desktop";
    "application/xhtml+xml" = "zen.desktop";
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
    "x-scheme-handler/about" = "zen.desktop";
    "x-scheme-handler/unknown" = "zen.desktop";
  };

  # ---------------------------
  # PROGRAMS
  # ---------------------------

  programs.firefox.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = ["nvidia"];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    download-buffer-size = 268435456;
    trusted-users = ["root" "normativefact"];
    extra-substituters = ["https://hyprland.cachix.org"];
    extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.iosevka
    fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    dejavu_fonts
  ];


  catppuccin = {
    enable = true;
    autoEnable = true; # Cascades the theme to all supported modules
    flavor = "mocha";
    accent = "lavender";
  };



  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
