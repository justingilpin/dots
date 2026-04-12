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

  # Use unstable's Qt6 packages to match the Qt version Quickshell is built with
  # (inputs.quickshell follows nixpkgs-unstable, so they must align).
  qt6Packages = if unstable ? qt6Packages then unstable.qt6Packages
                else if pkgs ? qt6Packages then pkgs.qt6Packages
                else {};
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

  # Quickshell's own wrapper already sets NIXPKGS_QT6_QML_IMPORT_PATH for
  # qtdeclarative and qtwayland.  We extend it with the extra QML packages
  # that illogical-impulse needs but Quickshell doesn't bundle itself.
  extraQmlPackages =
    (map (name: qt6Packages.${name} or null)
      [ "qt5compat" "qtpositioning" "qtmultimedia" "qtimageformats" ])
    ++ (map (name: kdePackages.${name} or null)
      [ "syntax-highlighting" ])
    # kirigami-wrapped doesn't expose QML; use the unwrapped derivation directly
    ++ (if kdePackages ? kirigami then
          let unwrapped = kdePackages.kirigami.unwrapped or kdePackages.kirigami;
          in [ unwrapped ]
        else []);

  extraQmlPaths = lib.concatStringsSep ":" (lib.filter (p: p != "")
    (map (pkg:
      let qmlDir = if pkg != null then "${pkg}/lib/qt-6/qml" else "";
      in if pkg != null && builtins.pathExists (pkg + "/lib/qt-6/qml")
         then qmlDir else ""
    ) extraQmlPackages));

  # Wrap the already-Qt-wrapped qs binary with extra QML paths and runtime PATH.
  illogicalImpulseLauncher = pkgs.symlinkJoin {
    name = "illogical-impulse-quickshell";
    paths = [ quickshellPackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/qs \
        --prefix NIXPKGS_QT6_QML_IMPORT_PATH : "${extraQmlPaths}" \
        --prefix PATH : "${runtimePath}" \
        --add-flags "-c ii" \
        --set-default ILLOGICAL_IMPULSE_VIRTUAL_ENV "$HOME/.local/state/quickshell/.venv"
      mv $out/bin/qs $out/bin/illogical-impulse-quickshell
    '';
  };

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

  # Cloudflare WARP — toggled from the right sidebar in ii.
  # After rebuild: run `warp-cli registration new` once to register the device.
  systemd.services.warp-svc = {
    description = "Cloudflare WARP daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
      Restart = "on-failure";
    };
  };

  fonts.packages = fontPackages;

  environment.systemPackages =
    runtimePackages
    ++ fontPackages
    ++ [
      illogicalImpulseLauncher
      illogicalImpulsePythonVenv
      pkgs.cloudflare-warp
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

        # illogical-impulse shell keybinds — bindd descriptions appear in the cheatsheet (Super+/)
        # Keys deliberately avoided to not conflict with base hyprland config:
        #   Super+M (exit), Super+V (togglefloating), Super+P (pseudo),
        #   Super+J (movefocus d), Super+K (movefocus u), Super+F (fullscreen)
        $settingsApp = qs -p ~/.config/quickshell/$qsConfig/settings.qml

        bindd = Super, R,          Open launcher,          global, quickshell:searchToggle
        bind  = Super, Tab,        global,  quickshell:overviewWorkspacesToggle
        bindd = Super, Period,     Emoji picker,           global, quickshell:overviewEmojiToggle
        bind  = Super, A,          global,  quickshell:sidebarLeftToggle
        bindd = Super, N,          Toggle right sidebar,   global, quickshell:sidebarRightToggle
        bindd = Super, Slash,      Toggle cheatsheet,      global, quickshell:cheatsheetToggle
        bind  = Super, G,          global,  quickshell:overlayToggle
        bindd = Ctrl+Alt, Delete,  Toggle session menu,    global, quickshell:sessionToggle
        bindd = Super, I,          Open settings,          exec, $settingsApp
        bindd = Ctrl+Super, T,     Toggle wallpaper selector, global, quickshell:wallpaperSelectorToggle
        bindd = Ctrl+Super+Alt, T, Random wallpaper,       global, quickshell:wallpaperSelectorRandom
        bind  = Ctrl+Super, P,     global,  quickshell:panelFamilyCycle
        bind  = Super+Shift, S,    global,  quickshell:regionScreenshot
        bind  = Super+Shift, A,    global,  quickshell:regionSearch
        bind  = Super+Shift, X,    global,  quickshell:regionOcr
        bind  = Super+Shift, T,    global,  quickshell:screenTranslate
        bind  = Ctrl+Super, R,     exec, killall ydotool qs quickshell; qs -c $qsConfig &
      '';
    };
}
