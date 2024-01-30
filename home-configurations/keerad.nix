{
  pkgs,
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
    username = osConfig.users.users.keerad.name or "keerad";
    stateVersion = lib.trivial.release;
    homeDirectory =
      osConfig.users.users.keerad.home
      or (
        if pkgs.stdenv.isDarwin
        then "/Users/keerad"
        else "/home/keerad"
      );
  };
}
