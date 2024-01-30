args @ {
  ezModules,
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  homeModules = ezModules;
  unstable = pkgs.callPackage args.inputs.nixpkgs-unstable {};
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
            home.packages = [pkgs.pavucontrol unstable.signal-desktop unstable.zoom-us];
          }
          (import chromium)
          (import kdeconnect)
          (import webcord {inherit lib pkgs;})
          (import obs)
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

  xdg.desktopEntries = let
    mkHidden = name: {
      "${name}" = {
        inherit name;
        noDisplay = true;
      };
    };
  in
    lib.mkMerge [(mkHidden "Proton 8.0") (mkHidden "Zoom")];
}
