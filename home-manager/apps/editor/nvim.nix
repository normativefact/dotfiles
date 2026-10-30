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
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Nushell does not source Home Manager's POSIX session-variable script.
  programs.nushell.environmentVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  programs.git.settings.core.editor = "nvim";
}
