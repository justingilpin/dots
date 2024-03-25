{ config, inputs, nixvim, pkgs, ... }: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
#    enableMan = true; # install man pages for nixvim options

#    clipboard.register = "unnamedplus"; # use system clipboard instead of internal registers

    colorschemes = {
      gruvbox = {
        enable = true;
        contrastDark = "medium";
        # transparentBg = "true";
      };
    };
  };
}

