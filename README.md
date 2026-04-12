# Justin's NixOS Dots

Personal NixOS flake managing multiple machines with Home Manager. Configurations are fully declarative — no install scripts, no symlink managers.

## Hosts

| Host | Type | WM |
|------|------|----|
| `fibonacci` | ThinkPad E14 (laptop) | Hyprland |
| `seykota` | Desktop | Hyprland |
| `bachelier` | Desktop | Hyprland |
| `donchian` | Home server | — |

## Structure

```
flake.nix          # Entry point — defines all hosts via mkSystem helper
hosts/
  common/          # Shared NixOS options and packages across all hosts
  nixos/           # Per-host configurations
home/
  justin.nix       # Home Manager config for desktop/laptop
  server.nix       # Home Manager config for server
modules/
  alacritty/       # Terminal
  hyprland/        # Hyprland config files
  nvim/            # Neovim
  servarr/         # Media server stack
  vectorbt/        # Algo trading / data analysis
  waybar/          # Status bar
  wm/hyprland/     # Hyprland NixOS module
```

## Usage

Apply configuration for a host:
```bash
sudo nixos-rebuild switch --flake .#hostname
```

Update flake inputs:
```bash
nix flake update
```

## Flake Inputs

- [nixpkgs](https://github.com/nixos/nixpkgs) — stable (25.11)
- [nixpkgs-unstable](https://github.com/nixos/nixpkgs) — unstable channel for select packages
- [home-manager](https://github.com/nix-community/home-manager)
- [nixvim](https://github.com/nix-community/nixvim)
- [nixarr](https://github.com/rasmus-kirk/nixarr)
- [disko](https://github.com/nix-community/disko)
