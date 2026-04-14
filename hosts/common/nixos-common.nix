{ pkgs, lib, inputs, ... }:
let
  inherit (inputs) nixpkgs;
in
{
  time.timeZone = "Asia/Manila";

  # ── Display manager: greetd + tuigreet ─────────────────────────────────────
  # Replaces TTY manual login. Unlocks GNOME keyring via PAM so VSCode and
  # other apps don't prompt for the keyring password separately.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      user = "greeter";
    };
  };
  security.pam.services.greetd.enableGnomeKeyring = true;

#  services.flatpak.enable = true; # Additional pkgs required for server
  nix = {
    settings = {
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
	auto-optimise-store = true;
    };
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  environment.systemPackages = with pkgs; [
    wget
    git
    git-crypt
    tailscale
    cifs-utils
    neofetch
    ntfs3g
    htop
    btop
    coreutils
    bitwarden-cli
    go

    #-------------Encoders--------------#
    ffmpeg # possibly use ffmpeg-headless

    #--------------ZSH------------------#
    starship
    zsh-syntax-highlighting
    zsh-vi-mode

    #-------------Security--------------#
#    gnupg
#    sops
#    age

  ];
}
