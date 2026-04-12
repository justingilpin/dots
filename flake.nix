{
  description = "Justin's NixOS configuration and home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixarr.url = "github:rasmus-kirk/nixarr";
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # caelestia shell — comment this input out when not using modules/shell
    caelestia-shell.url = "github:caelestia-dots/shell";
    caelestia-shell.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, nixarr, home-manager, disko, vscode-server, nixvim, caelestia-shell, ... }:
  let
    unstablePkgs = import nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    mkSystem = { host, home ? ./home/justin.nix, extraModules ? [] }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs-unstable;
          unstable = unstablePkgs;
        };
        modules = [
          ./hosts/nixos/${host}/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { unstable = unstablePkgs; };
            home-manager.users.justin.imports = [
              home
              nixvim.homeModules.nixvim
              caelestia-shell.homeManagerModules.default # registers programs.caelestia option (safe when shell is disabled)
            ];
          }
        ] ++ extraModules;
      };
  in {
    nixosConfigurations = {
      # Laptop
      fibonacci = mkSystem { host = "fibonacci"; };

      # Server
      donchian = mkSystem {
        host = "donchian";
        home = ./home/server.nix;
        extraModules = [ nixarr.nixosModules.default ];
      };

      # Old Desktop
      seykota = mkSystem { host = "seykota"; };

      # Desktop
      bachelier = mkSystem { host = "bachelier"; };
    };
  };
}
