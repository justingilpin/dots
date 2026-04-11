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

    # For RTX 4070 Ti, this is usually the right first thing to try.
    # If it causes trouble on your exact setup, flip it to false.
    open = true;
  };

  boot.blacklistedKernelModules = [ "nouveau" ];
}
