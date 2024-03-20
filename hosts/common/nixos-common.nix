{ pkgs, unstablePkgs, lib, inputs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
  my-python-packages = python-packages: with python-packages; [
    appdirs
    ipdb
    ipython
    numpy
    numba
    pandas
    jupyter
    openpyxl
    pip
    requests
    tox
    virtualenv
    virtualenvwrapper
  ];
  python-with-my-packages = pkgs.python311.withPackages my-python-packages;
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
    neovim
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
    python-with-my-packages

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
    
    #--------------Fonts----------------#
    jetbrains-mono

  ];
}
