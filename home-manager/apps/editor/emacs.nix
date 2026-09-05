{ config, pkgs, ... }: {
  programs.emacs = {
    enable = true;
    # Native Wayland build (PGTK = Pure GTK)
    package = pkgs.emacs-pgtk; 
    
    extraPackages = epkgs: [
      epkgs.vterm
    ];
  };

  # Systemd user daemon: starts Emacs on login in the background
  services.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    defaultEditor = true;
    client.enable = true;
  };

  # Out-of-store symlink to your local configuration folder:
  xdg.configFile."emacs".source = config.lib.file.mkOutOfStoreSymlink 
    "${config.home.homeDirectory}/path/to/your/dotfiles/emacs";
}
