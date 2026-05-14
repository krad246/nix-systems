{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.input.touchpad = {
      rightClick = lib.options.mkEnableOption "touchpad right click" // {default = true;};
      twoFingerScrolling = lib.options.mkEnableOption "two-finger scrolling" // {default = true;};
    };
  };
}
