# modules/shell/default.nix
#
# Advanced Quickshell/Caelestia desktop. Import instead of modules/basic.
# Requires the caelestia-shell flake input in flake.nix (already wired).
#
# Host swap:
#   ./../../../modules/wm/hyprland
#   # ./../../../modules/basic
#   ./../../../modules/shell

{ pkgs, lib, ... }:


{
  # ── i2c access for ddcutil (monitor brightness via DDC) ────────────────────
  hardware.i2c.enable = true;

  # ── Fonts the shell uses ───────────────────────────────────────────────────
  # The shell binary wraps its own FONTCONFIG_FILE for these, but having them
  # system-wide makes other apps (terminals, browsers) pick them up too.
  fonts.packages = with pkgs; [
    material-symbols        # shell icon font
    rubik                   # shell UI font
    nerd-fonts.caskaydia-cove # shell mono font
  ];

  # ── Activate Caelestia shell for justin ────────────────────────────────────
  # programs.caelestia option is registered by caelestia-shell.homeManagerModules.default
  # which is imported in flake.nix — it is always available, just off by default.
  home-manager.users.justin = { lib, ... }: {

    programs.caelestia = {
      enable = true;

      systemd = {
        enable = true;
        # Ties the shell service to the same target waybar used — starts after
        # Hyprland has exported WAYLAND_DISPLAY into the systemd environment.
        target = "hyprland-session.target";
      };

      # Include the CLI — needed for wallpaper switching, scheme changes, IPC
      cli.enable = true;

    }; # end programs.caelestia

    # ── Seed shell.json on first deploy only (GUI can freely overwrite after) ──
    # home.activation runs before services start; the guard means subsequent
    # rebuilds never clobber changes made via the settings GUI.
    home.activation.caelestiaShellConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      SHELL_CFG="$HOME/.config/caelestia/shell.json"
      if [ ! -f "$SHELL_CFG" ]; then
        mkdir -p "$(dirname "$SHELL_CFG")"
        cat > "$SHELL_CFG" << 'EOF'
{
  "general": {
    "apps": { "terminal": ["kitty"], "explorer": ["thunar"], "audio": ["pavucontrol"] },
    "idle": {
      "lockBeforeSleep": true,
      "inhibitWhenAudio": true,
      "timeouts": [
        { "timeout": 180, "idleAction": "lock" },
        { "timeout": 300, "idleAction": "dpms off", "returnAction": "dpms on" },
        { "timeout": 600, "idleAction": ["systemctl", "suspend-then-hibernate"] }
      ]
    }
  },
  "paths": { "wallpaperDir": "~/Pictures/Wallpapers" },
  "bar": { "status": { "showBattery": true, "showNetwork": true, "showWifi": true, "showBluetooth": true, "showAudio": false } },
  "launcher": { "enabled": true },
  "services": { "audioIncrement": 0.05, "brightnessIncrement": 0.05, "maxVolume": 1.0, "smartScheme": true }
}
EOF
      fi
    '';

    # ── Disable waybar — shell provides its own bar ───────────────────────────
    programs.waybar.enable = lib.mkForce false;

    # ── Hyprland config additions for the shell ──────────────────────────────
    # The shell uses Hyprland global shortcuts (CustomShortcut in Quickshell)
    # rather than exec commands. The format is: global, caelestia:<shortcut-name>
    # Names come from modules/Shortcuts.qml in the caelestia-shell source.
    wayland.windowManager.hyprland.extraConfig = ''
      # Shell launcher — replaces $menu / wofi from basic
      bind = $mainMod, R,           global, caelestia:launcher

      # Shell panels
      bind = $mainMod, Tab,         global, caelestia:showall
      bind = $mainMod, D,           global, caelestia:dashboard
      bind = $mainMod, backslash,   global, caelestia:sidebar
      bind = $mainMod SHIFT, E,     global, caelestia:session
      bind = CTRL, Space,           global, caelestia:controlCenter

    '';

  }; # end home-manager.users.justin

}
