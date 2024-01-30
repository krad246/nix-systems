{
  config,
  pkgs,
  stdenv,
  lib,
  ezModules,
  osConfig,
  ...
}: {
  imports = with ezModules; [
    colima
    shellenv
  ];

  home = {
    username = osConfig.users.users.krad246.name or "krad246";
    stateVersion = lib.trivial.release;
    homeDirectory =
      osConfig.users.users.krad246.home
      or (
        if pkgs.stdenv.isDarwin
        then "/Users/krad246"
        else "/home/krad246"
      );

    sessionVariables = {
      HOME = "${config.home.homeDirectory}";
    };
  };
}
