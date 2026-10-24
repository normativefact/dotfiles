{ config, pkgs, lib, ... }:

let
  mod = "Super";

  # Workspaces: 1 -> learning, 2 -> browser, 3 -> others, 4..10 numeric
  workspaces = [
    { key = "1"; name = "learning"; }
    { key = "2"; name = "browser"; }
    { key = "3"; name = "others"; }
    { key = "4"; name = 4; }
    { key = "5"; name = 5; }
    { key = "6"; name = 6; }
    { key = "7"; name = 7; }
    { key = "8"; name = 8; }
    { key = "9"; name = 9; }
    { key = "0"; name = 10; }
  ];

  # Toggle scratchpad script: jumps to 'scratchpad', or returns to the previous workspace
  toggleScratchpad = pkgs.writeShellScript "toggle-scratchpad" ''
    ACTIVE_WS=$(${pkgs.niri}/bin/niri msg --json workspaces 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[] | select(.is_active == true or .is_focused == true) | .name // ""')
    if [ "$ACTIVE_WS" = "scratchpad" ]; then
      ${pkgs.niri}/bin/niri msg action focus-workspace-previous
    else
      ${pkgs.niri}/bin/niri msg action focus-workspace scratchpad
    fi
  '';

  # Combinatorial Binds Generator
  generateBinds =
    { prefixes, suffixes, substitutions ? { } }:
    let
      replacer = lib.replaceStrings (builtins.attrNames substitutions) (builtins.attrValues substitutions);
      pairs = attrs: fn:
        builtins.concatMap (
          key: fn { inherit key; action = attrs.${key}; }
        ) (builtins.attrNames attrs);
    in
    builtins.listToAttrs (
      pairs prefixes (p:
        pairs suffixes (s: [
          {
            name = "${p.key}+${s.key}";
            value.action.${replacer "${p.action}-${s.action}"} = [];
          }
        ])
      )
    );
in
{
  programs.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      # ---------------------------------------------------------
      # Environment & Startup Daemons
      # ---------------------------------------------------------
      environment = {
        NIXOS_OZONE_WL = "1";
        XCURSOR_SIZE = "24";
        XCURSOR_THEME = "Adwaita";
      };

      spawn-at-startup = [
        { command = [ "swaybg" "-i" "${config.home.homeDirectory}/Downloads/wallpapers/mountain-dark.jpg" ]; }
        { command = [ "waybar" ]; }
        { command = [ "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP=niri" ]; }
        { command = [ "wl-paste" "--type" "text" "--watch" "cliphist" "store" ]; }
        { command = [ "wl-paste" "--type" "image" "--watch" "cliphist" "store" "-max-items" "300" ]; }
        
        # Dedicated Workspace Launchers
        { command = [ "sioyek" "--new-instance" ]; }
        { command = [ "zen-beta" ]; }
        { command = [ "kitty" "-e" "nvim" "${config.home.homeDirectory}/notes/" ]; }
      ];

      # ---------------------------------------------------------
      # Input Configuration
      # ---------------------------------------------------------
      input = {
        keyboard.xkb = {
          layout = "us";
          options = "compose:ralt";
        };
        keyboard.repeat-delay = 200;
        keyboard.repeat-rate = 35;

        touchpad = {
          tap = true;
          natural-scroll = false;
        };

        mouse = {
          accel-profile = "flat";
          accel-speed = -0.2;
        };
      };

      # ---------------------------------------------------------
      # Layout, Proportions & Catppuccin Mocha Styling
      # ---------------------------------------------------------
      layout = {
        gaps = 2;
        center-focused-column = "never";

        # Preset cycling steps (1/3, 1/2, 2/3, 3/4)
        preset-column-widths = [
          { proportion = 1.0 / 3.0; }
          { proportion = 1.0 / 2.0; }
          { proportion = 2.0 / 3.0; }
          { proportion = 3.0 / 4.0; }
        ];
        default-column-width = { proportion = 1.0 / 2.0; };

        # Native tab bar for merged columns
        tab-indicator = {
          position = "top";
          gaps-between-tabs = 4;
        };

        border = {
          enable = true;
          width = 2;
          active.gradient = {
            from = "#89b4fa";
            to = "#a6e3a1";
            angle = 45;
          };
          inactive.color = "#6c7086";
        };

        shadow = {
          enable = true;
          color = "#1e1e2e99";
        };

        focus-ring.enable = false;
      };

      # ---------------------------------------------------------
      # Privacy & Application Window Rules
      # ---------------------------------------------------------
      window-rules = [
        # Screenshot Annotation Utility
        {
          matches = [{ app-id = "^com\\.gabm\\.satty$"; }];
          open-floating = true;
          default-column-width = { fixed = 900; };
        }
        # Scratchpad Window
        {
          matches = [{ app-id = "^scratchpad$"; }];
          opacity = 0.9;
          open-on-workspace = "scratchpad";
        }
        # Fixed Workspace Placements
        {
          matches = [{ app-id = "^sioyek$"; }];
          open-on-workspace = "learning";
        }
        {
          matches = [{ app-id = "^zen-beta$"; }];
          open-on-workspace = "browser";
        }
        # Screen Sharing Blacklist (Keeps sensitive data off stream/recordings)
        {
          matches = [
            { app-id = "^signal$"; }
            { app-id = "^steam$"; title = "^notificationtoasts"; }
            { app-id = "^org\\.keepassxc\\.KeePassXC$"; }
          ];
          block-out-from = "screencast";
        }
        # Geometry Clipping
        {
          geometry-corner-radius = {
            top-left = 6.0;
            top-right = 6.0;
            bottom-left = 6.0;
            bottom-right = 6.0;
          };
          clip-to-geometry = true;
        }
      ];

      # ---------------------------------------------------------
      # Keybindings
      # ---------------------------------------------------------
      binds = lib.attrsets.mergeAttrsList [
        # 1. Navigation & Moving (Vim & Arrow Keys)
        (generateBinds {
          suffixes."h" = "column-left";
          suffixes."j" = "window-down";
          suffixes."k" = "window-up";
          suffixes."l" = "column-right";

          suffixes."Left" = "column-left";
          suffixes."Down" = "window-down";
          suffixes."Up" = "window-up";
          suffixes."Right" = "column-right";

          prefixes."${mod}" = "focus";
          prefixes."${mod}+Shift" = "move";
        })

        # 2. Workspace Navigation (1=learning, 2=browser, 3=others, 4..10)
        (builtins.listToAttrs (
          builtins.concatMap (ws: [
            {
              name = "${mod}+${ws.key}";
              value.action.focus-workspace = ws.name;
            }
            {
              name = "${mod}+Shift+${ws.key}";
              value.action.move-column-to-workspace = ws.name;
            }
          ]) workspaces
        ))

        # 3. Explicit Utility & Action Keybinds
        {
          # Launchers
          "${mod}+T".action.spawn = [ "kitty" ];
          "${mod}+E".action.spawn = [ "yazi" ];
          "${mod}+R".action.spawn = [ "fuzzel" ];
          "${mod}+V".action.spawn = [ "sh" "-c" "cliphist list | fuzzel -dmenu | cliphist decode | wl-copy" ];
          "${mod}+B".action.spawn = [ "kitty" "--class" "scratchpad" "-e" "nvim" "${config.home.homeDirectory}/notes/scratchpad.md" ];
          "${mod}+O".action.show-hotkey-overlay = [];

          # Window Operations
          "${mod}+Q".action.close-window = [];
          "${mod}+F".action.toggle-window-floating = [];
          "${mod}+Shift+F".action.fullscreen-window = [];
          "${mod}+Shift+M".action.quit = [];

          # Ribbon Manipulation & Tab Toggling
          "${mod}+Space".action.toggle-column-tabbed-display = [];
          "${mod}+Comma".action.consume-window-into-column = [];
          "${mod}+Period".action.expel-window-from-column = [];
          "${mod}+Tab".action.focus-window-down-or-column-right = [];
          "${mod}+Shift+Tab".action.focus-window-up-or-column-left = [];
          "${mod}+Return".action.expand-column-to-available-width = [];
          "${mod}+C".action.center-column = [];

          # Preset Cycling & Fine-grained Resizing
          "${mod}+Shift+R".action.switch-preset-column-width = [];
          "${mod}+Ctrl+H".action.set-column-width = "-10%";
          "${mod}+Ctrl+L".action.set-column-width = "+10%";
          "${mod}+Ctrl+K".action.set-window-height = "+10%";
          "${mod}+Ctrl+J".action.set-window-height = "-10%";

          # Toggleable Scratchpad (Mod+S toggles back and forth; Mod+Shift+S sends window)
          "${mod}+S".action.spawn = [ "${toggleScratchpad}" ];
          "${mod}+Shift+S".action.move-column-to-workspace = "scratchpad";

          # Screenshots
          "Print".action.spawn = [ "sh" "-c" "grim -g \"$(slurp -d)\" -l 3 -t png - | wl-copy" ];
          "Shift+Print".action.spawn = [ "sh" "-c" "grim -g \"$(slurp -d)\" - | satty -f - --copy-command wl-copy -o ~/Pictures/Screenshots/%Y%m%d_%H%M%S.png" ];

          # Media & Hardware Keys
          "XF86AudioRaiseVolume".action.spawn = [ "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+" ];
          "XF86AudioLowerVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
          "XF86AudioMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
          "XF86AudioMicMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
          "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "-e4" "-n2" "set" "5%+" ];
          "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "-e4" "-n2" "set" "5%-" ];
          "XF86AudioNext".action.spawn = [ "playerctl" "next" ];
          "XF86AudioPrev".action.spawn = [ "playerctl" "previous" ];
          "XF86AudioPlay".action.spawn = [ "playerctl" "play-pause" ];
          "XF86AudioPause".action.spawn = [ "playerctl" "play-pause" ];
        }
      ];
    };
  };
}
