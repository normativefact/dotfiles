{ pkgs, ... }: {
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ]; # Applies to all keyboards
        settings = {
          main = {
            # Map capslock to escape when pressed, and control/meta when held
            capslock = "overload(control, esc)";
            # Remap escape to capslock
            esc = "capslock";
            # Disable a specific key if needed
            # leftmeta = "noop";
          };
        };
      };
    };
  };
}

