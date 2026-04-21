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
  boot.kernelParams = [ "amd_pstate=active" "consoleBlank=300" "mem_sleep_default=s2idle" ];
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

  # gnome-keyring is enabled in modules/wm/hyprland; PAM unlock via greetd is in nixos-common.nix

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
  # xhci_hcd quirks=0x80000 — XHCI_RESET_ON_RESUME: force full controller reset on resume
  # to fix "xHC error in resume, USBSTS 0x401" on the AMD 500 Series USB controller (PTXH)
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8219 device_setup=1
    options xhci_hcd quirks=0x80000
  '';

  # Suspend wakeup — only allow XHC0 (the USB controller the keyboard is on) to wake.
  # XHC0 = 0000:09:00.3, which is the bus the Razer BlackWidow Elite is connected to.
  # tmpfiles can't write the same path multiple times, so a oneshot service is used instead.
  systemd.services.disable-wakeup-sources = {
    description = "Disable ACPI wakeup sources except keyboard USB controller";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.gnugrep ];
    script = ''
      disable() {
        local dev=$1
        if grep -q "^$dev .*\*enabled" /proc/acpi/wakeup; then
          echo "$dev" > /proc/acpi/wakeup
        fi
      }
      disable GP13
      disable GPP0
      disable GPP8
      disable PT24
      disable PT28
      disable PT29
      disable PTXH
    '';
  };

  # AMD 500 Series USB controller (0000:02:00.0) throws USBSTS 0x401 on resume,
  # causing an immediate phantom wakeup. Rebinding the driver after suspend clears it.
  systemd.services.fix-xhci-resume = {
    description = "Rebind AMD 500 Series USB controller after resume to fix USBSTS 0x401";
    # Use post-sleep hook — wantedBy suspend.target causes a lingering start job
    # that blocks shutdown after resume.
    wantedBy = [ "post-sleep.target" ];
    after = [ "post-sleep.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      echo "0000:02:00.0" > /sys/bus/pci/drivers/xhci_hcd/unbind 2>/dev/null || true
      sleep 0.5
      echo "0000:02:00.0" > /sys/bus/pci/drivers/xhci_hcd/bind 2>/dev/null || true
    '';
  };

  # Restore Scarlett 2i2 audio after resume — the USB audio driver loses state
  # on suspend. Reload snd_usb_audio then restart wireplumber as the user so
  # pipewire re-enumerates the device with the correct profile.
  systemd.services.fix-audio-resume = {
    description = "Reload USB audio and restart wireplumber after resume";
    wantedBy = [ "post-sleep.target" ];
    after = [ "post-sleep.target" "fix-xhci-resume.service" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.kmod pkgs.coreutils pkgs.systemd ];
    script = ''
      modprobe -r snd_usb_audio || true
      sleep 1
      modprobe snd_usb_audio || true
      sleep 1
      runuser -l justin -c 'XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus systemctl --user restart wireplumber'
    '';
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
    extraCompatPackages = [
      pkgs.proton-ge-bin
      (pkgs.stdenvNoCC.mkDerivation {
        pname = "proton-ge-bin";
        version = "GE-Proton10-34";
        src = pkgs.fetchurl {
          url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-34/GE-Proton10-34.tar.gz";
          hash = "sha256-UcWAtmqDPHOZj+APBxfurFcZdlQECi8u1RiePuaNdz0=";
        };
        installPhase = ''
          mkdir -p $out
          cp -r . $out/
        '';
      })
    ];
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


  # OpenRGB — controls RGB for Logitech G403 Hero and Razer BlackWidow
  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.motherboard = "amd";
  # After rebuild, run once to set static color D79921 (215,153,33):
  #   openrgb --noautoconnect -c D79921 --mode static
  environment.systemPackages = with pkgs; [ openrgb-with-all-plugins ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.xpadneo.enable = true; # Xbox controller Bluetooth driver

  # Prevent idle/lock/suspend while a Steam game is running.
  # Xbox controller input is not a Wayland seat event so the idle timer runs
  # even during active gameplay. This service polls hyprctl every 10 s and
  # holds a systemd idle+sleep inhibitor for the duration of any steam_app_*.
  systemd.user.services.steam-idle-inhibit = {
    description = "Inhibit idle and suspend while a Steam game is running";
    wantedBy = [ "default.target" ];
    path = [ pkgs.hyprland pkgs.python3 pkgs.systemd ];
    serviceConfig = {
      Type      = "simple";
      Restart   = "always";
      RestartSec = "5s";
    };
    script = ''
      while true; do
        if hyprctl clients -j 2>/dev/null | python3 -c "
import sys, json, re
clients = json.load(sys.stdin)
# Only count a game as 'running' if the window is mapped, not hidden,
# and on a real workspace (id > 0) — this excludes steam tray/minimised windows.
def is_active_game(c):
    return (re.match(\"steam_app_\", c.get(\"class\", \"\"))
            and c.get(\"mapped\", False)
            and not c.get(\"hidden\", True)
            and c.get(\"workspace\", {}).get(\"id\", -1) > 0)
exit(0 if any(is_active_game(c) for c in clients) else 1)
        " 2>/dev/null; then
          systemd-inhibit \
            --what=idle:sleep \
            --who=steam-idle-inhibit \
            --why="Steam game is running" \
            --mode=block \
            sleep 10
        else
          sleep 10
        fi
      done
    '';
  };

  # USB
  services.usbmuxd.enable = true;
  systemd.services.usbmuxd.serviceConfig.TimeoutStopSec = lib.mkForce "5s"; # default 1m30s causes slow shutdown

  # Reduce global stop timeout — default 1m30s causes long shutdown delays when
  # services or user processes (e.g. whisper-server) don't exit cleanly.
  systemd.settings.Manager.DefaultTimeoutStopSec = "15s";
  systemd.user.extraConfig = "DefaultTimeoutStopSec=15s";

  # udev rules — Stream Deck access + Razer BlackWidow wakeup from suspend
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", GROUP="plugdev", MODE="0660", TAG+="uaccess"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{product}=="Razer BlackWidow Elite", ATTR{power/wakeup}="enabled"
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
      #---------Audio--------------#
      pwvucontrol               # PipeWire volume control (audio mixer GUI)
      #---------Elgato / Streaming--------------#
      streamdeck-ui             # Stream Deck MK.2 button configuration GUI
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
