{
  config,
  pkgs,
  ...
}: {
  programs.sioyek = {
    enable = true;
bindings = {
  # --- Highlights & Annotations (Emacs C-c mode prefix) ---
  add_highlight = "<C-c>h";
  # goto_highlight = "<C-c>gh";
  # delete_highlight = "<C-c>dh";
  add_annot_to_highlight = "<C-c>a";

  # --- Window & Frame Controls ---
  new_window = "<C-x>52"; # make-frame (C-x 5 2)
  portal = "<C-c>p"; # Marks source/destination for a portal link
  toggle_one_window = "<C-x>1"; # delete-other-windows (C-x 1)
  close_window = "q"; # Standard Doc-View / View-Mode quit

  # --- Navigation (Core Emacs & Doc-View) ---
  move_down = "<C-n>"; # next-line
  move_up = "<C-p>"; # previous-line
  move_left = "<C-b>"; # backward-char
  move_right = "<C-f>"; # forward-char

  # --- Paging & Screen Movement ---
  next_page = "<space>"; # Doc-View / Info scroll down
  previous_page = "<backspace>"; # Doc-View / Info scroll up
  screen_down = "<C-v>"; # scroll-up-command (C-v)
  screen_up = "<A-v>"; # scroll-down-command (M-v)

  goto_begining = "<A-<>"; # beginning-of-buffer (M-<)
  goto_end = "<A->>"; # end-of-buffer (M->)

  open_document_embedded_from_current_path = "<C-x><C-f>"; # find-file (C-x C-f)

  # --- Selection, Copy & Definitions ---
  keyboard_select = "<C-space>"; # set-mark-command (C-SPC)
  toggle_visual_scroll = "<C-c>v"; # Visual ruler toggle
  keyboard_smart_jump = "<C-c><C-o>"; # Ace-link / link follow
  goto_definition = "<A-.>"; # xref-find-definitions (M-.)
  copy = "<A-w>"; # kill-ring-save (M-w)

  # --- Overview & Jump History ---
  keyboard_overview = "<C-c>o"; # Outline / link overview
  set_mark = "m"; # Set bookmark/mark
  goto_mark = "b"; # Jump to mark
  prev_state = "<A-,>"; # xref-pop-marker-stack (M-, jumps back)
  next_state = "<C-c><right>"; # Step forward in jump history

  # --- UI, Search & Zoom ---
  goto_toc = "<C-c><C-t>"; # Outline/TOC (pdf-tools style)
  search = "<C-s>"; # isearch-forward (C-s)
  next_item = "n"; # Next search match
  previous_item = "p"; # Previous search match
  zoom_in = "+"; # text-scale-adjust / Doc-View zoom in
  zoom_out = "-"; # text-scale-adjust / Doc-View zoom out
  fit_to_page_smart = "=";
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
