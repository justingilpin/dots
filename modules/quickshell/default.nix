# modules/quickshell/default.nix
#
# illogical-impulse Quickshell gateway.
# Source: https://github.com/end-4/dots-hyprland
# NixOS reference only: https://github.com/soymou/illogical-flake
#
# Import this alongside modules/wm/hyprland, instead of modules/basic or
# modules/shell, to let illogical-impulse own the bar/launcher/widgets.

{
  pkgs,
  lib,
  unstable ? pkgs,
  inputs ? {},
  ...
}:

let
  optionalPackages = set: names:
    lib.concatMap (name:
      lib.optional (builtins.hasAttr name set) (builtins.getAttr name set)
    ) names;

  qt6Packages = if pkgs ? qt6Packages then pkgs.qt6Packages else {};
  kdePackages = if pkgs ? kdePackages then pkgs.kdePackages else {};
  nerdFonts = if pkgs ? nerd-fonts then pkgs.nerd-fonts else {};
  pythonPackage = if pkgs ? python312 then pkgs.python312 else pkgs.python3;

  quickshellPackage =
    if inputs ? quickshell
      && inputs.quickshell ? packages
      && builtins.hasAttr pkgs.system inputs.quickshell.packages
      && builtins.hasAttr "default" inputs.quickshell.packages.${pkgs.system}
    then
      inputs.quickshell.packages.${pkgs.system}.default.override {
        withX11 = false;
        withI3 = false;
      }
    else if unstable ? quickshell then unstable.quickshell
    else if pkgs ? quickshell then pkgs.quickshell
    else null;

  runtimePackages =
    (lib.optional (quickshellPackage != null) quickshellPackage)
    ++ (optionalPackages pkgs [
      "bash"
      "bc"
      "brightnessctl"
      "cava"
      "cliphist"
      "coreutils"
      "curl"
      "ddcutil"
      "easyeffects"
      "file"
      "findutils"
      "fish"
      "fontconfig"
      "fuzzel"
      "glib"
      "gnome-keyring"
      "grim"
      "hypridle"
      "hyprland"
      "hyprlock"
      "hyprpicker"
      "hyprshot"
      "hyprsunset"
      "imagemagick"
      "jq"
      "kitty"
      "libqalculate"
      "matugen"
      "pamixer"
      "pavucontrol"
      "pavucontrol-qt"
      "playerctl"
      "procps"
      "python312"
      "ripgrep"
      "rsync"
      "slurp"
      "songrec"
      "swappy"
      "tesseract"
      "translate-shell"
      "upower"
      "uv"
      "wget"
      "wf-recorder"
      "wireplumber"
      "wl-clipboard"
      "wlogout"
      "wtype"
      "xdg-user-dirs"
      "ydotool"
      "meson"
      "ninja"
      "pkg-config"
    ])
    ++ (optionalPackages qt6Packages [
      "qtbase"
      "qtdeclarative"
      "qt5compat"
      "qtimageformats"
      "qtmultimedia"
      "qtpositioning"
      "qtquicktimeline"
      "qtsensors"
      "qtsvg"
      "qttools"
      "qttranslations"
      "qtvirtualkeyboard"
      "qtwayland"
    ])
    ++ (optionalPackages kdePackages [
      "bluedevil"
      "dolphin"
      "kdialog"
      "kirigami"
      "plasma-nm"
      "polkit-kde-agent-1"
      "systemsettings"
      "syntax-highlighting"
    ]);

  fontPackages =
    (optionalPackages pkgs [
      "material-symbols"
      "readex-pro"
      "rubik"
      "space-grotesk"
      "twemoji-color-font"
    ])
    ++ (optionalPackages nerdFonts [
      "jetbrains-mono"
    ]);

  runtimePath = lib.makeBinPath runtimePackages;

  illogicalImpulseLauncher = pkgs.writeShellScriptBin "illogical-impulse-quickshell" ''
    export PATH="${runtimePath}:$PATH"
    if command -v qs >/dev/null 2>&1; then
      exec qs -c ii
    fi
    exec quickshell -c ii
  '';

  illogicalImpulsePythonVenv = pkgs.writeShellScriptBin "illogical-impulse-python-venv" ''
    set -euo pipefail

    export UV_NO_MODIFY_PATH=1
    export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
    export ILLOGICAL_IMPULSE_VIRTUAL_ENV="''${ILLOGICAL_IMPULSE_VIRTUAL_ENV:-$XDG_STATE_HOME/quickshell/.venv}"

    requirements="$HOME/.dots/modules/quickshell/source/uv/requirements.txt"
    if [ ! -f "$requirements" ]; then
      echo "Missing $requirements" >&2
      exit 1
    fi

    mkdir -p "$(dirname "$ILLOGICAL_IMPULSE_VIRTUAL_ENV")"
    ${pkgs.uv}/bin/uv venv --prompt .venv "$ILLOGICAL_IMPULSE_VIRTUAL_ENV" -p ${pythonPackage}/bin/python3
    . "$ILLOGICAL_IMPULSE_VIRTUAL_ENV/bin/activate"
    ${pkgs.uv}/bin/uv pip install -r "$requirements"
  '';
