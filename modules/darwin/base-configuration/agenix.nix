{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) agenix;
in {
  imports = [agenix.darwinModules.age];

  environment.systemPackages = [
    pkgs.krad246.agenix
  ];
}
