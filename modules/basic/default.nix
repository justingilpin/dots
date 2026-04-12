# modules/basic/default.nix
#
# Simple UI addon for Hyprland. Import alongside modules/wm/hyprland.
# Swap this out for modules/shell when moving to the advanced shell setup.

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # Status bar
    waybar

    # Notifications
    dunst
    libnotify   # dunst dep

    # App launcher
    wofi

    # Wallpaper
    hyprpaper

  ];
}
