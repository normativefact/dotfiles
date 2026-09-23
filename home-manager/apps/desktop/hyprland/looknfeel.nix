{ config, lib, ... }:

let
  c = config.lib.stylix.colors;

  # Recursive Lua Serializer
  toLuaVal = v:
    if builtins.isBool v then (if v then "true" else "false")
    else if builtins.isInt v || builtins.isFloat v then toString v
    else if builtins.isString v then builtins.toJSON v
    else if builtins.isList v then "{ " + (lib.concatStringsSep ", " (map toLuaVal v)) + " }"
    else if builtins.isAttrs v then toLuaTable v
    else "nil";

  toLuaTable = attrs:
    let
      formatKey = k:
        if builtins.match "^[a-zA-Z_][a-zA-Z0-9_]*$" k != null
        then k
        else "[${builtins.toJSON k}]";
      entries = lib.mapAttrsToList (k: v: "${formatKey k} = ${toLuaVal v}") attrs;
    in
    "{ " + (lib.concatStringsSep ", " entries) + " }";

  curves = {
    easeOutQuint   = { type = "bezier"; points = [ [ 0.23 1 ] [ 0.32 1 ] ]; };
    easeInOutCubic = { type = "bezier"; points = [ [ 0.65 0.05 ] [ 0.36 1 ] ]; };
    linear         = { type = "bezier"; points = [ [ 0 0 ] [ 1 1 ] ]; };
    almostLinear   = { type = "bezier"; points = [ [ 0.5 0.5 ] [ 0.75 1 ] ]; };
    quick          = { type = "bezier"; points = [ [ 0.15 0 ] [ 0.1 1 ] ]; };
    easy           = { type = "spring"; mass = 1; stiffness = 238.1191; dampening = 24.21279333; };
  };

  animations = [
    { leaf = "global";        enabled = true; speed = 10.0; bezier = "default"; }
    { leaf = "border";        enabled = true; speed = 5.39; bezier = "easeOutQuint"; }
    { leaf = "windows";       enabled = true; speed = 4.79; spring = "easy"; }
    { leaf = "windowsIn";     enabled = true; speed = 4.1;  spring = "easy"; style = "popin 87%"; }
    { leaf = "windowsOut";    enabled = true; speed = 1.49; bezier = "linear"; style = "popin 87%"; }
    { leaf = "fadeIn";        enabled = true; speed = 1.73; bezier = "almostLinear"; }
    { leaf = "fadeOut";       enabled = true; speed = 1.46; bezier = "almostLinear"; }
    { leaf = "fade";          enabled = true; speed = 3.03; bezier = "quick"; }
    { leaf = "layers";        enabled = true; speed = 3.81; bezier = "easeOutQuint"; }
    { leaf = "layersIn";      enabled = true; speed = 4.0;  bezier = "easeOutQuint"; style = "fade"; }
    { leaf = "layersOut";     enabled = true; speed = 1.5;  bezier = "linear"; style = "fade"; }
    { leaf = "fadeLayersIn";  enabled = true; speed = 1.79; bezier = "almostLinear"; }
    { leaf = "fadeLayersOut"; enabled = true; speed = 1.39; bezier = "almostLinear"; }
    { leaf = "workspaces";    enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
    { leaf = "workspacesIn";  enabled = true; speed = 1.21; bezier = "almostLinear"; style = "fade"; }
    { leaf = "workspacesOut"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
    { leaf = "zoomFactor";    enabled = true; speed = 7.0;  bezier = "quick"; }
  ];

  configObj = {
    general = {
      gaps_in  = 1;
      gaps_out = 1;
      border_size = 2;
      col = {
        # Dynamically pulling Stylix base0D (blue/accent) & base0B (green)
        active_border   = { colors = [ "rgb(${c.base0D})" "rgb(${c.base0B})" ]; angle = 45; };
        inactive_border = "rgb(${c.base03})";
      };
      resize_on_border = false;
      allow_tearing    = false;
      layout           = "master";
    };

    decoration = {
      rounding       = 0;
      rounding_power = 2;
      active_opacity   = 1.0;
      inactive_opacity = 1.0;
      blur = {
        enabled  = true;
        size     = 3;
        passes   = 1;
        vibrancy = 0.1696;
      };
    };

    animations = { enabled = true; };
    dwindle    = { preserve_split = true; };
    master     = { new_status = "slave"; };
    scrolling  = { fullscreen_on_one_column = true; };

    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo   = true;
    };
  };

  envs = {
    XCURSOR_SIZE    = toString config.stylix.cursor.size;
    XCURSOR_THEME   = config.stylix.cursor.name;
    HYPRCURSOR_SIZE = toString config.stylix.cursor.size;
    HYPRCURSOR_THEME = config.stylix.cursor.name; 
    
    };
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: cfg: "hl.curve(${builtins.toJSON name}, ${toLuaVal cfg})") curves)}
    ${lib.concatMapStringsSep "\n" (anim: "hl.animation(${toLuaVal anim})") animations}
    hl.config(${toLuaVal configObj})
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "hl.env(${builtins.toJSON k}, ${builtins.toJSON v})") envs)}
  '';
}
