args @ {
  ezModules,
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  imports = with ezModules; [
    kitty
    nerdfonts
    shellenv
    spotify
    vscode
  ];

  config = lib.mkMerge [
    {
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

      nix.settings = {
        trusted-users = ["${config.home.username}"];
      };
    }

    (lib.mkIf pkgs.stdenv.isDarwin (import ezModules.darwin args))
    (lib.mkIf pkgs.stdenv.isLinux (import ezModules.linux args))
  ];
}
