{ pkgs, lib, ... }: {
  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;

    configs = {
      default = {
        show_notifications = false;
      };
    };

    matches = {
      base = {
        matches = [
          # Simple static expansion
          {
            trigger = ":email";
            replace = "user@example.com";
          }

          # Date extension
          {
            trigger = ":today";
            replace = "{{current_date}}";
            vars = [
              {
                name = "current_date";
                type = "date";
                params = { format = "%Y-%m-%d"; };
              }
            ];
          }

          # Shell command output
          {
            trigger = ":ip";
            replace = "{{my_ip}}";
            vars = [
              {
                name = "my_ip";
                type = "shell";
                params = { cmd = "curl -s https://ifconfig.me"; };
              }
            ];
          }

          # Dynamic cursor placement
          {
            trigger = ":link";
            replace = "[$|$](https://)";
          }

          # 1. Math Evaluator (:calc 12 * 4.5 / 2)
          {
            regex = ":calc (?P<expr>[0-9+\\-*/^(). ]+)";
            replace = "{{result}}";
            vars = [
              {
                name = "result";
                type = "shell";
                params = {
                  cmd = "echo \"scale=4; {{expr}}\" | bc -l | sed -E 's/\\.?0+$//'";
                };
              }
            ];
          }

          # 2. Dynamic Date Offset (:in 3d, :in 2w, :in 1m)
          {
            regex = ":in (?P<offset>[0-9]+)(?P<unit>[dwm])";
            replace = "{{future_date}}";
            vars = [
              {
                name = "future_date";
                type = "shell";
                params = {
                  cmd = ''
                    case "{{unit}}" in
                        d) date -d "+{{offset}} days" +"%Y-%m-%d" ;;
                        w) date -d "+{{offset}} weeks" +"%Y-%m-%d" ;;
                        m) date -d "+{{offset}} months" +"%Y-%m-%d" ;;
                    esac
                  '';
                };
              }
            ];
          }

          # 3. Dynamic Length Password Generator (:pw 16)
          {
            regex = ":pw (?P<len>[0-9]+)";
            replace = "{{password}}";
            vars = [
              {
                name = "password";
                type = "shell";
                params = {
                  cmd = "tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c {{len}}";
                };
              }
            ];
          }
        ];
      };
    };
  };

  # Point the systemd unit to the capability wrapper
  systemd.user.services.espanso.Service.ExecStart = lib.mkForce "/run/wrappers/bin/espanso daemon";
}
