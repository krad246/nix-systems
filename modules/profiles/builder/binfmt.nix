{
  config,
  lib,
  ...
}: {
  flake.modules.nixos.binfmt = {pkgs, ...}: {
    boot.binfmt.emulatedSystems = lib.trivial.pipe config.systems [
      (lib.trivial.flip lib.lists.forEach lib.systems.parse.mkSystemFromString)
      (lib.lists.filter lib.systems.inspect.predicates.isLinux)
      (lib.trivial.flip lib.lists.forEach lib.systems.parse.doubleFromSystem)
      (lib.lists.remove pkgs.stdenv.hostPlatform.system)
    ];
  };
}
