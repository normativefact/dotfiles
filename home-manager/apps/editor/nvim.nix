{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    gnumake
    nodejs
    tree-sitter
python3Packages.pylatexenc
  ];

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/normativefact/dotfiles/nvim/.config/nvim";
}
