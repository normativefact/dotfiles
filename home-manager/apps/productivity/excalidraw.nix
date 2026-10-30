{ lib, pkgs, ... }: {
  home.packages = [ pkgs.chromium ];

  xdg.desktopEntries.excalidraw = {
    name = "Excalidraw";
    genericName = "Whiteboard";
    exec = "${lib.getExe pkgs.chromium} --app=https://excalidraw.com --ozone-platform=wayland";
    terminal = false;
    categories = [ "Graphics" "Office" ];
  };
}
