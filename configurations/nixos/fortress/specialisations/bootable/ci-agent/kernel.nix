{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.loader.grub.configurationLimit = 6;
}
