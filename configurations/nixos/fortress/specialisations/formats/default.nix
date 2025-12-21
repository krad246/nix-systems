let
  mkConfig = extraConfig: let
    module = {
      imports = [extraConfig];

      disko = {
        enableConfig = false;
        memSize = 6 * 1024;
      };

      virtualisation = {
        diskSize = 20 * 1024;
      };
    };
  in
    module;
  # mkQemuConfig = extraConfig: let
  #   module = {modulesPath, ...}: {
  #     imports =
  #       [
  #         (modulesPath + "/virtualisation/qemu-vm.nix")
  #       ]
  #       ++ [
  #         (mkConfig extraConfig)
  #       ];
  #     virtualisation = {
  #       cores = 6;
  #       memorySize = 8 * 1024;
  #     };
  #   };
  # in
  #   module;
in {
  disko-vm = mkConfig ./disko-vm.nix;
  disko-vm-darwin = mkConfig ./disko-vm-darwin.nix;
  hyperv = mkConfig ./hyperv.nix;
  install-iso-hyperv = mkConfig ./install-iso-hyperv.nix;
  install-iso = mkConfig ./install-iso.nix;
  iso = mkConfig ./iso.nix;
  qcow-efi = mkConfig ./qcow-efi.nix;
  qcow = mkConfig ./qcow.nix;
  raw-efi = mkConfig ./raw-efi.nix;
  raw = mkConfig ./raw.nix;
  sd-aarch64-installer = mkConfig ./sd-aarch64-installer.nix;
  sd-aarch64 = mkConfig ./sd-aarch64.nix;
  sd-x86_64 = mkConfig ./sd-x86_64.nix;
  vagrant-virtualbox = mkConfig ./vagrant-virtualbox.nix;
  virtualbox = mkConfig ./virtualbox.nix;
  vm = mkConfig ./vm.nix;
  vmware = mkConfig ./vmware.nix;
}
