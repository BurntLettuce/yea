{ config,lib, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.default
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModulePackages = with config.boot.kernelPackages; [ rtw88 ];
  };

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

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ 
	fcitx5-chewing  
    ];
  };

  services = {
    blueman.enable = true;
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      videoDrivers = [ "modesetting" ];
    };
    # Displays
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      extraPackages = with pkgs; [
        kdePackages.qtsvg
        kdePackages.qtmultimedia
      ];
      wayland.enable = true;
      theme = "sddm-stray"; 
    };
    atd.enable = true;
    printing.enable = true;
  };
 
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
    extraGroups = [ "networkmanager" "wireshark" "wheel" "libvirtd" ];
    packages = with pkgs; [
    ];
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

    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    steam = {
      enable = true;
    };

  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];
  };     

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    inputs.swww.packages.${pkgs.system}.swww
    inputs.tpanel.packages.${system}.default
    inputs.sddm-stray.packages.${pkgs.system}.default
    age
    angryoxide
    brightnessctl
    discord
    easyeffects
    fastfetch
    ferrishot
    ffmpeg
    font-awesome
    git
    gromit-mpx
    imagemagick
    kitty
    hashcat
    hcxtools
    home-manager
    hypridle
    hyprlock
    libnotify
    lz4
    networkmanagerapplet
    nmap
    nicotine-plus
    pavucontrol
    playerctl
    pywal
    quickshell
    rofi-screenshot
    rofi-wayland
    sops
    swaynotificationcenter
    ladybird
    tauon
    traceroute
    lz4
    notes
    qt6.qt5compat
    qt6.qtsvg
    qt6.qtquick3d
    qt6.qtmultimedia
    unrar
    vscode
    waybar
    wireguard-tools
    zathura
    clinfo
    ocl-icd
  ];

  # Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    fira-code
    noto-fonts-cjk-sans
  ];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.ssh.startAgent = true;

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt    
        intel-compute-runtime-legacy1 
      ];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  #   nix.gc = {
  #  automatic = true;
  #  dates = "weekly";
  #  options = "--delete-older-than 7d";
  #  };

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
      privateKeyFile = "/home/ghostyyistoasty/wireguard-keys/private";
     #privateKeyFile = config.sops.secrets."wireguard/private-key".path;
	peers = [
        {
          publicKey = "H6MgkDP53l4F6K2WtasnUtwsYGhIueE7tcEhJUXypVM=";
          allowedIPs = [ "192.168.1.249/32" ];
          endpoint = "wg.ghostyyistoastyy.com";
          persistentKeepalive = 25;
        }
      ];
    };
    wg1 = {
     address = [ "10.8.0.5/24" "fdcc:ad94:bacf:61a4::cafe:5" ];
      privateKeyFile = "/home/ghostyyistoasty/wireguard-keys/private2";
     #privateKeyFile = config.sops.secrets."wireguard/private-key".path;
        peers = [
        {
          publicKey = "NRMY4vETagf+4E4XwNzY7F7Rvj2mv91OkyjwgX/R+XE=";
          presharedKeyFile = "/home/ghostyyistoasty/wireguard-keys/presharedkey";          
          allowedIPs = [ "192.168.1.211/32" "::ffff:c0a8:1d3/32"];
          endpoint = "wg.ghostyyistoastyy.com:51820";
          persistentKeepalive = 25;
        }
      ];  
    };  
  };

  #  sops.secrets."wireguard/private-key" = {
  #    owner = "ghostyyistoasty";
  #  };

  sops.defaultSopsFile = ../common/secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/ghostyyistoasty/.config/sops/age/keys.txt";

  sops.secrets.example-key = { };
  sops.secrets."myservice/my_subdir/my_secret" = {
    owner = "ghostyyistoasty";
  };

  system.stateVersion = "24.11";
}
