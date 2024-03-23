{
  inputs = {
#      nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

      #nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      #nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    
      home-manager.url = "github:nix-community/home-manager/release-23.11";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";

#      firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
#      firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
      poetry2nix = {
        url = "github:nix-community/poetry2nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      disko.url = "github:nix-community/disko";
      disko.inputs.nixpkgs.follows = "nixpkgs";

      vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = inputs@{ self
    , nixpkgs, nixpkgs-unstable
    , home-manager, disko, vscode-server, nixos-hardware, poetry2nix, ... }:
    let
      inputs = { inherit disko poetry2nix home-manager nixpkgs nixpkgs-unstable; };

      genPkgs = system: import nixpkgs { inherit system; config.allowUnfree = true; };
      genUnstablePkgs = system: import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

      # creates a nixos system config
      nixosSystem = system: hostname: username:
        let
          pkgs = genPkgs system;
          unstablePkgs = genUnstablePkgs system;
        in
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit pkgs unstablePkgs;
              # lets us use these things in modules
              customArgs = { inherit system hostname username pkgs unstablePkgs; };
            };
            modules = [
              #disko.nixosModules.disko
              #./hosts/nixos/${hostname}/disko-config.nix

              ./hosts/nixos/${hostname}

              vscode-server.nixosModules.default
              home-manager.nixosModules.home-manager {
                networking.hostName = hostname;
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = { imports = [ ./home/${username}.nix ]; };
              }
              ./hosts/common/nixos-common.nix
            ];
          };
    in {
      nixosConfigurations = {
        # desktop
        seykota = nixosSystem "x86_64-linux" "seykota" "justin";

	#laptop
        fibonacci = nixosSystem "x86_64-linux" "fibonacci" "justin";

        # servers
        donchian = nixosSystem "x86_64-linux" "donchian" "justin";

        # test system
        markowitz = nixosSystem "x86_64-linux" "markowits" "justin";

        # use this for a blank ISO + disko to work
        nixos = nixosSystem "x86_64-linux" "nixos" "justin";
      };
    };
}
