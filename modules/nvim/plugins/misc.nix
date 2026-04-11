{pkgs, ...}: {
  programs.nixvim = {
    plugins = {
      surround.enable = true;
      comment-nvim.enable = true;
      gitsigns = {
        enable = true;
        currentLineBlame = true;
      };
      todo-comments = {
        enable = true;
        signs = false;
      };
      vim-matchup = {
        enable = true;
        enableSurround = true;
      };
      which-key.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-kitty-navigator
      vim-sleuth
      targets-vim
      vim-eunuch
      vim-repeat
      vim-highlightedyank
      vim-just
    ];
  };
}
