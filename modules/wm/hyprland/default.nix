# modules/wm/hyprland/default.nix
#
# Core Hyprland compositor — always loaded.
# Pair with modules/basic (simple UI) or modules/shell (advanced UI).

{ pkgs, lib, ... }:

{
  imports = [
    #    ./hyprlock.nix
  ];

  # ── Compositor ─────────────────────────────────────────────────────────────
  programs.hyprland.enable = true;

  # ── XDG portals ────────────────────────────────────────────────────────────
  # Mask xdg-desktop-portal-gtk — running it alongside hyprland portal
  # causes a ~25s tray startup delay on login.
  systemd.user.services.xdg-desktop-portal-gtk.wantedBy = lib.mkForce [];
  xdg.portal.extraPortals = lib.mkForce [ pkgs.xdg-desktop-portal-hyprland ];

  # ── Session security ────────────────────────────────────────────────────────
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [

    # Wayland plumbing
    wl-clipboard
    xdg-desktop-portal-hyprland

    # GTK / cursor theming
    adwaita-icon-theme
    gtkmm3
    gtk3

    # Polkit agent
    polkit_gnome

    # Lock / idle stack
    hyprlock
    hypridle
    hyprlang       # hyprlock dep
    wlr-protocols  # hyprlock dep
    mesa           # hyprlock dep
    sdbus-cpp      # hyprlock dep

    # Screen sharing (Wayland)
    pipewire
    wireplumber

    # Screenshot tools
    grim
    slurp

    # Hardware controls
    pamixer
    brightnessctl

    # Network tray
    networkmanagerapplet

    # Fallback terminal
    kitty

  ];
}
