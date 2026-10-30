{ config, lib, ... }:

{
  programs.carapace = {
    enable = true;
    # Supply the record-based completer below instead of the generated legacy
    # positional completer, which warns on recent Nushell releases.
    enableNushellIntegration = false;
    enableBashIntegration = true;
  };
  programs.nushell.extraConfig = ''
    let carapace_completer = {|place|
      let spans = $place.command
      load-env {
        CARAPACE_SHELL_BUILTINS: (help commands | where category != "" | get name | each { split row " " | first } | uniq | str join "\n")
        CARAPACE_SHELL_FUNCTIONS: (help commands | where category == "" | get name | each { split row " " | first } | uniq | str join "\n")
      }

      let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)
      let spans = if $expanded_alias != null {
        $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
      } else {
        $spans
      }

      ${lib.getExe config.programs.carapace.package} $spans.0 nushell ...$spans | from json
    }
    $env.config.completions.external.enable = true
    $env.config.completions.external.completer = $carapace_completer
  '';
}
