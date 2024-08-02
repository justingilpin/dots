
{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cifs.nix
      ./../../common/nixos-common.nix
#      ./../../../modules/nextcloud
			./../../../modules/servarr
#			./dashy.nix
#      ./../../../modules/code-server
#      ./../../common/common-packages.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "donchian"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  
  # Tailscale Mesh VPN 
  services.tailscale.enable = true;

  # Shell
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  environment.binsh = "${pkgs.dash}/bin/dash";
  users.defaultUserShell = pkgs.zsh;
  # Also check that user has shell enabled

  # Enable Docker Containers
  virtualisation.docker.enable = true;

  users.users.justin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
    useDefaultShell = true;
  };

  users.users.radarr = {
	  extraGroups = [ "wheel" "users"];
	};

	users.users.sonarr = {
	  extraGroups = [ "wheel" "users"];
	};
  
	users.users.torrenter = {
		extraGroups = [ "wheel" "users"];
	};

	users.users.bazarr = {
		extraGroups = [ "wheel" "users"];
	};

  environment.systemPackages = with pkgs; [
    lego # used for Let's Encrypt
    docker-compose
    docker
    sysstat
    clipboard-jh
    go
    traceroute
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    ffmpeg-headless
		recyclarr
#		ombi
	#	ripgrip #required for nvim
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

	services.gitea = {
		enable = true;
		database.host = "192.168.88.62";
	};

	services.audiobookshelf = {
		enable = true;
		port = 13378;
		host = "192.168.88.62";
	};

  services.prometheus = {
		enable = true;
		port = 9090;
	};

  services.uptime-kuma = {
		enable = true;
		settings = {
			HOST = "192.168.88.62";
      PORT = "3001";
		};
	};

  # Waiting for 24.11
#  services.immich = {
#    enable = true;
#    environment.IMMICH_MACHINE_LEARNING_URL = "http://192.168.88.62:3003";
#  };

  services.ombi = {
		enable = true;
		port = 3579;
	};
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 8080 ];
  # networking.firewall.trustedInterfaces = [ "docker0" ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  system.stateVersion = "24.05"; 

}

