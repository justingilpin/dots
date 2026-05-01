{pkgs, lib, config, ...}:
{
  programs.nixvim = {
	  colorschemes.ayu.enable = false;
	  colorschemes.base16.enable = false;
	  colorschemes.catppuccin.enable = false;
	  colorschemes.dracula.enable = false;
	  colorschemes.gruvbox.enable = true;
	  colorschemes.kanagawa.enable = false;
	  colorschemes.melange.enable = false;
	  colorschemes.nord.enable = false;
	  colorschemes.one.enable = false;
	  colorschemes.onedark.enable = false;
	  colorschemes.oxocarbon.enable = false;
	  colorschemes.rose-pine.enable = false;
	  colorschemes.tokyonight.enable = false;
  };

}
