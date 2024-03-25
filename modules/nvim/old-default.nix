{ pkgs, lib, ... }:
{

  programs.nixvim = {
    enable = true;
    options = {
      number = true; # Show line numbers
      nu = true;
      relativenumber = true; # Show relative line numbers
      shiftwidth = 2; # Tab width 
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      termguicolors = true;
      wrap = true;

    };
    colorschemes.gruvbox.enable = true;
    plugins = {
      lightline = {
        enable = true;
	};
      };
    };


}
