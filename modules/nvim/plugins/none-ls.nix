{ ... }: {
  programs.nixvim.plugins = {
    # null-ls has been forked to none-ls after the original author archived the project.
    none-ls = {
      enable = true;
      updateInInsert = true;
      enableLspFormat = true;
      sources = {
        code_actions = {
          gitsigns.enable = true;
          statix.enable = true;
        };
        diagnostics = {
          alex.enable = true;
          cppcheck.enable = true;
					deadnix.enable = true;
	    	  gitlint.enable = true;
					golangci_lint.enable = true;
					hadolint.enable = true;
					ktlint.enable = true;
					mypy.enable = true;
					protolint.enable = true;
					pylint.enable = true;
					statix.enable = true;
					vale.enable = true;
        };
        formatting = {
          alejandra.enable = true;
          isort.enable = true;
          cbfmt.enable = true;
          fnlfmt.enable = true;
          gofmt.enable = true;
          ktlint.enable = true;
          nixpkgs_fmt.enable = true;
          nixfmt.enable = true;
          markdownlint.enable = true;
          prettier.enable = true;
          protolint.enable = true;
          shfmt.enable = true;
          sqlfluff.enable = true;
          stylua.enable = true;
        };
      };
    };
  };
}
