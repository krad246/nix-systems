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
    username = osConfig.users.users.keerad.name or "keerad";
    homeDirectory =
      osConfig.users.users.keerad.home
      or (
        if pkgs.stdenv.isDarwin
        then "/Users/keerad"
        else "/home/keerad"
      );

    stateVersion = lib.trivial.release;
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
