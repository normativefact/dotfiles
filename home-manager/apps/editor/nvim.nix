{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    gnumake
    nodejs
    tree-sitter
    python3Packages.pylatexenc
  ];

  # Install Neovim without linking to a configuration absent from the repository.
  programs.neovim.enable = true;
}
