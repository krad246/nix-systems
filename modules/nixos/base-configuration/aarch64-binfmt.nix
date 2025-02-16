{
  lib,
  pkgs,
  ...
}: {
  boot.binfmt.emulatedSystems = lib.modules.mkDefault (lib.lists.remove pkgs.stdenv.system ["aarch64-linux"]);
}
