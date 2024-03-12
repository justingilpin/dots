
{ config, unstablePkgs, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cifs.nix
      ./../../../modules/nextcloud
      ./../../../modules/jellyfin
#      ./../../../modules/code-server
#      ./../../common/common-packages.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

#  networking.hostName = "jim_simons"; # Define your hostname.
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

  environment.systemPackages = with pkgs; [
    lego # used for Let's Encrypt
    docker-compose
    docker
#    sysstat
    clipboard-jh
    go
    traceroute
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    ffmpeg-headless
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 443 8080 ];
  # networking.firewall.trustedInterfaces = [ "docker0" ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  system.stateVersion = "23.11"; 

}

