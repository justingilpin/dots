{ pkgs, unstablePkgs, lib, inputs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  time.timeZone = "Asia/Manila";

#  time.timeZone = "Etc/GMT+0"; # Temperary fix to get correct time


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
    figurine

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
