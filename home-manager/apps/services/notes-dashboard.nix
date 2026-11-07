{ config, pkgs, ... }:
let
  dashboard = "${config.home.homeDirectory}/notes/Workspace/learning-dashboard";
in {
  systemd.user.services.notes-dashboard = {
    Unit = {
      Description = "Local notes dashboard";
      After = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.nodejs}/bin/node ${dashboard}/server.mjs";
      WorkingDirectory = dashboard;
      Restart = "on-failure";
      RestartSec = 3;
      Environment = [ "PORT=3210" ];
      NoNewPrivileges = true;
      PrivateTmp = true;
      UMask = "0077";
    };
    Install.WantedBy = [ "default.target" ];
  };
  xdg.desktopEntries.notes-dashboard = {
    name = "Notes dashboard";
    comment = "Goals, processes, and small improvements";
    exec = "${pkgs.xdg-utils}/bin/xdg-open http://127.0.0.1:3210";
    terminal = false;
    categories = [ "Office" ];
  };
}
