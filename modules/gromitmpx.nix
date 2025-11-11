{ config, lib, pkgs, ... }:

let
  # Helper function to create shell scripts, inspired by your waybar.nix
  mkScript = { name, deps ? [], text }: lib.getExe (pkgs.writeShellApplication {
    inherit name text;
    runtimeInputs = deps;
  });

  # Create a script for toggling Gromit-MPX
  gromitToggle = mkScript {
    name = "gromit-toggle";
    text = ''
      if ${pkgs.procps}/bin/pgrep -x "gromit-mpx" > /dev/null; then
          ${pkgs.gromit-mpx}/bin/gromit-mpx --quit
      else
          ${pkgs.gromit-mpx}/bin/gromit-mpx --hidden
      fi
    '';
  };

in {
  # 1. Declare the module's options
  options = {
    programs.gromit-mpx = {
      enable = lib.mkEnableOption "GROMIT-MPX desktop annotation tool";
    };
  };

  # 2. Implement the configuration
  config = lib.mkIf config.programs.gromit-mpx.enable {
    
    # Ensure the gromit-mpx package is installed
    environment.systemPackages = with pkgs; [ gromit-mpx ];

    # Configure Hyprland settings
    wayland.windowManager.hyprland.settings = {
      # Define the special workspace
      workspace = "special:gromit, gapsin:0, gapsout:0, on-created-empty:gromit-mpx -a";
      
      # Window rules for GROMIT-MPX
      windowrule = [
        "noblur, ^(Gromit-mpx)$"
        "opacity 1 override, 1 override, ^(Gromit-mpx)$"
        "noshadow, ^(Gromit-mpx)$"
        "nofullscreenrequest, ^(Gromit-mpx)$"
        "size 100% 100%, ^(Gromit-mpx)$"
      ];
      
      # Key bindings
      bind = [
        # Use the custom toggle script
        ", F9, exec, ${gromitToggle}"
        # Your original undo/redo bindings
        ", F8, exec, gromit-mpx --undo"
        "SHIFT, F8, exec, gromit-mpx --redo"
      ];
    };
  };
}
