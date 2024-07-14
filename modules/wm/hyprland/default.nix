{
  pkgs,
	lib,
	config,
	inputs,
	nixpkgs-unstable,
	nixvim,
	nixos-hardware,
  ...
}: {
  imports = [
    #    ./hyprlock.nix
  ];

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Enable Gnome Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # security.pam.services<yourDisplayManager>.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    waybar
    dunst
    libnotify # dunst dependency
    networkmanagerapplet
    gtkmm3
    gtk3
    #    dbus
    xdg-desktop-portal-hyprland
    wofi
    kitty
    hyprpaper
		wlr-protocols # hyprlock dep
		mesa # hyprlock dep
		sdbus-cpp #hyprlock dep
		pipewire #wayland screen share dep
		wireplumber #for pipewire

    #Unstable Packages example nixpkgs-unstable
    hyprlock # unstable only
    hypridle # unstable only
    hyprlang # hyprlock dependency
  ];
}
