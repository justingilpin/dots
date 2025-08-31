{
  config,
  pkgs,
  inputs,
  lib,
  nixvim,
  outputs,
  nixpkgs-unstable,
  ...
}: {
  home.stateVersion = "24.05";
#  home-manager.backupFileExtension = "backup";
  # list of programs
  # https://mipmip.github.io/home-manager-option-search
  imports = [
    ./../modules/nvim
    ./../modules/alacritty
    #		./../modules/eww
  ];
 # programs.nixvim = {
 #   enable = true;
  #    colorschemes.gruvbox.enable = true;
  #    plugins.lightline.enable = true;
 # };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "justin";
    diff-so-fancy.enable = true;
    lfs.enable = true;
    extraConfig = {
      init = {defaultBranch = "master";};
      merge = {
        conflictStyle = "diff3";
        tool = "meld";
      };
      pull = {rebase = false;};
    };
  }; # end git

  # Source Dot Files
  home.file.".config/hypr/hyprland.conf".source = ./../modules/hyprland/hyprland.conf;
  home.file.".config/hypr/hypridle.conf".source = ./../modules/hyprland/hypridle.conf;
  home.file.".config/hypr/hyprlock.conf".source = ./../modules/hyprland/hyprlock.conf;
  home.file.".config/hypr/hyprpaper.conf".source = ./../modules/hyprland/hyprpaper.conf;
  
  # Test file to see if home-manager is working
  home.file.".config/test-home-manager.txt".text = "Home manager is working!";

  #  programs.firefox = {
  #    enable = true;
  #    profiles.justin = {
  #      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
  #        bitwarden
  #	ublock-origin
  #	sponsorblock
  #	darkreader
  #	tridactyl
  #	youtube-shorts-block
  #      ];
  #    };
  #  };

  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  programs.lf.enable = true;

  #  programs.tmux = {
  #    enable = true;
  #    #keyMode = "vi";
  #    clock24 = true;
  #    historyLimit = 10000;
  #    plugins = with pkgs.tmuxPlugins; [
  #      gruvbox
  #    ];
  #    extraConfig = ''
  #      new-session -s main
  #      bind-key -n C-a send-prefix
  #    '';
  #  };

  programs.zsh = {
    enable = true;
#    enableAutosuggestions = true; # old
    autosuggestion.enable = true; # new name change
    enableCompletion = true;
    initExtra = builtins.readFile ./files/zshrc;
    initExtraBeforeCompInit = ''
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.zsh
    '';
    oh-my-zsh = {
      enable = true;
      #   theme = "robbyrussell";
      plugins = ["python"];
    };
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;
  programs.zoxide.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.ssh = {
    enable = true;
    #  extraConfig = ''
    #  Host *
    #    StrictHostKeyChecking no
    #  '';
    #  matchBlocks = {
    # wd
    #    "dt deepthought" = {
    #      hostname = "10.42.0.42";
    #      user = "alex";
    #    };
    #    "a anton" = {
    #      hostname = "10.42.1.20";
    #      user = "root";
    #    };
    #    "bricktop" = {
    #      hostname = "10.42.1.80";
    #      user = "pi";
    #    };
    #  };
  };
}
