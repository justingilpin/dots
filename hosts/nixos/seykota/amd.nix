{ config, lib, pkgs, ... }:
{

  # Enable Vulkan — hardware.opengl renamed to hardware.graphics in NixOS 25.11
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # amdvlk removed in 25.11 (deprecated by AMD); RADV is the default Vulkan driver
  };
  # AMD Kernel
  boot.initrd.kernelModules = [ "amdgpu" ];
  # XServer
  services.xserver.videoDrivers = ["amdgpu"];

  # HIP
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
}

