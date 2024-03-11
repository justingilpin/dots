
{ config, lib, pkgs, unstablePkgs, nixos-hardware, ... }:


{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./amd.nix
      ./mounts.nix
      ./../../common/common-packages.nix
      ./../../../modules/wm/plasma6
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ]; # allows NTFS support at boot

  networking.hostName = "seykota"; # Define your hostname.
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

  # Enable the Plasma 5 Desktop Environment.
#  services.xserver.enable = true; # X11
#  services.xserver.displayManager.sddm.enable = true;
#  services.xserver.displayManager.sddm.wayland.enable = true; # Enable Wayland commit out for X11
#  services.xserver.desktopManager.plasma5.enable = true;
#  services.xserver.displayManager.defaultSession ="plasma"; # Enable Wayland 'plasmawayland'
#  services.xserver.desktopManager.wallpaper.mode = "fill";

  #nixpkgs.config.permittedInsecurePackages = [
  #  "electron-25.9.0"
  #];

#  nixpkgs.config.permittedInsecurePackages = [
#    "electron-25.9.0"
#  ];

  # Enable Plasma 6
#  services.xserver.enable = true;
#  services.xserver.displayManager.sddm.enable = true;
#  services.xserver.desktopManager.plasma6.enable = true;
#  services.xserver.displayManager.defaultSession = "plasma"; #'plasmax11' for X11 default plasma

#  environment.plasma6.excludePackages = with pkgs.kdePackages; [
#    plasma-browser-integration
#    konsole
#    oxygen
#  ];


  # Enable Sunshine at Boot
#  security.wrappers.sunshine = {
#    owner = "root";
#    group = "root";
#    capabilities = "cap_sys_admin+p";
#    source = "${pkgs.sunshine}/bin/sunshine";
#  };

#  systemd.user.services.sunshine =
#    {
#      description = "sunshine";
#      wantedBy = [ "graphical-session.target" ];
#      serviceConfig = {
#      ExecStart = "${config.security.wrapperDir}/sunshine";
#    };
#  };

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

  users.users.justin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager"]; 
    packages = with pkgs; [
#      zoom-us
#      obsidian
#      heroic
#      prismlauncher
#      xsel
#      xclip
#      dig
#      go
#      sunshine
#      ffmpeg #encoder
#      mesa
#      ntfs3g
    #---------Games--------------#
      lutris
      heroic
      prismlauncher
      gamemode
      gamescope

      # unstable below this line
#      unstablePkgs.vscode
      unstablePkgs.obsidian

#      unstable.hello

      # Wayland
#      wlroots
#      wlrctl
#      vaapiVdpau #encoder
#      vaapi-intel-hybrid #encoder
#      nv-codec-headers-12 # encoder
#      x265 # encoder
#      blender-hip # 3D Creation using HIP enabled in AMD.nix
#      clinfo # OpenCL info
#      gpu-viewer
 #     warp-terminal
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
#    alacritty
#    firefox
#    cifs-utils # needed for mounting samba shares
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

  # KDE apps
#  programs.partition-manager.enable = true;
#  programs.kdeconnect.enable = true;

#  programs.gnupg.agent = {
#    enable = true;
#    enableSSHSupport = true;
#  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
#  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?

}
