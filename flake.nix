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

    # Shell build dependencies — vendored source lives in modules/shell/
    # quickshell and caelestia-cli are low-level deps we don't need to own.
    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs-unstable";

    caelestia-cli.url = "github:caelestia-dots/cli";
    caelestia-cli.inputs.nixpkgs.follows = "nixpkgs-unstable";
    caelestia-cli.inputs.caelestia-shell.follows = "";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, nixarr, home-manager, disko, vscode-server, nixvim, ... }:
  let
    system = "x86_64-linux";

    unstablePkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Build caelestia-shell directly from vendored source in modules/shell/nix/
    # Edit modules/shell/ freely — this rebuilds from your local files every time.
    caelestiaShell = unstablePkgs.callPackage ./modules/shell/nix {
      rev          = "vendored";
      stdenv       = unstablePkgs.clangStdenv;
      quickshell   = inputs.quickshell.packages.${system}.default.override {
        withX11 = false;
        withI3  = false;
      };
      caelestia-cli = inputs.caelestia-cli.packages.${system}.default;
      withCli      = true; # CLI always included — needed for wallpaper/scheme IPC
    };

    # Minimal self-like attrset the HM module expects from the caelestia flake.
    # Replaces caelestia-shell.homeManagerModules.default.
    caelestiaHmModule = import ./modules/shell/nix/hm-module.nix {
      packages.${system} = {
        default  = caelestiaShell;
        with-cli = caelestiaShell;
      };
      inputs.caelestia-cli = inputs.caelestia-cli;
    };

    mkSystem = { host, home ? ./home/justin.nix, extraModules ? [] }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit nixpkgs-unstable;
          unstable = unstablePkgs;
        };
        modules = [
          ./hosts/nixos/${host}/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs        = true;
            home-manager.useUserPackages      = true;
            home-manager.backupFileExtension  = "backup";
            home-manager.extraSpecialArgs     = { unstable = unstablePkgs; };
            home-manager.users.justin.imports = [
              home
              nixvim.homeModules.nixvim
              caelestiaHmModule # registers programs.caelestia — safe when shell module is not loaded
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
