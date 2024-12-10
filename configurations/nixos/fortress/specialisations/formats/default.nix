{
  hyperv = import ./hyperv.nix;
  install-iso-hyperv = import ./install-iso-hyperv.nix;
  install-iso = import ./install-iso.nix;
  iso = import ./iso.nix;
  qcow-efi = import ./qcow-efi.nix;
  qcow = import ./qcow.nix;
  raw-efi = import ./raw-efi.nix;
  raw = import ./raw.nix;
  sd-aarch64-installer = import ./sd-aarch64-installer.nix;
  sd-aarch64 = import ./sd-aarch64.nix;
  sd-x86_64 = import ./sd-x86_64.nix;
  vagrant-virtualbox = import ./vagrant-virtualbox.nix;
  virtualbox = import ./virtualbox.nix;
  vmware = import ./vmware.nix;
}
