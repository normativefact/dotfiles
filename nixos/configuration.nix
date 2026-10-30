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

    ./modules/emacs.nix
    ./modules/nix-ld.nix
  ] ++ lib.optional (builtins.pathExists ./local.nix) ./local.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
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
  time.timeZone = "Asia/Kolkata";

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

  # Entries must exist in the selected NSS certificate bundle. emSign ECC
  # Root CA - G3 is already absent; listing it here makes nss-cacert fail.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
  ];
  
  # Wayland Espanso needs a privileged wrapper; Home Manager owns its config
  # and user service. This mirrors the NixOS Espanso module's wrapper.
  security.wrappers.espanso = {
    capabilities = "cap_dac_override+p";
    owner = "root";
    group = "root";
    source = lib.getExe (pkgs.espanso-wayland.override {
      securityWrapperPath = config.security.wrapperDir;
    });
  };

  programs.hyprlock.enable = true;
  services.input-remapper.enable = true;
  programs.ydotool.enable = true;
  # services.ydotoold.enable = true;
  hardware.uinput.enable = true;

  users.users.normativefact = {
    isNormalUser = true;
    extraGroups = ["wheel" "input" "uinput" "ydotool" "keyd"];
    packages = with pkgs; [
      tree
      devenv
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
      unzip
      qpdf
      mupdf
pup
      paperlib
      rucola
      trash-cli
      keymapp
      dust
      hledger
      gnome-pomodoro

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
      poppler
      # zotero
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
    sqlite

    slurp
    helix
    evtest
    keyd
    piper
    cliphist
    wl-clipboard
    hyprpolkitagent
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    download-buffer-size = 268435456;
    trusted-users = ["root" "@wheel"];
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
