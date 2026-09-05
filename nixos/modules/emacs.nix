{ inputs, pkgs, ... }: {
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlays.default
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
