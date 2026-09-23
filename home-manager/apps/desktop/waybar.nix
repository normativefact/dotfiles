{pkgs, ...}:

let
                    

pomodoro-script = pkgs.writeShellScriptBin "waybar-pomodoro" ''
    set -u

    # 1. Query State
    RAW_STATE=$(${pkgs.glib}/bin/gdbus call \
      --session \
      --dest org.gnome.Pomodoro \
      --object-path /org/gnome/Pomodoro \
      --method org.freedesktop.DBus.Properties.Get \
      org.gnome.Pomodoro State 2>/dev/null || echo "")

    if [ -z "$RAW_STATE" ]; then
      echo '{"text": "", "alt": "off", "class": "off"}'
      exit 0
    fi

    STATE=$(echo "$RAW_STATE" | ${pkgs.gnused}/bin/sed -n "s/.*'\([^']*\)'.*/\1/p")

    if [ "$STATE" = "null" ] || [ -z "$STATE" ]; then
      echo '{"text": " Idle", "alt": "idle", "class": "idle", "tooltip": "Pomodoro: Idle"}'
      exit 0
    fi

    # 2. Query Elapsed, StateDuration, and IsPaused
    RAW_ELAPSED=$(${pkgs.glib}/bin/gdbus call \
      --session \
      --dest org.gnome.Pomodoro \
      --object-path /org/gnome/Pomodoro \
      --method org.freedesktop.DBus.Properties.Get \
      org.gnome.Pomodoro Elapsed 2>/dev/null || echo "0")

    RAW_DURATION=$(${pkgs.glib}/bin/gdbus call \
      --session \
      --dest org.gnome.Pomodoro \
      --object-path /org/gnome/Pomodoro \
      --method org.freedesktop.DBus.Properties.Get \
      org.gnome.Pomodoro StateDuration 2>/dev/null || echo "0")

    RAW_PAUSED=$(${pkgs.glib}/bin/gdbus call \
      --session \
      --dest org.gnome.Pomodoro \
      --object-path /org/gnome/Pomodoro \
      --method org.freedesktop.DBus.Properties.Get \
      org.gnome.Pomodoro IsPaused 2>/dev/null || echo "false")

    ELAPSED=$(echo "$RAW_ELAPSED" | ${pkgs.gnused}/bin/sed -E 's/[^0-9.]//g')
    DURATION=$(echo "$RAW_DURATION" | ${pkgs.gnused}/bin/sed -E 's/[^0-9.]//g')

    # Calculate remaining time
    REMAINING=$(awk -v d="$DURATION" -v e="$ELAPSED" 'BEGIN {
      diff = int(d - e);
      print (diff > 0 ? diff : 0);
    }')

    MINS=$(( REMAINING / 60 ))
    SECS=$(( REMAINING % 60 ))
    TIMER=$(printf "%02d:%02d" "$MINS" "$SECS")

    # Set icon and class depending on state and pause status
    CLASS="$STATE"
    if echo "$RAW_PAUSED" | grep -q "true"; then
      CLASS="paused"
      ICON="⏸"
    else
      case "$STATE" in
        "pomodoro")
          ICON=""
          ;;
        "short-break"|"long-break")
          ICON=""
          ;;
        *)
          ICON=""
          ;;
      esac
    fi

    echo "{\"text\": \"$ICON $TIMER\", \"alt\": \"$CLASS\", \"class\": \"$CLASS\", \"tooltip\": \"$STATE: $TIMER remaining\"}"
  '';
                    
pomodoro-toggle = pkgs.writeShellScriptBin "waybar-pomodoro-toggle" ''
    set -u

    IS_PAUSED=$(${pkgs.glib}/bin/gdbus call \
      --session \
      --dest org.gnome.Pomodoro \
      --object-path /org/gnome/Pomodoro \
      --method org.freedesktop.DBus.Properties.Get \
      org.gnome.Pomodoro IsPaused 2>/dev/null || echo "false")

    STATE=$(${pkgs.glib}/bin/gdbus call \
      --session \
      --dest org.gnome.Pomodoro \
      --object-path /org/gnome/Pomodoro \
      --method org.freedesktop.DBus.Properties.Get \
      org.gnome.Pomodoro State 2>/dev/null || echo "'null'")

    # 1. If idle, start a new session
    if echo "$STATE" | grep -q "'null'"; then
      ${pkgs.glib}/bin/gdbus call --session --dest org.gnome.Pomodoro --object-path /org/gnome/Pomodoro --method org.gnome.Pomodoro.Start >/dev/null

    # 2. If running and paused, resume
    elif echo "$IS_PAUSED" | grep -q "true"; then
      ${pkgs.glib}/bin/gdbus call --session --dest org.gnome.Pomodoro --object-path /org/gnome/Pomodoro --method org.gnome.Pomodoro.Resume >/dev/null

    # 3. If running and active, pause
    else
      ${pkgs.glib}/bin/gdbus call --session --dest org.gnome.Pomodoro --object-path /org/gnome/Pomodoro --method org.gnome.Pomodoro.Pause >/dev/null
    fi
  '';
  
in

