{ config, pkgs, inputs, ... }:

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
    ./modules/rofi.nix
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

  home.file.".config/hypr/start.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      swww-daemon &
      current_hour=$(date +%H)
      if [[ "$current_hour" -ge 0 && "$current_hour" -lt 12 ]]; then
        swww img ~/wallpapers/wallpaper2.jpg &
      else
        swww img ~/wallpapers/wallpaper1.jpg &
      fi
    
      fcitx5 &
      nm-applet --indicator &
      waybar &
      hypridle &
      swaync &
      hyprproxlock &  # Add this
    '';
  };

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
