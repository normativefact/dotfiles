{ pkgs, ... }:{
  programs.kitty = {
    enable = true;

    # font = {
    #   name = "SauceCodePro Nerd Font";
    #   size = 12.0;
    # };

    settings = {
      # Shell Integration
      shell = "${pkgs.nushell}/bin/nu";

      # Performance & Bell
      input_delay = 3;
      visual_bell_duration = "0.0";
      enable_audio_bell = false;

      # Window Layout & Blur


      dynamic_background_opacity = true;
      remember_window_size = false;
      initial_window_width = 1200;
      initial_window_height = 750;
      window_border_width = "1.5pt";
      enabled_layouts = "tall";
      hide_window_decorations = "titlebar-only";
      
      # UPGRADE: Breathing room for text
      window_padding_width = 4;
      window_margin_width = 2;

      # UPGRADE: Gorgeous Slanted Powerline Tab Bar
      tab_bar_min_tabs = 1;
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}{\' :{}\':.format(num_windows) if num_windows > 1 else \'\'}";

      # Cursor & Mouse
      cursor_shape = "block";
      cursor_blink_interval = 0;
      cursor_stop_blinking_after = 0;
      shell_integration = "no-cursor";
      mouse_hide_wait = -1;

      # Scrollback
      scrollback_lines = 5000;
      wheel_scroll_multiplier = "3.0";

      # Remote Control / Daemon
      allow_remote_control = true;
      listen_on = "unix:@mykitty";

    };

    keybindings = {
      # Clipboard
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+s" = "paste_from_selection";
      "alt+c"        = "copy_to_clipboard";
      "alt+v"        = "paste_from_selection";

      # Scrolling
      "ctrl+shift+k"         = "scroll_line_up";
      "ctrl+shift+j"         = "scroll_line_down";
      "ctrl+shift+page_up"   = "scroll_page_up";
      "ctrl+shift+page_down" = "scroll_page_down";
      "ctrl+shift+home"      = "scroll_home";
      "ctrl+shift+end"       = "scroll_end";
      "ctrl+shift+h"         = "show_scrollback";

      # Window Navigation & Splitting
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+]"     = "next_window";
      "ctrl+shift+["     = "previous_window";
      "ctrl+shift+f"     = "move_window_forward";
      "ctrl+shift+b"     = "move_window_backward";
      "ctrl+shift+`"     = "move_window_to_top";
      "ctrl+shift+1"     = "first_window";
      "ctrl+shift+2"     = "second_window";
      "ctrl+shift+3"     = "third_window";
      "ctrl+shift+4"     = "fourth_window";
      "ctrl+shift+5"     = "fifth_window";
      "ctrl+shift+6"     = "sixth_window";
      "ctrl+shift+7"     = "seventh_window";
      "ctrl+shift+8"     = "eighth_window";
      "ctrl+shift+9"     = "ninth_window";
      "ctrl+shift+0"     = "tenth_window";

      # Tab Management
      "ctrl+tab"       = "next_tab";
      "ctrl+shift+tab" = "previous_tab";
      "ctrl+shift+t"   = "new_tab";
      "ctrl+shift+w"   = "close_tab";
      "ctrl+shift+l"   = "next_layout";
      "ctrl+shift+."   = "move_tab_forward";
      "ctrl+shift+,"   = "move_tab_backward";

      # Font Adjustments
      "ctrl+shift+up"        = "increase_font_size";
      "ctrl+shift+down"      = "decrease_font_size";
      "ctrl+shift+backspace" = "change_font_size all 0";
    };

  };
}
