{pkgs, ...}: {
  home.packages = with pkgs; [];

  programs.nixvim = {
    plugins = {
      nvim-cmp = {
        enable = true;
				completion = {
					autocomplete = ["TextChanged"];
					keywordLength = 1;
				};
        preselect = "None";
        snippet.expand = "luasnip";
        sources = [
				  {name = "copilot";}
          {name = "nvim_lsp";}
          {name = "luasnip";}
          {name = "path";}
          {name = "dictionary";}
          {name = "buffer";}
          {name = "nvim_lsp_signature_help";}
          {name = "nvim_lua";}
        ];
        formatting = {fields = ["abbr" "kind" "menu"];};
       # mappingPresets = ["insert" "cmdline"];
       # mapping."<CR>".modes = ["i" "s" "c"];
       # mapping."<CR>".action = ''
       #   function(fallback)
       #     if cmp.visible() and cmp.get_active_entry() then
       #       cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
       #     else
       #       fallback()
       #     end
       #   end
       # '';
		    mapping = {
          "<tab>" = "cmp.mapping.select_next_item()";
          "<s-tab>" = "cmp.mapping.select_prev_item()";
          "<c-n>" = "cmp.mapping.select_next_item()";
          "<c-p>" = "cmp.mapping.select_prev_item()";
        };
      };
      harpoon = {
        enable = true;
        keymaps.addFile = "<leader>a";
      };
      # copilot-lua.enable = true; #already installed seperately 

      gitsigns = {
        enable = true;
        signs = {
          add.text = "+";
          change.text = "~";
        };
      };
    };

    autoCmd = [
      {
        event = "FileType";
        pattern = "nix";
        command = "setlocal tabstop=2 shiftwidth=2";
      }
    ];
  };
}
