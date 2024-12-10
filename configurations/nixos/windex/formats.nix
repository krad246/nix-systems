{
  inputs,
  config,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports = [nixos-generators.nixosModules.all-formats];

  formats = {
    tarball = config.system.build.tarballBuilder;
  };

  formatConfigs = {
    tarball = {
      formatAttr = "tarballBuilder";
    };
  };
}
