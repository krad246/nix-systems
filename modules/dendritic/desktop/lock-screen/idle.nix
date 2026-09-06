{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.lockScreen.idle = {
      delay = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 300;
        description = "Desktop idle delay in seconds.";
      };

      lockDelay = lib.options.mkOption {
        type = lib.types.ints.unsigned;
        default = 300;
        description = "Delay in seconds between idle/screensaver and lock.";
      };
    };
  };
}
