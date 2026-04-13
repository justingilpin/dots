# modules/wm/hyprland/default.nix
#
# Core Hyprland compositor — always loaded.
# Pair with modules/basic (simple UI) or modules/shell (advanced UI).
#
# hyprland.conf is managed here via wayland.windowManager.hyprland.settings.
# basic/default.nix appends its own exec-once lines (hypridle, dunst) via extraConfig.
# shell/default.nix does not — the shell manages idle and notifications itself.

{ pkgs, lib, ... }:

{
  imports = [
    # ./hyprlock.nix  # home-manager hyprlock config — currently unused (using conf symlink)
  ];

  # ── Compositor (NixOS side) ────────────────────────────────────────────────
  programs.hyprland.enable = true;

  # ── XDG portals ────────────────────────────────────────────────────────────
  # Mask xdg-desktop-portal-gtk — causes ~25s tray startup delay alongside hyprland portal.
  systemd.user.services.xdg-desktop-portal-gtk.wantedBy = lib.mkForce [];
  xdg.portal.extraPortals = lib.mkForce [ pkgs.xdg-desktop-portal-hyprland ];

  # ── Session security ────────────────────────────────────────────────────────
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # ── System packages ─────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland
    adwaita-icon-theme
    gtkmm3
    gtk3
    polkit_gnome
    hyprlock
    hypridle
    hyprlang
    wlr-protocols
    mesa
    sdbus-cpp
    pipewire
    wireplumber
    grim
    slurp
    pamixer
    brightnessctl
    kitty
  ];

  # ── Hyprland config (home-manager side) ────────────────────────────────────
  # Generates ~/.config/hypr/hyprland.conf — replaces the static file symlink.
  # basic/default.nix and shell/default.nix append to extraConfig as needed.
  home-manager.users.justin = {

    wayland.windowManager.hyprland = {
      enable   = true;
      systemd.enable = false; # we manage session target ourselves via exec-once below

      settings = {

        monitor = ",highres,auto,1";

        # ── Autostart ─────────────────────────────────────────────────────────
        # hypridle and dunst are intentionally NOT here — basic/default.nix adds
        # them via extraConfig so they are absent when using modules/shell instead.
        exec-once = [
          # hyprpaper is basic-only — shell manages wallpaper itself via its own daemon.
          # hypridle and dunst are basic-only — shell manages idle/notifications itself.
          # Both are appended via extraConfig from their respective module.
          # nm-applet and blueman-applet are basic-only — shell has its own network/bluetooth widgets.
          # Both are appended via extraConfig from modules/basic.
          # Export wayland env then activate session target so systemd services
          # (waybar, caelestia, etc.) have WAYLAND_DISPLAY set before starting.
          "systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP && systemctl --user start --no-block hyprland-session.target"
        ];

        # ── Variables ─────────────────────────────────────────────────────────
        "$terminal"   = "alacritty";
        "$fileManager" = "thunar";
        "$browser"    = "firefox";
        # $menu is set in basic/default.nix (wofi) — shell provides its own launcher

        # ── Environment ───────────────────────────────────────────────────────
        env = [
          "XCURSOR_THEME,Adwaita"
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt5ct"
        ];

        # ── Input ─────────────────────────────────────────────────────────────
        input = {
          kb_layout          = "us";
          follow_mouse       = 1;
          numlock_by_default = true;
          sensitivity        = 0;
          touchpad.natural_scroll = false;
        };

        # ── General ───────────────────────────────────────────────────────────
        general = {
          gaps_in    = 5;
          gaps_out   = 15;
          border_size = 2;
          # col.active_border / col.inactive_border intentionally omitted — stylix sets these from the active theme
          layout = "dwindle";
        };

        # ── Decoration ────────────────────────────────────────────────────────
        decoration = {
          rounding           = 10;
          inactive_opacity   = 1.0;
          fullscreen_opacity = 1.0;
          blur = {
            enabled  = true;
            size     = 3;
            passes   = 1;
            vibrancy = 0.1696;
          };
          shadow = {
            enabled      = true;
            range        = 4;
            render_power = 3;
            # color intentionally omitted — stylix sets this from the active theme
          };
        };

        # ── Animations ────────────────────────────────────────────────────────
        animations = {
          enabled = true;
          bezier   = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows,     1, 7, myBezier"
            "windowsOut,  1, 5, default, popin 80%"
            "border,      1, 5, default"
            "borderangle, 1, 8, default"
            "fade,        1, 8, default"
            "workspaces,  1, 6, default"
          ];
        };

        # ── Layouts ───────────────────────────────────────────────────────────
        dwindle = {
          pseudotile     = true;
          preserve_split = true;
        };

        # ── Misc ──────────────────────────────────────────────────────────────
        misc = {
          force_default_wallpaper = 0;
        };

        ecosystem.no_update_news = true;

        debug.disable_logs = false;

        # ── Window rules ──────────────────────────────────────────────────────
        windowrulev2 = "immediate, class:^(cs2)$";

        # ── Keybinds ──────────────────────────────────────────────────────────
        "$mainMod" = "SUPER";

        bind = [
          # Core
          "$mainMod, Return, exec, $terminal"
          "$mainMod, B,      exec, $browser"
          "$mainMod SHIFT, C, killactive,"
          "$mainMod, M,      exit,"
          "$mainMod, F,      fullscreen"
          "$mainMod, E,      exec, $fileManager"
          "$mainMod, V,      togglefloating,"
          # $mainMod R — launcher bind set by basic (exec $menu) or shell (global shortcut)
          "$mainMod, P,      pseudo,"
          "$mainMod, Space,  togglesplit,"

          # Focus (vim keys)
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          # Resize
          "$mainMod SHIFT, l, resizeactive,  15 0"
          "$mainMod SHIFT, h, resizeactive, -15 0"
          "$mainMod SHIFT, k, resizeactive, 0 -15"
          "$mainMod SHIFT, j, resizeactive, 0  15"

          # Workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move to workspace
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Scratchpad
          "$mainMod, S,       togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"

          # Scroll through workspaces
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up,   workspace, e-1"

          # Hardware — brightness
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"

          # Hardware — volume
          ",XF86AudioRaiseVolume, exec, pamixer -i 5"
          ",XF86AudioLowerVolume, exec, pamixer -d 5"
          ",XF86AudioMute,        exec, pamixer -t"
          ",XF86AudioMicMute,     exec, pamixer --default-source -t"

          # Hardware — media
          ",XF86AudioPlay, exec, mpc -q toggle"
          ",XF86AudioNext, exec, mpc -q next"
          ",XF86AudioPrev, exec, mpc -q prev"

          # Screenshots
          "CTRL, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          ",    Print, exec, grim - | wl-copy"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

      }; # end settings

    }; # end wayland.windowManager.hyprland

  }; # end home-manager.users.justin

}