{
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        exclusive = true;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;
        spacing = 6;
        reload_style_on_change = true;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/submap"
          "custom/pomodoro"          
        ];

        modules-center = [
          "hyprland/window"
        ];

        modules-right = [
          "tray"
          "pulseaudio#source"
          "battery"
          "memory"
          "disk"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          tooltip = false;
          all-outputs = false;
          sort-by-number = true;
          disable-scroll = false;
          on-scroll-up = "hyprctl dispatch workspace +1";
          on-scroll-down = "hyprctl dispatch workspace -1";
        };

        "hyprland/submap" = {
          format = "󰌌  {}";
          max-length = 20;
          tooltip = false;
        };

        "hyprland/window" = {
          format = "{class}  {title}";
          icon = false;
          max-length = 45;
          separate-outputs = true;
          tooltip = false;
        };

        tray = {
          icon-size = 15;
          spacing = 8;
        };

        "pulseaudio#source" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 Muted";
          format-icons = {
            default = ["󰕿" "󰖀" "󰕾"];
          };
          scroll-step = 5;
          on-click = "pavucontrol";
        };

        "custom/pomodoro" = {
        format = "{}";
        return-type = "json";
        exec = "${pomodoro-script}/bin/waybar-pomodoro";
        interval = 1;
on-click = "${pomodoro-toggle}/bin/waybar-pomodoro-toggle";
        on-click-right = "${pkgs.glib}/bin/gdbus call --session --dest org.gnome.Pomodoro --object-path /org/gnome/Pomodoro --method org.gnome.Pomodoro.Skip";
        on-click-middle = "${pkgs.glib}/bin/gdbus call --session --dest org.gnome.Pomodoro --object-path /org/gnome/Pomodoro --method org.gnome.Pomodoro.Reset";
        tooltip = true;
      };

        battery = {
          interval = 60;
          states = {
            warning = 20;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        };

        memory = {
          format = "󰘚 {used:0.1f}G";
          tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G";
          interval = 4;
          on-click = "kitty -e htop";
        };

        disk = {
          interval = 30;
          format = "󰋊 {specific_used:0.1f}G";
          path = "/";
          unit = "GB";
        };

        "clock" = {
format = "{:%A %d-%m-%Y  %I:%M %p}";

          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
      };
    };

    style = ''
          /* --- Soft Pastel Dark Palette --- */
      @define-color bg_main       #1e1e2e;
      @define-color bg_card       #313244;
      @define-color bg_card_hover #45475a;
      @define-color border_color  #45475a;

      @define-color text_main     #cdd6f4;
      @define-color text_dim      #a6adc8;

      @define-color blue_accent   #89b4fa;
      @define-color mauve_accent  #cba6f7;
      @define-color green_accent  #a6e3a1;
      @define-color yellow_accent #f9e2af;
      @define-color red_accent    #f38ba8;
      @define-color peach_accent  #fab387;

      * {
          all: unset;
          font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font", monospace;
          font-size: 13px;
          font-weight: 600;
      }

      /* Floating bar styling */
      window#waybar {
          background-color: transparent;
      }

      /* Shared module capsule styling */
      #workspaces,
      #submap,
      #window,
      #tray,
      #pulseaudio,
      #battery,
      #memory,
      #disk,
      #clock {
          background-color: @bg_card;
          border: 1px solid @border_color;
          color: @text_main;
          padding: 3px 12px;
          border-radius: 8px;
          margin: 0px 2px;
      }

      /* Workspaces */
      #workspaces {
          padding: 2px 4px;
      }

      #workspaces button {
          padding: 2px 8px;
          margin: 2px 3px;
          border-radius: 5px;
          color: @text_dim;
          transition: all 0.2s ease-in-out;
      }

      #workspaces button.active {
          background-color: @blue_accent;
          color: @bg_main;
          font-weight: 800;
      }

      #workspaces button.urgent {
          background-color: @red_accent;
          color: @bg_main;
      }

      #workspaces button:hover {
          background-color: @bg_card_hover;
          color: @text_main;
      }

      /* Center Window Title */
      #window {
          color: @text_main;
          border-color: @border_color;
      }

      /* Active Submap Indicator */
      #submap {
          background-color: @mauve_accent;
          color: @bg_main;
          font-weight: 800;
          border-color: @mauve_accent;
      }

      /* Distinct Accents Per Module */
      #pulseaudio {
          color: @green_accent;
      }

      #pulseaudio.muted {
          color: @text_dim;
      }

      #battery {
          color: @blue_accent;
      }

      #battery.charging {
          color: @green_accent;
      }

      #battery.warning {
          color: @yellow_accent;
      }

      #battery.critical {
          color: @red_accent;
          border-color: @red_accent;
      }

      #memory {
          color: @mauve_accent;
      }

      #disk {
          color: @peach_accent;
      }

      #clock {
          color: @blue_accent;
          font-weight: 700;
      }

      /* Tooltips */
      tooltip {
          background-color: @bg_main;
          border: 1px solid @border_color;
          border-radius: 8px;
          padding: 8px 12px;
          color: @text_main;
      }
#custom-pomodoro {
        padding: 0 10px;
        margin: 0 4px;
      }

      #custom-pomodoro.pomodoro {
        color: #f38ba8; /* Highlight red for work period */
      }

      #custom-pomodoro.short-break,
      #custom-pomodoro.long-break {
        color: #a6e3a1; /* Calm green for breaks */
      }

      #custom-pomodoro.paused,
      #custom-pomodoro.off {
        color: #6c7086;
      }
    '';
  };

  home.packages = with pkgs; [
    pavucontrol
    htop
    glib
    gnused
  ];
}
