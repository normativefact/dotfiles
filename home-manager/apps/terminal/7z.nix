{ pkgs, ... }:

{
  # Installs the 7-Zip package for your user
  home.packages = [
    pkgs.p7zip
  ];

  # Optional: Add user-specific shell aliases for 7z commands
  home.shellAliases = {
    x7z = "7z x";      # Extract with full paths
    e7z = "7z e";      # Extract ignoring directory structure
    c7z = "7z a -mx9"; # Create archive with maximum compression
  };
}
