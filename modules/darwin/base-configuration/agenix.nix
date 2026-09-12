{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) agenix;
in {
  imports = [agenix.darwinModules.age];

  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
