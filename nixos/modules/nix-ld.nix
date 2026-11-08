{ pkgs, ... }:

{
  # Stata may still require GTK 2 at runtime. Keep this exception limited to
  # GTK 2 until the installed Stata version can use a supported toolkit.
  nixpkgs.config.problems.handlers."gtk+".broken = "warn";

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

