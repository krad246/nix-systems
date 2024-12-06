{
  withSystem,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) agenix;
in {
  imports = [agenix.darwinModules.age];

  environment.systemPackages = [
    (withSystem pkgs.stdenv.system ({inputs', ...}:
        inputs'.agenix.packages.default))
  ];
}
