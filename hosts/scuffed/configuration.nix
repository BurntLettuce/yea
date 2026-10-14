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
    allowedTCPPorts = [ 53  4533  8080  22000];
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
          publicKey = "a4ITZ58dnlF0sS5FiADXzn3DW7TaFPzvBXVDiYz9324=";
          allowedIPs = [ "10.0.0.2/32" ];
        }
        {
          publicKey = "gMwdY3UEHGsMidURtSpEFt4HSsufmrpGBZJbDClijX0=";
          allowedIPs = [ "10.0.0.3/32" ];
        }
        {
          publicKey = "sOhOhqq0BIJJh4i78uL6QLkyCEC2H9NfbJhmj5iCPkY=";
          allowedIPs = [ "10.0.0.4/32" ];
        }
      ];
    };
  };

services.syncthing = {
  enable = true;
  openDefaultPorts = false;
  guiAddress = "127.0.0.1:8384";
  overrideDevices = true;
  overrideFolders = true;
  settings = {
    options = {
      listenAddresses = [ "tcp://0.0.0.0:22000" ];
      globalAnnounceEnabled = false;
      localAnnounceEnabled = false;
      relaysEnabled = false;
      natEnabled = false;
      urAccepted = -1;
    };
    devices.phone = {
      id = "SOOKI3K-MCRORCX-YAAA4XU-D2WYXJM-J6MMKK2-5XVKP54-VXK7N6H-JVSPQQW";
      addresses = [ "dynamic" ];
    };
    folders = {
     music-soulseek = {
       id = "dlgq9-1b514";
       label = "music-soulseek";
       path = "/srv/music/soulseek";
        devices = [ "phone" ];
        type = "receiveonly";
        versioning = { type = "trashcan"; params.cleanoutDays = "30"; };
      };
      music-downloads = {
        id = "ehnhq-5pfar";
        label = "music-downloads";
        path = "/srv/music/downloads";
        devices = [ "phone" ];
        type = "receiveonly";
        versioning = { type = "trashcan"; params.cleanoutDays = "30"; };
      };
    };
  };
};

  systemd.tmpfiles.rules = [
    "d /srv/music           0750 syncthing syncthing -"
    "d /srv/music/soulseek  0750 syncthing syncthing -"
    "d /srv/music/downloads 0750 syncthing syncthing -"
  ];
  systemd.services.navidrome.environment.TMPDIR = "/var/lib/navidrome";
  users.users.navidrome.extraGroups = [ "syncthing" ];

  networking.firewall.interfaces.eth0.allowedTCPPorts = [ 22000 ];
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 22000 ];

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
  sops.secrets."cloudflare/api-token" = { owner = "root"; };
  sops.secrets."cloudflare/zone-id" = { owner = "root"; };
  sops.secrets."cloudflare/record-name" = { owner = "root"; };
  
  systemd.services.cloudflare-ddns = {
    description = "Update Cloudflare DNS record with current public IP";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.curl pkgs.jq ];
    script = ''
      set -euo pipefail

      TOKEN=$(cat ${config.sops.secrets."cloudflare/api-token".path})
      ZONE_ID=$(cat ${config.sops.secrets."cloudflare/zone-id".path})
      RECORD_NAME=$(cat ${config.sops.secrets."cloudflare/record-name".path})

      CURRENT_IP=$(curl -s https://api.ipify.org)

      RECORD_ID=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$RECORD_NAME" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')

      curl -s -X PUT \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":false}"
    '';
  };

  systemd.timers.cloudflare-ddns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "5m";
    };
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
    clinfo  
    hashcat
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    kitty
    git
    
    navidrome
    pciutils
   
    qbittorrent-nox    
    sabnzbd
  
    sops
    wireguard-tools

    hcxtools
  ];

  services = {
    navidrome = {
      enable = true;
      settings = {
        MusicFolder = "/srv/music";
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

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa.opencl # This package provides Rusticl
    ];
  };

  environment.variables = {
    RUSTICL_ENABLE = "radeonsi"; # Explicitly enable Rusticl for AMD GPUs
  };

  users.users.ghostyytoastyy.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHF/RJRc+8fRilYNBUVBQzg6hfpW0T8TK5/zh9PFkhEP ghostyyistoasty@nixos"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMHzHOi6Dej74WRWMqwvUlaWVbgW30fjJtO6rDZul9A polytzu@gmail.com"
  ];

  nix.settings.trusted-users = [ "ghostyyistoasty" "@wheel" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  system.stateVersion = "24.11";

}
