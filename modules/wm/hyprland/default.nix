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
    wl-clipboard
    pamixer
    brightnessctl
    kitty

    # ── Whisper dictation ────────────────────────────────────────────────────
    # Hold Super+Ctrl to record, release to transcribe and type the result.
    # whisper-cpp-vulkan uses the GPU (Vulkan) for fast inference on any machine.
    whisper-cpp-vulkan
    wtype        # types transcribed text into the focused window
    curl         # sends audio to whisper-server for transcription

    # whisper-dictate: hold=record, release=transcribe+type
    # Uses whisper-server (model stays loaded in VRAM) for fast response.
    # whisper-server starts automatically via exec-once on login.
    (pkgs.writeShellScriptBin "whisper-dictate" ''
      PIDFILE="/tmp/whisper-record.pid"
      WAVFILE="/tmp/whisper-input.wav"

      case "$1" in
        start)
          # Kill any leftover recording before starting a new one
          [ -f "$PIDFILE" ] && kill -INT "$(cat "$PIDFILE")" 2>/dev/null
          pw-record --rate 16000 --channels 1 --format s16 "$WAVFILE" &
          echo $! > "$PIDFILE"
          ;;
        stop)
          if [ -f "$PIDFILE" ]; then
            kill -INT "$(cat "$PIDFILE")" 2>/dev/null
            rm -f "$PIDFILE"
            sleep 0.3
            # Send to whisper-server (model already loaded in VRAM — fast response)
            OUTPUT=$(curl -s http://127.0.0.1:8178/inference \
              -F file="@$WAVFILE" \
              -F temperature=0 \
              -F response_format=text 2>/dev/null | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [ -n "$OUTPUT" ] && wtype "$OUTPUT"
          fi
          ;;
      esac
    '')
  ];

  # ── Hyprland config (home-manager side) ────────────────────────────────────
  # Generates ~/.config/hypr/hyprland.conf — replaces the static file symlink.
  # basic/default.nix and shell/default.nix append to extraConfig as needed.
  home-manager.users.justin = { lib, ... }: {

    wayland.windowManager.hyprland = {
      enable   = true;
      systemd.enable = false; # we manage session target ourselves via exec-once below

      settings = {

        monitor = [
          ",highres,auto,1"
          "DVI-I-1,disabled"
        ];

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
          # WirePlumber sometimes misses USB audio devices on boot — restart to re-enumerate
          "systemctl --user restart wireplumber"
          # RGB — set Logitech G403 Hero and Razer BlackWidow to static color D79921
          "openrgb --noautoconnect -c D79921 --mode static"
          # Whisper server — keeps model loaded in VRAM for instant dictation response
          "whisper-server -m $HOME/.local/share/whisper-cpp/ggml-small.en.bin --port 8178 --host 127.0.0.1 -l en"
        ];

        # ── Variables ─────────────────────────────────────────────────────────
        "$terminal"   = "kitty";
        "$fileManager" = "dolphin";
        "$browser"    = "firefox";
        # $menu is set in basic/default.nix (wofi) — shell provides its own launcher

        # ── Environment ───────────────────────────────────────────────────────
        env = [
          "XCURSOR_THEME,Adwaita"
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,kde"
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
          # col.active_border / col.inactive_border intentionally omitted — set by the active shell theme
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
            # color intentionally omitted — set by the active shell theme
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
        windowrulev2 = [
          "immediate, class:^(cs2)$"
          "idleinhibit fullscreen, class:^(firefox)$"
          "idleinhibit fullscreen, class:^(stremio)$"
        ];

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

          # Move to workspace (silent — keeps focus on current workspace)
          "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
          "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
          "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
          "$mainMod SHIFT, 0, movetoworkspacesilent, 10"

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
          "$mainMod, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          ",    Print, exec, grim - | wl-copy"

          # Whisper push-to-talk — hold Super+Ctrl to record, release to transcribe+type
          "$mainMod, Control_L, exec, whisper-dictate start"
        ];

        # Whisper release — stop recording and transcribe
        bindl = [ "$mainMod, Control_L, exec, whisper-dictate stop" ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

      }; # end settings

    }; # end wayland.windowManager.hyprland

    # ── Whisper model setup ────────────────────────────────────────────────
    # Downloads large-v3-turbo on first login if not already present.
    # small.en is ~150 MB — fast inference (<1s on RTX 4070 Ti), good accuracy for English dictation.
    home.activation.downloadWhisperModel = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      MODEL_DIR="$HOME/.local/share/whisper-cpp"
      MODEL="$MODEL_DIR/ggml-small.en.bin"
      if [ ! -f "$MODEL" ]; then
        mkdir -p "$MODEL_DIR"
        echo "Downloading Whisper small.en model (~150 MB)..."
        ${pkgs.curl}/bin/curl -L --progress-bar \
          "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin" \
          -o "$MODEL" || rm -f "$MODEL"
      fi
    '';

  }; # end home-manager.users.justin

}

