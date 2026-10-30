{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    gcc
    gnumake
    nodejs
    tree-sitter
    python3Packages.pylatexenc
  ];

  # Install the editor, but leave ~/.config/nvim entirely user-managed.
  # Enabling the Neovim module or its Stylix target generates init.lua.
  stylix.targets.neovim.enable = false;
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Nushell does not source Home Manager's POSIX session-variable script.
  programs.nushell.environmentVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  programs.git.settings.core.editor = "nvim";
}
