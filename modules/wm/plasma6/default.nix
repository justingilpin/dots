{ config, lib, pkgs, unstablePkgs, ... }:
{
  imports =
    [

    ];

  services = {
    xserver = {
      enable = true;
      desktopManager.plasma6.enable = true;
      displayManager = {
        defaultSession = "plasma"; # 'plasmax11" for X11
        sddm = {
          enable = true;
          enableHidpi = true;
	};
      };
    };
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
#    plasma-browser-integration
    konsole
#    oxygen
  ];

  environment.systemPackages = with pkgs; [
    nv-codec-headers-12 # Sunshine NVENC Encoder
    x265 # Sunshine HEVC Encoder
    rav1e # Sunshine AV1 Encoder
    vaapiVdpau # Sunshine VAAPI Encoder
    libva-utils # Allows vapinfo to check encoders
    xdg-dbus-proxy # Dbus launch proxy for flatpak
    dbus # default dbus-launch
    wl-clipboard
  ];

}
