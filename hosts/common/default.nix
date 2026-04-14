{ inputs, lib, pkgs, ... }:

{
  imports = [
    ./common-packages.nix
    ./nixos-common.nix
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    bat
    bottom
    eza
    wl-clipboard
  ] ++ [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home-manager.users.justin = {
    programs.zsh.initContent = lib.mkOrder 1500 ''
      # Modern CLI replacements from hosts/common/default.nix.
      if command -v eza >/dev/null 2>&1; then
        alias ls='eza --icons --group-directories-first'
        alias l='eza -alh --icons --group-directories-first --git'
        alias ll='eza -lh --icons --group-directories-first --git'
        alias la='eza -lah --icons --group-directories-first --git'
        alias tree='eza --tree --icons'
      fi

      if command -v bat >/dev/null 2>&1; then
        alias cat='bat --paging=never'
      fi

      if command -v btm >/dev/null 2>&1; then
        alias top='btm'
      fi
    '';

  };
}
