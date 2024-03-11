{ pkgs, unstablePkgs, lib, inputs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  time.timeZone = "Asia/Manila";

  nix = {
    settings = {
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
    };
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;
#  nixpkgs.config.permittedInsecurePackages = [
#    "electron-24.8.6"
#    "electron-25.9.0"
#  ];

  environment.systemPackages = with pkgs; [
    # jellyfin-ffmpeg
    # hddtemp
    # synergy
  ];
}
