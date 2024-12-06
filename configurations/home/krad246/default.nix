{
  self,
  osConfig,
  config,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      self.homeModules.shellenv
    ]
    ++ [
      ./specialisations
    ];

  home = {
    username = osConfig.users.users.krad246.name or "krad246";
    homeDirectory =
      osConfig.users.users.krad246.home
      or (
        if pkgs.stdenv.isDarwin
        then "/Users/krad246"
        else "/home/krad246"
      );

    stateVersion = lib.trivial.release;
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
