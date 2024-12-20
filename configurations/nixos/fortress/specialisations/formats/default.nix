_: let
  mkConfig = extraConfig: let
    module = _: rec {
      imports = [extraConfig];

      disko = {
        enableConfig = false;
        memSize = 6 * 1024;
      };

      virtualisation = {
        diskSize = 32 * 1024;
        memorySize = disko.memSize;
      };
    };
  in
    module;

  mkQemuConfig = extraConfig: let
    module = {modulesPath, ...}: {
      imports = [(modulesPath + "/virtualisation/qemu-vm.nix")] ++ [ (mkConfig extraConfig) ];

      virtualisation = {
        cores = 6;
      };
    };
  in
    module;
in {
  disko-vm = mkQemuConfig ./disko-vm.nix;
  disko-vm-darwin = mkQemuConfig ./disko-vm-darwin.nix;
  hyperv = mkConfig ./hyperv.nix;
  install-iso-hyperv = mkConfig ./install-iso-hyperv.nix;
  install-iso = mkConfig ./install-iso.nix;
  iso = mkConfig ./iso.nix;
  qcow-efi = mkQemuConfig ./qcow-efi.nix;
  qcow = mkQemuConfig ./qcow.nix;
  raw-efi = mkQemuConfig ./raw-efi.nix;
  raw = mkQemuConfig ./raw.nix;
  sd-aarch64-installer = mkConfig ./sd-aarch64-installer.nix;
  sd-aarch64 = mkConfig ./sd-aarch64.nix;
  sd-x86_64 = mkConfig ./sd-x86_64.nix;
  vagrant-virtualbox = mkConfig ./vagrant-virtualbox.nix;
  virtualbox = mkConfig ./virtualbox.nix;
  vm = mkQemuConfig ./vm.nix;
  vmware = mkConfig ./vmware.nix;
}
