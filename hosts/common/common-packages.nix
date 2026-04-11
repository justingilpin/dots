{ pkgs, config, lib, nixpkgs-unstable, ... }:
{
#  nixpkgs.overlays = [unstable-packages];
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  # Example of adding an unstable package
#  environment.systemPackages = with pkgs; [
#    # Existing stable packages...
#    (nixpkgs-unstable.lib.getPackages pkgs).yt-dlp
#		(nixpkgs-unstable.lib.getPackages pkgs).get_iplayer
#  ];
  nixpkgs.config.allowUnfree = true; 
  environment.systemPackages = with pkgs; [
    ## unstable
#    (nixpkgs-unstable.lib.getPackages pkgs).yt-dlp
#    (nixpkgs-unstable.lib.getPackages pkgs).get_iplayer
    obsidian # usually on unstable
    vscode
    nix-prefetch-git
    ripgrep #neovim telescope grep requirement
    lua # requirement for neovim to be modified / treesitter
		vim-full # for vimtutor
		calibre
		wgnord # nord vpn helper with wireguard
		speedtest-cli # simple terminal internet tester
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
    lutris
		bottles-unwrapped
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
    sioyek # pdf viewer
    libreoffice-still
#    unstablePkgs.obsidian
#    unstablePkgs.vscode
    feh
    vivaldi
    tor
    tor-browser
		element-desktop
		flatpak

    #---------Media----------------#
    vlc
    discord
    zoom-us
		unzip

    vscode-extensions.ms-vscode-remote.remote-ssh
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-mono
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.blex-mono
    nerd-fonts.mononoki
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    curl
    expat
    libuuid
  ];

  system.activationScripts.wgnord.text = ''
  mkdir -p /var/lib/wgnord
  mkdir -p /etc/wireguard

  ln -sf ${../../home/files/wgnord/template.conf} /var/lib/wgnord/template.conf
  ln -sf ${../../home/files/wgnord/countries.txt} /var/lib/wgnord/countries.txt
  ln -sf ${../../home/files/wgnord/countries_iso31662.txt} /var/lib/wgnord/countries_iso31662.txt

  if [ ! -e /etc/wireguard/wgnord.conf ]; then
    cp ${../../home/files/wgnord/template.conf} /etc/wireguard/wgnord.conf
  fi

  chmod 700 /var/lib/wgnord
  chmod 700 /etc/wireguard
  chmod 600 /etc/wireguard/wgnord.conf || true
'';
}
