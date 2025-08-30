# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./e14.nix # Original is e15
      ./../../common/common-packages.nix
			./../../common/nixos-common.nix
      ./../../../modules/wm/hyprland
    ];

  # Quick fix for Obsidian to allow insecure install
    nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  # Enable for lutris
  hardware.opengl.driSupport32Bit = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ]; # allows NTFS at boot

  networking.hostName = "fibonacci"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Fixes laptop error when rebuilding Nixos
  systemd.services.systemd-udevd.restartIfChanged = true;
  
  # Enable Bluetooth typically with blueman-applet
  hardware.bluetooth.enable = true;
	hardware.bluetooth.powerOnBoot = true;
	services.blueman.enable = true;

  # Fixes Network error when rebuilding Nixos
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable Tailscale
  services.tailscale.enable = true;

  # Shell
  programs.zsh.enable = true; # configured in /modules/shell
  environment.shells = with pkgs; [ zsh ]; # Many programs look if user is a 'normal' user
  environment.binsh = "${pkgs.dash}/bin/dash";
  # Also check that user has shell enabled


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.justin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      zoom-us
      tailscale
      xclip
      xsel
      go
			stremio
			spotifywm
			gimp
      xfce.thunar
			xfce.thunar-archive-plugin # enables right click compression
			p7zip
			zip
			code-cursor-fhs
      #------ Laptop Software ------#
      brightnessctl
			blueman


    ];
    shell = pkgs.zsh;
    useDefaultShell =true;
    openssh.authorizedKeys.keys = [
  ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    git-crypt
    alacritty
    kitty
    firefox
    cifs-utils # needed for mounting samba shares
  ];

  # mount cifs truenas scale need cifs-utils package
    fileSystems."/mnt/alliance" = {
    device = "//192.168.88.156/Alliance/";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
  };

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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?

}

