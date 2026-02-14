{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.services.minibook-support;
  package = inputs.self.packages.${pkgs.system}.minibook-support
    or (pkgs.callPackage ../../pkgs/minibook-support { });
in {
  options.services.minibook-support = {
    enable = lib.mkEnableOption "CHUWI MiniBook support (system permissions)";
    user = lib.mkOption {
      type = lib.types.str;
      description = "Username that will run the user services";
      example = "ghostyyistoasty";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Make the binaries available system‑wide
    environment.systemPackages = [ package ];

    # 2. Add the user to the 'input' group
    users.users.${cfg.user}.extraGroups = [ "input" ];

    # 3. udev rule for /dev/uinput (allows the user to create virtual input devices)
    services.udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      KERNEL=="uinput", SUBSYSTEM=="misc", GROUP="input", MODE="0660"
    '';

    # 4. Load the uinput kernel module
    boot.kernelModules = [ "uinput" ];
  };
}
