{ pkgs, ... }:

{
  imports = [
    ./../../common/pc/laptop/ssd
    ./../../common/pc/laptop/acpi_call.nix
  ];

  # ThinkPad E14 — use latest kernel for better Tiger Lake / hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    # Force use of the thinkpad_acpi driver for backlight control.
    # This allows the backlight save/load systemd service to work.
    "acpi_backlight=native"
  ];

  # Firmware — load redistributable blobs (Intel WiFi, BT, GPU) and enable LVFS updates
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # RTKit — realtime scheduling for pipewire (fixes RTKit DBus errors at boot)
  security.rtkit.enable = true;

  # UPower — battery info for wireplumber and other desktop services
  services.upower.enable = true;

  # Zram swap — increase to 50% RAM (3.75GB) to give more headroom for VS Code + Chromium
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  # Kill memory hogs before the system hard-freezes
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;   # kill when free mem drops below 5%
    freeSwapThreshold = 5;  # kill when free swap drops below 5%
    enableNotifications = true;
  };

  # Tune kernel to swap earlier and avoid hard freezes under memory pressure
  boot.kernel.sysctl = {
    "vm.swappiness" = 60;        # default is 60, tuned for zram
    "vm.vfs_cache_pressure" = 50; # keep more file cache, reduce swap pressure
  };
}
