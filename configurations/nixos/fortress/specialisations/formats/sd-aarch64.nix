{lib, ...}: let
  inherit (lib) modules;
in {
  boot.binfmt.emulatedSystems = modules.mkForce [];
  disko.enableConfig = false;
}
