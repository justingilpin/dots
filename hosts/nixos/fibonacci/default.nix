# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, nixpkgs-unstable, unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./e15.nix
      ./../../common/common-packages.nix
      ./../../common/nixos-common.nix
      ./../../common/pc/laptop
      ./../../../modules/wm/hyprland

     # Pick One Shell or Bar
     # ./../../../modules/basic
      ./../../../modules/noctalia

      # Trading / backtesting: environment managed via Docker Compose in infra/
      # See ~/Automation/Backtesting Engine/infra/docker-compose.yml
    ];

  # Quick fix for Obsidian to allow insecure install
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  # Graphics / 32-bit support / Enable for Lutris
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ]; # allows NTFS at boot


  networking.hostName = "fibonacci"; # Define your hostname.

  # Dual-boot time fix — keep hardware clock in local time so Windows and NixOS agree
  time.hardwareClockInLocalTime = true;
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
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ]; # Many programs look if user is a 'normal' user
  environment.binsh = "${pkgs.dash}/bin/dash";
  # Also check that user has shell enabled


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound. Old audio 24.05
#  sound.enable = true;
#  hardware.pulseaudio.enable = true;

  # Audio
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.justin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tailscale
      xclip
      xsel
      go
			spotify
			gimp
			p7zip
			zip
			unstable.claude-code
			unstable.code-cursor
			nodejs_20 # required for some MCP's that run in code-cursor
#			wgnord # nord vpn helper with wireguard
      #------ Laptop Software ------#
      brightnessctl
			blueman
			pamixer # volume control
			grim # screenshots
			slurp # area selection
#			speedtest-cli # simple terminal internet tester

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

  systemd.tmpfiles.rules = [
    "d /var/lib/wgnord 0755 root root -"
    "d /etc/wireguard 0700 root root -"
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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;

  system.stateVersion = "24.05"; # Did you read the comment?

}
