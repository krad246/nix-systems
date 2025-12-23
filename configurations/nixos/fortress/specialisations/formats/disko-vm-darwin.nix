{
  self,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./disko-vm.nix
  ];

  virtualisation.vmVariantWithDisko = let
    parse = lib.systems.parse.mkSystemFromString pkgs.stdenv.system;
    arch = parse.cpu.name;
  in {
    virtualisation.host.pkgs = self.legacyPackages."${arch}-darwin";
  };
}
