_: {
  boot.kernelModules = ["kvm-amd" "kvm-intel"];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
        ];
      };
    };
  };

  programs.virt-manager.enable = true;
}
