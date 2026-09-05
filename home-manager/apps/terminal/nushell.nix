{ config, ... }:

{
  programs.nushell = {
    enable = true;

    extraEnv = ''
      $env.EDITOR = "nvim"
      $env.VISUAL = "nvim"

      $env.PATH = (
        $env.PATH
        | split row (char esep)
        | prepend ($env.HOME | path join "bin")
        | prepend ($env.HOME | path join ".local" "bin")
        | uniq
      )

      let ai_path = ($env.HOME | path join ".config" "ai.nu")
      if ($ai_path | path exists) {
        load-env (open $ai_path | from nuon)
      }

    if not ("SSH_AUTH_SOCK" in $env) {
      $env.SSH_AUTH_SOCK = ($env.XDG_RUNTIME_DIR | path join "ssh-agent")
    }
    '';

    extraConfig = ''
      $env.config = (
        $env.config? | default {} | merge {
          show_banner: false
          edit_mode: 'vi'

          history: {
            max_size: 20000
            sync_on_enter: true
            file_format: "sqlite"
            isolation: false
          }

          table: {
            mode: 'rounded'
            index_mode: 'always'
            show_empty: true
          }
        }
      )

      def --env mkcd [dir: path] {
        mkdir $dir
        cd $dir
      }

      def extract [file: path] {
        if not ($file | path exists) {
          print -e $"($file) is not a valid file"
          return
        }

        if ($file | str ends-with ".tar.bz2") or ($file | str ends-with ".tbz2") {
          ^tar xjf $file
        } else if ($file | str ends-with ".tar.gz") or ($file | str ends-with ".tgz") {
          ^tar xzf $file
        } else if ($file | str ends-with ".bz2") {
          ^bunzip2 $file
        } else if ($file | str ends-with ".rar") {
          ^unrar x $file
        } else if ($file | str ends-with ".gz") {
          ^gunzip $file
        } else if ($file | str ends-with ".tar") {
          ^tar xf $file
        } else if ($file | str ends-with ".zip") {
          ^unzip $file
        } else if ($file | str ends-with ".7z") {
          ^7z x $file
        } else {
          print -e $"($file) cannot be extracted via extract"
        }
      }

    '';

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
