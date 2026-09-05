{lib, ...}: {
  imports = [

    ./desktop/fuzzel.nix
    ./desktop/niri.nix
    ./desktop/stylix.nix
    ./desktop/waybar.nix
./desktop/hyprland/default.nix

./editor/nvim.nix
    ./editor/espanso.nix
./editor/emacs.nix

./lang/rust.nix

./llm.nix

# ./mime.nix
    ./productivity/sioyek.nix

./services/activitywatch.nix
    ./services/cliphist.nix
./services/ssh-agent.nix

./terminal/carapace.nix
    ./terminal/kitty.nix
    ./terminal/nushell.nix
    ./terminal/starship.nix
    ./terminal/yazi.nix
    ./terminal/zellij.nix
    ./terminal/7z.nix





  ];
}
