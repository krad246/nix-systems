{
  pkgs,
  lib,
  ezModules,
  config,
  osConfig,
  ...
}: {
  imports = with ezModules;
    [
      shellenv
    ]
    ++ (lib.optionals (lib.attrsets.attrByPath ["wsl" "enable"] false osConfig) [vscode-server]);

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
    packages = with pkgs; [nodejs jq];
  };

  nix.settings = {
    trusted-users = ["${config.home.username}"];
  };
}
