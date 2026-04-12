# illogical-impulse Quickshell

Vendored from upstream:

- Source: https://github.com/end-4/dots-hyprland
- Imported commit: e03cbfe
- Upstream Quickshell path: `dots/.config/quickshell`
- Upstream Hyprland snippets path: `dots/.config/hypr`
- NixOS reference only: https://github.com/soymou/illogical-flake

`default.nix` is the gateway module. Import `./../../../modules/quickshell`
from a host alongside `modules/wm/hyprland`, and comment out `modules/basic`
or `modules/shell` so only one shell layer owns the bar/launcher.

The Home Manager module symlinks this source tree out-of-store into
`~/.config/quickshell` and `~/.config/hypr/hyprland`, so QML and script edits
under this directory can be tested without copying files around.

Some image/color helper features use upstream's Python virtual environment.
After enabling the module, run `illogical-impulse-python-venv` once if those
features complain about missing Python packages.
