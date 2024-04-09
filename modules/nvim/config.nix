# common/programs/nixvim/config.nix
pkgs: {
  enable = true;

  colorschemes.tokyonight.enable = true;

  clipboard = {
    providers.wl-copy.enable = true;
    register = "unnamedplus";
  };

  extraPlugins = with pkgs.vimPlugins; [
    vim-nix # Nix expressions in Neovim.
    vim-fugitive # Git command under G(it) menu
    telescope-live-grep-args-nvim # Corrects ripgrep error with telescope
    neotest
    neotest-rust
  ];

  options = {
    number = true;
    tabstop = 2;
  };

  keymaps = [
    # Close buffer
    {
      key = "<space>q";
      action = "<cmd>q<cr>";
    }

    # Close buffer (force)
    {
      key = "<space>Q";
      action = "<cmd>q!<cr>";
    }

    # Save buffer
    {
      key = "<space>w";
      action = "<cmd>w<cr>";
    }

    # Toggle file explorer
    {
      key = "<space>e";
      action = "<cmd>NvimTreeToggle<cr>";
    }

    # Toggle file finder
    {
      key = "<space>f";
      action = "<cmd>Telescope find_files<CR>";
    }

    # Toggle buffer finder
    {
      key = "<space>b";
      action = "<cmd>Telescope buffers<CR>";
    }

    # Toggle live grep
    {
      key = "<space>g";
      action = "<cmd>Telescope live_grep<CR>";
    }

    # Toggle meta finder
    {
      key = "<space>p";
      action = "<cmd>Telescope<CR>";
    }

    # Toggle Git view
    {
      key = "<space>g";
      action = "<cmd>Neogit<CR>";
    }

    # Toggle floating terminal
    {
      key = "<space>t";
      action = "<cmd>FloatermToggle<CR>";
    }

    # Diagnostics
    {
      key = "<space>d";
      action = "<cmd>TroubleToggle<CR>";
    }
  ];

  plugins = {
    copilot-vim.enable = true; # Github CoPilot
    nvim-tree.enable = true; # File browser
    gitgutter.enable = true; # Git information in editor gutter
    comment-nvim.enable = true; # Comment with `gc` `gcc` etc.
    lualine.enable = true; # Status line
    telescope.enable = true; # Fuzzy finder
    trouble.enable = true; # Error list
    rust-tools.enable = true; # Rust tools
    neogit.enable = true; # Git integration
    indent-blankline.enable = true; # Indentation lines
    treesitter.enable = true; # Syntax highlighting
    # nvim-ufo = {
    #   enable = true; # Folding
    #   providerSelector = "treesitter";
    # };

    dap = {
      enable = true;
      extensions = {
        dap-ui.enable = true;
      };
    };

    # Dashboard
    alpha = {
      enable = true;
      layout = [
        {
          type = "padding";
          val = 2;
        }
        {
          opts = {
            hl = "Type";
            position = "center";
          };
          type = "text";
          val = [
            "  ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗  "
            "  ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║  "
            "  ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║  "
            "  ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║  "
            "  ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║  "
            "  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝  "
          ];
        }
        {
          type = "padding";
          val = 2;
        }
        {
          type = "group";
          val = [
            {
              command = "<CMD>ene <CR>";
              desc = "  New file";
              shortcut = "e";
            }
            {
              command = ":qa<CR>";
              desc = "  Quit Neovim";
              shortcut = "SPC q";
            }
          ];
        }
        {
          type = "padding";
          val = 2;
        }
        {
          opts = {
            hl = "Keyword";
            position = "center";
          };
          type = "text";
          val = "Inspiring quote here.";
        }
      ];
    };

    # Floating terminal
    floaterm = {
      enable = true;
      shell = "zsh";
    };

    # Language servers
    # !TODO Make it an input
    lsp = {
      enable = true;
      servers = {
        # Rust
        rust-analyzer = {
          enable = true;
          # installCargo = true;
          # installRustc = true;
        };

        # !TODO Find a better Nix linter, this was broken!
        rnix-lsp.enable = true;

        # Lua
        lua-ls.enable = true;

        # LaTex
        ltex.enable = true;

        # C, C++ etc.
        clangd.enable = true;

        # Python
        pylsp.enable = true;

        # Haskell
        hls.enable = true;

        # Html
        html.enable = true;

        # Bash
        bashls.enable = true;
      };

      keymaps = {
        lspBuf = {
          K = "hover";
          gD = "references";
          gd = "definition";
          gi = "implementation";
          gt = "type_definition";
        };
        diagnostic = {
          ne = "goto_next";
          pe = "goto_prev";
        };
      };
    };
  };

  extraConfigLua = ''
    -- Set clipboard to unnamedplus for wl-copy
    vim.g.clipboard=unnamedplus

    -- Remap copilot to `Control e` (mapping with Nixvim the command printed garbage at the end of the output)
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.api.nvim_set_keymap("i", "<C-e>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

    -- Remove backgrounds that don't stretch to the terminal window
  '';
}
