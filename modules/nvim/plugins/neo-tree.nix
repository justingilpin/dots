{...}: {
  programs.nixvim = {
    plugins = {
      neo-tree = {
        enable = true;
			};
    };
    keymaps = [
      {
        key = "<leader>n";
        action = "<cmd>Neotree filesystem reveal left<cr>";
        options.desc = "find git file";
      }
    ];
  };
}
