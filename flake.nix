{
description = "nixos config";

inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
        url = "github:hyprwm/Hyprland";
    };
    sddm-stray = {
      url = "github:Bqrry4/sddm-stray";
    };
     swww = {
      url = "github:LGFae/swww";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tpanel = {
      url = "github:tuxdotrs/tpanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprproxlock-src = {
      url = "github:Da4ndo/hyprproxlock";
      flake = false;
    };
    minibook-support = {
      url = "github:petitstrawberry/minibook-support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
};

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkNixosConfig = { hostDir, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            (./. + "/hosts/${hostDir}/configuration.nix")
          ] ++ extraModules;
        };

      hyprproxlock = pkgs.callPackage ./pkgs/hyprproxlock.nix { };
    in
    {
      # Import the modules from separate files
      nixosModules.minibook-support = import ./modules/minibook-support/nixos.nix;
      homeManagerModules.minibook-support = import ./modules/minibook-support/home-manager.nix;

      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
                ./hosts/default/configuration.nix
		inputs.home-manager.nixosModules.home-manager
                {
                   home-manager = {
         	      backupFileExtension = "hm-backup";
         	      useGlobalPkgs = true;
        	      useUserPackages = true;
        	      users.ghostyyistoasty = {
 		          imports = [ ./home.nix ];
        	      };
     		   };
	        }
                ({ pkgs, lib, ... }: {
                  nixpkgs.overlays = [
                    (final: prev: {
     		      hyprproxlock = prev.callPackage "${self}/pkgs/hyprproxlock.nix" {
       			 hyprlock = prev.hyprlock;
       			 bluez = prev.bluez;
		      };
                    })
                  ];
                })
	    ];
 	};
        scuffed = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
	    modules = [
	    	./hosts/scuffed/configuration.nix
	    ];
        };
        # NEW: chuwi profile – same as default, plus CHUWI support
        chuwi = mkNixosConfig {
          hostDir = "default";
          extraModules = [
	    inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                backupFileExtension = "hm-backup";
                useGlobalPkgs = true;
                useUserPackages = true;
                users.ghostyyistoasty = {
                  imports = [
                    ./home.nix
                    self.homeManagerModules.minibook-support   # import the user module
                  ];
                  services.minibook-support.enable = true;     # enable the user services
                };
                extraSpecialArgs = { inherit inputs; };        # pass inputs to home.nix if needed
              };
            }
            ({ pkgs, lib, ... }: {
              nixpkgs.overlays = [
                (final: prev: {
                  hyprproxlock = prev.callPackage ./pkgs/hyprproxlock.nix {
                    hyprlock = prev.hyprlock;
                    bluez = prev.bluez;
                  };
                })
              ];
            })
            self.nixosModules.minibook-support                # import the system module
            {
              services.minibook-support = {
                enable = true;
                user = "ghostyyistoasty";
              };
            }
          ];
        };
      };
    };
}
