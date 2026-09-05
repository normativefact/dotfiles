{
  config,
  pkgs,
  ...
}: {
  programs.sioyek = {
    enable = true;
    bindings = {
      # Highlight
      add_highlight = "ah";
      # goto_highlight = "hg";
      # delete_highlight = "hd";
      add_annot_to_highlight = "Ah";

      # --- Window & Panel Controls ---
      new_window = "td"; # Spawns a fully independent, scrollable second window
      portal = "p"; # Marks source/destination for a portal link
      toggle_one_window = "<C-p>"; # Toggles the split-screen Helper Window (for portals)
      close_window = "q"; # Quits the current instance

      # --- Zathura-like / Vim Navigation ---
      move_down = "j"; # Smooth scroll down
      move_up = "k"; # Smooth scroll up
      move_left = "l"; # Smooth scroll left
      move_right = "h"; # Smooth scroll right

      next_page = "J"; # Full page down
      previous_page = "K"; # Full page up
      screen_down = "<C-d>"; # Half-page down (classic Vim)
      screen_up = "<C-u>"; # Half-page up (classic Vim)

      goto_begining = "gg"; # Jump to the very top
      goto_end = "G"; # Jump to the very bottom

      open_document_embedded_from_current_path = "o";
      # --- Visual Mode & Selection (The Vim Way) ---
      keyboard_select = "v"; # Enters visual text selection mode
      toggle_visual_scroll = "V"; # Toggles a visual ruler for reading (move with j/k)
      keyboard_smart_jump = "f"; # Follow links/citations via keyboard hints
      goto_definition = "gd"; # Auto-jump to reference on the currently highlighted line
      copy = "y"; # Yank (copy) selected text
      # --- Word / Chapter Navigation ---
      # next_chapter = "w";             # Jump forward one section/chapter
      # prev_chapter = "b";             # Jump backward one section/chapter

      # --- Selection & Overview ---
      # enter_visual_mark_mode = "V";   # Marks current line as the active visual reference
      keyboard_overview = "s"; # Overviews links and locations on the page

      # --- History & Marks (Standard Vim) ---
      set_mark = "m"; # Set a local mark (e.g., press 'ma')
      goto_mark = "'"; # Jump to a local mark (e.g., press ''a')
      prev_state = "<C-o>"; # Jump back in history (like Vim's Ctrl+O)
      next_state = "<C-i>"; # Jump forward in history (like Vim's Ctrl+I)

      # --- UI & Utilities ---
      goto_toc = "T"; # Table of Contents
      search = "/";
      next_item = "n";
      previous_item = "N";
      zoom_in = "z";
      zoom_out = "Z";
    };

    config = {
      # Layout & launch preferences
      # "startup_commands" = "open_last_document";
      "should_launch_new_window" = "1";
      should_launch_new_instance = "1";

      # Visual Mode Aesthetics (Makes 'V' look like a highlighter block)

      # "ruler_mode"               = "1";
      # "ruler_padding"            = "1.0";
      # "ruler_x_padding"          = "5.0";

      # Optional Color Tweaks (Uncomment to enable)
      # "background_color" = "0.1 0.1 0.1";
      # "visual_mark_color" = "0.3 0.3 0.3 0.2"; # Color of the 'V' visual mode line
    };
  };
}
