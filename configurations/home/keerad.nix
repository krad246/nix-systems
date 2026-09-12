{
  self,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    self.modules.homeManager.base
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
}
