{
  ezModules,
  config,
  lib,
  osConfig,
  ...
}: {
  imports = with ezModules; [
    shellenv
  ];

  home = {
    username = osConfig.users.users.krad246.name;
    stateVersion = lib.trivial.release;
    homeDirectory =
      osConfig.users.users.krad246.home;

    sessionVariables = {
      HOME = "${config.home.homeDirectory}";
    };
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
