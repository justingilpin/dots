{ pkgs, unstablePkgs, config, lib, ... }:
{

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  environment.systemPackages = with pkgs; [
    ## unstable
#    unstablePkgs.yt-dlp
#    unstablePkgs.get_iplayer
    nix-prefetch-git
		libsForQt5.dolphin
    ripgrep #neovim telescope grep requirement
    lua # requirement for neovim to be modified / treesitter
    gccgo12 # requirement for neovim / treesitter
		vim-full # for vimtutor
    ## stable
#    luajitPackages.lua-lsp
#    nodePackages_latest.pyright
#    asciinema
#    diffr # Modern Unix `diff`
#    difftastic # Modern Unix `diff`
#    dua # Modern Unix `du`
#    duf # Modern Unix `df`
#    du-dust # Modern Unix `du`
#    docker
#    docker-compose
#    drill
#    entr # Modern Unix `watch`
    firefox
#    esptool

#    fd
    #fzf # programs.fzf
    gh
    gnused
    xsel
    xclip

#    hub
#    hugo
#    iperf3
#    ipmitool
#    just
#    jq
#    kubectl
#    mc
#    mosh
    nmap
    qemu
#    ripgrep
#    skopeo
    smartmontools
#    terraform
#    tree
#    unzip
    watch
    wireguard-tools
    #----------Utilies--------------#
    mesa # video drivers

    #-------Favorite Software-------#
 #       gimp-with-plugins
    lf # file manager | ranger replacement
 #  sioyek # pdf viewer
    libreoffice-still
    unstablePkgs.obsidian
    unstablePkgs.vscode
    feh
    vivaldi
    tor
    tor-browser
		element-desktop

    #---------Media----------------#
    vlc
    discord
    zoom-us

    vscode-extensions.ms-vscode-remote.remote-ssh
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-mono
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Iosevka" "JetBrainsMono" "IBMPlexMono" "Mononoki" "Monofur"
    ]; })
  ];
}
