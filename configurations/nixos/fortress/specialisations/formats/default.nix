{
  config,
  lib,
  ...
}: let
  mkConfig = extraConfig: _: {
    imports = [extraConfig];
    disko.enableConfig = false;

    # provide the builder VM that generates these images some beefier specs...
    virtualisation =
      {
        diskSize = 32 * 1024;
      }
      // lib.attrsets.optionalAttrs (lib.attrsets.hasAttrByPath ["virtualisation" "cores"] config) {
        cores = 6;
      }
      // lib.attrsets.optionalAttrs (lib.attrsets.hasAttrByPath ["virtualisation" "memorySize"] config) {
        memorySize = 6 * 1024;
      };
  };
in {
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