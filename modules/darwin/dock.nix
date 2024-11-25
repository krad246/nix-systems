{
  system.defaults = {
    dock = {
      appswitcher-all-displays = true;
      autohide = false;
      dashboard-in-overlay = true;

      minimize-to-application = true;

      mouse-over-hilite-stack = true;

      persistent-apps = [
        /Applications/Arc.app
        /System/Applications/Utilities/Terminal.app
        "/System/Applications/iPhone Mirroring.app"
      ];

      persistent-others = [];

      scroll-to-open = true;
      show-process-indicators = true;
      show-recents = true;
      showhidden = false;
      static-only = false;
      tilesize = 64;

      # Disable all hot corners
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
    };
    spaces.spans-displays = true;
  };
}
