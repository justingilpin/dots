 {
  programs.nixvim.plugins.lsp = {
    enable = true;
    keymaps.lspBuf = {
      K = "hover";
      gD = "references";
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
      gr = "rename";
      "<leader>f" = "format";
    };
#		silent = true;
#		diagnostic = {
#			"<leader>k" = "goto_prev";
#			"<leader>j" = "goto_next:;
#		};
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
      rust-analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
    };
  };
}
