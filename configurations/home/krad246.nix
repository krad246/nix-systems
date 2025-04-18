{
  self,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    self.homeModules.base-home
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
  };
}
