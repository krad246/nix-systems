{
  config,
  lib,
  ...
}: {
  system.defaults = {
    dock = {
      appswitcher-all-displays = true;
      autohide = false;
      dashboard-in-overlay = true;

      minimize-to-application = true;

      mouse-over-hilite-stack = true;

      persistent-apps = let
        inherit (config.krad246.darwin) apps;
      in
        (lib.lists.optionals apps.arc [/Applications/Arc.app])
        ++ (lib.lists.optionals apps.kitty [/Applications/kitty.app])
        ++ (lib.lists.optionals apps.vscode ["/Applications/Visual Studio Code.app"])
        ++ [
          "/System/Applications/iPhone Mirroring.app"
          /System/Applications/Launchpad.app
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
