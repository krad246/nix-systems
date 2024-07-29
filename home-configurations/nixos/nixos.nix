{
  ezModules,
  lib,
  pkgs,
  osConfig,
  ...
}: {
  imports = with ezModules; [colima kitty nvim shellenv vscode];
  home = {
    username = osConfig.users.users.nixos.name or "nixos";
    stateVersion = lib.trivial.release;
    homeDirectory =
      osConfig.users.users.nixos.home
      or "/home/nixos";

    packages = with pkgs; [];
  };
}
