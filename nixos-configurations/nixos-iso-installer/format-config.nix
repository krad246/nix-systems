{
  lib,
  modulesPath,
  ...
}: let
  folder = ./formats;
  filterSrc = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  impls = lib.filterAttrs filterSrc (builtins.readDir folder);
in
  builtins.trace impls {
    formatConfigs = let
      commonImports =
        [../../nixos-modules/efiboot.nix]
        ++ [
          "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
        ];
      isoImports = [
        "${modulesPath}/installer/cd-dvd/iso-image.nix"
      ];
    in {
      docker = _: {
      };

      hyperv = _: {
      };

      install-iso-hyperv = _: {
        imports = commonImports ++ isoImports;
      };

      install-iso = _: {
        imports = commonImports ++ isoImports;
      };

      iso = _: {
        imports = commonImports ++ isoImports;
      };

      kexec-bundle = _: {
      };

      qcow-efi = _: {
      };

      qcow = _: {
      };

      raw-efi = _: {
      };

      raw = _: {
      };

      sd-aarch64-installer = _: {
      };

      sd-aarch64 = _: {
      };

      vagrant-virtualbox = _: {
      };

      virtualbox = _: {
        # works
        imports = [];
      };

      vm-bootloader = _: {
        virtualisation.diskSize = 16 * 1024;
      };

      vm-nogui = _: {
      };

      vm = _: {
      };

      vmware = _: {
      };
    };
  }
