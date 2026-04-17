{ config, lib, pkgs, ... }:
{

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.nvidia-vaapi-driver ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
    # Keeps the GPU initialized across suspend/resume and DPMS cycles.
    powerManagement.enable = true;
    # Fine-grained power management — allows GPU to fully power down when idle.
    # Helps prevent the "flip event timeout" and "failed atomic modeset" errors
    # seen on Hyprland login after long idle periods on NVIDIA.
    powerManagement.finegrained = false;
  };

  # Disable atomic commits for NVIDIA — fixes "Failed to apply atomic modeset"
  # and black screen after logging in from greetd on Wayland + NVIDIA.
  environment.sessionVariables.WLR_DRM_NO_ATOMIC = "1";

  boot.blacklistedKernelModules = [ "nouveau" ];
}
