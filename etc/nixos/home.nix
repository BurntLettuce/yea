{ config, pkgs, ... }:

{
  home.username = "ghostyyistoasty";
  home.homeDirectory = "/home/ghostyyistoasty";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    waybar
    bibata-cursors
    dracula-theme
  ];

  imports = [
    ./modules/waybar.nix
    ./modules/fastfetch.nix
    ./modules/hypr.nix
  ];

  # Enable dconf (optional for GNOME users)
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

  home.sessionVariables = {
    # EDITOR = "nvim";
    # BROWSER = "firefox";
  };
}
