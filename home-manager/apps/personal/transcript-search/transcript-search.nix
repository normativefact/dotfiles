{ config, lib, pkgs, inputs, ... }:
let
  search = pkgs.writeShellApplication {
    name = "transcript-search";
    runtimeInputs = [ pkgs.python3 pkgs.ripgrep pkgs.fzf pkgs.mpv ];
    text = ''
      export TRANSCRIPT_ROOT="''${TRANSCRIPT_ROOT:-${config.home.homeDirectory}/ics-transcripts}"
      export VIDEO_ROOT="''${VIDEO_ROOT:-${config.home.homeDirectory}/ics-video-original}"
      export BROWSER_BIN="''${BROWSER_BIN:-${inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/zen-beta}"
      exec ${lib.getExe pkgs.python3} ${./search} "$@"
    '';
  };
in {
  home.packages = [ search ];
  xdg.desktopEntries.transcript-search = {
    name = "iCS Transcript Search";
    comment = "Search transcripts and open videos at matching timestamps";
    exec = "${lib.getExe pkgs.kitty} -e ${lib.getExe search}";
    icon = "system-search";
    terminal = false;
    categories = [ "Utility" ];
  };
}
