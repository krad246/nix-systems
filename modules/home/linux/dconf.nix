# Generated via dconf2nix: https://github.com/nix-commmunity/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "apps/psensor" = {
      graph-alpha-channel-enabled = false;
      graph-background-alpha = mkDouble "1.0";
      graph-background-color = "#e8f4e8f4a8f5";
      graph-foreground-color = "#000000000000";
      graph-monitoring-duration = 20;
      graph-update-interval = 2;
      interface-hide-on-startup = false;
      interface-window-divider-pos = 866;
      interface-window-h = 850;
      interface-window-restore-enabled = true;
      interface-window-w = 1666;
      interface-window-x = 45;
      interface-window-y = 29;
      sensor-update-interval = 2;
      slog-enabled = false;
      slog-interval = 300;
    };

    "apps/seahorse/listing" = {
      keyrings-selected = ["gnupg://"];
    };

    "apps/seahorse/windows/key-manager" = {
      height = 476;
      width = 600;
    };

    "io/missioncenter/MissionCenter" = {
      performance-selected-page = "gpu-0000:03:00.0";
      window-height = 400;
      window-width = 600;
    };

    "org/freedesktop/folks" = {
      primary-store = "eds:a3117721c18ca91f93da7d2bcbd4d4edf633e818";
    };

    "org/gnome/Connections" = {
      first-run = false;
    };

    "org/gnome/Console" = {
      last-window-maximised = true;
      last-window-size = mkTuple [1008 595];
    };

    "org/gnome/Contacts" = {
      did-initial-setup = true;
    };

    "org/gnome/Geary" = {
      migrated-config = true;
    };

    "org/gnome/baobab/ui" = {
      is-maximized = false;
      window-size = mkTuple [960 600];
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = true;
      window-size = mkTuple [768 600];
    };

    "org/gnome/clocks/state/window" = {
      maximized = false;
      panel-id = "world";
    };

    "org/gnome/control-center" = {
      last-panel = "keyboard";
      window-state = mkTuple [980 595 true];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = ["Utilities" "YaST" "Pardus" "3bebe58e-992c-49db-b6ca-29cd02ba98c7"];
    };

    "org/gnome/desktop/app-folders/folders/3bebe58e-992c-49db-b6ca-29cd02ba98c7" = {
      apps = ["org.kde.kdeconnect.app.desktop" "org.kde.kdeconnect.nonplasma.desktop" "org.kde.kdeconnect-settings.desktop" "org.kde.kdeconnect.sms.desktop"];
      name = "KDE Connect";
      translate = false;
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = ["X-Pardus-Apps"];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = ["gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" "org.gnome.Snapshot.desktop" "org.gnome.Extensions.desktop" "pavucontrol.desktop" "nvim.desktop" "virt-manager.desktop"];
      categories = ["X-GNOME-Utilities"];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = ["X-SuSE-YaST"];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/input-sources" = {
      sources = [(mkTuple ["xkb" "us"])];
      xkb-options = ["terminate:ctrl_alt_bksp"];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "WhiteSur-cursors";
      gtk-theme = "WhiteSur-Dark";
      icon-theme = "WhiteSur-dark";
    };

    "org/gnome/desktop/notifications" = {
      application-children = ["vesktop" "gnome-power-panel" "org-kde-kdeconnect-daemon" "org-gnome-evolution-alarm-notify" "com-valvesoftware-steam" "org-signal-signal" "app-zen-browser-zen"];
      show-banners = true;
      show-in-lock-screen = false;
    };

    "org/gnome/desktop/notifications/application/app-zen-browser-zen" = {
      application-id = "app.zen_browser.zen.desktop";
    };

    "org/gnome/desktop/notifications/application/chromium-browser" = {
      application-id = "chromium-browser.desktop";
    };

    "org/gnome/desktop/notifications/application/com-github-tchx84-flatseal" = {
      application-id = "com.github.tchx84.Flatseal.desktop";
    };

    "org/gnome/desktop/notifications/application/com-spotify-client" = {
      application-id = "com.spotify.Client.desktop";
    };

    "org/gnome/desktop/notifications/application/com-valvesoftware-steam" = {
      application-id = "com.valvesoftware.Steam.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/kitty" = {
      application-id = "kitty.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-baobab" = {
      application-id = "org.gnome.baobab.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-evolution-alarm-notify" = {
      application-id = "org.gnome.Evolution-alarm-notify.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-software" = {
      application-id = "org.gnome.Software.desktop";
    };

    "org/gnome/desktop/notifications/application/org-kde-kdeconnect-daemon" = {
      application-id = "org.kde.kdeconnect.daemon.desktop";
    };

    "org/gnome/desktop/notifications/application/org-signal-signal" = {
      application-id = "org.signal.Signal.desktop";
    };

    "org/gnome/desktop/notifications/application/signal-desktop" = {
      application-id = "signal-desktop.desktop";
    };

    "org/gnome/desktop/notifications/application/spotify" = {
      application-id = "spotify.desktop";
    };

    "org/gnome/desktop/notifications/application/steam" = {
      application-id = "steam.desktop";
    };

    "org/gnome/desktop/notifications/application/us-zoom-zoom" = {
      application-id = "us.zoom.Zoom.desktop";
    };

    "org/gnome/desktop/notifications/application/vesktop" = {
      application-id = "vesktop.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
    };

    "org/gnome/desktop/remote-desktop/rdp" = {
      enable = true;
      tls-cert = "/home/krad246/.local/share/gnome-remote-desktop/certificates/rdp-tls.crt";
      tls-key = "/home/krad246/.local/share/gnome-remote-desktop/certificates/rdp-tls.key";
      view-only = false;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      lock-delay = mkUint32 300;
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = ["org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop"];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 300;
    };

    "org/gnome/desktop/wm/keybindings" = {
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

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/evolution-data-server/calendar" = {
      reminders-past = [];
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
    };

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [];
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [890 550];
      initial-size-file-chooser = mkTuple [890 550];
    };

    "org/gnome/nm-applet/eap/067a9569-d9b0-3c92-949d-a8d1c4ce3e76" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/portal/filechooser/steam" = {
      last-folder-path = "/home/krad246/.var/app/com.valvesoftware.Steam/.local/share/Steam";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
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

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-timeout = 3600;
      sleep-inactive-ac-type = "suspend";
    };

    "org/gnome/settings-daemon/plugins/sharing/gnome-user-share-webdav" = {
      enabled-connections = ["1676a610-974d-4a3e-864e-76de0696d17f"];
    };

    "org/gnome/settings-daemon/plugins/sharing/rygel" = {
      enabled-connections = ["1676a610-974d-4a3e-864e-76de0696d17f"];
    };

    "org/gnome/shell" = {
      app-picker-layout = [
        [
          (mkDictionaryEntry [
            "nixos-manual.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 0)])
            ])
          ])
          (mkDictionaryEntry [
            "3bebe58e-992c-49db-b6ca-29cd02ba98c7"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 1)])
            ])
          ])
          (mkDictionaryEntry [
            "com.github.tchx84.Flatseal.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 2)])
            ])
          ])
          (mkDictionaryEntry [
            "us.zoom.Zoom.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 3)])
            ])
          ])
          (mkDictionaryEntry [
            "org.signal.Signal.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 4)])
            ])
          ])
          (mkDictionaryEntry [
            "com.spotify.Client.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 5)])
            ])
          ])
          (mkDictionaryEntry [
            "com.valvesoftware.Steam.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 6)])
            ])
          ])
          (mkDictionaryEntry [
            "Utilities"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 7)])
            ])
          ])
          (mkDictionaryEntry [
            "org.pulseaudio.pavucontrol.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 8)])
            ])
          ])
          (mkDictionaryEntry [
            "vesktop.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 9)])
            ])
          ])
          (mkDictionaryEntry [
            "org.gnome.Settings.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 10)])
            ])
          ])
          (mkDictionaryEntry [
            "Helix.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 11)])
            ])
          ])
          (mkDictionaryEntry [
            "home-manager-manual.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 12)])
            ])
          ])
          (mkDictionaryEntry [
            "org.gnome.Software.desktop"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 13)])
            ])
          ])
        ]
      ];
      command-history = ["sudo journalctl --vacuum-time=1d" "sudo shutdown now" "sudo systemctl hybrid-sleep"];
      disable-user-extensions = true;
      favorite-apps = ["org.gnome.Nautilus.desktop" "app.zen_browser.zen.desktop" "kitty.desktop" "code.desktop"];
      last-selected-power-profile = "power-saver";
      welcome-dialog-last-shown-version = "46.2";
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/shell/keybindings" = {
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

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = [];
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/software" = {
      check-timestamp = mkInt64 1743453362;
      first-run = false;
      flatpak-purge-timestamp = mkInt64 1743467701;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

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

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
