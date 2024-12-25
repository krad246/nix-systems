{
  self,
  osConfig,
  config,
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
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
