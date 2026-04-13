# modules/basic/default.nix
#
# Simple UI addon for Hyprland. Import alongside modules/wm/hyprland.
# Swap this out for modules/shell when moving to the advanced shell setup.

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    waybar
    dunst
    libnotify          # dunst dep
    wofi
    hyprpaper
    networkmanagerapplet
    blueman
  ];

  # Inject basic-only autostart and launcher variable into the Nix-managed
  # hyprland config. These are absent when using modules/shell — the shell
  # handles idle, notifications, and launching itself.
  home-manager.users.justin.wayland.windowManager.hyprland = {

    extraConfig = ''
      exec-once = hyprpaper & disown
      exec-once = hypridle & dunst & disown
      exec-once = nm-applet --indicator & disown
      exec-once = blueman-applet

      $menu = wofi --show drun --show-icons
      bind = $mainMod, R, exec, $menu

      # Restart waybar (basic only — not relevant with shell)
      bind = $mainMod SHIFT, Q, exec, systemctl --user restart waybar

    '';

  };
}
