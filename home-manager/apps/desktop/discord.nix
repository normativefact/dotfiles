{ pkgs, ... }:

{
 
  home.packages = [
    pkgs.equibop
  ];

  # Write the config directly to ~/.config/equibop/settings.json
  xdg.configFile."equibop/settings.json".text = builtins.toJSON {
    discordBranch = "stable";
    arRPC = true;
    tray = true;
    minimizeToTray = true;
    checkUpdates = false;
  };
}
