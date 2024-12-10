{
  inputs,
  self,
  ...
}: let
  inherit (inputs) nixos-generators;
  desktop = import ./desktop;
in {
  imports =
    [nixos-generators.nixosModules.all-formats]
    ++ [desktop];

  config = {
    formatConfigs = {
      hyperv = import ./formats/hyperv.nix;
      install-iso-hyperv = import ./formats/install-iso-hyperv.nix;
      install-iso = import ./formats/install-iso.nix;
      iso = import ./formats/iso.nix;
      qcow-efi = import ./formats/qcow-efi.nix;
      qcow = import ./formats/qcow.nix;
      raw-efi = import ./formats/raw-efi.nix;
      raw = import ./formats/raw.nix;
      sd-aarch64-installer = import ./formats/sd-aarch64-installer.nix;
      sd-aarch64 = import ./formats/sd-aarch64.nix;
      sd-x86_64 = import ./formats/sd-x86_64.nix;
      vagrant-virtualbox = import ./formats/vagrant-virtualbox.nix;
      virtualbox = import ./formats/virtualbox.nix;
      vmware = import ./formats/vmware.nix;
    };

    specialisation = rec {
      default = fortress;
      fortress.configuration = _: {
        imports = [desktop] ++ [self.diskoConfigurations.fortress-desktop];
      };
    };
  };
}
