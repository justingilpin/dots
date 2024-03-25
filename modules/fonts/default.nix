{ config, lib, pkgs, ... }:
{
  fonts = {
    fontconfig = {
      #ultimate.enable = true; # This enables fontconfig-ultimate settings for better font rendering
      defaultFonts = {
        monospace = ["Josevka Mono"];
        sansSerif = ["Josevka Book Sans"];
        emoji = ["Twemoji"];
      };
    };
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      roboto
      roboto-mono
      fantasque-sans-mono
      font-awesome
      nerdfonts
      meslo-lgs-nf
      terminus_font
      noto-fonts
      twemoji-color-font
    ];
  };
}
