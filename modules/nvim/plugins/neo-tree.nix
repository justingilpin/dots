{...}: {
  programs.nixvim = {
    plugins = {
      neo-tree = {
        enable = true;
				autoCleanAfterSessionRestore = true;
				closeIfLastWindow = true;
				defaultComponentConfigs = {
          indent.padding = 0;
          icon = {
            folderClosed = "";
            folderOpen = "";
            folderEmpty = "";
            folderEmptyOpen = "";
            default = "󰈙";
          };
          modified = {symbol = "";};
          gitStatus = {
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
#        filesystem = {
#          followCurrentFile = true;
#          hijackNetrwBehavior = "open_current";
#          useLibuvFileWatcher = true;
#        };
        sourceSelector = {
          contentLayout = "start";
          winbar = true;
          sources = [
            {
              source = "filesystem";
              displayName = " File";
            }
            {
              source = "buffers";
              displayName = "󰈙 Bufs";
            }
            {
              source = "git_status";
              displayName = "󰊢 Git";
            }
          ];
        };
        window = {
          width = 30;
        };
      };
#			};
    };
    keymaps = [
      {
        key = "<leader>n";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "Toggle Explorer";
      }
    ];
  #  };
  };
}
