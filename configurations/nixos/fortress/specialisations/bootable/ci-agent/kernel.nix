{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_6_6;
    loader.grub.configurationLimit = 6;
    binfmt.emulatedSystems = [];
  };
}
