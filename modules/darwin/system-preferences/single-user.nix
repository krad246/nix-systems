{
  config,
  lib,
  modulesPath,
  ...
}: let
  cfg = config.krad246.darwin.system-preferences.masterUser;
in {
  options = {
    krad246.darwin.system-preferences.masterUser = {
      enable = lib.options.mkEnableOption "masterUser";
      owner = lib.options.mkOption {
        description = "Configuration for master user.";
        type = lib.types.submodule (import "${modulesPath}/users/user.nix");
      };
    };
  };

  config = lib.modules.mkIf cfg.enable {
    system.defaults = {
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };

      screensaver.askForPassword = true;

      CustomSystemPreferences = config.system.defaults.CustomUserPreferences;
    };

    users = {
      knownUsers = [cfg.owner.name];

      users = {
        ${cfg.owner.name} = cfg.owner;
      };
    };
  };
}
