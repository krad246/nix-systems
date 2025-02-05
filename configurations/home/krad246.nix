{
  osConfig,
  config,
  pkgs,
  ...
}: {
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

  nix.settings = {
    trusted-users = [config.home.username];
  };
}
