{ config, lib, ... }:

{
  imports = [ ../. ];

  # Gnome 40 introduced a new way of managing power, without tlp.
  # However, these 2 services clash when enabled simultaneously.
  # https://github.com/NixOS/nixos-hardware/issues/260
  services.tlp.enable = lib.mkDefault ((lib.versionOlder (lib.versions.majorMinor lib.version) "21.05")
                                       || !config.services.power-profiles-daemon.enable);

  # Laptop hypridle — dims backlight and suspends after 30 min idle
  home-manager.users.justin.home.file.".config/hypr/hypridle.conf".source =
    ../../../../modules/hyprland/hypridle-laptop.conf;
}
