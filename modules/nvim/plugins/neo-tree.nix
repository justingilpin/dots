{...}: {
  programs.nixvim = {
    plugins = {
      neo-tree = {
        enable = true;
        settings = {
          auto_clean_after_session_restore = true;
          close_if_last_window = true;

          default_component_configs = {
            indent = {
              padding = 0;
            };
            icon = {
              folder_closed = "";
              folder_open = "";
              folder_empty = "";
              folder_empty_open = "";
              default = "󰈙";
            };
            modified = {
              symbol = "";
            };
            git_status = {
              symbols = {
                added = "";
                deleted = "";
                modified = "";
                renamed = "➜";
                untracked = "★";
                ignored = "◌";
                unstaged = "✗";
                staged = "✓";
                conflict = "";
              };
            };
          };

          source_selector = {
            content_layout = "start";
            winbar = true;
            sources = [
              {
                source = "filesystem";
                display_name = " File";
              }
              {
                source = "buffers";
                display_name = "󰈙 Bufs";
              }
              {
                source = "git_status";
                display_name = "󰊢 Git";
              }
            ];
          };

          window = {
            width = 30;
          };
        };
      };
    };

    keymaps = [
      {
        key = "<leader>n";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Toggle Explorer";
      }
    ];
  };
}
