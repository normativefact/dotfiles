{ pkgs, ... }:
let
  # aw-core 0.5.17 requires peewee==3.*. Keep this compatibility override
  # local to ActivityWatch; do not relax its runtime dependency checks.
  activitywatchPkgs = pkgs.extend (_: prev:
    let
      python = prev.python3.override {
        packageOverrides = pyFinal: pyPrev: {
          aw-core = pyPrev.aw-core.override { peewee = pyFinal.peewee_3; };
        };
      };
    in {
      python3 = python;
      python3Packages = python.pkgs;
    });
  activitywatch = activitywatchPkgs.activitywatch;
in {
  home.packages = [
    activitywatch
    pkgs.awatcher
  ];

  systemd.user.startServices = "sd-switch";

  # Server backend
  systemd.user.services.activitywatch-server = {
    Unit = {
      Description = "ActivityWatch Core Server Backend";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${activitywatch}/bin/aw-server";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Wayland Watcher
  systemd.user.services.awatcher = {
    Unit = {
      Description = "ActivityWatch Wayland Tracker (Awatcher)";
      After = [ "activitywatch-server.service" "graphical-session.target" ];
      Requires = [ "activitywatch-server.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [ 
        "AW_SERVER_URL=http://127.0.0.1:5600"
      ];
      ExecStart = "${pkgs.awatcher}/bin/awatcher";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
