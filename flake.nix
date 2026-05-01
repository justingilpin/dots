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

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Noctalia shell — minimal Quickshell-based Wayland desktop shell
    # Requires nixpkgs-unstable (depends on latest Quickshell)
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs-unstable";

  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, nixarr, home-manager, disko, vscode-server, nixvim, noctalia, ... }:
  let
    system = "x86_64-linux";

    unstablePkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Noctalia binary cache — skip local compilation of Quickshell/QML deps.
    # Add to /etc/nix/nix.conf or trusted-users if substituters are restricted.
    noctaliaCacheModule = {
      nix.settings = {
        extra-substituters = [ "https://noctalia.cachix.org" ];
        extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };
    };

    mkSystem = { host, home ? ./home/justin.nix, extraModules ? [] }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit nixpkgs-unstable;
          unstable = unstablePkgs;
        };
        modules = [
          ./hosts/nixos/${host}/default.nix
          home-manager.nixosModules.home-manager
          noctaliaCacheModule
          {
            home-manager.useGlobalPkgs        = true;
            home-manager.useUserPackages      = true;
            home-manager.backupFileExtension  = "backup";
            home-manager.extraSpecialArgs     = { inherit inputs; unstable = unstablePkgs; };
            home-manager.users.justin.imports = [
              home
              nixvim.homeModules.nixvim
              noctalia.homeModules.default # registers programs.noctalia-shell — safe when inactive
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
