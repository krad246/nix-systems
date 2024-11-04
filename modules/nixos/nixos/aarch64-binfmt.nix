{
  lib,
  pkgs,
  ...
}: {
  boot.binfmt.emulatedSystems = lib.lists.remove pkgs.stdenv.system ["aarch64-linux"];
}