in
{
  assertions = [
    {
      assertion = quickshellPackage != null;
      message = "modules/quickshell needs a Quickshell package from inputs.quickshell, unstable.quickshell, or pkgs.quickshell.";
    }
  ];

  # Upstream setup-notes.sh adds video/i2c/input group access and loads i2c-dev.
  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" "uinput" ];
  users.users.justin.extraGroups = [ "video" "i2c" "input" ];

  fonts.packages = fontPackages;

  environment.systemPackages =
    runtimePackages
    ++ fontPackages
    ++ [
      illogicalImpulseLauncher
      illogicalImpulsePythonVenv
    ];

  home-manager.users.justin = { config, lib, ... }:
    let
      sourceRoot = "${config.home.homeDirectory}/.dots/modules/quickshell/source";
      outOfStore = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      programs.waybar.enable = lib.mkForce false;

      home.file.".config/quickshell".source =
        outOfStore "${sourceRoot}/quickshell";

      home.file.".config/hypr/hyprlock".source =
        outOfStore "${sourceRoot}/hypr/hyprlock";

      home.file.".config/hypr/hypridle.conf".source =
        lib.mkForce (outOfStore "${sourceRoot}/hypr/hypridle.conf");

      home.file.".config/hypr/hyprlock.conf".source =
        lib.mkForce (outOfStore "${sourceRoot}/hypr/hyprlock.conf");

      systemd.user.services.illogical-impulse-quickshell = {
        Unit = {
          Description = "illogical-impulse Quickshell";
          After = [ "hyprland-session.target" ];
          PartOf = [ "hyprland-session.target" ];
        };

        Service = {
          ExecStart = "${illogicalImpulseLauncher}/bin/illogical-impulse-quickshell";
          Environment = "PATH=${runtimePath}";
          Restart = "on-failure";
          RestartSec = "2s";
        };

        Install.WantedBy = [ "hyprland-session.target" ];
      };

      wayland.windowManager.hyprland.extraConfig = ''
        # illogical-impulse Quickshell
        $qsConfig = ii

        env = ILLOGICAL_IMPULSE_VIRTUAL_ENV, ~/.local/state/quickshell/.venv

        exec-once = systemctl --user restart illogical-impulse-quickshell.service
        exec-once = gnome-keyring-daemon --start --components=secrets
        exec-once = hypridle
        exec-once = dbus-update-activation-environment --all
        exec-once = sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec-once = wl-paste --type text --watch bash -c 'cliphist store && qs -c $qsConfig ipc call cliphistService update'
        exec-once = wl-paste --type image --watch bash -c 'cliphist store && qs -c $qsConfig ipc call cliphistService update'

        # Keep this module as a shell layer only: your base Hyprland config still
        # owns monitors, window rules, workspaces, and normal app binds.
        bind = $mainMod, R, global, quickshell:searchToggle
        bind = $mainMod, Tab, global, quickshell:overviewWorkspacesToggle
        bind = $mainMod, A, global, quickshell:sidebarLeftToggle
        bind = $mainMod, N, global, quickshell:sidebarRightToggle
        bind = $mainMod, Slash, global, quickshell:cheatsheetToggle
        bind = $mainMod, J, global, quickshell:barToggle
        bind = CTRL ALT, Delete, global, quickshell:sessionToggle
        bind = CTRL $mainMod, T, global, quickshell:wallpaperSelectorToggle
        bind = CTRL $mainMod ALT, T, global, quickshell:wallpaperSelectorRandom
        bind = CTRL $mainMod, P, global, quickshell:panelFamilyCycle
        bind = Ctrl+Super, R, exec, systemctl --user restart illogical-impulse-quickshell.service
      '';
    };
}
