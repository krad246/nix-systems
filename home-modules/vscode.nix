{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) vscode-server;
in {
  imports = [vscode-server.homeModules.default];

  nixpkgs.config.allowUnfree = true;
  services.vscode-server = {
    enable = true;
    enableFHS = true;
  };
  programs.vscode = {
    enable = true;
    package =
      if pkgs.stdenv.isLinux
      then pkgs.vscode.fhsWithPackages (ps: with ps; [nodejs])
      else pkgs.vscode;
  };
}
