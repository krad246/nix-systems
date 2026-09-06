{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.notifications = {
      showBanners = lib.options.mkEnableOption "notification banners" // {default = true;};
      showOnLockScreen = lib.options.mkEnableOption "notifications on the lock screen";
    };
  };
}
