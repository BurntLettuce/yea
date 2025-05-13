{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.sops-nix.nixosModules.sops
    ];

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };
  networking.firewall = {
    allowedTCPPorts = [ 53  4533  8080];
    allowedUDPPorts = [ 53  30912 ];
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.0.1/24" ];
      listenPort = 30912;
      privateKeyFile = config.sops.secrets."wireguard/private-key".path;

      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
      '';
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
      '';

      peers = [
        {
          publicKey = "8YrZuC6Swmx9tybtyRTvg8Qnuu0F60qM7giuJEnOkj4=";
          allowedIPs = [ "10.0.0.2/32" ];
        }
      ];
    };
  };

  sops.defaultSopsFile = ../common/secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/ghostyytoastyy/.config/sops/age/keys.txt";

  sops.secrets."wireguard/private-key" = {
    owner = "ghostyytoastyy";
  };

  sops.secrets.example-key = { };
  sops.secrets."myservice/my_subdir/my_secret" = {
      owner = "ghostyytoastyy";
  };
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

  users.users.ghostyytoastyy = {
    isNormalUser = true;
    description = "main user";
    extraGroups = [ "networkmanager" "wheel" "navidrome" "sonarr"  ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
  programs.firefox.enable = true;
  programs.dconf.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    age
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    kitty

    navidrome
    qbittorrent-nox    
    sabnzbd

    sops
    wireguard-tools
  ];

  services = {
    navidrome = {
      enable = true;
      settings = {
        MusicFolder = "/var/lib/navidrome/music";
        Address = "0.0.0.0";
        Port = 4533;
        LastFM.Enabled = false;  
        Spotify.Enabled = false;
      };
    };  
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    jackett = {
      enable = true;
      openFirewall = true; # Opens port 9117
    };
    sonarr = {
      enable = true;
      openFirewall = true;
      dataDir = "/var/lib/sonarr";
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
  };

  users.users.ghostyytoastyy.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFouIyzSfXTYwET9IhNvxkRDejrKEA+Rw3yke0KF0crP ghostyyistoasty@nixos"
  ];

  nix.settings.trusted-users = [ "ghostyyistoasty" "@wheel" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "24.11";

}
