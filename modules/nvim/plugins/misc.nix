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

      # Vim training/practice plugins
      # vim-be-good  — neovim game by ThePrimeagen; run with :VimBeGood
      #                drills hjkl, relative jumps, deletion, etc.
      # train-nvim   — motion/operator drills; run with :TrainUpDown,
      #                :TrainWord, :TrainTextObj, etc.
      # vimtutor     — built into vim/nvim, no install needed; just run
      #                `vimtutor` in the terminal or :Tutor inside nvim
      # pacvim       — terminal game (like pacman) that teaches vim motions;
      #                installed via hosts/common/common-packages.nix
      # vimgolf      — CLI for vimgolf.com challenges;
      #                installed via hosts/common/common-packages.nix
      vim-be-good
      train-nvim
    ];
  };
}
