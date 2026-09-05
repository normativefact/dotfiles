{pkgs, ...}: 
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
          format = "{:%Y-%m-%d  %I:%M %p}";
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
          font-family: "JetBrainsMono Nerd Font", monospace;
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
    '';
  };

  home.packages = with pkgs; [
    pavucontrol
    htop
    nerd-fonts.jetbrains-mono
  ];
}
