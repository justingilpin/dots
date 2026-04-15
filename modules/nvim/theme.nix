{pkgs, lib, config, ...}:
{
  programs.nixvim = {
    # All static colorschemes disabled — Noctalia themes nvim dynamically.
    # The template engine writes ~/.config/nvim/themes/noctalia.lua on every
    # color scheme change; extraConfigLua below loads it at startup.
	  colorschemes.ayu.enable = false;
	  colorschemes.base16.enable = false;
	  colorschemes.catppuccin.enable = false;
	  colorschemes.dracula.enable = false;
	  colorschemes.gruvbox.enable = false;
	  colorschemes.kanagawa.enable = false;
	  colorschemes.melange.enable = false;
	  colorschemes.nord.enable = false;
	  colorschemes.one.enable = false;
	  colorschemes.onedark.enable = false;
	  colorschemes.oxocarbon.enable = false;
	  colorschemes.rose-pine.enable = false;
	  colorschemes.tokyonight.enable = false;

    extraConfigLua = ''
      -- Load Noctalia dynamic theme (written by Noctalia template engine)
      local theme_path = vim.fn.expand("~/.config/nvim/themes/noctalia.lua")
      if vim.fn.filereadable(theme_path) == 1 then
        dofile(theme_path)
      end
    '';
  };

}
