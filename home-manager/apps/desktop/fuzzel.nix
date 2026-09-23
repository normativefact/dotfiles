{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      border.width = 4;
      main = {
        icon-theme = "Papirus";
        prompt = "λ ";
        terminal = "${lib.getExe pkgs.kitty} -e";

        # --- Window Size ---
        width = 60;         # Default is 30 characters; 50-80 works well for cliphist
        lines = 15;         # Number of items visible at once (default is 15)

        # --- Spacing ---
        horizontal-pad = 24; # Horizontal padding between edge and content
        vertical-pad = 16;   # Vertical padding
        inner-pad = 10;      # Space between prompt/input and the list

        # --- Font & HiDPI (if text/elements are physically tiny) ---
        # Increases font size (Fuzzel scales its UI relative to the font):
        # font = "monospace:size=14";

        # Uncomment if you are on a HiDPI / 4K monitor and scaling is off:
        # dpi-aware = "yes";
      };
    };
  };
}
