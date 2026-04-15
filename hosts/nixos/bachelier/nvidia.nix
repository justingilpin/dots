{ config, lib, pkgs, ... }:
{

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
    # Keeps the GPU initialized across DPMS sleep/wake cycles.
    # Without this, the screen can wake to a black/dim image on Wayland.
    powerManagement.enable = true;
  };

  boot.blacklistedKernelModules = [ "nouveau" ];
}
