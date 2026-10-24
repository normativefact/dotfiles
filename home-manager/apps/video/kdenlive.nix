{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Modern Qt6 Kdenlive build
    kdePackages.kdenlive
    # Animation and vector graphics editor integrated with Kdenlive
    glaxnimate
    # Collection of video plugins and transitions used by MLT
    frei0r
    # Technical inspector for video/audio codecs and container metadata
    mediainfo
  ];
}
