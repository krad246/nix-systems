{
  self,
  osConfig,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) modules;
in {
  imports = [
    self.homeModules.shellenv
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

    stateVersion = lib.trivial.release;
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };

  specialisation = rec {
    default = modules.mkForce fortress;
    fortress = modules.mkIf pkgs.stdenv.isLinux {
      configuration = _: {
        imports = with self.homeModules; [
          dconf
          discord
          kdeconnect
          vscode
          vscode-server
        ];

        services = {
          flatpak = {
            packages = [
              "us.zoom.Zoom"
              "org.signal.Signal"
              "com.spotify.Client"
              "com.valvesoftware.Steam"
            ];
          };
        };
      };
    };
  };
}
