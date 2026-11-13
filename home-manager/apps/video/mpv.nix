{ ... }:

{
  programs.mpv = {
    enable = true;

    # Uncomment settings to override mpv's defaults.
    # config = {
    #   save-position-on-quit = true;
    #   keep-open = true;
    #   volume = 80;
    #   volume-max = 100;
    #   sub-auto = "fuzzy";
    #   screenshot-format = "png";
    #   screenshot-directory = "~/Pictures/Screenshots";
    # };

    # Uncomment bindings to add or override keyboard shortcuts.
    # See mpv's input.conf documentation for key names and commands.
    # bindings = {
    #   "h" = "seek -5";
    #   "l" = "seek 5";
    #   "j" = "add volume -5";
    #   "k" = "add volume 5";
    #   "Ctrl+LEFT" = "add speed -0.1";
    #   "Ctrl+RIGHT" = "add speed 0.1";
    #   "Ctrl+0" = "set speed 1.0";
    # };
  };
}
