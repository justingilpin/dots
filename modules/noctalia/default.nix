# modules/noctalia/default.nix
#
# Noctalia shell — a minimal Quickshell-based Wayland desktop shell.
# https://github.com/noctalia-dev/noctalia-shell
# https://docs.noctalia.dev/getting-started/nixos/
#
# Import instead of modules/basic or modules/shell.
# Host swap example (fibonacci/default.nix):
#
#   # ./../../../modules/basic
#   # ./../../../modules/shell
#   ./../../../modules/noctalia   # <--- Active
#
# NOTE: Noctalia requires nixpkgs-unstable (it depends on the latest Quickshell).
#       The flake.nix wires inputs.noctalia to follow nixpkgs-unstable.
#
# OWNERSHIP MODEL: Noctalia is configured declaratively through the home-manager
#   module below (programs.noctalia-shell). Settings are stored as a read-only
#   symlink at ~/.config/noctalia/settings.json generated from your Nix config.
#   To capture GUI changes back into Nix, run:
#     noctalia-shell ipc call state all | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)['settings'], indent=2))"
#   then paste the relevant values into the settings block below.

{ pkgs, lib, inputs, ... }:

{
  # ── Services required by Noctalia features ────────────────────────────────
  # wifi, bluetooth, battery, and power-profile widgets need these enabled.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # ── Noctalia for justin ───────────────────────────────────────────────────
  home-manager.users.justin = { lib, ... }: {
    # Note: inputs.noctalia.homeModules.default is already imported globally in flake.nix
    # — no need to re-import here.

    programs.noctalia-shell = {
      enable = true;

      # ── Shell settings ───────────────────────────────────────────────────
      # Full options reference:
      # https://github.com/noctalia-dev/noctalia-shell/blob/main/Assets/settings-default.json
      #
      # To get your current live settings (after tweaking in the GUI):
      #   noctalia-shell ipc call state all | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin)['settings'], indent=2))"
      settings = {

        general = {
          avatarImage                    = "/home/justin/.face";
          dimmerOpacity                  = 0.2;
          scaleRatio                     = 1;
          radiusRatio                    = 1;
          animationSpeed                 = 1;
          enableShadows                  = true;
          enableBlurBehind               = true;
          shadowDirection                = "bottom_right";
          shadowOffsetX                  = 2;
          shadowOffsetY                  = 3;
          lockOnSuspend                  = true;
          compactLockScreen              = false;
          lockScreenAnimations           = false;
          showSessionButtonsOnLockScreen = true;
          showHibernateOnLockScreen      = false;
          enableLockScreenMediaControls  = false;
          enableLockScreenCountdown      = true;
          lockScreenCountdownDuration    = 10000;
          autoStartAuth                  = false;
          allowPasswordWithFprintd       = false;
          clockStyle                     = "custom";
          clockFormat                    = "hh\\nmm";
          passwordChars                  = false;
          lockScreenBlur                 = 0;
          lockScreenTint                 = 0;
          telemetryEnabled               = false;
          showChangelogOnStartup         = true;
          allowPanelsOnScreenWithoutBar  = true;
          reverseScroll                  = false;
          smoothScrollEnabled            = true;
        };

        ui = {
          fontDefault             = "Fira Code";
          fontFixed               = "BlexMono Nerd Font";
          fontDefaultScale        = 1;
          fontFixedScale          = 1;
          tooltipsEnabled         = true;
          scrollbarAlwaysVisible  = true;
          boxBorderEnabled        = false;
          panelBackgroundOpacity  = 0.93;
          translucentWidgets      = false;
          panelsAttachedToBar     = true;
          settingsPanelMode       = "attached";
          settingsPanelSideBarCardStyle = false;
        };

        location = {
          name                    = "Davao City, Philippines";
          weatherEnabled          = true;
          weatherShowEffects      = true;
          weatherTaliaMascotAlways = false;
          useFahrenheit           = true;
          use12hourFormat         = false;
          showWeekNumberInCalendar = false;
          showCalendarEvents      = true;
          showCalendarWeather     = true;
          analogClockInCalendar   = false;
          firstDayOfWeek          = -1;
          hideWeatherTimezone     = false;
          hideWeatherCityName     = false;
          autoLocate              = false;
        };

        bar = {
          barType              = "simple";
          position             = "top";
          monitors             = [];
          density              = "comfortable";
          showOutline          = false;
          showCapsule          = true;
          capsuleOpacity       = 1;
          capsuleColorKey      = "none";
          widgetSpacing        = 6;
          contentPadding       = 2;
          fontScale            = 1;
          enableExclusionZoneInset = true;
          backgroundOpacity    = 0.93;
          useSeparateOpacity   = false;
          marginVertical       = 4;
          marginHorizontal     = 4;
          frameThickness       = 8;
          frameRadius          = 12;
          outerCorners         = true;
          hideOnOverview       = false;
          displayMode          = "always_visible";
          autoHideDelay        = 500;
          autoShowDelay        = 150;
          showOnWorkspaceSwitch = true;
          mouseWheelAction     = "none";
          reverseScroll        = false;
          mouseWheelWrap       = true;
          middleClickAction    = "none";
          middleClickFollowMouse = false;
          middleClickCommand   = "";
          rightClickAction     = "controlCenter";
          rightClickFollowMouse = true;
          rightClickCommand    = "";
          screenOverrides      = [];

          widgets = {
            left = [
              {
                id                   = "Launcher";
                icon                 = "rocket";
                useDistroLogo        = false;
                enableColorization   = false;
                colorizeSystemIcon   = "none";
                colorizeSystemText   = "none";
                customIconPath       = "";
                iconColor            = "none";
              }
              {
                id                   = "Clock";
                formatHorizontal     = "HH:mm ddd, MMM dd";
                formatVertical       = "HH mm - dd MM";
                tooltipFormat        = "HH:mm ddd, MMM dd";
                clockColor           = "none";
                customFont           = "";
                useCustomFont        = false;
              }
              {
                id                   = "SystemMonitor";
                compactMode          = true;
                diskPath             = "/";
                iconColor            = "none";
                showCpuCores         = false;
                showCpuFreq          = false;
                showCpuTemp          = true;
                showCpuUsage         = true;
                showDiskAvailable    = false;
                showDiskUsage        = false;
                showDiskUsageAsPercent = false;
                showGpuTemp          = false;
                showLoadAverage      = false;
                showMemoryAsPercent  = false;
                showMemoryUsage      = true;
                showNetworkStats     = false;
                showSwapUsage        = false;
                textColor            = "none";
                useMonospaceFont     = true;
                usePadding           = false;
              }
              {
                id                   = "ActiveWindow";
                colorizeIcons        = false;
                hideMode             = "hidden";
                maxWidth             = 145;
                scrollingMode        = "hover";
                showIcon             = true;
                showText             = true;
                textColor            = "none";
                useFixedWidth        = false;
              }
              {
                id                   = "MediaMini";
                compactMode          = false;
                hideMode             = "hidden";
                hideWhenIdle         = false;
                maxWidth             = 145;
                panelShowAlbumArt    = true;
                scrollingMode        = "hover";
                showAlbumArt         = true;
                showArtistFirst      = true;
                showProgressRing     = true;
                showVisualizer       = false;
                textColor            = "none";
                useFixedWidth        = false;
                visualizerType       = "linear";
              }
            ];
            center = [
              {
                id                         = "Workspace";
                characterCount             = 2;
                colorizeIcons              = false;
                emptyColor                 = "secondary";
                enableScrollWheel          = true;
                focusedColor               = "primary";
                followFocusedScreen        = false;
                fontWeight                 = "bold";
                groupedBorderOpacity       = 1;
                hideUnoccupied             = false;
                iconScale                  = 0.8;
                labelMode                  = "index";
                occupiedColor              = "secondary";
                pillSize                   = 0.6;
                showApplications           = false;
                showApplicationsHover      = false;
                showBadge                  = true;
                showLabelsOnlyWhenOccupied = true;
                unfocusedIconsOpacity      = 1;
              }
            ];
            right = [
              {
                id             = "Tray";
                blacklist      = [];
                chevronColor   = "none";
                colorizeIcons  = false;
                drawerEnabled  = true;
                hidePassive    = false;
                pinned         = [];
              }
              {
                id                  = "NotificationHistory";
                hideWhenZero        = false;
                hideWhenZeroUnread  = false;
                iconColor           = "none";
                showUnreadBadge     = true;
                unreadBadgeColor    = "primary";
              }
              {
                id                     = "Battery";
                deviceNativePath       = "__default__";
                displayMode            = "graphic-clean";
                hideIfIdle             = false;
                hideIfNotDetected      = true;
                showNoctaliaPerformance = false;
                showPowerProfiles      = false;
              }
              {
                id                 = "Volume";
                displayMode        = "onhover";
                iconColor          = "none";
                middleClickCommand = "pwvucontrol || pavucontrol";
                textColor          = "none";
              }
              {
                id                    = "Brightness";
                applyToAllMonitors    = false;
                displayMode           = "onhover";
                iconColor             = "none";
                textColor             = "none";
              }
              {
                id                   = "ControlCenter";
                colorizeDistroLogo   = false;
                colorizeSystemIcon   = "none";
                colorizeSystemText   = "none";
                customIconPath       = "";
                enableColorization   = false;
                icon                 = "noctalia";
                useDistroLogo        = false;
              }
            ];
          };
        };

        wallpaper = {
          enabled                      = true;
          directory                    = "/home/justin/Pictures/Wallpapers";
          monitorDirectories           = [];
          enableMultiMonitorDirectories = false;
          showHiddenFiles              = false;
          viewMode                     = "single";
          setWallpaperOnAllMonitors    = true;
          linkLightAndDarkWallpapers   = true;
          fillMode                     = "crop";
          fillColor                    = "#000000";
          useSolidColor                = false;
          solidColor                   = "#1a1a2e";
          automationEnabled            = false;
          wallpaperChangeMode          = "random";
          randomIntervalSec            = 300;
          transitionDuration           = 1500;
          transitionType               = [ "fade" "disc" "stripes" "wipe" "pixelate" "honeycomb" ];
          skipStartupTransition        = false;
          transitionEdgeSmoothness     = 0.05;
          panelPosition                = "follow_bar";
          hideWallpaperFilenames       = false;
          useOriginalImages            = false;
          overviewBlur                 = 0.4;
          overviewTint                 = 0.6;
          sortOrder                    = "name";
          favorites                    = [];
        };

        appLauncher = {
          enableClipboardHistory       = false;
          autoPasteClipboard           = false;
          enableClipPreview            = true;
          clipboardWrapText            = true;
          enableClipboardSmartIcons    = true;
          enableClipboardChips         = true;
          clipboardWatchTextCommand    = "wl-paste --type text --watch cliphist store";
          clipboardWatchImageCommand   = "wl-paste --type image --watch cliphist store";
          position                     = "center";
          pinnedApps                   = [];
          sortByMostUsed               = true;
          terminalCommand              = "alacritty -e";
          customLaunchPrefixEnabled    = false;
          customLaunchPrefix           = "";
          viewMode                     = "list";
          showCategories               = true;
          iconMode                     = "tabler";
          showIconBackground           = false;
          enableSettingsSearch         = true;
          enableWindowsSearch          = true;
          enableSessionSearch          = true;
          ignoreMouseInput             = false;
          screenshotAnnotationTool     = "";
          overviewLayer                = false;
          density                      = "default";
        };

        controlCenter = {
          position  = "close_to_bar_button";
          diskPath  = "/";
          shortcuts = {
            left = [
              { id = "Network"; }
              { id = "Bluetooth"; }
              { id = "WallpaperSelector"; }
              { id = "NoctaliaPerformance"; }
            ];
            right = [
              { id = "Notifications"; }
              { id = "PowerProfile"; }
              { id = "KeepAwake"; }
              { id = "NightLight"; }
            ];
          };
          cards = [
            { id = "profile-card";      enabled = true; }
            { id = "shortcuts-card";    enabled = true; }
            { id = "audio-card";        enabled = true; }
            { id = "brightness-card";   enabled = false; }
            { id = "weather-card";      enabled = true; }
            { id = "media-sysmon-card"; enabled = true; }
          ];
        };

        notifications = {
          enabled                 = true;
          enableMarkdown          = false;
          density                 = "default";
          monitors                = [];
          location                = "top_right";
          overlayLayer            = true;
          backgroundOpacity       = 1;
          respectExpireTimeout    = false;
          lowUrgencyDuration      = 3;
          normalUrgencyDuration   = 8;
          criticalUrgencyDuration = 15;
          clearDismissed          = true;
          saveToHistory = {
            low      = true;
            normal   = true;
            critical = true;
          };
          sounds = {
            enabled         = false;
            volume          = 0.5;
            separateSounds  = false;
            criticalSoundFile = "";
            normalSoundFile = "";
            lowSoundFile    = "";
            excludedApps    = "discord,firefox,chrome,chromium,edge";
          };
          enableMediaToast          = false;
          enableKeyboardLayoutToast = true;
          enableBatteryToast        = true;
        };

        osd = {
          enabled           = true;
          location          = "top_right";
          autoHideMs        = 2000;
          overlayLayer      = true;
          backgroundOpacity = 1;
          enabledTypes      = [ 0 1 2 ];
          monitors          = [];
        };

        audio = {
          volumeStep         = 5;
          volumeOverdrive    = false;
          spectrumFrameRate  = 30;
          visualizerType     = "linear";
          spectrumMirrored   = true;
          mprisBlacklist     = [];
          preferredPlayer    = "";
          volumeFeedback     = false;
          volumeFeedbackSoundFile = "";
        };

        brightness = {
          brightnessStep       = 5;
          enforceMinimum       = true;
          enableDdcSupport     = false;
          backlightDeviceMappings = [];
        };

        colorSchemes = {
          useWallpaperColors = false;
          predefinedScheme   = "Nord";
          darkMode           = true;
          schedulingMode     = "off";
          manualSunrise      = "06:30";
          manualSunset       = "18:30";
          generationMethod   = "tonal-spot";
          monitorForColors   = "";
          syncGsettings      = true;
        };

        nightLight = {
          enabled       = false;
          forced        = false;
          autoSchedule  = true;
          nightTemp     = "4000";
          dayTemp       = "6500";
          manualSunrise = "06:30";
          manualSunset  = "18:30";
        };

        dock = {
          enabled             = true;
          position            = "bottom";
          displayMode         = "auto_hide";
          dockType            = "floating";
          backgroundOpacity   = 1;
          floatingRatio       = 1;
          size                = 1;
          onlySameOutput      = true;
          monitors            = [];
          pinnedApps          = [];
          colorizeIcons       = false;
          showLauncherIcon    = false;
          launcherPosition    = "end";
          launcherUseDistroLogo = false;
          launcherIcon        = "";
          launcherIconColor   = "none";
          pinnedStatic        = false;
          inactiveIndicators  = false;
          groupApps           = false;
          groupContextMenuMode = "extended";
          groupClickAction    = "cycle";
          groupIndicatorStyle = "dots";
          deadOpacity         = 0.6;
          animationSpeed      = 1;
          sitOnFrame          = false;
          showDockIndicator   = false;
          indicatorThickness  = 3;
          indicatorColor      = "primary";
          indicatorOpacity    = 0.6;
        };

        sessionMenu = {
          enableCountdown   = true;
          countdownDuration = 10000;
          position          = "center";
          showHeader        = true;
          showKeybinds      = true;
          largeButtonsStyle = true;
          largeButtonsLayout = "single-row";
          powerOptions = [
            { action = "lock";         enabled = true; keybind = "1"; }
            { action = "suspend";      enabled = true; keybind = "2"; }
            { action = "hibernate";    enabled = true; keybind = "3"; }
            { action = "reboot";       enabled = true; keybind = "4"; }
            { action = "logout";       enabled = true; keybind = "5"; }
            { action = "shutdown";     enabled = true; keybind = "6"; }
            { action = "rebootToUefi"; enabled = true; keybind = "7"; }
          ];
        };

        network = {
          bluetoothRssiPollingEnabled = false;
          bluetoothRssiPollIntervalMs = 60000;
          networkPanelView            = "wifi";
          wifiDetailsViewMode         = "grid";
          bluetoothDetailsViewMode    = "grid";
          bluetoothHideUnnamedDevices = true;
          disableDiscoverability      = false;
          bluetoothAutoConnect        = true;
        };

        # ── Idle management ──────────────────────────────────────────────────
        # Noctalia handles idle/lock/suspend natively — hypridle is NOT launched.
        # screenOffTimeout: turn display off after 10 min
        # lockTimeout:      lock screen 1 min after screen off (660s total)
        # suspendTimeout:   suspend after 30 min
        idle = {
          enabled            = true;
          screenOffTimeout   = 600;
          lockTimeout        = 660;
          suspendTimeout     = 1800;
          fadeDuration       = 5;
          screenOffCommand   = "";
          lockCommand        = "";
          suspendCommand     = "";
          resumeScreenOffCommand = "";
          resumeLockCommand  = "";
          resumeSuspendCommand = "";
          customCommands     = "[]";
        };

        noctaliaPerformance = {
          disableWallpaper       = true;
          disableDesktopWidgets  = true;
        };

        desktopWidgets = {
          enabled         = false;
          overviewEnabled = true;
          gridSnap        = false;
          gridSnapScale   = false;
          monitorWidgets  = [];
        };

        calendar = {
          cards = [
            { id = "calendar-header-card"; enabled = true; }
            { id = "calendar-month-card";  enabled = true; }
            { id = "weather-card";         enabled = true; }
          ];
        };

        hooks = {
          enabled                  = false;
          wallpaperChange          = "";
          darkModeChange           = "";
          screenLock               = "";
          screenUnlock             = "";
          performanceModeEnabled   = "";
          performanceModeDisabled  = "";
          startup                  = "";
          session                  = "";
          colorGeneration          = "";
        };

        plugins = {
          autoUpdate     = false;
          notifyUpdates  = true;
        };

      };

      # ── Plugin sources ───────────────────────────────────────────────────
      # Uncomment to enable the official plugin registry.
      # plugins = {
      #   sources = [
      #     {
      #       enabled = true;
      #       name = "Official Noctalia Plugins";
      #       url = "https://github.com/noctalia-dev/noctalia-plugins";
      #     }
      #   ];
      # };
    };

    # ── Hyprland integration for Noctalia ───────────────────────────────
    # NOTE: hypridle is intentionally NOT launched here — Noctalia manages
    #       idle/lock/suspend natively via its own idle daemon (idle.enabled = true).
    wayland.windowManager.hyprland.extraConfig = ''
      # Launch Noctalia on Hyprland start
      exec-once = noctalia-shell

      # ── Noctalia IPC keybinds ────────────────────────────────────────
      bind = $mainMod, R,           exec, noctalia-shell ipc call launcher toggle
      bind = $mainMod, D,           exec, noctalia-shell ipc call controlCenter toggle
      bind = $mainMod SHIFT, E,     exec, noctalia-shell ipc call sessionMenu toggle
      bind = $mainMod, comma,       exec, noctalia-shell ipc call settings toggle
      bind = $mainMod SHIFT, V,     exec, noctalia-shell ipc call launcher clipboard

      # Restart Noctalia shell
      bind = $mainMod SHIFT, Q,     exec, systemctl --user restart noctalia-shell
    '';

  }; # end home-manager.users.justin

}
