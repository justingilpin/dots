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

  # DisplayLink — Elgato Teleprompter USB display (17e9:ff1a)
  # evdi has no render node so Hyprland/Wayland can't use it directly.
  # Instead we run a minimal X11 server on card0 (evdi) alongside the Wayland session.
  # Launch with Super+T keybind — starts Xorg on :1 + QPrompt on the teleprompter screen.
  services.xserver.videoDrivers = [ "nvidia" "displaylink" "modesetting" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];

  # Xorg config for the evdi/DisplayLink card only (card0, platform:evdi:00)
  environment.etc."X11/teleprompter.conf".text = ''
    Section "Device"
      Identifier "DisplayLink"
      Driver     "modesetting"
      Option     "kmsdev" "/dev/dri/card0"
    EndSection

    Section "Screen"
      Identifier "Teleprompter"
      Device     "DisplayLink"
      DefaultDepth 24
      SubSection "Display"
        Depth 24
        Modes "1024x600"
      EndSubSection
    EndSection

    Section "ServerLayout"
      Identifier "TeleprompterLayout"
      Screen "Teleprompter"
    EndSection

    Section "ServerFlags"
      Option "AutoAddDevices" "false"
      Option "AutoEnableDevices" "false"
    EndSection
  '';

  environment.systemPackages = with pkgs; [
    xorg.xorgserver   # Xorg server for the teleprompter X11 session
    xorg.xinit        # startx / xinit
    xorg.xdpyinfo     # used by teleprompter-launch to wait for X to be ready

    # teleprompter-launch: start X11 on the evdi display and open QPrompt
    (pkgs.writeShellScriptBin "teleprompter-launch" ''
      # Kill any existing teleprompter X session
      sudo pkill -f "Xorg :1" 2>/dev/null
      sleep 0.5

      # Must run as root to open a virtual console from within a Wayland session
      sudo ${pkgs.xorg.xorgserver}/bin/Xorg :1 \
        -config /etc/X11/teleprompter.conf \
        vt5 -nolisten tcp -noreset &
      echo $! > /tmp/teleprompter-xorg.pid

      # Wait for X to be ready (up to 10s)
      for i in $(seq 1 20); do
        DISPLAY=:1 ${pkgs.xorg.xdpyinfo}/bin/xdpyinfo &>/dev/null && break
        sleep 0.5
      done

      # Unset WAYLAND_DISPLAY so Qt uses X11 instead of Wayland
      DISPLAY=:1 WAYLAND_DISPLAY="" flatpak run com.cuperino.qprompt &
    '')

    (pkgs.writeShellScriptBin "teleprompter-stop" ''
      pkill -f "com.cuperino.qprompt" 2>/dev/null
      pkill -f "Xorg :1" 2>/dev/null
      rm -f /tmp/teleprompter-xorg.pid
    '')
  ];

  # Enable OpenRGB
  # services.hardware.openrgb.enable = true;
  # services.hardware.openrgb.motherboard = "amd";

  # USB
  services.usbmuxd.enable = true;

  # Allow justin to start/stop the Xorg teleprompter session without a password prompt
  security.sudo.extraRules = [{
    users = [ "justin" ];
    commands = [
      { command = "${pkgs.xorg.xorgserver}/bin/Xorg"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/pkill"; options = [ "NOPASSWD" ]; }
    ];
  }];

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
