{lib, ...}: {
  flake.modules.homeManager.desktop = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.desktop;
    session = cfg.session.gnome;

    inherit (lib.hm.gvariant) mkDictionaryEntry mkTuple mkUint32 mkVariant;

    appPosition = name: position:
      mkDictionaryEntry [
        name
        (mkVariant [
          (mkDictionaryEntry ["position" (mkVariant position)])
        ])
      ];

    pinnedApps =
      lib.lists.filter (app: app != null)
      (map (id: session.dock.applications.${id} or null) cfg.dock.apps.pinned);

    wallpaper = {
      light =
        if cfg.theme.wallpaper.light != null
        then cfg.theme.wallpaper.light
        else "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      dark =
        if cfg.theme.wallpaper.dark != null
        then cfg.theme.wallpaper.dark
        else "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
    };
  in {
    options.desktop.session.gnome = {
      enable = lib.options.mkEnableOption "GNOME desktop settings dispatcher";

      dock.applications = lib.options.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          file-manager = "org.gnome.Nautilus.desktop";
          browser = "app.zen_browser.zen.desktop";
          terminal = "kitty.desktop";
          editor = "code.desktop";
        };
        description = "Mapping from logical pinned app IDs to desktop entry IDs.";
      };

      input.keyboard.xkbOptions = lib.options.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["terminate:ctrl_alt_bksp"];
        description = "GNOME XKB options.";
      };

      keybindings = {
        media = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {
            help = [];
            logout = ["<Shift><Super>q"];
            magnifier = [];
            magnifier-zoom-in = [];
            magnifier-zoom-out = [];
            next = ["F9"];
            play = ["F8"];
            previous = ["F7"];
            screenreader = [];
            screensaver = ["<Control><Super>q"];
            volume-down = ["F11"];
            volume-mute = ["F10"];
            volume-up = ["F12"];
          };
          description = "GNOME media and system keybindings.";
        };

        shell = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {
            screenshot = [];
            screenshot-window = [];
            show-screen-recording-ui = [];
            show-screenshot-ui = ["<Shift><Super>4"];
            switch-to-application-1 = [];
            switch-to-application-2 = [];
            switch-to-application-3 = [];
            switch-to-application-4 = [];
            toggle-message-tray = ["<Control><Alt>Right"];
            toggle-overview = ["<Super>space"];
          };
          description = "GNOME Shell keybindings.";
        };

        wayland = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {
            restore-shortcuts = [];
          };
          description = "GNOME Mutter Wayland keybindings.";
        };

        windowManager = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {
            activate-window-menu = ["<Control>Return"];
            begin-move = [];
            begin-resize = [];
            close = ["<Super>w"];
            cycle-group = [];
            cycle-group-backward = [];
            cycle-panels = [];
            cycle-panels-backward = [];
            cycle-windows = [];
            cycle-windows-backward = [];
            move-to-monitor-down = [];
            move-to-monitor-left = ["<Shift><Super>Left"];
            move-to-monitor-right = ["<Shift><Super>Right"];
            move-to-monitor-up = [];
            move-to-workspace-1 = [];
            move-to-workspace-last = [];
            move-to-workspace-left = [];
            move-to-workspace-right = [];
            panel-run-dialog = ["<Super>r"];
            show-desktop = ["<Shift><Super>h"];
            switch-input-source = [];
            switch-input-source-backward = [];
            switch-to-workspace-1 = [];
            switch-to-workspace-down = [];
            switch-to-workspace-last = [];
            switch-to-workspace-left = ["<Control>Left"];
            switch-to-workspace-right = ["<Control>Right"];
            toggle-maximized = [];
          };
          description = "GNOME window-manager keybindings.";
        };
      };

      launcher = {
        appFolders = lib.options.mkOption {
          type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
          default = {
            "org/gnome/desktop/app-folders" = {
              folder-children = ["Utilities" "YaST" "Pardus" "3bebe58e-992c-49db-b6ca-29cd02ba98c7"];
            };

            "org/gnome/desktop/app-folders/folders/3bebe58e-992c-49db-b6ca-29cd02ba98c7" = {
              apps = [
                "org.kde.kdeconnect.app.desktop"
                "org.kde.kdeconnect.nonplasma.desktop"
                "org.kde.kdeconnect-settings.desktop"
                "org.kde.kdeconnect.sms.desktop"
              ];
              name = "KDE Connect";
              translate = false;
            };

            "org/gnome/desktop/app-folders/folders/Pardus" = {
              categories = ["X-Pardus-Apps"];
              name = "X-Pardus-Apps.directory";
              translate = true;
            };

            "org/gnome/desktop/app-folders/folders/Utilities" = {
              apps = [
                "gnome-abrt.desktop"
                "gnome-system-log.desktop"
                "nm-connection-editor.desktop"
                "org.gnome.baobab.desktop"
                "org.gnome.Connections.desktop"
                "org.gnome.DejaDup.desktop"
                "org.gnome.Dictionary.desktop"
                "org.gnome.DiskUtility.desktop"
                "org.gnome.Evince.desktop"
                "org.gnome.FileRoller.desktop"
                "org.gnome.fonts.desktop"
                "org.gnome.Loupe.desktop"
                "org.gnome.seahorse.Application.desktop"
                "org.gnome.tweaks.desktop"
                "org.gnome.Usage.desktop"
                "vinagre.desktop"
                "org.gnome.Snapshot.desktop"
                "org.gnome.Extensions.desktop"
                "pavucontrol.desktop"
                "nvim.desktop"
                "virt-manager.desktop"
              ];
              categories = ["X-GNOME-Utilities"];
              name = "X-GNOME-Utilities.directory";
              translate = true;
            };

            "org/gnome/desktop/app-folders/folders/YaST" = {
              categories = ["X-SuSE-YaST"];
              name = "suse-yast.directory";
              translate = true;
            };
          };
          description = "GNOME app-folder dconf settings.";
        };

        shellSettings = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {
            app-picker-layout = [
              [
                (appPosition "nixos-manual.desktop" 0)
                (appPosition "3bebe58e-992c-49db-b6ca-29cd02ba98c7" 1)
                (appPosition "com.github.tchx84.Flatseal.desktop" 2)
                (appPosition "us.zoom.Zoom.desktop" 3)
                (appPosition "org.signal.Signal.desktop" 4)
                (appPosition "com.spotify.Client.desktop" 5)
                (appPosition "com.valvesoftware.Steam.desktop" 6)
                (appPosition "Utilities" 7)
                (appPosition "org.pulseaudio.pavucontrol.desktop" 8)
                (appPosition "vesktop.desktop" 9)
                (appPosition "org.gnome.Settings.desktop" 10)
                (appPosition "Helix.desktop" 11)
                (appPosition "home-manager-manual.desktop" 12)
                (appPosition "org.gnome.Software.desktop" 13)
              ]
            ];
            command-history = [
              "sudo journalctl --vacuum-time=1d"
              "sudo shutdown now"
              "sudo systemctl hybrid-sleep"
            ];
            disable-user-extensions = true;
            last-selected-power-profile = "power-saver";
            welcome-dialog-last-shown-version = "46.2";
          };
          description = "GNOME Shell launcher and overview state.";
        };
      };

      notifications = {
        applications = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {
            app-zen-browser-zen = "app.zen_browser.zen.desktop";
            chromium-browser = "chromium-browser.desktop";
            com-github-tchx84-flatseal = "com.github.tchx84.Flatseal.desktop";
            com-spotify-client = "com.spotify.Client.desktop";
            com-valvesoftware-steam = "com.valvesoftware.Steam.desktop";
            firefox = "firefox.desktop";
            gnome-power-panel = "gnome-power-panel.desktop";
            kitty = "kitty.desktop";
            org-gnome-baobab = "org.gnome.baobab.desktop";
            org-gnome-console = "org.gnome.Console.desktop";
            org-gnome-evolution-alarm-notify = "org.gnome.Evolution-alarm-notify.desktop";
            org-gnome-settings = "org.gnome.Settings.desktop";
            org-gnome-software = "org.gnome.Software.desktop";
            org-kde-kdeconnect-daemon = "org.kde.kdeconnect.daemon.desktop";
            org-signal-signal = "org.signal.Signal.desktop";
            signal-desktop = "signal-desktop.desktop";
            spotify = "spotify.desktop";
            steam = "steam.desktop";
            us-zoom-zoom = "us.zoom.Zoom.desktop";
            vesktop = "vesktop.desktop";
          };
          description = "GNOME notification application IDs keyed by dconf child name.";
        };

        children = lib.options.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "vesktop"
            "gnome-power-panel"
            "org-kde-kdeconnect-daemon"
            "org-gnome-evolution-alarm-notify"
            "com-valvesoftware-steam"
            "org-signal-signal"
            "app-zen-browser-zen"
            "com-spotify-client"
          ];
          description = "GNOME notification application children.";
        };
      };

      remoteDesktop.rdp = {
        tlsCert = lib.options.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/.local/share/gnome-remote-desktop/certificates/rdp-tls.crt";
          description = "Path to the GNOME RDP TLS certificate.";
        };

        tlsKey = lib.options.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/.local/share/gnome-remote-desktop/certificates/rdp-tls.key";
          description = "Path to the GNOME RDP TLS key.";
        };
      };

      search.providers = lib.options.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "org.gnome.Contacts.desktop"
          "org.gnome.Documents.desktop"
          "org.gnome.Nautilus.desktop"
        ];
        description = "GNOME search provider order.";
      };

      theme.gtkTheme = lib.options.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "WhiteSure-Dark";
        description = "GNOME GTK theme name.";
      };
    };

    config = lib.modules.mkIf session.enable {
      assertions = [
        (lib.hm.assertions.assertPlatform "desktop.session.gnome" pkgs lib.platforms.linux)
      ];

      dconf.settings =
        session.launcher.appFolders
        // {
          "org/gnome/desktop/background" = {
            color-shading-type = "solid";
            picture-options = "zoom";
            picture-uri = wallpaper.light;
            picture-uri-dark = wallpaper.dark;
            primary-color = cfg.theme.wallpaper.primaryColor;
            secondary-color = cfg.theme.wallpaper.secondaryColor;
          };

          "org/gnome/desktop/input-sources" = {
            sources = [(mkTuple ["xkb" cfg.input.keyboard.layout])];
            xkb-options = session.input.keyboard.xkbOptions;
          };

          "org/gnome/desktop/interface" = {
            color-scheme =
              if cfg.theme.darkMode.enable
              then "prefer-dark"
              else "default";
            cursor-theme = cfg.theme.cursor.name;
            gtk-theme = session.theme.gtkTheme;
            icon-theme = cfg.theme.icons.name;
          };

          "org/gnome/desktop/notifications" = {
            application-children = session.notifications.children;
            show-banners = cfg.notifications.showBanners;
            show-in-lock-screen = cfg.notifications.showOnLockScreen;
          };

          "org/gnome/desktop/peripherals/keyboard".numlock-state = cfg.input.keyboard.numlock;
          "org/gnome/desktop/peripherals/mouse".accel-profile = cfg.input.pointer.accelerationProfile;
          "org/gnome/desktop/peripherals/touchpad".two-finger-scrolling-enabled = cfg.input.touchpad.twoFingerScrolling;

          "org/gnome/desktop/privacy" = {
            old-files-age = mkUint32 cfg.privacy.oldFilesAge;
            recent-files-max-age = cfg.privacy.recentFilesMaxAge;
          };

          "org/gnome/desktop/remote-desktop/rdp" = {
            inherit (cfg.remoteDesktop.rdp) enable;
            tls-cert = session.remoteDesktop.rdp.tlsCert;
            tls-key = session.remoteDesktop.rdp.tlsKey;
            view-only = cfg.remoteDesktop.rdp.viewOnly;
          };

          "org/gnome/desktop/screensaver" = {
            color-shading-type = "solid";
            lock-delay = mkUint32 cfg.lockScreen.idle.lockDelay;
            picture-options = "zoom";
            picture-uri = wallpaper.light;
            primary-color = cfg.theme.wallpaper.primaryColor;
            secondary-color = cfg.theme.wallpaper.secondaryColor;
          };

          "org/gnome/desktop/search-providers".sort-order = session.search.providers;
          "org/gnome/desktop/session".idle-delay = mkUint32 cfg.lockScreen.idle.delay;
          "org/gnome/desktop/wm/keybindings" = session.keybindings.windowManager;

          "org/gnome/mutter" = {
            dynamic-workspaces = cfg.workspaces.dynamic;
            edge-tiling = cfg.window.edgeTiling;
          };

          "org/gnome/mutter/wayland/keybindings" = session.keybindings.wayland;

          "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "icon-view";
            migrated-gtk-settings = true;
            search-filter-time-type = "last_modified";
          };

          "org/gnome/nautilus/window-state" = {
            initial-size = mkTuple [890 550];
            initial-size-file-chooser = mkTuple [890 550];
          };

          "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = cfg.theme.nightLight.enable;
            night-light-schedule-automatic = cfg.theme.nightLight.automaticSchedule;
          };

          "org/gnome/settings-daemon/plugins/media-keys" = session.keybindings.media;

          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-timeout = cfg.power.sleepInactiveAcTimeout;
            sleep-inactive-ac-type = cfg.power.sleepInactiveAcType;
          };

          "org/gnome/shell" =
            session.launcher.shellSettings
            // {
              favorite-apps = pinnedApps;
            };

          "org/gnome/shell/app-switcher".current-workspace-only = cfg.window.currentWorkspaceSwitcher;
          "org/gnome/shell/keybindings" = session.keybindings.shell;

          "org/gtk/gtk4/settings/file-chooser" = {
            date-format = "regular";
            location-mode = "path-bar";
            show-hidden = false;
            sidebar-width = 140;
            sort-column = "name";
            sort-directories-first = true;
            sort-order = "ascending";
            type-format = "category";
            view-type = "list";
            window-size = mkTuple [859 372];
          };

          "org/gtk/settings/file-chooser" = {
            date-format = "regular";
            location-mode = "path-bar";
            show-hidden = false;
            show-size-column = true;
            show-type-column = true;
            sidebar-width = 183;
            sort-column = "name";
            sort-directories-first = false;
            sort-order = "ascending";
            type-format = "category";
            window-position = mkTuple [665 66];
            window-size = mkTuple [1231 902];
          };
        }
        // lib.attrsets.mapAttrs' (name: appId:
          lib.attrsets.nameValuePair "org/gnome/desktop/notifications/application/${name}" {
            application-id = appId;
          })
        session.notifications.applications;
    };
  };
}
