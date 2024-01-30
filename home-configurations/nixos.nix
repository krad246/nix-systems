{
  lib,
  ezModules,
  osConfig,
  ...
}: {
  imports = with ezModules; [
    shellenv
  ];

  home = {
    username = osConfig.users.users.nixos.name or "nixos";
    stateVersion = lib.trivial.release;
    homeDirectory =
      osConfig.users.users.nixos.home
      or "/home/nixos";

    packages = [];
  };
}
