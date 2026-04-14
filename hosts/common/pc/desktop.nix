{ ... }:

{
  # Desktop hypridle — no backlight dim, no suspend; screen off is enough
  home-manager.users.justin.home.file.".config/hypr/hypridle.conf".source =
    ../../../modules/hyprland/hypridle-desktop.conf;
}
