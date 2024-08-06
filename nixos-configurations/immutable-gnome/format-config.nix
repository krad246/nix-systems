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
      boot.kernelParams = ["nomodeset"];
    };

    install-iso-hyperv = _: {
      boot.kernelParams = ["nomodeset"];
    };

    raw-efi = _: {
      system.build.raw = diskoLib.makeDiskImages {
        nixosConfig = self.nixosConfigurations.immutable-gnome.extendModules {modules = [./fs-config/simple.nix];};
        inherit diskoLib;
      };
    };
  };
}
