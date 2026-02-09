{ config, pkgs, ... }:

{
  home.username = "ghostyyistoasty";
  home.homeDirectory = "/home/ghostyyistoasty";
  home.stateVersion = "24.11";
  wayland.windowManager.hyprland.enable = true;
  
  home.packages = with pkgs; [
    waybar
    bibata-cursors
    dracula-theme
    hyprproxlock
  ];

  imports = [
    ./modules/fastfetch.nix
    ./modules/hypr.nix
    ./modules/waybar.nix
    ./modules/vm.nix
  ];

  home.file.".config/hypr/hyprproxlock.conf".text = ''
    device {
      mac_address = "18:26:54:64:2D:9E"
      name = "Pwnagotchi"
      enabled = true
      auto_connect = true
    }
    thresholds {
      lock_threshold = -25
      unlock_threshold = -15
    }
    timings {
      lock_hold_seconds = 3
      unlock_hold_seconds = 3
      poll_interval = 10
      reconnect_interval = 20
    }
  '';

  dconf.enable = true;
 
  gtk = {
     enable = true;
     theme = {
       name = "Dracula";
       package = pkgs.dracula-theme;
     };
     cursorTheme = {
       name = "Bibata-Modern-Ice";
       package = pkgs.bibata-cursors;
     };
  };

}
