{
  config,
  lib,
  ...
}: {
  system.defaults = {
    dock = {
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
      mineffect = "scale";
      minimize-to-application = true;
      mouse-over-hilite-stack = true;
      mru-spaces = true;
      orientation = "bottom";
      persistent-apps = let
        inherit (lib) attrsets lists;
        arc = attrsets.attrByPath ["apps" "arc"] false config.krad246.darwin;
        zen-browser = attrsets.attrByPath ["apps" "zen-browser"] false config.krad246.darwin;
      in
        (lists.optionals arc [/Applications/Arc.app])
        ++ (lists.optionals zen-browser ["/Applications/Zen Browser.app"])
        ++ [
          "/System/Applications/iPhone Mirroring.app"
          /System/Applications/Launchpad.app
        ];
      persistent-others = [];
      scroll-to-open = true;
      show-process-indicators = true;
      show-recents = false;
      showhidden = true;
      slow-motion-allowed = true;
      static-only = false;
      tilesize = 64;

      wvous-bl-corner = 11;
      wvous-br-corner = 11;
      wvous-tl-corner = 2;
      wvous-tr-corner = 2;
    };

    spaces.spans-displays = false;
  };
}
