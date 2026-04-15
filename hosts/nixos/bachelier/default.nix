{
  config,
  lib,
  pkgs,
  inputs,
  nixpkgs-unstable,
  nixos-hardware,
  nixvim,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvidia.nix
    ./mounts.nix
    ./../../common
    ./../../common/pc/desktop.nix
#    ./../../../modules/wm/plasma5
    ./../../../modules/wm/hyprland

# Choose One Shell or Bar
   # ./../../../modules/basic
    ./../../../modules/noctalia
  #  ./../../../modules/shell
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs" "exfat"]; # allows NTFS and exFAT support at boot

  # AMD Ryzen 7800X3D — use amd-pstate active mode for optimal boost clock management.
  # "active" lets the CPU firmware (CPPC) self-manage clocks rather than the kernel,
  # which gives better single-core boost critical for gaming on 3D V-Cache CPUs.
  # consoleBlank=300 — blanks the TTY/greeter screen after 5 minutes of inactivity.
  # This covers the greetd login screen which has no Wayland compositor for DPMS.
  boot.kernelParams = [ "amd_pstate=active" "consoleBlank=300" ];
  powerManagement.cpuFreqGovernor = "performance";

  networking.hostName = "bachelier"; # Define your hostname.
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

  # Keyring — fixes VS Code "OS keyring couldn't be identified" dialog on Hyprland
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

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
#    nssmdns = true; # Renamed to nssmdns4 in Unstable
    nssmdns4 = true; # Unstable and future versions
    openFirewall = true;
  };

  # Scarlett 4th Gen — enable enhanced kernel driver with full mixer/routing support
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8215 device_setup=1
  '';

  # Enable sound.
 # hardware.pulseaudio = { 
#		enable = true;
#		support32Bit = true;
#	};
  #  security.rtkit.enable = true;
  services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
  #jack.enable = true;
    };
  
  zramSwap.enable = true; # Faster compression swap 

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    # Proton-GE: install into compatibilitytools.d so Steam lists it as a Proton version.
    # Select it per-game in Steam → game properties → Compatibility.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Gamemode — lets games request CPU/GPU performance boost while running
  programs.gamemode.enable = true;

#  programs.nixvim = {
#    enable = true;
#    colorschemes.gruvbox.enable = true;
#    plugins.lightline.enable = true;
#    defaultPackage = pkgs.vimPlugins.base16-vim;
#  };

  # DisplayLink (Elgato Teleprompter) — disabled.
  # DisplayLink + NVIDIA + Hyprland/Wayland is unsupported — evdi has no render node
  # so Hyprland cannot output to it. Xorg-based approach hijacks the VT and kills the session.
  # Revisit if Hyprland adds evdi/DisplayLink support in the future.


  # Enable OpenRGB
  # services.hardware.openrgb.enable = true;
  # services.hardware.openrgb.motherboard = "amd";

  # USB
  services.usbmuxd.enable = true;

  # Stream Deck udev rules — allows justin to access the device without root.
  # streamdeck-ui reads/writes the HID device directly.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", GROUP="plugdev", MODE="0660", TAG+="uaccess"
  '';
  users.groups.plugdev = {};

  # OBS Studio with useful plugins for streaming/recording with Cam Link 4K
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs                     # Wayland screen capture
      obs-pipewire-audio-capture # PipeWire audio capture
      obs-vkcapture              # Vulkan/game capture
    ];
  };

  users.users.justin = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker" "plugdev" "video"];
    packages = with pkgs; [
     #  google-chrome
     #  gimp
      chromium
      krita
      #---------Elgato / Streaming--------------#
      streamdeck-ui             # Stream Deck MK.2 button configuration GUI
      alsa-scarlett-gui         # Hardware mixer/gain control for Focusrite Scarlett 2i2
      scarlett2                 # Firmware management for Scarlett 4th Gen (enables PCM routing)
      # Teleprompter: install QPrompt via Flatpak after rebuild:
      #   flatpak install flathub com.cuperino.qprompt
      # QPrompt has voice-following scroll via built-in speech recognition.
      #---------Games--------------#
      lutris
      heroic
      prismlauncher
      gamemode
      gamescope
      protontricks
      wineWowPackages.waylandFull # wine for wayland
      winetricks
      dxvk # wine dependency for star citizen
#			pulseaudioFull # Audio for lutris and 32bit wine
#			libpulseaudio # audo for lutris
#			sof-firmware
#
      #      ckan # ksp mod manager
      mono5 #ckan requirement
      msbuild #ckan requirement
      #------Desktop Software------#

      # unstable below this line
   #   (nixpkgs-unstable.lib.getPackages pkgs).vscode
      #---------iPhone-------------#
      checkra1n
      ifuse
      libimobiledevice
    ];

  # Example of adding an unstable package
 # environment.systemPackages = with pkgs; [
    # Existing stable packages...
#    (nixpkgs-unstable.lib.getPackages pkgs).firefox  # Example of adding Firefox from unstable
#  ];

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

  system.stateVersion = "24.05";
}
