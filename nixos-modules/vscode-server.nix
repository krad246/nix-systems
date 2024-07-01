{inputs, ...}: let
  inherit (inputs) vscode-server;
in {
  imports = [vscode-server.nixosModules.default];
}
