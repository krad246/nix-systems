{
  inputs,
  withSystem,
  pkgs,
  ...
}: let
  inherit (inputs) vscode-server;
in {
  imports = [vscode-server.homeModules.default];

  services.vscode-server = {
    enable = true;
    extraRuntimeDependencies = (with pkgs; [nodejs jq wget coreutils]) ++ (withSystem pkgs.stdenv.system ({self', ...}: self'.packages.term-fonts.paths));
  };
}
