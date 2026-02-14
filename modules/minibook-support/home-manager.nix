{ config, lib, pkgs, inputs, ... }:
let
  package = inputs.self.packages.${pkgs.system}.minibook-support
    or (pkgs.callPackage ../../pkgs/minibook-support { });
in {
  options.services.minibook-support = {
    enable = lib.mkEnableOption "CHUWI MiniBook user services";
  };

  config = lib.mkIf config.services.minibook-support.enable {
    home.packages = [ package ];

    systemd.user.services = {
      tabletmoded = {
        Unit = {
          Description = "MiniBook tablet mode daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${package}/bin/tabletmoded";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };

      trackpadd = {
        Unit = {
          Description = "MiniBook trackpad/pointer manager";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${package}/bin/trackpadd";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };

      keyboardd = {
        Unit = {
          Description = "MiniBook keyboard pass‑through daemon";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${package}/bin/keyboardd";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };
  };
}
