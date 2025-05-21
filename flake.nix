
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
    swww = {
      url = "github:LGFae/swww";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
};

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
         	      backupFileExtension = "backup";
         	      useGlobalPkgs = true;
       		      useUserPackages = true;
        	      users.ghostyyistoasty = {
 		          imports = [ ./home.nix ];
        	      };
      		   };
	        }
	    ];
 	};
        scuffed = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
	    modules = [
	    	./hosts/scuffed/configuration.nix
	    ];
        };
      };
    };
}
