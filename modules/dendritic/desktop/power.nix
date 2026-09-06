{lib, ...}: {
  flake.modules.homeManager.desktop = {
    options.desktop.power = {
      sleepInactiveAcTimeout = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 3600;
        description = "Inactive AC sleep timeout in seconds.";
      };

      sleepInactiveAcType = lib.options.mkOption {
        type = lib.types.str;
        default = "suspend";
        description = "Inactive AC sleep action requested from desktop backends.";
      };
    };
  };
}
