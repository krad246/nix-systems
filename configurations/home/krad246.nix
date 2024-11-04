{
  ezModules,
  config,
  osConfig,
  ...
}: {
  imports = with ezModules; [
    shellenv
  ];

  home = {
    username = osConfig.users.users.krad246.name;
    stateVersion = "24.05";
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
