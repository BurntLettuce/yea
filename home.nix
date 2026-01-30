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
  ];

  imports = [
    ./modules/fastfetch.nix
    ./modules/hypr.nix
    ./modules/waybar.nix
    ./modules/vm.nix
  ];

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
