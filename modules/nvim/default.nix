{ pkgs, lib, unstablePkgs, ... }:

{

  imports = [
#	  ./theme.nix
    ./settings.nix

	];

  programs.nixvim = {
    enable = true;
    vimAlias = true;

    # Configure neovim options...
    options = {
      relativenumber = true;
      incsearch = true;
    };
    colorschemes.gruvbox.enable = true;
    # ...mappings...
    maps = {
      normal = {
        "<C-s>" = ":w<CR>";
        "<esc>" = { action = ":noh<CR>"; silent = true; };
      };
      visual = {
        ">" = ">gv";
        "<" = "<gv";
      };
    };

    # ...plugins...
    plugins = {
      telescope.enable = true;
#			lightline.enable = true;
      harpoon = {  # Hi Prime :)
        enable = true;
        keymaps.addFile = "<leader>a";
      };

      lsp = {
        keymaps = {
          silent = true;
          diagnostic = {
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            K = "hover";
          };
        };
        servers = {
          bashls.enable = true;
          clangd.enable = true;
          nil_ls.enable = true;
        };
      };
    };

    # ... and even highlights and autocommands !
#    highlight.ExtraWhitespace.bg = "red";
    match.ExtraWhitespace = "\\s\\+$";
    autoCmd = [
      {
        event = "FileType";
        pattern = "nix";
        command = "setlocal tabstop=2 shiftwidth=2";
      }
    ];
  };
}
