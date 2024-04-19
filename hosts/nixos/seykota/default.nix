{
  config,
  lib,
  pkgs,
  inputs,
  unstablePkgs,
  nixos-hardware,
  nixvim,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./amd.nix
    ./mounts.nix
    ./../../common/common-packages.nix
#    ./../../../modules/wm/plasma5
    ./../../../modules/wm/hyprland
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"]; # allows NTFS support at boot

  #  networking.hostName = "seykota"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Fixes Network error when rebuilding Nixos
  systemd.services.NetworkManager-wait-online.enable = false;

  # Services
  services.tailscale.enable = true;

  # Enable Flatpaks
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk]; ## for GTK based desktops
  ## or
  ## xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];  ## for KDE based desktops

  # Shell
  programs.zsh.enable = true; # configured in /modules/shell
  environment.shells = with pkgs; [zsh]; # Many programs look if user is a 'normal' user
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
    nssmdns = true; # Renamed to nssmdns4 in Unstable
  #  nssmdns4 = true; # Unstable only
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
#		gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

#  programs.nixvim = {
#    enable = true;
#    colorschemes.gruvbox.enable = true;
#    plugins.lightline.enable = true;
#    defaultPackage = pkgs.vimPlugins.base16-vim;
#  };

  # Enable OpenRGB
  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.motherboard = "amd";

  # USB
  services.usbmuxd.enable = true;

  users.users.justin = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    packages = with pkgs; [
      #---------Games--------------#
      lutris
      heroic
      prismlauncher
      gamemode
      gamescope
      protontricks
			wineWowPackages.waylandFull # wine for wayland
			winetricks
			pulseaudioFull # Audio for lutris and 32bit wine
#			libpulseaudio # audo for lutris
#			sof-firmware
#
      #      ckan # ksp mod manager
      mono5 #ckan requirement
      msbuild #ckan requirement
      #------Desktop Software------#

      # unstable below this line
      unstablePkgs.vscode
      #---------iPhone-------------#
      checkra1n
      ifuse
      libimobiledevice
    ];
    shell = pkgs.zsh;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  system.stateVersion = "23.11";
}
