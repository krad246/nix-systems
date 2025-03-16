{
  inputs,
  lib,
  pkgs,
  ...
}: let
  parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
  arch = parse.cpu.name;
in {
  formatAttr = "vmWithDisko";
  virtualisation.vmVariantWithDisko = {
    virtualisation.host.pkgs = inputs.nixpkgs.legacyPackages."${arch}-darwin";
  };
}
