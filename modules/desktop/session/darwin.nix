{lib, ...}: {
  flake.modules.homeManager.desktop = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.desktop;
    session = cfg.session.darwin;

    toDockAppTile = app: {
      tile-data.file-data = {
        _CFURLString = app;
        _CFURLStringType = 0;
      };
    };

    pinnedApps =
      lib.lists.filter (app: app != null)
      (map (id: session.dock.applications.${id} or null) cfg.dock.apps.pinned);
  in {
    options.desktop.session.darwin = {
      enable =
        lib.options.mkEnableOption "Darwin desktop settings dispatcher"
        // {
          default = pkgs.stdenv.hostPlatform.isDarwin;
        };

      dock = {
        applications = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {
            phone-mirroring = "/System/Applications/iPhone Mirroring.app";
            launchpad = "/System/Applications/Launchpad.app";
            browser = "/Applications/Zen.app";
          };
          description = "Mapping from logical pinned app IDs to macOS application paths.";
        };

        settings = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {
            enable-spring-load-actions-on-all-items = null;
            appswitcher-all-displays = true;
            autohide = true;
            autohide-delay = 0.15;
            autohide-time-modifier = 0.25;
            dashboard-in-overlay = null;
            expose-animation-duration = null;
            expose-group-apps = true;
            largesize = 128;
            launchanim = true;
            magnification = true;
            mineffect = "genie";
            minimize-to-application = true;
            mouse-over-hilite-stack = true;
            persistent-others = [];
            scroll-to-open = true;
            show-process-indicators = true;
            show-recents = false;
            showhidden = true;
            slow-motion-allowed = false;
            static-only = false;
            tilesize = 64;
            wvous-bl-corner = 11;
            wvous-br-corner = 11;
            wvous-tl-corner = 2;
            wvous-tr-corner = 2;
          };
          description = "macOS Dock defaults managed by the Darwin desktop dispatcher.";
        };
      };

      finder.settings = lib.options.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv";
          NewWindowTarget = null;
          NewWindowTargetPath = null;
          QuitMenuItem = true;
          _FXShowPosixPathInTitle = true;
        };
        description = "Finder defaults managed by the Darwin desktop dispatcher.";
      };

      keyboard = {
        fnKeyMode = lib.options.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = "Do Nothing";
          description = "macOS fn-key behavior as accepted by com.apple.HIToolbox.";
        };

        symbolicHotKeys = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
          description = "Raw com.apple.symbolichotkeys AppleSymbolicHotKeys overrides.";
        };
      };

      preferences.documentSaveToCloud =
        lib.options.mkEnableOption "saving new documents to iCloud by default"
        // {
          default = true;
        };

      search.spotlightItems = lib.options.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
        default = [
          {
            enabled = 1;
            name = "APPLICATIONS";
          }
          {
            enabled = 1;
            name = "MENU_EXPRESSION";
          }
          {
            enabled = 0;
            name = "CONTACT";
          }
          {
            enabled = 1;
            name = "MENU_CONVERSION";
          }
          {
            enabled = 0;
            name = "MENU_DEFINITION";
          }
          {
            enabled = 0;
            name = "DOCUMENTS";
          }
          {
            enabled = 1;
            name = "EVENT_TODO";
          }
          {
            enabled = 1;
            name = "DIRECTORIES";
          }
          {
            enabled = 0;
            name = "FONTS";
          }
          {
            enabled = 1;
            name = "IMAGES";
          }
          {
            enabled = 0;
            name = "MESSAGES";
          }
          {
            enabled = 0;
            name = "MOVIES";
          }
          {
            enabled = 0;
            name = "MUSIC";
          }
          {
            enabled = 1;
            name = "MENU_OTHER";
          }
          {
            enabled = 1;
            name = "PDF";
          }
          {
            enabled = 0;
            name = "PRESENTATIONS";
          }
          {
            enabled = 1;
            name = "MENU_SPOTLIGHT_SUGGESTIONS";
          }
          {
            enabled = 0;
            name = "SPREADSHEETS";
          }
          {
            enabled = 1;
            name = "SYSTEM_PREFS";
          }
          {
            enabled = 0;
            name = "TIPS";
          }
          {
            enabled = 0;
            name = "BOOKMARKS";
          }
        ];
        description = "Spotlight result ordering and enablement.";
      };

      touchpad = {
        cornerClickBehavior = lib.options.mkOption {
          type = lib.types.ints.unsigned;
          default = 1;
          description = "macOS trackpad corner click behavior.";
        };

        scaling = lib.options.mkOption {
          type = lib.types.float;
          default = 0.5;
          description = "macOS trackpad scaling.";
        };
      };

      window = {
        globalSettings = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {
            AppleShowScrollBars = "Automatic";
            AppleScrollerPagingBehavior = true;
            AppleWindowTabbingMode = "manual";
            NSAutomaticWindowAnimationsEnabled = true;
            NSWindowShouldDragOnGesture = true;
            NSTableViewDefaultSizeMode = 2;
          };
          description = "NSGlobalDomain window behavior defaults.";
        };

        managerSettings = lib.options.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {
            AppWindowGroupingBehavior = true;
            AutoHide = true;
            EnableStandardClickToShowDesktop = false;
            EnableTiledWindowMargins = true;
            GloballyEnabled = null;
            HideDesktop = true;
            StageManagerHideWidgets = false;
            StandardHideDesktopIcons = false;
            StandardHideWidgets = false;
          };
          description = "com.apple.WindowManager defaults.";
        };
      };
    };

    config = lib.modules.mkIf session.enable {
      assertions = [
        (lib.hm.assertions.assertPlatform "desktop.session.darwin" pkgs lib.platforms.darwin)
      ];

      targets.darwin = {
        search = cfg.search.webEngine;

        defaults =
          {
            ".GlobalPreferences"."com.apple.mouse.scaling" =
              {
                default = null;
                adaptive = null;
                flat = -1.0;
              }
              .${
                cfg.input.pointer.accelerationProfile
              };

            NSGlobalDomain =
              session.window.globalSettings
              // {
                AppleInterfaceStyle =
                  if cfg.theme.darkMode.enable
                  then "Dark"
                  else null;
                AppleInterfaceStyleSwitchesAutomatically = cfg.theme.darkMode.automatic;

                AppleKeyboardUIMode =
                  if cfg.input.keyboard.fullKeyboardAccess
                  then 3
                  else null;
                InitialKeyRepeat = cfg.input.keyboard.initialRepeat;
                KeyRepeat = cfg.input.keyboard.repeat;
                "com.apple.keyboard.fnState" = cfg.input.keyboard.functionKeysAsStandard;

                NSAutomaticCapitalizationEnabled = cfg.input.keyboard.textSubstitutions.capitalization;
                NSAutomaticDashSubstitutionEnabled = cfg.input.keyboard.textSubstitutions.dash;
                NSAutomaticPeriodSubstitutionEnabled = cfg.input.keyboard.textSubstitutions.period;
                NSAutomaticQuoteSubstitutionEnabled = cfg.input.keyboard.textSubstitutions.quote;
                NSAutomaticSpellingCorrectionEnabled = cfg.input.keyboard.textSubstitutions.spelling;

                NSNavPanelExpandedStateForSaveMode = cfg.dialogs.expandSavePanel;
                NSNavPanelExpandedStateForSaveMode2 = cfg.dialogs.expandSavePanel;
                PMPrintingExpandedStateForPrint = cfg.dialogs.expandPrintPanel;
                PMPrintingExpandedStateForPrint2 = cfg.dialogs.expandPrintPanel;

                "com.apple.swipescrolldirection" = cfg.input.pointer.naturalScrolling;
                "com.apple.trackpad.enableSecondaryClick" = cfg.input.touchpad.rightClick;
                "com.apple.trackpad.trackpadCornerClickBehavior" = session.touchpad.cornerClickBehavior;
                "com.apple.trackpad.scaling" = session.touchpad.scaling;

                AppleShowAllFiles = cfg.files.manager.showHidden;
                AppleShowAllExtensions = cfg.files.manager.showExtensions;
                AppleSpacesSwitchOnActivate = cfg.workspaces.switchToAppSpace;

                _HIHideMenuBar = cfg.menuBar.autohide;

                NSDisableAutomaticTermination = !cfg.preferences.automaticTermination;
                NSDocumentSaveNewDocumentsToCloud = session.preferences.documentSaveToCloud;
                "com.apple.sound.beep.volume" = cfg.preferences.alertVolume;
                "com.apple.springing.enabled" = cfg.preferences.springLoading;
              };

            "com.apple.HIToolbox".AppleFnUsageType = session.keyboard.fnKeyMode;

            "com.apple.AppleMultitouchTrackpad".TrackpadRightClick = cfg.input.touchpad.rightClick;

            "com.apple.dock" =
              session.dock.settings
              // {
                persistent-apps = map toDockAppTile pinnedApps;
                mru-spaces = cfg.workspaces.mostRecentFirst;
              };

            "com.apple.finder" =
              session.finder.settings
              // {
                AppleShowAllFiles = cfg.files.manager.showHidden;
                AppleShowAllExtensions = cfg.files.manager.showExtensions;
                CreateDesktop = cfg.files.manager.createDesktop;
                FXRemoveOldTrashItems = cfg.files.manager.removeOldTrashItems;
                ShowPathbar = cfg.files.manager.showPathBar;
                ShowStatusBar = cfg.files.manager.showStatusBar;
                _FXSortFoldersFirst = cfg.files.manager.sortFoldersFirst;
              };

            "com.apple.Spotlight".orderedItems = session.search.spotlightItems;
            "com.apple.WindowManager" = session.window.managerSettings;
            "com.apple.spaces".spans-displays = cfg.workspaces.spanDisplays;
          }
          // lib.attrsets.optionalAttrs (session.keyboard.symbolicHotKeys != {}) {
            "com.apple.symbolichotkeys".AppleSymbolicHotKeys = session.keyboard.symbolicHotKeys;
          };
      };
    };
  };
}
