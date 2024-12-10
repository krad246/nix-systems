args: {
  hyperv = import ./hyperv.nix args;
  install-iso-hyperv = import ./install-iso-hyperv.nix args;
  install-iso = import ./install-iso.nix args;
  iso = import ./iso.nix args;
  qcow-efi = import ./qcow-efi.nix args;
  qcow = import ./qcow.nix args;
  raw-efi = import ./raw-efi.nix args;
  raw = import ./raw.nix args;
  sd-aarch64-installer = import ./sd-aarch64-installer.nix args;
  sd-aarch64 = import ./sd-aarch64.nix args;
  sd-x86_64 = import ./sd-x86_64.nix args;
  vagrant-virtualbox = import ./vagrant-virtualbox.nix args;
  virtualbox = import ./virtualbox.nix args;
  vmware = import ./vmware.nix args;
}
