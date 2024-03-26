{pkgs, lib, unstablePkgs, config, ...}: 
{
  programs.nixvim = {
	  colorschemes.ayu.enable = false;
	  colorschemes.base16.enable = false;
	  colorschemes.catppuccin.enable = false;
	  colorschemes.dracula.enable = false;
	  colorschemes.gruvbox.enable = false;
	  colorschemes.kanagawa.enable = false;
	  colorschemes.melange.enable = false;
	  colorschemes.nord.enable = true;
	  colorschemes.one.enable = false;
	  colorschemes.onedark.enable = false; #maybe
	  colorschemes.oxocarbon.enable = false;
	  colorschemes.rose-pine.enable = false;
	  colorschemes.tokyonight.enable = false;
  };

}
