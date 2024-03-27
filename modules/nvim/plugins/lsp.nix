{...}: {
  programs.nixvim.plugins.lsp = {
		enable = true;
#		keymaps = {
#			silent = true;
#			diagnostic = {
#				"<leader>k" = "goto_prev";
#				"<leader>j" = "goto_next:;
#			};
#		};
    servers = {
      lua-ls.enable = true;
      pyright.enable = true;
      nil_ls.enable = true;
      html.enable = true;
      cssls.enable = true;
      jsonls.enable = true;
      yamlls.enable = true;
      ccls.enable = true;
    };
  };
}
