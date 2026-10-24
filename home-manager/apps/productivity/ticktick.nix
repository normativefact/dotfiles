{ config, pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfree = true;
  };
home.packages = [ pkgs.chromium ];


  xdg.desktopEntries.ticktick-scratch = {
    name = "TickTick Web";
    genericName = "Task Manager";
    exec = "chromium --app=https://ticktick.com --ozone-platform=wayland";
    terminal = false;
    categories = [ "Office" ];
  };

}
