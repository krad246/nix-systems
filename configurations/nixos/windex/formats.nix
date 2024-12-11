{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports = [nixos-generators.nixosModules.all-formats];

  formats = lib.modules.mkForce {
    tarball = config.system.build.tarballBuilder;
  };

  formatConfigs = {
    tarball = {
      formatAttr = "tarballBuilder";
    };
  };
}
