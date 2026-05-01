{ ... }:

{
  # Desktop hypridle — locks and conditionally turns displays off.
  home-manager.users.justin.home.file.".config/hypr/hypridle.conf".source =
    ../../../modules/hyprland/hypridle-desktop.conf;
}
