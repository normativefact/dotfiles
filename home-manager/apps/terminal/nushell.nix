{ config, ... }:

{
  programs.nushell = {
    enable = true;

    shellAliases = {
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "...." = "cd ../../..";
      "-"    = "cd -";

      ll = "ls -l";
      la = "ls -a";

      copy = "wl-copy";

      edit   = "${config.home.homeDirectory}/config.sh";
      hms    = "home-manager switch --flake .";
      znix   = "zellij --layout nixconf attach -c nixconf";
      zhypr  = "zellij --layout zhypr attach -c hyprconf";
      znvim  = "zellij --layout nvimconf attach -c nvimconf";
      zzola  = "zellij --layout zzola attach -c zzola";
      zhome  = "zellij --layout zhome attach -c zhome";
    };
  };
}
