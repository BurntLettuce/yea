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
};

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      hyprproxlock = pkgs.callPackage ./pkgs/hyprproxlock.nix { };
    in
    {
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
         chuwi = nixpkgs.lib.nixosSystem {
              specialArgs = { inherit inputs; };
              modules = [
                  ./hosts/chuwi/configuration.nix
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
      };
   };
}
