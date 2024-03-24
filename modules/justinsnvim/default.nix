{ config, pkgs, ... }:
{
  programs = {
    neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      plugins = with pkgs.vimPlugins; [

      ];
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraLuaConfig = ''
        -- Write Lua code here
	${builtins.readFile ./nvim/vim-options.lua}
	${builtins.readFile ./nvim/plugins/lsp-config.lua}
        ${builtins.readFile ./nvim/plugins/catppuccin.lua}
	${builtins.readFile ./nvim/plugins/lualine.lua}
	${builtins.readFile ./nvim/plugins/neo-tree.lua}
	${builtins.readFile ./nvim/plugins/telescope.lua}
	${builtins.readFile ./nvim/plugins/treesitter.lua}

      '';
     };
  };
}

