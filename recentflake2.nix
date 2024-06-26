{
  description = "Justin's NixOS configuration and home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11"; # /home-manager
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable"; # nixpkgs

    nixvim.url = "github:nix-community/nixvim/nixos-23.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    #    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    #    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # neovim-nightly-overlay = {
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
  };
  outputs = inputs @ {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    disko,
    vscode-server,
    nixvim,
    ...
  }: let
    overlays = import ./overlays {inherit inputs;};
    #  inputs.neovim-nightly-overlay.overlay
    #      (import ./overlays)
    #    ];
  in {
    # Laptop
    nixosConfigurations = {
      fibonacci = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        inherit overlays; # inherit config overlays
        specialArgs = {inherit nixpkgs-unstable;};
        modules = [
          ./hosts/nixos/fibonacci/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.justin = {
              imports = [./home/justin.nix nixvim.homeManagerModules.nixvim];
            };
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
    };
    # Server
    nixosConfigurations = {
      donchian = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/donchian/default.nix
          #	  home-manager.nixosModules.home-manager
          #	  {
          #	    home-manager.useGlobalPkgs = true;
          #	    home-manager.useUserPackages = true;
          #	    home-manager.users.justin = import ./hosts/server/home/default.nix;
          #	  }
        ];
      };
    };

    # Desktop
    nixosConfigurations = {
      seykota = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        #    inherit config overlays;
        modules = [
          ./hosts/nixos/seykota/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.justin = import ./home/justin.nix;
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
    };

    # Test System
    nixosConfigurations = {
      markowitz = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        #    inherit config overlays;
        modules = [
          ./hosts/nixos/markowitz/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.justin = import ./home/justin.nix;
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
    };

    # Use this for a blank ISO + disko to work
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        #    inherit config overlays;
        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.justin = import ./home/default.nix;
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
    };
  };
}
