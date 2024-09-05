{
  lib,
  pkgs,
  ...
}: {
  boot.binfmt.emulatedSystems =
    lib.lists.remove pkgs.stdenv.system
    ["aarch64-linux" "i386-linux" "i686-linux"];
}
