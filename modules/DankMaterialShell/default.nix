# modules/DankMaterialShell/default.nix
#
# DankMaterialShell — a Material Design 3 Quickshell-based Wayland desktop shell.
# https://github.com/AvengeMedia/DankMaterialShell
#
# Import instead of modules/basic or modules/shell.
# Host swap example (fibonacci/default.nix):
#
#   # ./../../../modules/basic
#   # ./../../../modules/shell
#   ./../../../modules/DankMaterialShell   # <--- Active
#
# NOTE: DankMaterialShell requires nixpkgs-unstable (depends on latest Quickshell).
#       The flake.nix wires inputs.dms to follow nixpkgs-unstable.

{ pkgs, lib, inputs, ... }:

{
  # ── Services required by DMS features ────────────────────────────────────
  # Battery, power profiles, and UPower-based widgets need these enabled.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # ── DankMaterialShell for justin ──────────────────────────────────────────
  home-manager.users.justin = { lib, ... }: {
    # Note: inputs.dms.homeModules.dank-material-shell is already imported globally in flake.nix
    # — no need to re-import here.

    programs.dank-material-shell = {
      enable = true;
    };

    # ── Disable waybar — DMS provides its own bar ────────────────────────
    programs.waybar.enable = lib.mkForce false;

    # ── Hyprland integration for DankMaterialShell ───────────────────────
    wayland.windowManager.hyprland.extraConfig = ''
      # Launch DMS on Hyprland start
      exec-once = dms run

      # Prevent animation flicker on DMS layers
      layerrule = no_anim on, match:namespace ^(dms)
      windowrule = float on, match:class ^(org.quickshell)

      # DMS IPC keybinds
      bind = $mainMod, space,       exec, dms ipc call spotlight focusOrToggle
      bind = $mainMod, V,           exec, dms ipc call clipboard toggle
      bind = $mainMod, M,           exec, dms ipc call processlist focusOrToggle
      bind = $mainMod, comma,       exec, dms ipc call settings focusOrToggle
      bind = $mainMod, N,           exec, dms ipc call notifications toggle
      bind = $mainMod, TAB,         exec, dms ipc call hypr toggleOverview
      bind = $mainMod ALT, L,       exec, dms ipc call lock lock

      # Media / volume / brightness (bindel = repeatable on hold)
      bindel = , XF86AudioRaiseVolume,   exec, dms ipc call audio increment 3
      bindel = , XF86AudioLowerVolume,   exec, dms ipc call audio decrement 3
      bindl  = , XF86AudioMute,          exec, dms ipc call audio mute
      bindel = , XF86MonBrightnessUp,    exec, dms ipc call brightness increment 5
      bindel = , XF86MonBrightnessDown,  exec, dms ipc call brightness decrement 5
    '';

  }; # end home-manager.users.justin

}
