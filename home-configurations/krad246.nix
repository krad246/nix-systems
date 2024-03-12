args @ {
  ezModules,
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  homeModules = ezModules;
in {
  imports = with homeModules;
    [
      agenix
      colima
      discord
      kitty
      nerdfonts
      shellenv
      spotify
      vscode
    ]
    ++ [
      ({
        lib,
        pkgs,
        ...
      }:
        lib.mkIf pkgs.stdenv.isLinux (lib.mkMerge [
          {
            home.packages = with pkgs; [signal-desktop];
          }
          (import chromium)
          (import kdeconnect)
          (import webcord {inherit lib pkgs;})
        ]))
    ]
    ++ [
      ({
        lib,
        pkgs,
        ...
      }:
        lib.mkIf pkgs.stdenv.isDarwin (lib.mkMerge [
          (import darwin {inherit lib pkgs;})
          (import dock (args // {inherit lib pkgs;}))
        ]))
    ];

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
