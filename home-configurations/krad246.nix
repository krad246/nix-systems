{
  ezModules,
  config,
  lib,
  pkgs,
  osConfig,
  inputs,
  ...
}: {
  imports = with ezModules; [
    kitty
    shellenv
    spotify
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
    }

    (lib.mkIf pkgs.stdenv.isDarwin (lib.evalModules {
      modules = [
        {
          _module.args.pkgs = pkgs;
          _module.args.inputs = inputs;
        }
        ezModules.darwin
      ];
    }))

    (lib.mkIf pkgs.stdenv.isLinux {
      })
  ];
}
