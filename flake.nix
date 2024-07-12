{
  inputs = {
      nixpkgs.url = "github:nixOS/nixpkgs/nixos-unstable"; #nixos-23.11
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  #    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      #nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      #nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    
      home-manager.url = "github:nix-community/home-manager/release-23.11";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";

      nixvim.url = "github:nix-community/nixvim/nixos-23.11";
      nixvim.inputs.nixpkgs.follows = "nixpkgs";
#      nixvim.inputs.home-manager.follows = "home-manager";

#      firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
#      firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

      disko.url = "github:nix-community/disko";
      disko.inputs.nixpkgs.follows = "nixpkgs";

      vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = inputs@{ self
    , nixpkgs, nixpkgs-unstable
    , home-manager, disko, nixvim, vscode-server, nixos-hardware, ... }:
    let
      inputs = { inherit disko nixvim home-manager nixpkgs nixpkgs-unstable; };

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
              inherit pkgs unstablePkgs nixvim inputs;
              # lets us use these things in modules
              customArgs = { inherit system hostname inputs username pkgs unstablePkgs; };
            };
            modules = [
              #disko.nixosModules.disko
              #./hosts/nixos/${hostname}/disko-config.nix
#              inputs.nixvim.homeManagerModules.nixvim
#              nixvim.homeManagerModules.nixvim
              ./hosts/nixos/${hostname}
              vscode-server.nixosModules.default
              home-manager.nixosModules.home-manager {
                networking.hostName = hostname;
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = { imports = [ 
                ./home/${username}.nix 
                nixvim.homeManagerModules.nixvim
              	]; };
              }
              ./hosts/common/nixos-common.nix
#	      inputs.nixvim.nixosModules.nixvim
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
