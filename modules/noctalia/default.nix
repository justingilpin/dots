# modules/noctalia/default.nix
#
# Noctalia shell — a minimal Quickshell-based Wayland desktop shell.
# https://github.com/noctalia-dev/noctalia-shell
# https://docs.noctalia.dev/getting-started/nixos/
#
# Import instead of modules/basic or modules/shell.
# Host swap example (fibonacci/default.nix):
#
#   # ./../../../modules/basic
#   # ./../../../modules/shell
#   ./../../../modules/noctalia   # <--- Active
#
# NOTE: Noctalia requires nixpkgs-unstable (it depends on the latest Quickshell).
#       The flake.nix wires inputs.noctalia to follow nixpkgs-unstable.
#
# OWNERSHIP MODEL: Noctalia is configured declaratively through the home-manager
#   module below (programs.noctalia-shell). Settings are stored as a read-only
#   symlink at ~/.config/noctalia/settings.json generated from your Nix config.
#   To capture GUI changes back into Nix, run:
#     noctalia-shell ipc call state all | jq .settings
#   then paste the relevant values into the settings block below.

{ pkgs, lib, inputs, ... }:

{
  # ── Services required by Noctalia features ────────────────────────────────
  # wifi, bluetooth, battery, and power-profile widgets need these enabled.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # ── Noctalia for justin ───────────────────────────────────────────────────
  home-manager.users.justin = { lib, ... }: {
    # Note: inputs.noctalia.homeModules.default is already imported globally in flake.nix
    # — no need to re-import here.

    programs.noctalia-shell = {
      enable = true;

      # ── Shell settings ───────────────────────────────────────────────────
      # Full options reference:
      # https://github.com/noctalia-dev/noctalia-shell/blob/main/Assets/settings-default.json
      #
      # To get your current live settings (after tweaking in the GUI):
      #   noctalia-shell ipc call state all | jq .settings
      settings = {
        general = {
          avatarImage = "/home/justin/.face";
        };

        location = {
          name = "Davao City, Philippines";
        };

        bar = {
          position = "top";
          density = "default";
        };

        # Wallpaper directory — points to your existing wallpaper folder
        wallpaper = {
          directory = "/home/justin/Pictures/Wallpapers";
        };
      };

      # ── Plugin sources ───────────────────────────────────────────────────
      # Uncomment to enable the official plugin registry.
      # plugins = {
      #   sources = [
      #     {
      #       enabled = true;
      #       name = "Official Noctalia Plugins";
      #       url = "https://github.com/noctalia-dev/noctalia-plugins";
      #     }
      #   ];
      # };
    };

    # ── Hyprland integration for Noctalia ───────────────────────────────
    wayland.windowManager.hyprland.extraConfig = ''
      # Launch Noctalia and hypridle on Hyprland start
      exec-once = noctalia-shell
      exec-once = hypridle & disown

      # ── Noctalia IPC keybinds ────────────────────────────────────────
      bind = $mainMod, R,           exec, noctalia-shell ipc call launcher toggle
      bind = $mainMod, D,           exec, noctalia-shell ipc call controlCenter toggle
      bind = $mainMod SHIFT, E,     exec, noctalia-shell ipc call sessionMenu toggle
      bind = $mainMod, F1,          exec, noctalia-shell ipc call controlCenter toggle
      bind = $mainMod, F2,          exec, noctalia-shell ipc call settings toggle
      bind = $mainMod, F3,          exec, noctalia-shell ipc call launcher clipboard
      bind = $mainMod, F4,          exec, noctalia-shell ipc call sessionMenu toggle

      # Restart Noctalia shell
      bind = $mainMod SHIFT, Q,     exec, systemctl --user restart noctalia-shell
    '';

  }; # end home-manager.users.justin

}
