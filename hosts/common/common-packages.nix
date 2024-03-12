{ pkgs, unstablePkgs, config, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    ## unstable
    unstablePkgs.yt-dlp
    unstablePkgs.get_iplayer

    ## stable
#    asciinema
#    diffr # Modern Unix `diff`
#    difftastic # Modern Unix `diff`
#    dua # Modern Unix `du`
#    duf # Modern Unix `df`
#    du-dust # Modern Unix `du`
    docker-compose
#    drill
#    entr # Modern Unix `watch`
    alacritty
    firefox
    esptool
    fira-code
    fira-mono
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
#    python39
#   (python39.withPackages(p: with p; [
#      fontforge
#      numpy
#      jupyter
#      ipykernel
#      matplotlib
#      tensorflow
#      pandas
#      flask
#      virtualenvwrapper
#      pip
#      httpx
#      pygobject3
#    ]))
    #----------Utilies--------------#
    mesa # video drivers

    #-------Favorite Software-------#
 #       gimp-with-plugins
    lf # file manager | ranger replacement
 #  sioyek # pdf viewer
    libreoffice-still
    unstablePkgs.obsidian
    feh
    vivaldi
    tor
    tor-browser

    #---------Media----------------#
    vlc
    discord
    zoom-us

    # requires nixpkgs.config.allowUnfree = true;
    vscode-extensions.ms-vscode-remote.remote-ssh
  ];
}
