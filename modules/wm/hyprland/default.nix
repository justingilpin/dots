{ config, lib, pkgs, unstablePkgs, ... }:

{

  imports =
    [

    ];

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Enable Gnome Keyring
  services.gnome.gnome-keyring.enable = true;
  # security.pam.services<yourDisplayManager>.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
#    nv-codec-headers-12 # Sunshine NVENC Encoder
#    x265 # Sunshine HEVC Encoder
#    rav1e # Sunshine AV1 Encoder
#    vaapiVdpau # Sunshine VAAPI Encoder
#    libva-utils # Allows vapinfo to check encoders
#    xdg-dbus-proxy # Dbus launch proxy for flatpak
#    dbus # default dbus-launch
    wl-clipboard
  ];

}
