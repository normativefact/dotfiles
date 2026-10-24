{ pkgs, ... }:

{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;
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

    settings = {
      user.name = "normativefact";
      user.email = "311160822+normativefact@users.noreply.github.com";
      init.defaultBranch = "main";
      gpg.format = "ssh";

      pull.rebase = true;
      push.autoSetupRemote = true;
      commit.verbose = true;
      diff.algorithm = "histogram";
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      "*~"
      ".direnv/"
    ];
  };
}
