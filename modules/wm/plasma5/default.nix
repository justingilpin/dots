{ config, lib, pkgs, unstablePkgs, ... }:

{

  imports =
    [

    ];

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.enable = true; # X11
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
#  services.xserver.displayManager.sddm.wayland.enable = true; # Enable for Wayland 
#  services.xserver.desktopManager.defaultSession = "plasma"; # For wayland enable 'plasmawayland' 

}
