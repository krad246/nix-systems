{
  system.defaults = {
    ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;

    trackpad = {
      TrackpadRightClick = true;
    };

    NSGlobalDomain = {
      # Disable “natural” (Lion-style) scrolling
      "com.apple.swipescrolldirection" = false;

      "com.apple.trackpad.enableSecondaryClick" = true;
      "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
      "com.apple.trackpad.scaling" = 0.5;
    };
  };
}
