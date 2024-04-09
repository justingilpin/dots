# common/prgrams/nixvim/default.nix
{pkgs, ...}: {
  programs.nixvim = import ./config.nix pkgs;
}
