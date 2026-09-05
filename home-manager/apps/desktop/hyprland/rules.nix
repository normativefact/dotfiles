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
  # Declarative Window Rules (maps to hl.window_rule)
  # -------------------------------------------------------------
  windowRules = [
    {
      name  = "satty-float";
      match = { class = "com.gabm.satty"; };
      float = true;
      center = true;
    }
    {
      name           = "suppress-maximize-events";
      match          = { class = ".*"; };
      suppress_event = "maximize";
    }
    {
      name = "fix-xwayland-drags";
      match = {
        class    = "^$";
        title    = "^$";
        xwayland = true;
      };
      float      = true;
      fullscreen = false;
      pin        = false;
      no_focus   = true;
    }
    {
      name  = "move-hyprland-run";
      match = { class = "hyprland-run"; };
      move  = "20 monitor_h-120";
      float = true;
    }
    {
      name      = "Scratchpad";
      match     = { class = "scratchpad"; };
      opacity   = 0.9;
      workspace = "special:scratchpad";
    }
  ];
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    -- Window Rules (hl.window_rule)
    ${lib.concatMapStringsSep "\n" (rule: "hl.window_rule(${toLuaVal rule})") windowRules}
  '';
}
