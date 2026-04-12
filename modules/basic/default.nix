# modules/basic/default.nix
#
# Simple UI addon for Hyprland. Import alongside modules/wm/hyprland.
# Swap this out for modules/shell when moving to the advanced shell setup.

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    waybar
    dunst
    libnotify   # dunst dep
    wofi
    hyprpaper
  ];

  # Waybar — systemd service with restart tuning so crash loops don't lock it
  # into failed state permanently on next Hyprland login.
  home-manager.users.justin = {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
    };
    systemd.user.services.waybar = {
      Service.RestartSec = "3s";
      Unit.StartLimitIntervalSec = 0;
    };
  };

  # Inject basic-only autostart and launcher variable into the Nix-managed
  # hyprland config. These are absent when using modules/shell — the shell
  # handles idle, notifications, and launching itself.
  home-manager.users.justin.wayland.windowManager.hyprland = {

    extraConfig = ''
      exec-once = hyprpaper & disown
      exec-once = hypridle & dunst & disown

      $menu = wofi --show drun --show-icons
      bind = $mainMod, R, exec, $menu

      # Restart waybar (basic only — not relevant with shell)
      bind = $mainMod SHIFT, Q, exec, systemctl --user restart waybar
    '';

  };
}
