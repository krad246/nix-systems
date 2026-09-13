{
  inputs,
  lib,
  types,
  ...
}: let
  inherit (types) virtualisationPresetType;
in {
  options.dendritic.virtualisation = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable virtualization capabilities and their artifact projections.";
    };
    presets = lib.mkOption {
      type = lib.types.attrsOf virtualisationPresetType;
      default = {
        vm.modules = [
          ({modulesPath, ...}: {
            imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];
          })
        ];
        vm-with-bootloader.modules = [
          ({modulesPath, ...}: {
            imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];
            virtualisation.useBootLoader = true;
          })
        ];
        vm-nogui.modules = [inputs.nixos-generators.nixosModules.vm-nogui];
        disko-vm.modules = [
          ({modulesPath, ...}: {
            imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];
          })
        ];
      };
      description = "Named virtualization presets; consumer modules merge after the selected preset.";
    };
  };
}
