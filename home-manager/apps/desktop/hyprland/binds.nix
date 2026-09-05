{ lib, pkgs, ... }:
let
  mainMod = "SUPER";
  terminal = "kitty";
  fileManager = "yazi";
  menu = "fuzzel";

  # -------------------------------------------------------------
  # Lua Compiler Helpers (Turns Nix Attribute Sets into Lua)
  # -------------------------------------------------------------
  toLuaVal = v:
    if builtins.isBool v then (if v then "true" else "false")
    else if builtins.isInt v then toString v
    else if builtins.isString v then builtins.toJSON v
    else if builtins.isAttrs v then toLuaTable v
    else "nil";

  toLuaTable = attrs:
    let entries = lib.mapAttrsToList (k: v: "${k} = ${toLuaVal v}") attrs;
    in "{ " + (lib.concatStringsSep ", " entries) + " }";

  renderBind = indent: b:
    let
      action = if b ? exec then "hl.dsp.exec_cmd(${builtins.toJSON b.exec})" else b.dsp;
      opts = if (b ? opts && b.opts != { }) then ", ${toLuaTable b.opts}" else "";
    in
    "${indent}hl.bind(${builtins.toJSON b.key}, ${action}${opts})";

  renderSubmap = name: data: ''
    hl.bind(${builtins.toJSON data.trigger}, hl.dsp.submap(${builtins.toJSON name})${if (data ? triggerOpts && data.triggerOpts != { }) then ", ${toLuaTable data.triggerOpts}" else ""})
    hl.define_submap(${builtins.toJSON name}, function()
    ${lib.concatMapStringsSep "\n" (renderBind "    ") data.binds}
    end)
  '';

  # -------------------------------------------------------------
  # Declarative Keybind Data
  # -------------------------------------------------------------
  coreBinds = [
    # Applications & Windows
    { key = "${mainMod} + T"; exec = terminal; opts = { submap_universal = true; }; }
    { key = "${mainMod} + Q"; dsp = "hl.dsp.window.close()"; opts = { submap_universal = true; }; }
    { key = "${mainMod} + SHIFT + M"; exec = "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"; }
    { key = "${mainMod} + E"; exec = fileManager; }
    { key = "${mainMod} + F"; dsp = "hl.dsp.window.float({ action = 'toggle' })"; }
    { key = "${mainMod} + V"; exec = "cliphist list | ${menu} -d | cliphist decode | wl-copy"; }
    { key = "${mainMod} + R"; exec = menu; }
    { key = "${mainMod} + P"; dsp = "hl.dsp.window.pseudo()"; }
    { key = "${mainMod} + Return"; dsp = "hl.dsp.layout('swapwithmaster')"; opts = { submap_universal = true; }; }
    { key = "${mainMod} + SHIFT + F"; dsp = "hl.dsp.window.fullscreen({ action = 'toggle' })"; }

    # Scratchpad
    { key = "${mainMod} + B"; exec = "${terminal} --class scratchpad -e nvim ~/notes/scratchpad.md ."; opts = { workspace = "special:scratchpad"; }; }
    { key = "${mainMod} + S"; dsp = "hl.dsp.workspace.toggle_special('scratchpad')"; }
    { key = "${mainMod} + SHIFT + S"; dsp = "hl.dsp.window.move({ workspace = 'special:scratchpad' })"; }

    # Screenshots
    { key = "SHIFT + Print"; exec = ''grim -g "$(slurp -d)" - | satty -f - --copy-command wl-copy -o "~/Pictures/Screenshots/%Y%m%d_%H%M%S.png"''; }
    { key = "Print"; exec = ''grim -g "$(slurp -d)" -l 3 -t png - | wl-copy''; }

    # Focus Movement (Vim keys)
    { key = "${mainMod} + h"; dsp = "hl.dsp.focus({ direction = 'left' })"; opts = { submap_universal = true; }; }
    { key = "${mainMod} + l"; dsp = "hl.dsp.focus({ direction = 'right' })"; opts = { submap_universal = true; }; }
    { key = "${mainMod} + k"; dsp = "hl.dsp.focus({ direction = 'up' })"; opts = { submap_universal = true; }; }
    { key = "${mainMod} + j"; dsp = "hl.dsp.focus({ direction = 'down' })"; opts = { submap_universal = true; }; }

    # Window Movement (Vim keys)
    { key = "${mainMod} + SHIFT + h"; dsp = "hl.dsp.window.move({ direction = 'left' })"; }
    { key = "${mainMod} + SHIFT + l"; dsp = "hl.dsp.window.move({ direction = 'right' })"; }
    { key = "${mainMod} + SHIFT + k"; dsp = "hl.dsp.window.move({ direction = 'up' })"; }
    { key = "${mainMod} + SHIFT + j"; dsp = "hl.dsp.window.move({ direction = 'down' })"; }

    # Mouse Binds
    { key = "${mainMod} + mouse_down"; dsp = "hl.dsp.focus({ workspace = 'e+1' })"; }
    { key = "${mainMod} + mouse_up"; dsp = "hl.dsp.focus({ workspace = 'e-1' })"; }
    { key = "${mainMod} + mouse:272"; dsp = "hl.dsp.window.drag()"; opts = { mouse = true; }; }
    { key = "${mainMod} + mouse:273"; dsp = "hl.dsp.window.resize()"; opts = { mouse = true; }; }

    # Media & Hardware Keys
    { key = "XF86AudioRaiseVolume"; exec = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"; opts = { locked = true; repeating = true; }; }
    { key = "XF86AudioLowerVolume"; exec = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; opts = { locked = true; repeating = true; }; }
    { key = "XF86AudioMute"; exec = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; opts = { locked = true; repeating = true; }; }
    { key = "XF86AudioMicMute"; exec = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; opts = { locked = true; repeating = true; }; }
    { key = "XF86MonBrightnessUp"; exec = "brightnessctl -e4 -n2 set 5%+"; opts = { locked = true; repeating = true; }; }
    { key = "XF86MonBrightnessDown"; exec = "brightnessctl -e4 -n2 set 5%-"; opts = { locked = true; repeating = true; }; }
    { key = "XF86AudioNext"; exec = "playerctl next"; opts = { locked = true; }; }
    { key = "XF86AudioPause"; exec = "playerctl play-pause"; opts = { locked = true; }; }
    { key = "XF86AudioPlay"; exec = "playerctl play-pause"; opts = { locked = true; }; }
    { key = "XF86AudioPrev"; exec = "playerctl previous"; opts = { locked = true; }; }
  ];

  # Workspace 1-10 Switch & Move Generator
  workspaceBinds = builtins.concatLists (map (i:
    let key = toString (lib.mod i 10); in [
      { key = "${mainMod} + ${key}"; dsp = "hl.dsp.focus({ workspace = ${toString i} })"; }
      { key = "${mainMod} + SHIFT + ${key}"; dsp = "hl.dsp.window.move({ workspace = ${toString i} })"; }
    ]
  ) (lib.range 1 10));

  # -------------------------------------------------------------
  # Declarative Submaps
  # -------------------------------------------------------------
  submaps = {
    "Easy Mover" = {
      trigger = "${mainMod} + M";
      binds = (builtins.concatLists (map (i:
        let key = toString (lib.mod i 10); in [
          { key = "${mainMod} + ${key}"; dsp = "hl.dsp.focus({ workspace = ${toString (i + 3)} })"; }
          { key = "${mainMod} + SHIFT + ${key}"; dsp = "hl.dsp.window.move({ workspace = ${toString (i + 3)} })"; }
        ]
      ) (lib.range 1 10))) ++ [
        { key = "M"; dsp = "hl.dsp.submap('reset')"; }
      ];
    };

    "resize" = {
      trigger = "${mainMod} + O";
      binds = [
        { key = "l"; dsp = "hl.dsp.window.resize({ x = 10, y = 0, relative = true })"; opts = { repeating = true; }; }
        { key = "h"; dsp = "hl.dsp.window.resize({ x = -10, y = 0, relative = true })"; opts = { repeating = true; }; }
        { key = "j"; dsp = "hl.dsp.window.resize({ x = 0, y = 10, relative = true })"; opts = { repeating = true; }; }
        { key = "k"; dsp = "hl.dsp.window.resize({ x = 0, y = -10, relative = true })"; opts = { repeating = true; }; }
        { key = "O"; dsp = "hl.dsp.submap('reset')"; }
        { key = "escape"; dsp = "hl.dsp.submap('reset')"; }
      ];
    };

    "group_mode" = {
      trigger = "${mainMod} + D";
      triggerOpts = { description = "Enter group management submap"; };
      binds = [
        { key = "grave"; dsp = "hl.dsp.group.toggle()"; opts = { description = "Toggle window group"; }; }
        { key = "CTRL + TAB"; dsp = "hl.dsp.group.next()"; opts = { description = "Next window in group"; }; }
        { key = "CTRL + SHIFT + TAB"; dsp = "hl.dsp.group.prev()"; opts = { description = "Previous window in group"; }; }
        { key = "ALT + TAB"; dsp = "hl.dsp.group.move_window({ forward = true })"; opts = { description = "Move tab right"; }; }
        { key = "ALT + SHIFT + TAB"; dsp = "hl.dsp.group.move_window({ forward = false })"; opts = { description = "Move tab left"; }; }

        { key = "${mainMod} + SHIFT + l"; dsp = "hl.dsp.window.move({ into_group = 'right' })"; opts = { description = "Move window into group right"; }; }
        { key = "${mainMod} + SHIFT + h"; dsp = "hl.dsp.window.move({ into_group = 'left' })"; opts = { description = "Move window into group left"; }; }
        { key = "${mainMod} + SHIFT + k"; dsp = "hl.dsp.window.move({ into_group = 'up' })"; opts = { description = "Move window into group up"; }; }
        { key = "${mainMod} + SHIFT + j"; dsp = "hl.dsp.window.move({ into_group = 'down' })"; opts = { description = "Move window into group down"; }; }

        { key = "${mainMod} + SHIFT + semicolon + l"; dsp = "hl.dsp.window.move({ out_of_group = 'right' })"; opts = { description = "Move window out of group right"; }; }
        { key = "${mainMod} + SHIFT + semicolon + h"; dsp = "hl.dsp.window.move({ out_of_group = 'left' })"; opts = { description = "Move window out of group left"; }; }

        { key = "SHIFT + r"; dsp = "hl.dsp.group.lock_active()"; opts = { description = "Toggle group lock"; }; }
        { key = "1"; dsp = "hl.dsp.group.active({ index = 1 })"; opts = { description = "Switch to group tab 1"; }; }
        { key = "2"; dsp = "hl.dsp.group.active({ index = 2 })"; opts = { description = "Switch to group tab 2"; }; }
        { key = "3"; dsp = "hl.dsp.group.active({ index = 3 })"; opts = { description = "Switch to group tab 3"; }; }
        { key = "4"; dsp = "hl.dsp.group.active({ index = 4 })"; opts = { description = "Switch to group tab 4"; }; }
        { key = "+ D + F"; dsp = "hl.dsp.submap('reset')"; opts = { description = "Panic exit"; }; }
        { key = "escape"; dsp = "hl.dsp.submap('reset')"; opts = { description = "Panic exit"; }; }
      ];
    };
  };
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    -- Core Binds
    ${lib.concatMapStringsSep "\n" (renderBind "") coreBinds}

    -- Generated Workspace Binds
    ${lib.concatMapStringsSep "\n" (renderBind "") workspaceBinds}

    -- Submaps
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList renderSubmap submaps)}

    hl.bind("SUPER + CTRL + mouse:272", hl.dsp.exec_cmd([[
      ${pkgs.bash}/bin/bash -c '
        if pgrep -f "ydotool click" > /dev/null; then
            pkill -f "ydotool click"
        else
            while true; do
        	ydotool click 0xC0
                sleep 0.05
            done
        fi
      '
      ]]))


  '';

    # { key = "${mainMod} + CTRL + mouse:272"; exec = "${autoclickToggle}/bin/autoclick-toggle" ; } # Autoclicker
}
