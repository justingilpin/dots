{ config, pkgs, ... }:
{
  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        catppuccin-nvim

      {
        plugin = catppuccin-nvim;
	type = "lua";
	config = /*lua*/ ''
        return {
          "catppuccin/nvim",
          lazy = false,
          name = "catppuccin",
          priority = 1000,
          config = function()
            vim.cmd.colorscheme "catppuccin"
          end
        };
	'';
      };

      ];
#      extraLuaConfig = ''
#        -- Write Lua code here
#	${builtins.readFile ./nvim/init.lua}
#        ${builtins.readFile ./nvim/vim-options.lua}
#	${builtins.readFile ./nvim/plugins/lsp-config.lua}
#        ${builtins.readFile ./nvim/plugins/catppuccin.lua}
#	${builtins.readFile ./nvim/plugins/lualine.lua}
#	${builtins.readFile ./nvim/plugins/neo-tree.lua}
#	${builtins.readFile ./nvim/plugins/telescope.lua}
#	${builtins.readFile ./nvim/plugins/treesitter.lua}
#
#      '';
     };
  };
}

