{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "normativefact";
    userEmail = "311160822+normativefact@users.noreply.github.com";

    package = pkgs.symlinkJoin {
      name = "git-wrapped";
      paths = [ pkgs.git ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/git --set TZ UTC
      '';
    };

    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
      gpg.format = "ssh";

      pull.rebase = true;
      push.autoSetupRemote = true;
      commit.verbose = true;
      diff.algorithm = "histogram";
    };

    delta.enable = true;

    ignores = [
      ".DS_Store"
      "*.swp"
      "*~"
      ".direnv/"
    ];
  };
}
