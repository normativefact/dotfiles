{ pkgs, ... }:

let
  horizon = pkgs.appimageTools.wrapType2 {
    pname = "horizon-launcher";
    version = "0.2.45";
    src = pkgs.fetchurl {
      url = "https://github.com/horizon-rust/horizon/releases/download/launcher%400.2.45/horizon-launcher-linux-x86_64.AppImage";
      hash = "sha256-" + (builtins.convertHash {
        hash = "1pbjfxq2nl7arjchjr5yggz809mxki3j0x5zrr3mrz21fjxag5b6";
        hashAlgo = "sha256";
        toHashFormat = "base64";
      });
    };
  };
in {
  home.packages = [ horizon ];
  xdg.desktopEntries.horizon-launcher = {
    name = "Horizon Launcher";
    comment = "Launch Horizon for Minecraft";
    exec = "horizon-launcher";
    icon = "applications-games";
    categories = [ "Game" ];
  };
}
