{
  pkgs,
  lib,
  ezModules,
  config,
  osConfig,
  ...
}: {
  imports = with ezModules; [
    shellenv
    vscode-server
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

    packages = with pkgs; [
      nodejs
    ];
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
