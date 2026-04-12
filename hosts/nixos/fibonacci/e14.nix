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
}
