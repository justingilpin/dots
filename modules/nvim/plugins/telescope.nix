{pkgs, ...}: {
  # home.packages = with pkgs; [vimPlugins.telescope-ui-select-nvim];
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      plenary-nvim
    ];
    plugins = {
      telescope = {
        enable = true;
#        extraOptions = { # old
				settings = { # new
          defaults = {
            sorting_strategy = "ascending";
            layout_config.prompt_position = "top";
            # Insert mode mappings (within the prompt)
            mappings.i = {
              "<esc>" = "close";
              "<tab>" = "move_selection_next";
              "<s-tab>" = "move_selection_previous";
            };
          };
        };
        enabledExtensions = ["ui-select"];
        #        extensionsConfig.ui-select = {};

        extensions = {
          ui-select.enable = true;
          fzf-native.enable = true;
          frecency.enable = true;
#          file_browser = { # old
					file-browser.settings = { # new
            enable = true;
            hidden = true;
            depth = 9999999999;
            autoDepth = true;
          };
        };
      };
    };
    keymaps = [
      {
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<cr>";
        options.desc = "find buffer";
      }
      {
        key = "<leader>fc";
        action = "<cmd>Telescope command_history<cr>";
        options.desc = "search command history";
      }
      {
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "find file";
      }
      {
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<cr>";
        options.desc = "find help";
      }
      {
        key = "<leader>fm";
        action = "<cmd>Telescope marks<cr>";
        options.desc = "find mark";
      }
      {
        key = "<leader>fr";
        action = "<cmd>Telescope registers<cr>";
        options.desc = "find register";
      }
      {
        key = "<leader>fs";
        action = "<cmd>Telescope search_history<cr>";
        options.desc = "search search history";
      }
      {
        key = "<leader>ft";
        action = "<cmd>TodoTelescope<cr>";
        options.desc = "find todo";
      }
      {
        key = "<leader>flb";
        action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
        options.desc = "find line in buffer";
      }
      {
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<cr>";
        options.desc = "find line in cwd";
      }
      #      {
      #        key = "<leader>fg";
      #        action = "<cmd>Telescope git_files<cr>";
      #        options.desc = "find git file";
      #      }
    ];
  };
}
