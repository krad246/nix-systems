{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./disko-vm.nix
  ];

  formatAttr = "vmWithDisko";

  virtualisation.vmVariantWithDisko = let
    parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
    arch = parse.cpu.name;
  in {
    virtualisation.host.pkgs = inputs.nixpkgs.legacyPackages."${arch}-darwin";
  };
}
