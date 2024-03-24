
{ config, lib, pkgs, inputs, unstablePkgs, nixos-hardware, ... }:


{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./amd.nix
      ./mounts.nix
      ./../../common/common-packages.nix
      ./../../../modules/wm/plasma6
#      ./../../../modules/nvim
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ]; # allows NTFS support at boot

#  networking.hostName = "seykota"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Fixes desktop error when rebuilding Nixos
  systemd.services.NetworkManager-wait-online.enable = false; 

  # Services
  services.tailscale.enable = true;
  services.flatpak.enable = true;

  # Shell
  programs.zsh.enable = true; # configured in /modules/shell
  environment.shells = with pkgs; [ zsh ]; # Many programs look if user is a 'normal' user
  environment.binsh = "${pkgs.dash}/bin/dash";
  users.defaultUserShell = pkgs.zsh;
  # Also check that user has shell enabled

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable Printer Auto Discovery
  services.avahi = {
    enable = true;
    # nssmdns = true; # Renamed to nssmdns4 in Unstable
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
#  security.rtkit.enable = true;
#  services.pipewire = {
#    enable = true;
#    alsa.enable = true;
#    alsa.support32Bit = true;
#    pulse.enable = true;
    #jack.enable = true;
#  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable OpenRGB
  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.motherboard = "amd";

  # USB
  services.usbmuxd.enable = true;

  users.users.justin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager"]; 
    packages = with pkgs; [
    #---------Games--------------#
      lutris
      heroic
      prismlauncher
      gamemode
      gamescope
      protontricks
#      ckan # ksp mod manager
      mono5 #ckan requirement
      msbuild #ckan requirement
    #------Desktop Software------#

      # unstable below this line
      unstablePkgs.vscode
      unstablePkgs.obsidian
    #---------iPhone-------------#
      checkra1n
      ifuse
      libimobiledevice
    ];
   shell = pkgs.zsh;
   useDefaultShell =true;
    openssh.authorizedKeys.keys = [
    # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
  ];
  };

#  environment.systemPackages = with pkgs; [
#    wget
#    git
#    git-crypt
#  ];

#  virtualisation.libvirtd.enable = true;
#  virtualisation.spiceUSBRedirection.enable = true;
#  virtualisation =
#  {
#    docker = {
#      enable = true;
#      autoPrune = {
#        enable = true;
#        dates = "weekly";
#      };
#    };
#  };

#  programs.gnupg.agent = {
#    enable = true;
#    enableSSHSupport = true;
#  };

  # Enable the OpenSSH daemon.
#  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  system.stateVersion = "23.11"; 
}
