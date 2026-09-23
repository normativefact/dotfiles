{lib, ...}: let
  toLuaVal = v:
    if builtins.isBool v
    then
      (
        if v
        then "true"
        else "false"
      )
    else if builtins.isInt v || builtins.isFloat v
    then toString v
    else if builtins.isString v
    then builtins.toJSON v
    else if builtins.isList v
    then "{ " + (lib.concatStringsSep ", " (map toLuaVal v)) + " }"
    else if builtins.isAttrs v
    then toLuaTable v
    else "nil";

  toLuaTable = attrs: let
    formatKey = k:
      if builtins.match "^[a-zA-Z_][a-zA-Z0-9_]*$" k != null
      then k
      else "[${builtins.toJSON k}]";
    entries = lib.mapAttrsToList (k: v: "${formatKey k} = ${toLuaVal v}") attrs;
  in
    "{ " + (lib.concatStringsSep ", " entries) + " }";

  # -------------------------------------------------------------
  # Declarative Input, Gesture, and Device Configurations
  # -------------------------------------------------------------
  inputConfig = {
    input = {
      kb_layout = "us";
      kb_variant = "";
      kb_model = "";
      kb_options = "compose:ralt";
      kb_rules = "";

      follow_mouse = 1;
      repeat_rate = 35;
      repeat_delay = 200;
      sensitivity = 0;

      touchpad = {
        natural_scroll = false;
      };
    };
    cursor = {
      no_hardware_cursors = 2; # 2 = auto-fallback, 1 = true (force software)
      enable_hyprcursor = false;
      sync_gsettings_theme = true;
    };
  };

  gestures = [
    {
      fingers = 3;
      direction = "horizontal";
      action = "workspace";
    }
  ];

  devices = [
    {
      name = "instant-usb-gaming-mouse-";
      sensitivity = -0.2;
      accel_profile = "flat";
    }
  ];
in {
  wayland.windowManager.hyprland.extraConfig = ''
    -- Input settings (hl.config)
    hl.config(${toLuaVal inputConfig})

    -- Gestures (hl.gesture - singular)
    ${lib.concatMapStringsSep "\n" (g: "hl.gesture(${toLuaVal g})") gestures}

    -- Per-device configurations (hl.device - singular)
    ${lib.concatMapStringsSep "\n" (d: "hl.device(${toLuaVal d})") devices}
  '';
}
