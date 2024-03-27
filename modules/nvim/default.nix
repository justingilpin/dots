{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
  ];

  imports = [
    ./theme.nix
    ./settings.nix
#    ./keybindings.nix
#    ./filetype.nix
#    ./autocmd.nix
#    ./plugins/completion.nix
    ./plugins/lsp.nix
#    ./plugins/misc.nix
#    ./plugins/taboo.nix
		./plugins/lualine.nix
    ./plugins/telescope.nix
    ./plugins/treesitter.nix
		./plugins/neo-tree.nix
#    ./plugins/winshift.nix
	];

  programs.nixvim = {
    enable = true;
		viAlias = true;
    vimAlias = true;
		globals.mapleader = " ";

    # Configure neovim options...
#    options = {
#      relativenumber = true;
#      incsearch = true;
#    };

    # ...mappings...
#    maps = {
#      normal = {
#        "<C-s>" = ":w<CR>";
#        "<esc>" = { action = ":noh<CR>"; silent = true; };
#      };
#      visual = {
#        ">" = ">gv";
#      "<" = "<gv";
#      };
#    };

    # ...plugins...
    plugins = {
			treesitter.enable = true;
#      telescope.enable = true;
#			lightline.enable = true;
      harpoon = {  # Hi Prime :)
        enable = true;
      keymaps.addFile = "<leader>a";
      };
      copilot-lua.enable = true;
#      noice.enable = true;
			#which-key.enable = true;
			#nvim-autopairs.enable = true;
			gitsigns = {
				enable = true;
				signs = {
					add.text = "+";
					change.text = "~";
				};
			};
 #     lsp = {
 #       keymaps = {
 #         silent = true;
 #         diagnostic = {
 #           "<leader>k" = "goto_prev";
 #           "<leader>j" = "goto_next";
 #         };

 #         lspBuf = {
 #           gd = "definition";
 #           K = "hover";
 #         };
 #       };
 #       servers = {
 #         bashls.enable = true;
 #         clangd.enable = true;
 #         nil_ls.enable = true;
 #       };
 #     };
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
