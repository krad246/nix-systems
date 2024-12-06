{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.masterUser;
in {
  options = {
    krad246.darwin = {
      masterUser = {
        enable = lib.options.mkEnableOption "masterUser";
        username = lib.mkOption {
          description = lib.mdDoc ''
            The name of the master user owning the Homebrew directories.
          '';
          type = lib.types.str;
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
    };

    nix-homebrew.user = cfg.username;
    users = {
      knownUsers = [cfg.username];

      users = {
        ${cfg.username} = {
          createHome = true;
          home = "/Users" + "/" + cfg.username;
          shell = "${config.homebrew.brewPrefix}/bash";
        };
      };
    };
  };
}
