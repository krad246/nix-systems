{
  formatConfigs = {
    docker = _: {
    };

    hyperv = _: {
    };

    install-iso-hyperv = _: {
      imports = [];
    };

    install-iso = _: {
      imports = [];
    };

    iso = _: {
      imports = [];
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
