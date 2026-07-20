{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    rofi-wayland
  ];

  # Main rofi config (~/.config/rofi/config.rasi)
  home.file.".config/rofi/config.rasi".source = ./assets/rofi/config.rasi;

  # Color scheme (~/.config/rofi/colors/onedark.rasi)
  home.file.".config/rofi/colors/onedark.rasi".source = ./assets/rofi/colors-onedark.rasi;

  # Powermenu theme (~/.config/rofi/powermenu/style-1.rasi)
  home.file.".config/rofi/powermenu/style-1.rasi".source = ./assets/rofi/powermenu-style-1.rasi;

  # Shared confirm dialog (~/.config/rofi/powermenu/shared/confirm.rasi)
  home.file.".config/rofi/powermenu/shared/confirm.rasi".source = ./assets/rofi/powermenu-shared-confirm.rasi;

  # Shared fonts (~/.config/rofi/powermenu/shared/fonts.rasi)
  home.file.".config/rofi/powermenu/shared/fonts.rasi".source = ./assets/rofi/powermenu-shared-fonts.rasi;

  # Shared colors (~/.config/rofi/powermenu/shared/colors.rasi)
  home.file.".config/rofi/powermenu/shared/colors.rasi".source = ./assets/rofi/powermenu-shared-colors.rasi;

  # Powermenu script (~/.config/rofi/powermenu/powermenu.sh)
  home.file.".config/rofi/powermenu/powermenu.sh" = {
    executable = true;
    source = ./assets/rofi/powermenu.sh;
  };
}
