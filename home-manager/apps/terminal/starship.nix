{ config, lib, ... }:
let
  # Pull base16 hex colors directly from Stylix
  colors = config.lib.stylix.colors;

  makeColor = c: "#" + c;
  makeStyle = bg: fg: "bg:" + bg + " fg:" + fg + " bold";
  
  # Background color of your terminal for the powerline arrows
  baseBg = makeColor colors.base00;
  # Dark text color inside high-contrast blocks
  darkFg = makeColor colors.base01;

  surround =
    fg: text:
    "[](fg:"
    + baseBg
    + " bg:"
    + fg
    + ")"
    + "[█](fg:"
    + fg
    + ")"
    + text
    + "[█](fg:"
    + fg
    + ")";
in
{
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$hostname"
        "$shell"
        "$directory"
        "$git_branch"
        "$cmd_duration"
        "$character "
      ];
      character =
        let
          makeChar =
            bg: c:
            surround (makeColor bg) ("[" + c + "](" + makeStyle (makeColor bg) darkFg + ")");
        in
        {
          error_symbol = makeChar colors.base08 "⊥"; # Red
          format = "$symbol";
          success_symbol = makeChar colors.base0C "λ"; # Cyan / Teal
        };
      cmd_duration = {
        format = surround (makeColor colors.base0E) "[ $duration]($style)"; # Purple / Magenta
        min_time = 0;
        show_milliseconds = true;
        style = makeStyle (makeColor colors.base0E) darkFg;
      };
      directory = {
        format = surround (makeColor colors.base0D) "[󰉋 $path]($style)[$read_only]($read_only_style)"; # Blue
        read_only = "  ";
        read_only_style = makeStyle (makeColor colors.base0D) darkFg;
        style = makeStyle (makeColor colors.base0D) darkFg;
        truncation_length = 1;
        truncate_to_repo = false;
      };
      git_branch = {
        format = surround (makeColor colors.base09) "[$symbol $branch]($style)"; # Orange / Peach
        style = makeStyle (makeColor colors.base09) darkFg;
        symbol = " ";
      };
      git_status = {
        format = "[ \\[$all_status$ahead_behind\\]]($style)";
        style = makeStyle (makeColor colors.base0A) darkFg; # Yellow
      };
      hostname = {
        format = surround (makeColor colors.base0C) "[$ssh_symbol$hostname]($style)"; # Cyan / Sapphire
        ssh_symbol = "󰖟 ";
        style = makeStyle (makeColor colors.base0C) darkFg;
      };
    };
  };
}
