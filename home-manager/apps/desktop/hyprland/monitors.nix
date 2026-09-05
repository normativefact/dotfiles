{ lib, ... }:

let
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

  # -------------------------------------------------------------
  # Declarative Monitors (maps to hl.monitor)
  # -------------------------------------------------------------
  monitors = [
    {
      output   = "";
      mode     = "preferred";
      position = "auto";
      scale    = "auto";
    }
    # Add more monitors as needed:
    # {
    #   output   = "DP-1";
    #   mode     = "1920x1080@144";
    #   position = "0x0";
    #   scale    = 1.0;
    # }
  ];
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    -- Monitors (hl.monitor)
    ${lib.concatMapStringsSep "\n" (m: "hl.monitor(${toLuaVal m})") monitors}
  '';
}
