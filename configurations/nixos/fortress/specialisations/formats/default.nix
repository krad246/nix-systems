let
  mkConfig = module: {config, ...}: {
    imports = [module];

    disko = {
      memSize = 6 * 1024;
    };

    virtualisation = let
      toMB = size: let
        m = builtins.match "^([0-9]+)([MG])$" size;
      in
        if m == null
        then throw "Invalid size string (expected <int>M or <int>G): ${size}"
        else let
          value = builtins.fromJSON (builtins.elemAt m 0);
          unit = builtins.elemAt m 1;
        in
          if unit == "M"
          then value
          else value * 1024;
    in {
      diskSize = toMB config.disko.devices.disk.main.imageSize;
    };
  };
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
