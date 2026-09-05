{ lib, ... }:

let
  # Pure declarative Nix data
  autostartList = [
    { cmd = "swaybg -i ~/Downloads/wallpapers/mountain-dark.jpg"; }
    { cmd = "waybar"; }
    { cmd = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"; }
    { cmd = "zen-beta"; workspace = 2; }
    { cmd = "sioyek --new-instance --execute-command open_last_document"; workspace = 1; }
    { cmd = "kitty -e nvim ~/notes/"; workspace = 1; }
    # { cmd = "kitty -e zzola"; workspace = 1; }
    { cmd = "kitty --class scratchpad -e nvim ~/notes/scratchpad.md"; workspace = "special:scratchpad"; }
    { cmd = "bash -c wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store -max-items 300"; }
  ];

  # Nix compiler: translates Nix attrsets -> Lua hl.exec_cmd calls
  compileExec = app:
    let
      cmdStr = builtins.toJSON app.cmd;
      opts = lib.optionalString (app ? workspace) 
        ", { workspace = ${builtins.toJSON app.workspace} }";
    in
    "    hl.exec_cmd(${cmdStr}${opts})";
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.on("hyprland.start", function()
    ${lib.concatMapStringsSep "\n" compileExec autostartList}
    end)
  '';
}
