{
  config,
  pkgs,
  inputs,
  ...
}: {
  stylix = {
    enable = true;
    autoEnable = true;
    # The image to generate the color palette from
    image = ./walls/mountain-dark.jpg;

    # Force a dark theme
    polarity = "dark";

    # OR: If you prefer strict Gruvbox over the wallpaper-generated colors,
    # uncomment the line below and comment out the image line above.
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # Global Font Configuration

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "Sauce Code Pro";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        terminal = 12;
        applications = 11;
        desktop = 10;
        popups = 11;
      };
    };
    cursor = {
      # package = pkgs.bibata-cursors;
      # name = "Bibata-Modern-Classic";
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    # Explicitly define what apps Stylix should control
    targets = {
      kitty.enable = true;
      waybar.enable = false;
      hyprland.enable = true;
      zellij.enable = true;
      gtk.enable = true;
      fuzzel.enable = true;
      starship.enable = true;
      sioyek.enable = true;
    };
  };
}
