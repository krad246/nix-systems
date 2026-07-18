{lib, ...}: {
  flake.modules.homeManager.browser = {config, ...}: {
    options.browser = {
      default = {
        command = lib.options.mkOption {
          type = lib.types.str;
          description = "Command used to open the default graphical browser";
        };

        appPath = lib.options.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Platform application path for the default graphical browser.";
        };
      };
    };

    config.home.sessionVariables.BROWSER = lib.modules.mkDefault config.browser.default.command;
  };
}
