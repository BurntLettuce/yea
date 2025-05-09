{ config,lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.ghostyyistoasty = {
    isNormalUser = true;
    description = "ghostyyisToasty";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-chewing ];
  };

  programs = {
    thunar.enable = true;
    xfconf.enable = true;
    firefox.enable = true;
    
    hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    inputs.swww.packages.${pkgs.system}.swww
    age
    brightnessctl
    discord
    dunst
    fastfetch
    ffmpeg
    font-awesome
    git
    gromit-mpx
    helix
    imagemagick
    kitty
    home-manager
    hypridle
    hyprlock
    libnotify
    lz4
    networkmanagerapplet
    pavucontrol
    playerctl
    pywal
    rofi-screenshot
    rofi-wayland
    sops
    soulseekqt
    tauon
    lz4
    vscode
    waybar
    wireguard-tools
    zathura
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    fira-code
  ];

  services = {
    tumbler.enable = true;
    blueman.enable = true;
  };

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.ssh.startAgent = true;

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  # nix.gc = {
  # automatic = true;
  # dates = "weekly";
  # options = "--delete-older-than 7d";
  # };

  security.pam.services.hyprlock = {
   text = ''
     auth include login
     account include login
     password include login
     session include login
    '';
  };

  networking.wg-quick.interfaces = {
    wg0 = {
     address = [ "10.0.0.2/24" ];
      privateKeyFile = config.sops.secrets."wireguard/private-key".path;      
      peers = [
        {
          publicKey = "H6MgkDP53l4F6K2WtasnUtwsYGhIueE7tcEhJUXypVM=";
          allowedIPs = [ "192.168.1.249/32" ];
          endpoint = "100.18.33.168:30912";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  sops.secrets."wireguard/private-key" = {
    owner = "ghostyyistoasty";
  };

  sops.defaultSopsFile = ../common/secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/ghostyyistoasty/.config/sops/age/keys.txt";

  sops.secrets.example-key = { };
  sops.secrets."myservice/my_subdir/my_secret" = {
    owner = "ghostyyistoasty";
  };

  system.stateVersion = "24.11";
}
