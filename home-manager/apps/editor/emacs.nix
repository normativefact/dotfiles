{ config, pkgs, ... }: {
  home.packages = with pkgs; [nixd];
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk; 

    extraPackages = epkgs: with epkgs; [
      vterm
      vertico
      consult
      orderless
      marginalia
      corfu
      which-key
      magit
      catppuccin-theme
      org-roam
      emacsql


    ];
  };

  services.emacs = {
    enable = true;
    client.enable = true;
  };

}
