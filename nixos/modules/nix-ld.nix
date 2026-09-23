{ pkgs, ... }:

{
  # Enable the core nix-ld linker system-wide
  programs.nix-ld.enable = true;

  # Declare all libraries unpatched binaries (like Stata) can access
  programs.nix-ld.libraries = with pkgs; [
    # Core CLI & Stata dependencies
    ncurses
    curl
    zlib
    glibc
    gcc.cc.lib

    # GUI / X11 / GTK graphics support for Stata's interface
    gtk2
    gtk3
    glib
    pango
    cairo
    atk
    gdk-pixbuf
    libx11
    libxext
    libxrender
    libxt
    libxinerama
    libxi
    libxrandr
    libxcursor
    fontconfig
    freetype
  ];
}

