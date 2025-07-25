{
  config,
  lib,
  modulesPath,
  ...
}: let
  cfg = config.krad246.darwin.masterUser;
in {
  options = {
    krad246.darwin = {
      masterUser = {
        enable = lib.options.mkEnableOption "masterUser";
        owner = lib.options.mkOption {
          description = "Configuration for master user.";
          type = lib.types.submodule (import "${modulesPath}/users/user.nix");
        };
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

    nix-homebrew.user = cfg.owner.name;
    users = {
      # knownUsers = [cfg.owner.name];

      users = {
        ${cfg.owner.name} = cfg.owner;
      };
    };

    nix.settings.trusted-users = [cfg.owner.name];

    system.primaryUser = cfg.owner.name;
  };
}
