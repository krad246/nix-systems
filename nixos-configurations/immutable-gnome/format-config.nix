{
  inputs,
  self,
  ...
}: let
  inherit (inputs) disko;
  diskoLib = disko.lib;
in {
  formatConfigs = {
    hyperv = _: {
    };

    raw-efi = _: {
      system.build.raw = diskoLib.makeDiskImages {
        nixosConfig = self.nixosConfigurations.immutable-gnome.extendModules {modules = [./fs-config/simple.nix];};
        inherit diskoLib;
      };
    };
  };
}
