{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./modules/keyd.nix
    ./modules/graphics.nix

    ./modules/emacs.nix
    ./modules/nix-ld.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    sessionVariables = {
      # Forces Qt applications to search the NixOS system library path
      LD_LIBRARY_PATH = ["/run/current-system/sw/lib"];

      # OPTIONAL: Alternative fallback to bypass PipeWire for Qt entirely
      # QT_MULTIMEDIA_BACKEND = "pulse";
    };
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add common libraries if the plugin crashes on other dependencies later
    stdenv.cc.cc
    glibc
  ];

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
    alsa.enable = true;
    alsa.support32Bit = true;
  };



  services.libinput.enable = true;
  services = {
    displayManager = {ly.enable = true;};
  };

  services.input-remapper.enable = true;
  programs.ydotool.enable = true;
# services.ydotoold.enable = true;
hardware.uinput.enable = true;

  users.users.normativefact = {
    isNormalUser = true;
    extraGroups = ["wheel" "input" "uinput" "ydotool"];
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
      markdown-oxide
      jq
      pavucontrol

      paperlib
      rucola
      espanso
      trash-cli
      keymapp
      dust
      hledger

      swaynotificationcenter

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
    ];
  };

  environment.systemPackages = with pkgs; [
  ydotool
  libfaketime
    bc
    vim
    wget
    htop
    fzf
    (zathura.override {
      plugins = [zathuraPkgs.zathura_pdf_poppler];
    })
    sioyek
    input-remapper
    zellij
    satty
    grim
    gnumake
    ffmpeg
    wayland-protocols
xwayland-satellite
    rclone
    zola
    home-manager

    slurp
    helix
    espanso-wayland
    evtest
    keyd
    piper
    cliphist
    wl-clipboard
    hyprpolkitagent
    inputs.zen-browser.packages."${pkgs.system}".default
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 20d";
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
