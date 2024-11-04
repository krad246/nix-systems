{
  config,
  lib,
  pkgs,
  ...
}: {
  specialisation = {
    ${config.networking.hostName} = {
      configuration = {
        boot.binfmt.emulatedSystems = lib.lists.remove pkgs.stdenv.system ["aarch64-linux"];
      };
    };
  };
}
