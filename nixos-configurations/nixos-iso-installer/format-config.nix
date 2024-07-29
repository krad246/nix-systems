{lib, ...}: let
  folder = ./formats;
  filterSrc = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  impls = lib.filterAttrs filterSrc (builtins.readDir folder);
in
  builtins.trace impls {
    formatConfigs = {
      docker = _: {
      };

      hyperv = _: {
      };

      install-iso-hyperv = _: {
      };

      install-iso = _: {
      };

      iso = _: {
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
      };

      vm-bootloader = _: {
      };

      vm-nogui = _: {
      };

      vm = _: {
      };

      vmware = _: {
      };
    };
  }
