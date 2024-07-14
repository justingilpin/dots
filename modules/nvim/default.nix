{pkgs, ...}: {
  home.packages = with pkgs; [fd];

  imports = [
    ./theme.nix
    ./settings.nix
    ./keybindings.nix
    #    ./filetype.nix
    ./autocmd.nix
#    ./plugins/completion.nix
    ./plugins/lsp.nix
    #    ./plugins/misc.nix
    #    ./plugins/taboo.nix
    ./plugins/lualine.nix
    ./plugins/telescope.nix
    ./plugins/treesitter.nix
    ./plugins/neo-tree.nix
    ./plugins/none-ls.nix
#    ./plugins/nvim-cmp.nix
    ./plugins/copilot.nix
    ./plugins/trouble.nix
    #   ./plugins/winshift.nix
    #    ./plugins/alpha2.nix
  ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    globals.mapleader = " ";

    # ...plugins...
    plugins = {
      treesitter.enable = true;
      luasnip.enable = true;
      lsp-format.enable = true;
      #		neocord.enable = true;
      rust-tools.enable = true;
      which-key.enable = true;
      noice.enable = true;
      nvim-colorizer.enable = true;
      nvim-autopairs.enable = true;
      nvim-lightbulb.enable = true;
      oil = {
        enable = true;
#        viewOptions.showHidden = true; # old
				settings.view_options.show_hidden = true; # new
      };
    };

    #      none-ls = {
    #        enable = true;
    #        updateInInsert = true;
    #        enableLspFormat = true;
    #        sources = {
    #          code_actions = { shellcheck.enable = true; };
    #          diagnostics = { shellcheck.enable = true; };
    #          formatting = {
    #            gofmt.enable = true;
    #            markdownlint.enable = true;
    #            nixfmt.enable = true;
    #            rustfmt.enable = true;
    #            shfmt.enable = true;
    #          };
    #        };
    #      };

    #      harpoon = {
    #        enable = true;
    #        keymaps.addFile = "<leader>a";
    #      };
    #      copilot-lua.enable = true;

    #      gitsigns = {
    #        enable = true;
    #        signs = {
    #          add.text = "+";
    #          change.text = "~";
    #        };
    #      };
    #    };

    # This for nvim-cmp ?
    #    autoCmd = [
    #      {
    #        event = "FileType";
    #        pattern = "nix";
    #        command = "setlocal tabstop=2 shiftwidth=2";
    #      }
    #    ];
  };
}
